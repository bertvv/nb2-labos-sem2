# Opdracht 1: LAMP Stack

## Doelstelling

* Applicaties (packages) kunnen beheren met RPM en yum
* Een Mariadb-database server kunnen installeren en configureren voor gebruik door webapplicaties
    * Basisbeveiliging van een Mariadb-installatie (zoals root-wachtwoord instellen, de test-database verwijderen, anonieme gebruikers verwijderen)
    * Databases en gebruikers aanmaken, rechten aan gebruikers toekennen
* De Apache webserver kunnen installeren en configureren
    * Ondersteuning voor PHP toevoegen
    * Ondersteuning voor SSL (HTTPS) toevoegen
    * Een self-signed certificaat kunnen aanmaken en gebruiken
* Een PHP-webapplicatie kunnen opzetten, gekoppeld aan Apache en MySQL.
* De firewall voor een Linux-webserver kunnen instellen (Firewalld)
* De installatie van een server, van "JEOS" ("Just Enough Operating System", een minimale installatie) tot een volledig geconfigureerde netwerkservice, kunnen automatiseren met een Bash-script.

## Studiemateriaal en referenties

- Galuschka, C. (2014) "Setting up an SSL secured Webserver with CentOS". Opgehaald op 2016-09-20 van <https://wiki.centos.org/HowTos/Https>
- Svistunov, M., et al. (2016) "Chapter 11. Web Servers." In *RedHat 7 System Administrator's Guide.* RedHat, Inc. Opgehaald op 2015-09-21 van <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/>
- Van Vreckem, B. (2015) *Automating `mysql_secure_installation`*. Opgehaald op 2016-03-22 van <https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/>

## Opdrachtomschrijving

Een website is vaak het uithangbord voor een bedrijf. Dat is dan ook de eerste service die we voor ons op te zetten netwerk gaan aanpakken. Zet dus een Apache webserver op met een LAMP-stack (= Linux, Apache, MariaDB, PHP) en een CMS-platform. In dit labo gaan we voor Wordpress.

De webserver ondersteunt ook HTTPS (Galuschka, 2014). SELinux is geactiveerd en de firewall is correct ingesteld (enkel webverkeer en SSH kan door).

We gaan de installatie zoveel mogelijk automatiseren met Vagrant en een Bash provisioning-script. Probeer in het script zo ver mogelijk te gaan. Als er nog manuele handelingen nodig zijn om de installatie af te werken, dan documenteer je die gedetailleerd in je labo-verslag.

In het beste geval krijg je na een `vagrant up` (wanneer de VM nog niet gecreëerd is) de installatiepagina van Wordpress te zien als je vanop je hostsysteem in een browser surft naar <https://192.168.15.10/wordpress/>.

MariaDB wordt standaard geïnstalleerd met een blanco root-wachtwoord, anonieme gebruikers (d.w.z. de gebruikersnaam is de lege string) en een database met de naam "test". Er bestaat een script `mysql_secure_installation.sh` dat deze potentiële beveiligingsrisico's oplost. Het probleem is dat dit script gebruikersinvoer verwacht en dat is natuurlijk de doodsteek van goede automatisering (Van Vreckem, 2015). Zorg er voor dat je provisioning-script dezelfde acties uitvoert als `mysql_secure_installation`, maar dan zonder interactie.

Het testscript gaat er van uit dat je bepaalde gebruikersnamen en wachtwoorden gebruikt voor MariaDB. Vervang die waarden door deze die jij gekozen hebt:

```Bash
mariadb_root_password=fogMeHud8
wordpress_database=wp_db
wordpress_user=wp_user
wordpress_password=CorkIgWac
```

Bij installatie van een package worden er vaak al basis-configuratiebestanden aangemaakt. Voor Apache vind je die bijvoorbeeld in `/etc/httpd/conf.d/`. Je provisioning-script zal aangepaste configuratiebestanden (met de instellingen die jij als systeembeheerder kiest) naar de server moeten kopiëren. De makkelijkste manier om dit aan te pakken is om de bestanden die je moet aanpassen eerst van de VM naar het hostsysteem te kopiëren. Je project-directory op het hostsysteem is binnen de VM zichtbaar onder `/vagrant`. Doe dus bv. `cp /etc/httpd/conf.d/ssl.conf /vagrant/provisioning/files/srv010/` (in de veronderstelling dat je onder `files/` een subdirectory aangemaakt hebt voor alle bestanden die bij deze server horen). Je kan het bestand dan aanpassen vanop je hostsysteem en door je provisioning-script opnieuw naar de server laten kopiëren (op de juiste plaats, met de juiste permissies).

## Testplan en -rapport

Bij deze opgave hoort ook een testscript, `lamp.bats`, dat in de directory `test/srv010/` staat. Toon bij je demo zeker de uitvoer van dit script.

Zoek voor alle requirements op hoe je ze gaat testen: welke commando's kan je gebruiken of welke handelingen moet je uitvoeren? Welke uitvoer verwacht je telkens? Is het resultaat wat je verwacht? Wat heb je moeten doen om eventuele fouten recht te trekken?

## Evaluatie

Zorg dat volgende deliverables op Github geregistreerd zijn en aangeduid met tag `labo1`.

* Labo-verslag met
    * Toelichting van de gekozen aanpak: hoe heb je de requirements gerealiseerd?
    * Testplan en -rapport: hoe toon je aan dat de specificaties, zoals hierboven omschreven, ook gerealiseerd zijn?
    * Gebruikte bronnen voor het uitwerken van de opdracht (naast deze uit de referentielijst)
* Uitgewerkt installatiescript `provisioning/srv010.sh`, en bijhorende configuratiebestanden
* Demo met toelichting aan de hand van je testplan

Om de score in de rechterkolom te halen, moet je **alle** taken tot en met de overeenkomstige lijn realiseren.

| Taak                                                             | Score     |
| :---                                                             | :---      |
| Alle code zit in de Github repository, aangeduid met tag `labo1` |           |
| Het labo-verslag is aanwezig en volledig                         |           |
| Mondeling toegelicht/demo gegeven aan de lector                  |           |
| `vagrant up` $\Rightarrow$ werkende VM met Apache+PHP en MariaDB | bekwaam   |
| Firewall- en SELinux-instellingen zijn correct                   |           |
| `vagrant up` $\Rightarrow$ MySQL mét een DB voor de app          | gevorderd |
| HTTPS-ondersteuning met self-signed certificate                  |           |
| `vagrant up` $\Rightarrow$ Wordpress installatiepagina zichtbaar | deskundig |
| Basisbeveiliging MariaDB                                         |           |
