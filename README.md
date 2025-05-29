# LIA-projekt - Linuxplattform för centrala nätverkstjänster & övervakning

Detta projekt är en del av min LIA och syftar till att bygga upp en linuxbaserad servermiljö som levererar flera viktiga nätverkstjänster för ett fiktivt företag med ungefär 150 användare.

## Syfte

## Teknik & miljö

## Tjänster som implementeras

## DNS (BIND9)

DNS server is configured with BIND9 and holds a forward and reverse lookup on the network with IP 192.168.1.1/24.

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
- [X] Vecka 4 – Syslog + Logrotate + backupscript
- [ ] Vecka 5 – Zabbix Server + agent
- [ ] Vecka 6 – Test, felsökning, rapport

## automatisering


## Dokumentation

## Test & presentation
