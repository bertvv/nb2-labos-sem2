# Opdracht 3: Een fileserver opzetten met Samba

## Leerdoelen

* Een Samba-fileserver kunnen opzetten en testen
    * Het configuratoebestand van Samba begrijpen en kunnen aanpassen
    * Problemen met de configuratie van een Samba-server kunnen opsporen en oplossen
* Gebruikers, groepen en bestandspermissies kunnen toepassen
* SELinux kunnen gebruiken
    * SELinux kunnen aan- of uitzetten
    * SELinux booleans kunnen opvragen en aanpassen
    * Het concept van SELinux labels begrijpen en kunnen aanpassen

## Studiemateriaal en referenties

* RHEL 7 System Administrator's Guide
    * Secties 12.1
* RHEL 7 SELinux User's and Administrator's Guide
* Van Vreckem, Bert. (2014) "[Een fileserver opzetten met Samba](https://youtu.be/w2RxBkqQ3ZQ) (videoles). Let op: in de video gebruik ik een oudere versie van CentOS. Pas de gebruikte commando's waar nodig aan. De syntax van het configuratiebestand `smb.conf` is wel hetzelfde gebleven.
    * Slides: <http://www.slideshare.net/bertvanvreckem/een-fileserver-opzetten-met-samba>
    * "Walkthrough": <http://wp.me/p2XuZW-2P>
* Cameron, Thomas (2012). ["SELinux for Mere Mortals"](http://www.youtube.com/watch?v=MxjenQ31b70). 2012 Red Hat Summit.
* Vernooij, J.R.,  Terpstra, J. & Carter, G. (2010). ["The Official Samba 3.5.x HOWTO and Reference Guide"](https://www.samba.org/samba/docs/man/Samba-HOWTO-Collection/)
    * Hst. 38 [The Samba Checklist](https://www.samba.org/samba/docs/man/Samba-HOWTO-Collection/diagnosis.html)
    * Hst. 39 [Analyzing and Solving Samba Problems](https://www.samba.org/samba/docs/man/Samba-HOWTO-Collection/problems.html)

## Opdrachtomschrijving

De doelstelling van dit labo is het opzetten van een Linux fileserver voor een klein bedrijfje. De fileserver heeft vier gedeelde mappen (shares) voor de verschillende afdelingen van het bedrijf:

- financial
- management
- public
- technical

De gepaste plaats in het filesysteem voor deze shares is onder de directory `/srv/`. Je kan bijvoorbeeld een directory `/srv/shares` met voor elke share een afzonderlijke subdirectory.

Er worden gebruikersaccounts voorzien met gepaste toegangsrechten. Maak een gebruikersgroep voor elke share om toegangsrechten toe te kennen. De shares zijn enkel zichtbaar voor geregistreerde gebruikers (d.w.z. je moet een gebruikersnaam en wachtwoord ingeven voordat je de shares kan bekijken). Hieronder vind je een tabel met de shares waar elke gebruiker schrijftoegang toe moet hebben:

| Naam             | Gebruikersnaam | Schrijftoegang tot share |
| :---             | :---           | :---                     |
| Liza Elaut       | lizae          | `management`             |
| Maarten Mousavi  | maartenm       | `technical`              |
| Maxim de Roeck   | maximdr        | `financial`              |
| Quinten de Coen  | quintendc      | `management`             |
| Stefanie Lievens | stefaniel      | `technical`              |
| Thomas Beirlaen  | thomasb        | `financial`              |
| (je eigen naam)  | (kies zelf)    | alle shares              |

1. Deze gebruikers kunnen niet inloggen op de server via ssh. De toegang gebeurt enkel via Samba. In productiesystemen is dit uiteraard uit den boze, maar de acceptatietests gaan er van uit dat het wachtwoord hetzelfde is als de gebruikersnaam.
2. Voeg jezelf ook toe, met dezelfde gebruikersnaam als in labo 0. Als beheerder krijg je schrijftoegang tot alle shares. Jij kan uiteraard blijven inloggen met ssh. Vergeet niet je naam aan te passen in het testscript (variabele `${admin_user}`).
3. Bij de shares `management` en `financial` is er enkel leestoegang voor de leden van de overeenkomstige groepen.
4. Iedereen heeft leestoegang tot de share `technical`
5. Iedereen heeft lees- en schrijftoegang tot de share `public`
6. Als gebruikers bestanden aanmaken, moeten die ook schrijfbaar zijn door andere gebruikers van dezelfde groep.
7. Alle gebruikers hebben een persoonlijke map op de server (in `/home/${USER}`)
8. Eventueel delen van printers is uitgeschakeld (zie verder)
9. SELinux moet geactiveerd blijven (in sommige tutorials die je op het web vindt is stap 1 immers om SELinux uit te zetten)
10. Je moet de fileserver kunnen zien als je in een File Explorer-venster op je hostsysteem `\\files\` intikt en je aanmeldt als één van de hierboven genoemde gebruikers. De workgroup is LINUXLAB.

## Tips en truuks

### Permissies

Het opzetten van een Samba fileserver is soms een uitdaging, vooral wat betreft het correct instellen van de toegangsrechten. Als je bepaalde gebruikers lees- of schrijftoegang wil geven tot een share, dan moet dit op drie verschillende niveaus correct en consistent ingesteld zijn:

1. **Bestandspermissies:** De gewone bestandspermissies moeten de gebruiker lees- of schrijftoegang geven. Dit kan je testen door in te loggen als die gebruiker (`sudo su - GEBRUIKERSNAAM`) en een bestand proberen aan te maken.
2. **Samba configuratie:** De share moet via het Samba-configuratiebestand `/etc/samba/smb.conf` de juiste toegangsrechten toekennen aan de gebruiker
3. **SELinux:**
    * De algemene SELinux-instelling `samba_export_all_rw` moet "aan" staan:
        ```Bash
        setsebool -P samba_export_all_rw on
        ```
    * De directory moet de juiste SELinux context hebben, hetzij `samba_share_t`, hetzij `public_content_rw_t`. Dit laatste gebruik je als je de share ook via een ander protocol wil toegankelijk maken, bv. FTP.
        ```Bash
        chcon -R -t samba_share_t /srv/shares
        ```

Als ook maar één van deze drie elementen te streng is ingesteld, hebben de gebruikers niet de gewenste toegang. Door dit proces te automatiseren, kan je vervelende fouten (en de tijd die nodig is die op te lossen) vermijden.

De makkelijkste manier om gebruikersrechten per share te organiseren is om voor elke share een gebruikersgroep aan te maken (bv. dezelfde naam als de share) en de gebruikers lid te maken van deze groepen. De directory van de share kan eigendom blijven van `root`, maar wordt toegekend aan de groep. De permissiecode wordt dan `775` als gebruikers buiten de groep leestoegang mogen hebben of `770` als dit niet mag. In `smb.conf` geef je dan voor de share `write list = +GROEP` (te vervangen door de eigenlijke naam van de groep) om de schrijfrechten te beperken. Je kan ook leesrechten beperken tot de groep met `valid users = +GROEP`.

### Gebruikers en wachtwoorden

Als je een gebruiker toegang wil geven tot een Samba-share, dan moet die ook bestaan als gebruiker op het systeem. Of concreet: de gebruiker moet voorkomen in `/etc/passwd`. Wachtwoorden voor Samba worden echter afzonderlijk beheerd van de systeemwachtwoorden. Als het niet de bedoeling is dat deze gebruikers ook shelltoegang hebben, dan kan je de accounts blokkeren en hen geen Linux-wachtwoord toekennen, maar wél één voor Samba. Het commando voor het instellen van een Samba-wachtwoord is `smbpasswd`. Dit commando is interactief en dus op zich niet geschikt voor gebruik in een shellscript. In het script `provisioning/util.sh` is een functie `set_samba_passwd` gedefinieerd die je kan gebruiken voor het instellen van wachtwoorden:

```Bash
set_samba_passwd GEBRUIKER WACHTWOORD
```

### Tips ivm. algemene configuratie

Wanneer je Samba installeert, wordt er al meteen een configuratiebestand meegeleverd. Je kan dit gebruiken om mee te starten, maar ik raad aan enkele algemene instellingen (onder de sectie `[global]`) aan te passen.

Voor **logging**, bijvoorbeeld, worden er standaard verschillende configuratiebestanden aangemaakt, één voor elke client-machine die contact opneemt met de server. Op den duur wordt dit erg onoverzichtelijk en moeilijk beheersbaar. Het is ook beter om in plaats van de logs weg te schrijven naar tekstbestanden, gebruik te maken van het centrale loggingsysteem, Syslog. Dit kan door onder de rubriek `[global]` volgende opties mee te geven:

```ini
  syslog only = yes
  syslog = 1
```

en alle andere instellingen ivm logging te verwijderen.

Voor het beheer van gebruikers en instellingen van **toegangsrechten** zijn de volgende opties aan te raden:

```ini
  security = user
  passdb backend = tdbsam
```

In sommige HOWTO's krijg je de instructie om `security = share` in te stellen, maar dit wordt door de Samba documentatie om beveiligingsredenen ten stelligste afgeraden.

Ook worden standaard de **printers** die eventueel zouden aangesloten zijn op het systeem gedeeld over het netwerk. Voor onze opstelling is dit niet relevant, dus gaan we dit uitzetten. Dat kan met het volgende stuk code:

```ini
  load printers = no
  printing = bsd
  printcap name = /dev/null
  disable spoolss = yes
```

Verwijder alle instellingen i.v.m. printen die eventueel al aanwezig zijn.

### Configuratie testen

Samba voorziet een commando voor het controleren of het configuratiebestand `/etc/samba/smb.conf` correct is: `testparm`. Het drukt ook de inhoud van het configuratiebestand af in de meest eenvoudige en compacte vorm. Dit kan ook van pas komen om de configuratie die je zelf hebt opgebouwd te "optimaliseren". Samba voorziet namelijk standaardinstellingen die je niet moet expliciet schrijven (bijvoorbeeld `guest ok = no`) en er zijn ook vaak verschillende manieren om hetzelfde te schrijven (bijvoorbeeld `guest ok = no` is het zelfde als `public = yes`). Sommige opties worden zelfs genegeerd afhankelijk van de waarde van andere (bijvoorbeeld `guest only` heeft geen effect als `guest ok` niet is ingesteld).

Je kan dus best in je provisioning script meteen `testparm` gebruiken om het configuratiebestand te testen voordat je het op de server plaatst. Geef de optie `-s` of `--suppress-prompt` mee, anders wordt er gevraagd om "ENTER" in te drukken voordat je het overzicht van de configuratie te zien krijgt.

Na wijzigen van `smb.conf` moet je de services `smb` en `nmb` herstarten. Die laatste is de zgn. "WinBind" service die er voor zorgt dat je de Samba server kan aanspreken aan de hand van de naam ipv het IP-adres (dus `\\files` ipv. `\\192.168.15.11`).

Om te testen of de share toegankelijk is van buitenaf, kan je vanop het hostsysteem in de file explorer werken, maar dit is niet zo interessant. De foutboodschappen geven weinig of geen informatie die helpt bij het vinden van de oorzaak van het probleem. Gebruik liever `smbclient`, daarmee krijg je alvast iets duidelijker foutboodschappen. Enkele voorbeelden van het gebruik:

```bash
## Geef overzicht van de shares
smbclient -L //files/

## Log in op een share als lizae met wachtwoord letmein
smbclient //files/public -Ulizae%letmein

## Log in op een share als "gast"
smbclient //files/public -U%
```

Als je toegang tot de fileserver gekregen hebt vanaf een Windows-hostsysteem en je hebt aangemeld met een gebruikersnaam en wachtwoord, dan blijft Windows die onthouden. Als je wil aanmelden met een ander account, kan je het huidige verwijderen met:

```
net use \\files /del
```

## Evaluatie

Er is zoals gewoonlijk een acceptatietest beschikbaar voor het valideren van deze specificaties. Vergeet niet je eigen gebruikersnaam in het testscript aan te passen!

Zorg dat volgende deliverables op Github geregistreerd zijn en aangeduid met tag `labo3`.

* Labo-verslag met
    * Toelichting van de gekozen aanpak: welke stappen heb je ondernomen?
    * Testplan en -rapport: hoe toon je aan dat de specificaties, zoals hierboven omschreven, ook gerealiseerd zijn?
    * Gebruikte bronnen voor het uitwerken van de opdracht (naast deze uit de referentielijst)
* Uitgewerkt installatiescript `provisioning/srv011.sh`, en bijhorende configuratiebestanden
* Demo met toelichting aan de hand van je testplan

Om de score in de rechterkolom te halen, moet je **alle** taken tot en met de overeenkomstige lijn realiseren.

| Taak                                                                     | Score     |
| :---                                                                     | :---      |
| Alle code zit in de Github repository, aangeduid met tag `labo3`         |           |
| Het labo-verslag is aanwezig en volledig                                 |           |
| Mondeling toegelicht/demo gegeven aan de lector                          |           |
| Vagrant up -> werkende Samba server met correcte lees- en schrijftoegang |           |
| De service is beschikbaar vanop het hostsysteem via `\\192.168.15.11`    | bekwaam   |
| De service is beschikbaar vanop het hostsysteem via `\\files`            |           |
| Gebruikers hebben toegang tot hun home-directory                         | gevorderd |
| Leden van dezelfde groep hebben schrijftoegang tot elkaars bestanden     | deskundig |

