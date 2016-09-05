# Opdracht 2: Domain Name Service met BIND

## Leerdoelen

- Een DNS server met BIND kunnen opzetten en testen
    - De configuratiebestanden van BIND, i.h.b. zonebestanden begrijpen en fouten kunnen opsporen
    - Een DNS-server kunnen ondervragen en testen met `dig`

## Studiemateriaal en referenties

- Aitchison, R. 2015. *DNS for Rocket Scientists.* Zytrax Open. Opgehaald op 2016-03-22 van <http://www.zytrax.com/books/dns/>/
- Mockapetris, P. 1987. RFC 1034: [*"Domain names: Concepts and Facilities"*](https://tools.ietf.org/html/rfc1034). IETF
- Wadeley, S. 2014. [*"Red Hat Enterprise Linux 7 Networking Guide"*](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/)

## Opdrachtomschrijving

DNS is essentieel voor de correcte werking van een domein, en heel wat ([volgens sommigen *alle*](http://www.krisbuytaert.be/blog/)) netwerkproblemen zijn terug te leiden tot fouten in de configuratie van DNS. Er zijn verschillende implementaties van DNS, maar veruit de meest gebruikte (en daarom ook essentieel voor de werking van het Internet als geheel) is [BIND](https://www.isc.org/downloads/bind/).

In dit labo gaan we een "Authoritative-only" DNS-server opzetten voor ons domein, "linuxlab.lan". In de tabel hieronder vind je een overzicht van de hosts, met hun IP adres en eventuele aliassen:

| Hostnaam | Alias | IP            | Functie                                               |
| :--      | :---  | :---          | :---                                                  |
| srv001   | ns1   | 192.168.15.2  | DNS server (BIND)                                     |
| srv002   | ns2   | 192.168.15.3  | Secundaire DNS-server                                 |
| srv003   | mail  | 192.168.15.4  | Mailserver                                            |
| srv010   | www   | 192.168.15.10 | Webserver (LAMP-stack met Apache, PHP, Mariadb + CMS) |
| srv011   | file  | 192.168.15.11 | Fileserver (Samba)                                    |
| srv012   | dhcp  | 192.168.15.12 | DHCP-server                                           |


- Voor alle hosts moet een "forward lookup" (van hostnaam naar IP-adres) en een "reverse lookup" (van IP-adres naar hostnaam) lukken, en ook moeten de aliassen herkend worden.
- Verwijs naar de mailserver met een MX-record ("preference number" 10).
- **Uitbreiding** Zet naast de primaire (*master*) DNS-server ook een zgn. *slave*-server op. Die heeft zelf geen zonebestanden, maar neemt die over van de primaire server. Verder kan de slave op net dezelfde requests reageren als de master.

Bedoeling is uiteraard opnieuw om heel de installatie te automatiseren aan de hand van een provisioning-script, dus alle acceptatietests (zie verder) slagen meteen na het reproduceren van de VM met "vagrant up".

## Over DNS

DNS is op zich geen complexe netwerkservice. Het komt neer op een databank met enkele tabellen die in de vorm van tekstbestanden zijn opgemaakt (= zonebestanden). Er zijn verschillende types van records, o.a.

- `A` voor mapping van hostnaam naar IP-adres
- `CNAME` voor een alias
- `PTR` voor mapping van IP-adres naar hostnaam (in een "reverse lookup" zonebestand)
- enz. (lees de documentatie!)

De syntax van deze *zone files* is echter heel strak en het is makkelijk om fouten te maken.

Een zonebestand begint met een zgn. SOA-record, wat staat voor Start Of Authority. Om tijd te besparen, kan je de volgende fragmenten gebruiken voor je zonebestanden. Voor de *forward zone file* wordt dat:

```
; /var/named/linuxlab.lan
; Forward lookup zone file for `linuxlab.lan.'
$ORIGIN linuxlab.lan.
$TTL 1W
;        primary DNS   email address admin
@ IN SOA srv001        hostmaster (
   2015101216   ; serial
   1D           ; refresh
   1H           ; retry
   1W           ; expire
   1D           ; minimum TTL
)
```

De *reverse zone file * begint als volgt:

```
; /var/named/15.168.192.in-addr.arpa.
; Reverse lookup zone file for `linuxlab.lan.'
$ORIGIN 15.168.192.in-addr.arpa.
$TTL 1W
@ IN SOA srv001.linuxlab.lan. hostmaster.linuxlab.lan. (
   2015101216   ; serial
   1D           ; refresh
   1H           ; retry
   1W           ; expire
   1D           ; minimum TTL
)
```

### Troubleshooting

De meest voorkomende fouten bij het opzetten van een DNS-server:

- Hostnamen die volledig uitgeschreven zijn (fully qualified domain name/FQDN) moeten in een zonebestand altijd afgesloten worden met een punt, bv. "`srv001.linuxlab.lan.`". Dit is één van de meest voorkomende fouten bij het configureren van BIND. Namen die niet op een punt eindigen, worden aangevuld met de waarde van `$ORIGIN` die aan het begin van een zonebestand gegeven wordt (d.i. de domeinnaam, in ons geval "`linuxlab.lan.`"). Bv. `srv002` wordt dan "`srv002.linuxlab.lan.`". Als je een hostnaam volledig uitschrijft en je vergeet het punt, dan zal de domeinnaam dus verkeerd geïnterpreteerd worden ("`srv002.linuxlab.lan`" wordt immers "`srv002.linuxlab.lan.linuxlab.lan.`").
- IP-adressen van netwerken worden op een eigenaardige manier genoteerd. Ten eerste wordt het host-deel van het netwerkadres niet genoteerd, de getallen in de "dotted quad"-notatie worden omgekeerd en je moet er "`in-addr.arpa.`" achter schrijven. Met andere woorden, `192.168.15.0/24` wordt als "`15.168.192.in-addr-arpa."` geschreven.

Het is niet altijd evident om fouten op te sporen in de configuratie van een BIND DNS-server. Daarom deze tips:

- Je kan de syntax van je configuratiebestanden testen voordat je de service opstart. Voor het hoofdbestand is het commando:

    ```bash
    sudo named-checkconf /etc/named.conf
    ```

- De syntax testen van zonebestanden gebeurt zo (voorbeeld voor forward en reverse zone, respectievelijk):

    ```bash
    sudo named-checkzone linuxlab.lan /var/named/linuxlab.lan
    sudo named-checkzone 15.168.192.in-addr.arpa /var/named/15.168.192.in-addr.arpa
    ```

    Gebruik deze commando's in je provisioning script, zo kan je meteen al een aantal fouten kan voorkomen!

- Je kan foutboodschappen van de service bekijken met `journalctl`. Het handigste is om een aparte console te openen, in te loggen op je server en dan het volgende commando uit te voeren:

    ```bash
    sudo journalctl -l -f -u named.service
    ```

    Terwijl je in een andere console commando's invoert (bv. de service herstarten) zie je meteen relevante info- en foutboodschappen verschijnen.

## Evaluatie

Zorg dat volgende deliverables op Github geregistreerd zijn en aangeduid met tag `labo2`.

* Labo-verslag met
    * Toelichting van de gekozen aanpak: welke stappen heb je ondernomen?
    * Testplan en testrapport. Stel zelf het scenario voor je tesplan op! Gebruik dat van het eerste labo (opzetten werkomgeving) als inspiratie.
    * Gebruikte bronnen voor het uitwerken van de opdracht
* Uitgewerkte installatiescripts (`provisioning/srv00[12].sh`), en bijhorende configuratiebestanden
* Demo met toelichting aan de hand van je testplan

Om de score in de rechterkolom te halen, moet je **alle** criteria tot en met de overeenkomstige lijn realiseren. Bij criteria aangeduid met (testscript) bedoelen we dat de acceptatietestscripts (meegeleverd als bijlage van de opdracht, één voor de master DNS en één voor de slave) slagen onmiddellijk na een "vagrant up" van een nog niet gecreëerde VM. Let op: het testscript gaat er van uit dat de naam van het zonebestand hetzelfde is als de zonenaam zelf, m.a.w. voor de "forward zone" is dat `/var/named/linuxlab.lan`, voor de "reverse zone" `/var/named/15.168.192.in-addr.arpa`. In principe moeten in de testscripts geen wijzigingen meer gemaakt worden.


| Taak                                                             | Score      |
| :---                                                             | :---       |
| Alle code zit in de Github repository, aangeduid met tag `labo2` |            |
| Het labo-verslag is aanwezig en volledig                         |            |
| Mondeling toegelicht/demo gegeven aan de lector                      |            |
| Het testscript `common.bats` slaagt ook voor deze hosts          |            |
| Forward lookups slagen (testscript)                              |            |
| De DNS-server antwoordt op DNS-requests vanop het hostsysteem    | voldoende  |
| Alias lookups slagen (testscript)                                | goed       |
| Reverse lookups slagen (testscript)                              | zeer goed  |
| NS en MX records slagen (testscript)                             | uitstekend |
| Alle tests op de slave server slagen (testscript)                | uitmuntend |

