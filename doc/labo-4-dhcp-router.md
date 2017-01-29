# Opdracht 4: DHCP-server en integratie netwerk

## Doelstelling

* Een DHCP-server kunnen opzetten met ISC-DHCP
    * Subnets declareren
    * IP-adressen toewijzen aan de hand van het MAC-adres van de client
    * Default gateway en DNS server toewijzen aan clients
* Een Linux router configureren aan de hand van VyOS

## Studiemateriaala en referenties

- Lemon, T. (n.d.). *`dhcpd.conf(5)` man page.* <http://linux.die.net/man/5/dhcpd.conf>
- Van Vreckem, B. (2014). *VyOS cheat sheet*. <https://github.com/bertvv/cheat-sheets/blob/master/src/VyOS.md>
- VyOS. (n.d.). VyOS User Guide. <http://vyos.net/wiki/User_Guide>

## Opdrachtomschrijving

In dit labo gaan we het netwerk dat we tot nu toe beetje bij beetje hebben opgezet "afwerken" met nog twee ontbrekende componenten. Eerst en vooral gaan we een router opzetten en daarnaast nog een DHCP-server om werkstations binnen het netwerk de juiste netwerkinstellingen te bezorgen.

### Router

Voor de router gebruiken we een gespecialiseerde Linux-distributie: [VyOS](http://vyos.net/). Een overzicht van de interfaces:

| Interface | VBox adapter | IP-adres         | Opmerkingen |
| :---      | :---         | :---             | :---        |
| `eth0`    | NAT          | 10.0.2.15 (DHCP) | WAN link    |
| `eth1`    | Host-only    | 192.168.15.254   | LAN link    |

Voor het aanmaken van een VyOS-VM met Vagrant moet je eerst een plugin installeren: `vagrant plugin install vagrant-vyos`.

In `vagrant_hosts`:

```Yaml
- name: router
  ip: 192.168.15.254
  box: bertvv/vyos116
```

De router past Network Address Translation toe op alle netwerkverkeer van hosts op het LAN naar buiten.

De router doet ook dienst als [*caching name server*](http://www.zytrax.com/books/dns/ch4/#caching) voor alle werkstations in het netwerk. Dat betekent dat hij niet zelf zonebestanden bijhoudt, maar alle DNS-requests die binnenkomen doorverwijst naar de juiste bron. Voor het domein linuxlab.lan wordt dat de DNS-server die je al opgezet hebt (`srv001`), alle andere worden doorgestuurd naar de DNS-server van het NAT-netwerk waar de router op is aangesloten.

Het provisioning-script ziet er totaal anders uit dan die voor andere hosts, daarom wordt er een sjabloon meegeleverd met deze opgave. Dit dient nog enkel aangevuld te worden met de commando's voor het configureren zoals hierboven aangegeven.

### DHCP-server

Op het netwerk moet ook nog een DHCP-server opgezet worden. Let op dat het mogelijk is dat nu het VirtualBox host-only netwerk zelf al een DHCP-server simuleert. Zorg er voor dat deze uitgezet is (vanuit het hoofdvenster van VirtualBox File > Preferences > Network > Host-only Networks. Kies het juiste host-onlynetwerk en zorg er voor dat de DHCP-server uit staat).

- De DHCP-server geeft werkstations die aangesloten worden op het netwerk alle nodige netwerkinstellingen om via de router Internettoegang te krijgen en gebruik te kunnen maken van de netwerkdiensten op het LAN.
- Gekende hosts krijgen een gereserveerd IP-adres aan de hand van het MAC-adres met een leasetijd van 8u (max. 12u).
- Hosts zonder MAC-registratie krijgen een dynamisch IP-adres toegekend met een leasetijd van 4u (max. 6u).

Het netwerk wordt zo onderverdeeld (opm: **geen** subnetting):

- 192.168.15.1-49: voorbehouden voor hosts met vast IP (servers en het host-systeem), niet toegekend door DHCP
- 192.168.15.50-199: hosts met een gereserveerd IP, toegekend door DHCP op basis van het MAC-adres
- 192.168.15.200-253: hosts met en dynamisch IP, toegekend door DHCP
- 192.168.15.254: voorbehouden voor de router, niet toegekend door DHCP

Merk op dat over de hosts die niet toegekend worden door DHCP **ook niets in de DHCP-configuratie moet staan**! Dit wordt hier enkel ter info meegegeven.

### Werkstation

Simuleer een werkstation door manueel een nieuwe VM aan te maken in VirtualBox met één netwerkadapter, aangesloten op het host-onlynetwerk.

Je kan een Linux-VM booten vanaf een live-cd, en het is niet nodig die verder te installeren of te configureren. Je kan ook een Windows-VM gebruiken, maar die nemen veel meer geheugen in.

Een werkstation moet *zonder specifiek iets te configureren*:

- een IP-adres krijgen van de DHCP-server (en ook de andere netwerkinstellingen: DNS-server en default gateway) op basis van het MAC-adres
- op het Internet kunnen (via de router), bv surfen naar <https://google.com/>
- de website van het domein kunnen bekijken via URL <https://www.linuxlab.lan>
- toegang kunnen krijgen tot de shares op de fileserver (in Windows bv. via `\\files\public`, in Linux `smb://files/public`).

## Evaluatie

Zorg dat volgende deliverables op Github geregistreerd zijn en aangeduid met tag `labo4`.

* Labo-verslag met
    * Toelichting van de gekozen aanpak: hoe heb je de requirements gerealiseerd?
    * Testplan en -rapport: hoe toon je aan dat de specificaties, zoals hierboven omschreven, ook gerealiseerd zijn?
    * Gebruikte bronnen voor het uitwerken van de opdracht (naast deze uit de referentielijst)
* Uitgewerkt installatiescript `provisioning/srv012.sh` en `provisioning/router.sh`, en bijhorende configuratiebestanden
* Demo met toelichting aan de hand van je testplan

Om de score in de rechterkolom te halen, moet je **alle** taken tot en met de overeenkomstige lijn realiseren.

| Taak                                                             | Score      |
| :---                                                             | :---       |
| Alle code zit in de Github repository, aangeduid met tag `labo4` |            |
| Het labo-verslag is aanwezig en volledig                         |            |
| Mondeling toegelicht/demo gegeven aan de lector                  |            |
| `vagrant up srv012` -> werkende DHCP-server                      | voldoende  |
| Werkstation krijgt IP (gereserveerd voor MAC), gateway, DNS      | goed       |
| `vagrant up router` -> werkende router met NAT en DNS forwarding | zeer goed  |
| Werkstation kan Internet bereiken                                | uitstekend |
| Werkstation kan interne services bereiken (website + fileserver) | uitmuntend |

