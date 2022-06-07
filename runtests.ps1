# Script permettant la construction et l'utilisation de l'image Docker pour
# effectuer les tests de performance du processeur nécessaire pour évaluer
# la surcharge computationnelle due a l'usage de Docker.

# Définition des paramètres du script
param(
    # Nombre de cœurs assignés au conteneur Docker (Défaut: maximum disponible)
    [int]$coeurs=$env:NUMBER_OF_PROCESSORS,
    # Quantité de mémoire assignée au conteneur Docker (Défaut: 8GB)
    [int]$memoire=8,
    # Est-ce que le script doit construire l'image localement avant d'effectuer
    # les tests?
    [bool]$construire=$false,
    # Affiche une aide simple dans la console pour l'usage du script
    [switch]$help,
    # Booléen controlant l'exécution des tests natifs
    [bool]$testsNatif=$false,
    # Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur
    # WSL 2 (doit être configuré avant le lancement du script) et l'isolation hyperV par défaut
    [bool]$testsWSL2=$false,
    # Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur
    # WSL 2 (doit être configuré avant le lancement du script) et l'isolation par processus
    [bool]$testsWSL2Processus=$false,
    # Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur
    # patrimonial (legacy) (doit être configuré avant le lancement du script) et l'isolation hyperV par défaut
    [bool]$testsHyper=$false,
    # Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur
    # patrimonial (legacy) (doit être configuré avant le lancement du script) et l'isolation par processus
    [bool]$testsHyperProcessus=$false
)

# Message d'erreur affiche lorsque le paramètre -help est invoqué
$messageErreur="`
Le script actuel permet de faciliter la construction et l'utilisation de l'image Docker pour effectuer les tests. `
`
Paramètres: -coeurs (défaut: maximum disponible): nombre de processeurs logiques assignés au conteneur utilisant l'image `
            -memoire (défaut: 8): quantité de mémoire, en GB, assignée au conteneur utilisant l'image `
            `
            -testsNatif (défaut: `$false): Booléen controlant l'exécution des tests natifs `
            -testsWSL2 (défaut: `$false): Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur `
                                         WSL 2 (doit être configuré avant le lancement du script) et l'isolation hyperV par défaut `
            -testsWSL2Processus (défaut: `$false): Booléen controlant l'exécution des tests pour un conteneur utilisant `
                                                  le moteur WSL 2 (doit être configuré avant le lancement du script) et l'isolation par processus `
            -testsHyper (défaut: `$false): Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur `
                                          patrimonial (legacy) (doit être configuré avant le lancement du script) et l'isolation hyperV par défaut `
            -testsHyperProcessus (défaut: `$false): Booléen controlant l'exécution des tests pour un conteneur utilisant le moteur `
                                                   patrimonial (legacy) (doit être configuré avant le lancement du script) et l'isolation par processus `
            `
            -construire (défaut: `$false): valeur booléenne permettant la construction locale de l'image`
            -help (défaut: `$false): # Affiche une aide simple dans la console pour l'usage du script `
            ";

# Calcul de la mémoire disponible de l'hôte, en GB, en évitant d'utiliser WMI
$memoireDisponible = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb;

# Détermine s'il faut afficher le message d'aide ou exécuter le script
if($help -or (!$testsNatif -and !$testsWSL2 -and !$testsWSL2Processus -and !$testsHyper -and !$testsHyperProcessus -and !$construire)){    
    Write-Output $messageErreur;
}else{
    # Test permettant de valider le nombre de cœurs demande
    if($coeurs -lt 1 -or $coeurs -gt $env:NUMBER_OF_PROCESSORS){
        # Message d'erreur pour un nombre erroné de cœurs
        Write-Output "`
                        Le nombre de cœurs spécifiés doit être entre 1 et le nombre maximum disponible($env:NUMBER_OF_PROCESSORS).`
                    ";
        exit;
    }
    # Test permettant de valider la quantité de mémoire demandée
    if($memoire -lt 1 -or $memoire -gt $memoireDisponible){
        # Message d'erreur pour une quantité de mémoire erronée
        Write-Output "`
                        La mémoire allouée doit se situer entre 1GB (valeur minimale par défaut de Docker) et la quantité totale disponible de l'hôte, soit $memoireDisponible GB.`
                    ";
        exit;
    }

    # Utilisation d'un paramètre non documenté de wrapper du programme Docker
    # pour Windows pour s'assurer que la version Windows de Docker Engine est bien
    # celle qui est actuellement utilisée avant de commencer les opérations. Le 
    # paramètre documenté, SwitchDaemon, ne permet pas de spécifier la version
    # voulu et fait simplement le changement d'une version à l'autre    
    &$env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine;

    # Construction, si nécessaire, de l'image Docker
    if($construire){
        docker build -f Images/Windows/Dockerfile -t jmrteluq/windowstests:2004 -t jmrteluq/windowstests:latest .;
    }

    # Conditionel permettant l'exécution des tests natifs
    if($testsNatif){
        &Scripts\Windows\testsNatifs.ps1 -toutTests $true
    }

    # N.B. Docker n'offre pas d'interface CLI pour changer d'un moteur à l'autre,
    # donc, il faut effectuer le changement manuellement avant de lancer le script

    # Conditionel permettant l'exécution des tests sous moteur WSL 2
    if($testsWSL2){
        # Exécuter le conteneur Docker avec un nombre de cœurs et une mémoire paramétrée et les
        # valeurs paramétrées passées au script du conteneur
        docker run `
        -v "${PWD}\Resultats\2 - Windows (WSL 2):C:\resultats" `
        -m $memoire"g" `
        --cpus $coeurs `
        -it jmrteluq/windowstests `
        powershell `
        .\testsConteneur.ps1 `
        -toutTests `$true;
    }

    # Conditionel permettant l'exécution des tests sous moteur WSL 2 avec isolation par processeur
    if($testsWSL2Processus){
        # Exécuter le conteneur Docker avec un nombre de cœurs et une mémoire paramétrée et les
        # valeurs paramétrées passées au script du conteneur
        docker run `
        -v "${PWD}\Resultats\3 - Windows (WSL 2 - Process):C:\resultats" `
        -m $memoire"g" `
        --cpus $coeurs `
        --isolation=process `
        -it jmrteluq/windowstests `
        powershell `
        .\testsConteneur.ps1 `
        -toutTests `$true;
    }

    # Conditionel permettant l'exécution des tests sous moteur patrimonial HyperV
    if($testsHyper){
        # Exécuter le conteneur Docker avec un nombre de cœurs et une mémoire paramétrée et les
        # valeurs paramétrées passées au script du conteneur
        docker run `
        -v "${PWD}\Resultats\4 - Windows (HyperV):C:\resultats" `
        -m $memoire"g" `
        --cpus $coeurs `
        -it jmrteluq/windowstests `
        powershell `
        .\testsConteneur.ps1 `
        -toutTests `$true;
    }

    # Conditionel permettant l'exécution des tests sous moteur patrimonial HyperV avec isolation par processeur
    if($testsHyperProcessus){
        # Exécuter le conteneur Docker avec un nombre de cœurs et une mémoire paramétrée et les
        # valeurs paramétrées passées au script du conteneur
        docker run `
        -v "${PWD}\Resultats\5 - Windows (HyperV - Process):C:\resultats" `
        -m $memoire"g" `
        --cpus $coeurs `
        --isolation=process `
        -it jmrteluq/windowstests `
        powershell `
        .\testsConteneur.ps1 `
        -toutTests `$true;
    }
    
}
