# Netwerkbeheer 2 - Linux

Naam cursist: NAAM

## Opracht

De bedoeling van dit labo is een klein netwerk op te zetten met een aantal typische services. Het netwerk heeft IP range 192.168.15.0/24 en de domeinnaam is `linuxlab.lan`.

We streven er naar om heel de opstelling zoveel mogelijk te automatiseren én voldoende generisch te maken, zodat deze configuratie met een minimum aan moeite kan toegepast worden in een andere situatie.

De opgave voor de specifieke hosts (zie tabel hieronder) vind je onder [`doc/`](doc/).

- Labo 0: [Opzetten werkomgeving](doc/labo-0-werkomgeving.md)
- Labo 1: [Een webserver met Linux/Apache/MySQL/PHP (LAMP-stack)](doc/labo-1-lamp.md)
- Labo 2: [Een DNS-server met ISC BIND](doc/labo-2-bind.md)
- Labo 3: [Een Samba fileserver](doc/labo-3-samba.md)
- Labo 4: [Een DHCP-server en gateway voor het netwerk](doc/labo-4-dhcp-router.md)

De algemene werkwijze is telkens:

- Lees eerst de opdracht door.
- Ga de opgegeven referenties opzoeken, maak jezelf vertrouwd met de inhoud. Dit wil niet zeggen dat je dat moet instuderen, maar zorg er voor dat je er vlot in kan zoeken naar relevante informatie.
- Zet eerst een VM op voor de opgave en zorg er voor dat je de acceptatietests kan uitvoeren (dit wordt in de eerste opgave uitgelegd).
- Registreer wijzigingen regelmatig in Git. Wacht dus niet tot je een "werkende" oplossing hebt vooraleer je die in Git registreert.
- Wanneer je klaar bent met de opgave, en alle wijzigingen zijn in Git ingevoerd, duid je dit aan met een zgn. "tag": `git tag laboN` (met N het nummer van het labo). In principe moet het nu mogelijk zijn dat de lector met jouw code de VM volledig kan reconstrueren en dat alle acceptatietests slagen.

Samenwerken aan deze labo's is toegelaten!

## Overzicht hosts

| Hostnaam | Alias | IP             | Functie                                               |
| :--      | :---  | :---           | :---                                                  |
| -        |       | 192.168.15.1   | Hostsysteem (= de pc waar je op werkt)                |
| srv001   | ns1   | 192.168.15.2   | DNS server (BIND)                                     |
| srv002   | ns2   | 192.168.15.3   | Secundaire DNS-server                                 |
| srv003   | dhcp  | 192.168.15.4   | DHCP-server                                           |
| srv010   | www   | 192.168.15.10  | Webserver (LAMP-stack met Apache, PHP, Mariadb + CMS) |
| srv011   | file  | 192.168.15.11  | Fileserver (Samba)                                    |
| srv012   | dhcp  | 192.168.15.12  | DHCP-server                                           |
| router   |       | 192.168.15.254 | Gateway voor het netwerk                              |

