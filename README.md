# LIA-projekt - Linuxplattform för centrala nätverkstjänster & övervakning

Detta projekt är en del av min LIA och syftar till att bygga upp en linuxbaserad servermiljö som levererar flera viktiga nätverkstjänster för ett fiktivt företag med ungefär 150 användare.

## Syfte

Syftet med projektet är att bygga upp en virtualiserad IT-miljö som efterliknar en mindre företagsinfrastruktur. Miljön innehåller centrala tjänster såsom DHCP, DNS, syslog-server med loggrotation samt mottagning av loggar från en Windows-klient via NXLog.

Projektet syftar till att:

- Skapa en förståelse för hur olika infrastrukturtjänster samverkar i ett nätverk
- Fördjupa kunskaper i systemadministration och nätverkskonfiguration i Linux
- Implementera automatiserad IP-hantering (DHCP) och namnuppslag (DNS)
- Centralisera logghantering och säkerställa loggarnas tillgänglighet och struktur
- Identifiera, felsöka och lösa problem relaterade till nätverk, tjänster och säkerhet

Resultatet dokumenteras i en GitHub-repo med fullständig struktur, konfigurationsfiler och teknisk dokumentation.

## Teknik & miljö

Projektet är uppbyggt i en virtualiserad miljö med hjälp av Oracle VirtualBox och består av följande system:

### Operativsystem
- Ubuntu Server 24.04 (används som central server)
- Windows 10 (används som klient)

### Nätverksmiljö
- Nätverksläge: Internal Network ("intnet")
- Statiska IP-adresser används
- Ubuntu-server: 192.168.1.1
- Windows-klient: 192.168.1.100
- DNS-servern fungerar även som DHCP och syslog-server

### Installerade tjänster
- DHCP-server (`isc-dhcp-server`)
- DNS (`bind9`)
- Syslog-server (`rsyslog`)
- Loggrotation (`logrotate`)
- Loggmottagning från Windows via `NXLog`

Miljön används för att simulera ett fiktivt nätverk för ett företag med ~150 anställda.

## Tjänster som implementeras

###  SSH-säkerhet & autentisering

För att säkra inloggning via SSH är följande åtgärder implementerade i servermiljön:

####  Nyckelbaserad inloggning
- Användaren `robin` loggar in via SSH med en RSA-nyckel 
- Servern accepterar endast inloggning med publik nyckel via `~/.ssh/authorized_keys`
- Lösenordsinloggning är inaktiverad i `sshd_config`

####  Fail2ban
- Fail2ban är installerat och skyddar mot brute force attacker på SSH
- Tjänsten övervakar autentiseringsförsök och spärrar IP-adresser vid upprepade misslyckade inloggningar

####  Least Privilege (minsta privilegier)
- Root inloggning via SSH är inaktiverad (`PermitRootLogin no`)
- En icke-root-användare (`robin`) används för administration, med begränsade rättigheter och `sudo` vid behov

#### Filer
- `ssh/sshd_config` – modifierad konfiguration för SSH
- `ssh/fail2ban-jail.local` – eventuell lokal konfiguration för Fail2ban

###  DHCP (isc-dhcp-server)

DHCP-servern är installerad på Ubuntu-servern och tilldelar automatiskt IP-adresser till klienter i nätverket `192.168.1.0/24`.

#### Konfiguration:
- IP-adressintervall: `192.168.1.50` – `192.168.1.200`
- Gateway (router): `192.168.1.1`
- DNS-server: `192.168.1.1`
- Domännamn: `fictive.local`
  
DHCP-tjänsten testades med en Windows 10-klient som korrekt tog emot IP-adress, gateway och DNS-inställningar från servern.


## DNS (BIND9)

DNS server är konfigurerad med BIND9 och har en forward samt en reverse lookup på nätverket med IP 192.168.1.1/24.

#### Configuration

-**Domain:** `fictive.local`
-**DNS-server:** `ns1.fictive.local` > 192.168.1.1
-**Pointers:**
  -`www.fictive.local` CNAME to web.fictive.local
  -`Web.fictive.local` > 192.168.1.1

  #### Reverse DNS

-"**Zone:** 1.168.192.in-addr.arpa
-Points 192.168.1.1 to:
- `ns1.fictive.local`
- `www.fictive.local`


Konfigfiler är sparade i:
 
dhcp-dns/
├── dhcpd.conf # DHCP-konfiguration
├── named.conf.local # Zones for DNS
└── zonfiler/
├── db.fictive.local # Forward-zon for fictive.local
└── db.192.168.1 # Reverse-zon for 192.168.1.0/24

BIND9 hade problem med rättigheter eftersom mina filer är i min git-repo. Utanför /etc/bind, behövde konfa AppArmor:
- AppArmor-profile för "named" uppdaterad att tillåta "/home/robin/Desktop/fictional-server/dhcp-dns/zonfiler/** r;"
- Rättigheter var satta med dessa kommandon:
- chmod 644 ~/Desktop
- chmod 644 ~/Desktop/fictional-server/dhcp-dns/zonfiler/*

  
## Syslog & logrotate

Att demonstrera att syslog-server tar emot logs från en windows klient via NXLog, exempel fil är inkluderad. 

-Loggfiler är från början från /var/log/windows/fictive.log på server
-Loggarna genererar från NXLog på en Windows klient med hostname "fictive"
-Exempel logg filn är bara 50 rader sparad i repon för att skydda information och skräp trafik

#### Loggexempel innehåller:
-Events från "Event Viewer" (systemstart, servicestart)
-Manuellt genererat test logs via PowerShell eller pinga servern från klienten

###  Zabbix Server + Agent

Zabbix 7.0 LTS används för övervakning av systemresurser som CPU, RAM och nätverkstrafik. Servern är installerad på en Ubuntu 24.04 server och övervakar sig själv via en lokal Zabbix-agent.

####  Installation
- Zabbix Server + webbgränssnitt installerades via Zabbix officiella apt-repo
- Databasen är MariaDB och användaren `zabbix` med egna rättigheter
- Zabbix frontend är tillgänglig via webbläsare på `http://192.168.1.1/zabbix`

#### ⚙ Konfigurationsfiler
Följande filer är inkluderade i repot:
- `zabbix/zabbix_server.conf` – konfiguration för Zabbix-servern
- `zabbix/zabbix_agentd.conf` – agent som körs lokalt på samma server
- `zabbix/zabbix.conf.php` – frontendinställningar för PHP
- `zabbix/zabbix_gui_result.png` – skärmbild som visar aktiv övervakning i Zabbix GUI

####  Övervakning
Agenten är konfigurerad mot `127.0.0.1:150` och rapporterar:
- CPU-användning
- Minnesanvändning
- Nätverkstrafik per interface
- Systemtid, uptime, och belastning

All konfiguration och övervakning är dokumenterad och automatiserat via skript i `scripts/`.

Projektstatus
- [x] Vecka 1 – Projektplan & riskanalys
- [x] Vecka 2 – Installation & härdning
- [x] Vecka 3 – DHCP + DNS (BIND9)
- [x] Vecka 4 – Syslog + Logrotate + backupscript
- [x] Vecka 5 – Zabbix Server + agent
- [x] Vecka 6 – Test, felsökning, rapport

## automatisering
