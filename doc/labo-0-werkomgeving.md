# Opdracht 0: Opzetten werkomgeving'

## Doelstelling

- Een werkomgeving opzetten voor het uitvoeren van de labo-taken en documenteren van de gevolgde werkwijze.
- Vertrouwd worden met de gebruikte tools, i.h.b.: Bash shell, Vagrant, Git.

## Studiemateriaal en referenties

- Github (n.d.). *About writing and formatting on Github*. <https://help.github.com/articles/about-writing-and-formatting-on-github/>
- Github (n.d.). *Generating an SSH key*. <https://help.github.com/articles/generating-an-ssh-key/>
- Gruber, John (2004). *Markdown*. <http://daringfireball.net/projects/markdown/>
- Hashicorp (n.d.). *Vagrant documentation*. <https://docs.vagrantup.com/v2/>
- Limoncelli, Tom (2012). *What makes a sysadmin a "senior sysadmin"?* Everything Sysadmin Blog. <http://everythingsysadmin.com/2012/09/seniorsysadmins.html>
- Van Vreckem, Bert (n.d.). *Cheat Sheets*, <https://github.com/bertvv/cheat-sheets>
- Van Vreckem, Bert (2015). *Vagrant Tutorial*, <https://bertvv.github.io/vagrant-presentation/>
- Van Vreckem, Bert (2014). *Workshop Inleiding Git*, <https://bertvv.github.io/git-workshop-nl/>

## Installatie software

Als je werkt met je eigen laptop, Installeer dan de nodige software, meer bepaald de *laatste* stabiele versies van deze applicaties:

- Een **degelijke** teksteditor: [Sublime](http://www.sublimetext.com/), [Notepad++](http://notepad-plus-plus.org/), [Vim](http://www.vim.org/), enz. **Gebruik geen Notepad of Wordpad**
    - Stel de editor in met automatische indentatie, met een breedte van 2 spaties (**GEEN TABs!**)
    - **Gebruik geen Notepad/Wordpad!**
- De laatste versie van [VirtualBox](https://virtualbox.org/wiki/Downloads) mét Extension Pack
    - Alle machines die we opzetten in de labo's zijn gebaseerd op een recente release van [CentOS](https://www.centos.org/) en worden opgezet als VirtualBox VMs. Het is echter niet nodig een installatie-ISO te downloaden, het opzetten van CentOS VMs die klaar zijn voor gebruik gebeurt is geautomatiseerd.
- [Vagrant](http://vagrantup.com/) is de tool die het opzetten van VMs automatiseert. Het is een command-line tool die VirtualBox (of een ander virtualisatieplatform) aanstuurt.
- [Git](http://git-scm.com/download/win), incl. de Bash shell "Git Bash". Je kan eventueel ook een grafische Git client installeren, bv. [Sourcetree](http://www.sourcetreeapp.com/) of [Github Desktop](https://desktop.github.com/).

In deze opgave (en alle volgende) verwijzen we naar de pc waarop je werkt als het "hostsysteem" en de servers die we opzetten als de virtuele machine of VM, of "guest"s.

## Versiebeheer

We gaan de volledige schriftelijke neerslag van de labo-taken bijhouden in een *versiebeheersysteem*. Dat omvat alle scripts en de exacte configuratie van de opgezette systemen, maar ook je documentatie, zoals procedures, "cheat sheets" en "checklists", enz. Op het einde van het semester moet je aan de hand hiervan in principe het gehele op te zetten netwerk kunnen reconstrueren zonder manuele tussenkomst.

1. Maak een account aan (als je dit nog niet hebt) op Github. Je kan het inloggen met gebruikersnaam en wachtwoord vereenvoudigen door een [SSH-sleutelpaar](https://help.github.com/articles/generating-an-ssh-key/) aan te maken. Maak zo'n sleutelpaar aan in Git Bash (voor je gemak: zonder passphrase) en registreer de publieke sleutel bij Github.
2. Ga naar de Github classroom (URL via Chamilo gepubliceerd)
3. Maak lokaal in een directory die je voorbehoudt voor al wat met deze cursus te maken heeft een kloon van je repository. Als je geen ssh-sleutelpaar hebt, gebeurt dat met commando

    ```Bash
    $ git clone --config core.autocrlf=input https://github.org/GEBRUIKERSNAAM/nb2-labos-linux.git
    ```

    Indien je correct een ssh-sleutelpaar hebt aangemaakt, vervang je de url "https:..." door `git@github.org:GEBRUIKERSNAAM/nb2-labos-linux.git`. Je kan de naam van de lokale directory wijzigen en verplaatsen zonder de link naar Github kwijt te spelen. Dit is (een deel van) de resulterende directorystructuur:

    ```
    $ tree
    .
    ├── doc
    │   ├── cheat-sheet.md
    │   └── laboverslag-sjabloon.md
    ├── provisioning
    │   ├── common.sh
    │   └── srv010.sh
    ├── README.md
    ├── test
    │   ├── common.bats
    │   └── runbats.sh
    ├── Vagrantfile
    └── vagrant_hosts.yml

    4 directories, 10 files
    ```

4. Basisconfiguratie Git op eigen pc: voer volgende commando's uit in een (Git) Bash terminal (gebruik zelfde emailadres als voor je Github-account):

    ```Bash
    $ git config --global user.name "VOORNAAM NAAM"
    $ git config --global user.email "VOORNAAM.NAAM@EXAMPLE.COM"
    $ git config --global push.default simple
    ```

    Wanneer je de labo's op de klaspc's maakt, is dit de werkwijze (instellingen gelden enkel voor jouw repository):

    ```Bash
    $ cd PAD/NAAR/nb2-labos-linux/
    $ git config user.name "VOORNAAM NAAM"
    $ git config user.email "VOORNAAM.NAAM@EXAMPLE.COM"
    $ git config push.default simple
    ```

    Het is aan te raden om je repository *niet* op de klaspc's te laten staan op het einde van de les. Werk eventueel vanop een USB-stick.

5. Bekijk de inhoud van de directory `doc/` (de andere komen later aan bod). Daar vind je een aantal bestanden in [Markdown](http://daringfireball.net/projects/markdown/)-formaat.
    - Het bestand `cheat-sheet.md` dient om in de loop van het semester nuttige commando's en troubleshooting checklists bij te houden. Zie <https://github.com/bertvv/cheat-sheets> voor enkele voorbeelden.
    - `laboverslag-sjabloon.md` is de basis van je laboverslagen.
    - In het bestand `whoami.md` wordt gevraagd jezelf voor te stellen
6. Pas het sjabloon voor het labo-verslag aan: vul je naam en repository-url in op de daarvoor voorziene plaats. Registreer de wijziging in Git (`git add` en `git commit`) en hevel die over naar Github (`git push`).
7. Kopieer het sjabloon naar `labo-0-verslag.md` en steek het ook in versiebeheer. Dit wordt je verslag voor het huidige labo.
8. Vul het bestand `whoami.md` aan volgens de instructies en registreer in Git.

## Opzetten CentOS-server met Vagrant

1. Zorg dat je in een Bash shell zit, op het hostsysteem, in de directory met de lokale versie van je repository. Voer het commando `vagrant status` uit:

    ```
    $ vagrant status
    Current machine states:

    srv010                    not created (virtualbox)

    The environment has not yet been created. Run `vagrant up` to
    create the environment. If a machine is not created, only the
    default provider will be shown. So if a provider is not listed,
    then the machine is not created for that environment.
    ```

    [Vagrant](https://www.vagrantup.com/) is een command-line tool die het opzetten van virtuele machines automatiseert en vereenvoudigt. Wij zullen het gebruiken in combinatie met VirtualBox, maar andere virtualisatieplatformen worden ook ondersteund.

    De uitvoer van het commando geeft aan dat er al een Vagrant-omgeving is opgezet met één virtuele machine genaamd `srv010`. Deze gaan we in het volgende labo verder configureren tot een webserver.

2. Maak de VM aan met het commando `vagrant up srv010`. Dit is wat er gebeurt:

    - Een vooraf opgezette VM met minimale CentOS installatie (base box) wordt gedownload en als "sjabloon" lokaal bewaard voor later gebruik.
    - Er wordt in VirtualBox een nieuwe VM aangemaakt gebaseerd op dit sjabloon met de naam "srv010".
    - De VM krijgt een geschikt IP-adres en wordt opgestart.
    - Een installatiescript (`provisioning/srv010.sh`) wordt uitgevoerd.

3. Je kan nu inloggen op deze nieuwe VM met `vagrant ssh srv010`. Je bent ingelogd als gebruiker `vagrant` en kan commando's uitvoeren. Commando's die root-rechten vereisen, laat je voorafgaan door `sudo`.

4. Er zijn geautomatiseerde acceptatietests voorzien die controleren of de VM voldoet aan de specificaties die hieronder zijn opgegeven. Je kan die uitvoeren na inloggen op de VM (geldt ook voor de VMs van volgende labo-opdrachten) met het commando:

    ```Bash
    $ sudo /vagrant/test/runbats.sh
    ```

Op dit moment zullen een aantal tests falen. Die vind je telkens in de directory `test/` als bestanden met extentie `.bats`. Merk op dat de directory `/vagrant` op de VM dezelfde directory is als je lokale repository op het hostsysteem. Als je op het hostsysteem een bestand zou toevoegen, is dit dus meteen zichtbaar op de VM.

Maak jezelf vertrouwd met de Vagrant-commando's (`vagrant up`, `vagrant provision`, `vagrant destroy`, `vagrant ssh`, enz.). Lees over Vagrant of bekijk een demo op Youtube.

Bestudeer het testscript `runbats.sh`. Hoe werkt het? Lees de handleiding van het [Bash Automated Testing Framework](https://github.com/sstephenson/bats) (BATS), het systeem dat hier gebruikt wordt voor het automatiseren van de acceptatietests. Bestudeer de test suite `common.bats` en zorg dat je begrijpt hoe deze tests werken. Merk op dat de inhoud van elke test case gewone Bash-code is.

## Opdracht

In staat zijn om systeembeheertaken uit te voeren zoals het installeren en configureren van software of netwerkservices is slechts het begin van wat het inhoudt om een systeembeheerder te zijn. Het is ook belangrijk om op een betrouwbare, reproduceerbare en consistente manier systemen in productie te brengen die beschikbaar zijn voor de gebruikers en voldoen aan de vooraf afgesproken specificaties. Het bijhouden van gedetaileerde procedures is daarbij een minimum, maar het automatiseren van het proces is beter (Limoncelli, 2012). Dit wordt de rode draad door heel de cursus.

- Zorg dat volgende packages geïnstalleerd zijn: `bash-completion`, `bind-utils`, `git`, `nano`, `tree`, `vim-enhanced`, `wget`
- Maak een gebruiker aan die je ook kan gebruiken als administrator (d.w.z. een gebruiker met sudo-rechten). Gebruik je eigen voornaam. Vergeet niet dit aan te passen in het testscript (variabele `admin_user` bovenaan het script).
- Toon aan dat je vanop het hostsysteem via ssh kan inloggen op de VM met de pas aangemaakte gebruiker. Dat kan met "ssh USER@IP_ADRES" in een (Git) Bash shell of met [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).
- Zorg er voor dat voor het inloggen vanop het hostsysteem geen wachtwoord nodig is (a.h.v. een SSH-sleutelpaar).

Al deze wijzigingen moeten volledig geautomatiseerd zijn. Het provisioning-script mag geen gebruikersinvoer verwachten. Bovendien moet het zodanig geschreven zijn dat het meerdere keren na elkaar uitvoeren ervan geen effect heeft. Deze eigenschap wordt "idempotentie" genoemd. Als je de tenslotte VM verwijdert (met `vagrant destroy srv010`), en opnieuw opzet met `vagrant up srv010`, zouden alle tests meteen moeten slagen zonder nog manuele wijzigingen aan het systeem te moeten aanbrengen.

Werk stap voor stap. Probeer eerst een wijziging manueel uit te voeren. Als dat lukt, kopieer dan het commando naar het provisioning-script. Schrijf niet teveel code ineens, anders wordt debuggen een heel stuk moeilijker. Telkens je een stap verder raakt en iets nieuws werkend krijgt, registreer je meteen de wijzigingen in versiebeheer.

Merk op dat het provisioning-script `srv010.sh` een ander script oproept, nl. `common.sh` en `utils.sh`. Het script `common.sh` bevat aanpassingen die op alle servers moeten uitgevoerd worden (bv. opzetten van een gebruikersaccount voor de administrator). Het script `utils.sh` bevat herbruikbare functies (in de Bash scriptingtaal) die in elk provisioning-script toegankelijke zijn.

## Testplan

Bij elk laboverslag hoort een testplan. Het testplan is een opsomming van alle concrete handelingen die nodig zijn om aan te tonen dat het op te zetten systeem zich gedraagt volgens de specificaties. Deze worden getest aan de hand van het testscript, is een testplan dan nog nodig? Jazeker, want niet *alle* specificaties worden effectief geverifieerd door het testscript. Onder andere de idempotentie van het provisioning script wordt niet aangetoond, en ook niet of dat script alle tests ineens doet slagen.

Het testplan is eigenlijk het scenario van de demo die je geeft aan de lector om aan te tonen dat je alle aspecten van de opdracht correct hebt uitgevoerd. Dit bestaat uit concrete handelingen of commando's die je moet uitvoeren met het verwachte resultaat.

Om je op weg te helpen, geven we bij dit labo een aanzet voor het tesplan, maar in volgende labo's moet je dit zelfstandig uitwerken. In je eigen laboverslag pas je dit testplan waar nodig aan en geef je de resultaten die jij zelf verkrijgt.

0. Open een Bash shell op het hostsysteem.
1. Ga naar de directory met de lokale kopie van de Git repository.
2. Voer `vagrant status` uit
    - je zou één VM moeten zien met naam `srv010` en status `not created`.
3. Voer `vagrant up srv010` uit.
    - Het commando moet slagen zonder fouten (exitstatus 0)
4. Voer `vagrant provision srv010` twee keer na elkaar uit
    - Het commando moet telkens slagen zonder fouten, de tweede keer worden geen wijzigingen uitgevoerd (idempotentie)
5. Log in op de server met `vagrant ssh srv010` en voer de acceptatietests uit:

    ```
    $ sudo /vagrant/test/runbats.sh
    Running test /vagrant/test/common.bats
     ✓ Bash-completion should have been installed
     ✓ bind-utils should have been installed
     ✓ Git should have been installed
     ✓ Nano should have been installed
     ✓ Tree should have been installed
     ✓ Vim-enhanced should have been installed
     ✓ Wget should have been installed
     ✓ Admin user bert should exist

     8 tests, 0 failures
    ```

6. Log uit en log vanop het hostsysteem opnieuw in, maar nu met ssh. Er mag geen wachtwoord gevraagd worden.

    ```
    $ ssh bert@192.168.15.10
    Welcome to your Packer-built virtual machine.
    [bert@srv010 ~]$
    ```

## Evaluatie

Om de score in de rechterkolom te halen, moet je **alle** taken tot en met de overeenkomstige lijn realiseren.

| Taak                                                         | Score      |
| :---                                                         | :---       |
| De gevraagde software is geïnstalleerd                       |            |
| Github account en repository is aangemaakt                   |            |
| De lector heeft toegang tot je Git repository                |            |
| Labo-verslag is aanwezig in je Git repository en is volledig |            |
| Alle documentatie ivm dit labo zit in Github                 |            |
| Alle specs van de VM (zie hoger) zijn gerealiseerd           | voldoende  |
| Er is geen wachtwoord nodig voor inloggen op de VM           | goed       |
| Er is geen wachtwoord nodig voor `git push`                  | zeer goed  |
| Alle taken uitgevoerd vóór afloop van de 1e les              | uitmuntend |

Het aantonen van de specificaties gebeurt aan de hand van een demo aan de lector waar je alle stappen van het testplan doorloopt.

**Extra's:**

Je kan een verhoging van je score bekomen (mits die al minstens voldoende was) door verder te gaan dan het utivoeren van de hierboven opgelegde specificaties. Enkele mogelijkheden worden hieronder opgesomd. Alles dient volledig automatisch te gebeuren, d.w.z. na `vagrant up` of `vagrant provision` zijn deze wijzigingen aangebracht.

- Installeer bij provisioning voor je eigen gebruiker een `.bashrc` script met aliassen voor vaak gebruikte commando's (bv. aangepaste `git log`, "shortcut" voor het uitvoeren van het testscript), een zelf ingestelde prompt met kleuren, enz. Zie <https://github.com/bertvv/dotfiles> voor een uitgebreid voorbeeld.
- Pas de [instellingen voor de editor Nano](http://www.if-not-true-then-false.com/2009/tuning-nano-text-editor-with-nanorc/) aan. Zorg er voor dat in Nano syntax-colouring aan staat. Voor sommige bestandsformaten is er in de standaardinstallatie geen ondersteuning van de sytax-colouring. Je kan die ook installeren, bijvoorbeeld downloaden van <https://github.com/nanorc/nanorc>.

