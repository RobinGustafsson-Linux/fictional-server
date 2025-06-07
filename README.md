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
- DNS-servern fungerar även som DHCP- och syslog-server

### Installerade tjänster
- DHCP-server (`isc-dhcp-server`)
- DNS (`bind9`)
- Syslog-server (`rsyslog`)
- Loggrotation (`logrotate`)
- Loggmottagning från Windows via `NXLog`

Miljön används för att simulera ett fiktivt nätverk för ett företag med ~150 anställda.

## Tjänster som implementeras

### 🔧 DHCP (isc-dhcp-server)

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

-**Domain:** "fictive.local"
-**DNS-server:** "ns1.fictive.local" > 192.168.1.1
-**Pointers:**
  -"www.fictive.local" CNAME to web.fictive.local
  -"Web.fictive.local > 192.168.1.1

  #### Reverse DNS

-"**Zone:** 1.168.192.in-addr.arpa
-Points 192.168.1.1 to:
- "ns1.fictive.local"
- "www.fictive.local"


Configfiles are located in:
 
dhcp-dns/
├── dhcpd.conf # DHCP-konfiguration
├── named.conf.local # Zones for DNS
└── zonfiler/
├── db.fictive.local # Forward-zon for fictive.local
└── db.192.168.1 # Reverse-zon for 192.168.1.0/24

BIND9 had issues with permissions since my files are in my git-repo. Outside of /etc/bind, had to configre AppArmor:
- AppArmor-profile for "named" uppdated to allow "/home/robin/Desktop/fictional-server/dhcp-dns/zonfiler/** r;"
- Permissions were set with these commands:
- chmod 644 ~/Desktop
- chmod 644 ~/Desktop/fictional-server/dhcp-dns/zonfiler/*

  
## Syslog & logrotate

To demostrate a syslog-server recieving logs from a windows client via NXLog, example file is included. 

-Loggfiles are originated from /var/log/windows/fictive.log on the server
-The logs generates from NXLog on a windows client with hostname "fictive"
-The example log file is only 50 rows saved in the repo to protect sensitive information and unnecessary traffic

#### Logexample includes:
-Events from "Event Viewer" (systemstart, servicestart)
-Manually generated test logs Via PowerShell or pinging the server from the client

Projektstatus
- [x] Vecka 1 – Projektplan & riskanalys
- [x] Vecka 2 – Installation & härdning
- [x] Vecka 3 – DHCP + DNS (BIND9)
- [x] Vecka 4 – Syslog + Logrotate + backupscript
- [x] Vecka 5 – Zabbix Server + agent
- [x] Vecka 6 – Test, felsökning, rapport

## automatisering
