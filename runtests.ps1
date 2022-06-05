# Script permettant la construction et l'utilisation de l'image Docker pour
# effectuer les tests de performance du processeur nécessaire pour évaluer
# la surcharge computationnelle due a l'usage de Docker.

# Définition des paramètres du script
param(
    # Nombre de cœurs assignés au conteneur Docker (Défaut: maximum disponible)
    [int]$cœurs=$env:NUMBER_OF_PROCESSORS,
    # Quantité de mémoire assignée au conteneur Docker (Défaut: 8GB)
    [int]$memoire=8,
    # Est-ce que le script doit construire l'image localement avant d'effectuer
    # les tests?
    [bool]$construire=$false,
    # Affiche une aide simple dans la console pour l'usage du script
    [switch]$help
)

# Message d'erreur affiche lorsque le paramètre -help est invoqué
$messageErreur="`
`
Le script actuel permet de faciliter la construction et l'utilisation de l'image Docker pour effectuer les tests. `
`
Usage: .\constructeurImage.ps1 -cœurs -memoire -construire`
`
Paramètres: -cœurs (défaut: maximum disponible): nombre de processeurs logiques assignés au conteneur utilisant l'image `
            -memoire (défaut: 8): quantité de mémoire, en GB, assignée au conteneur utilisant l'image `
            -construire (défaut: $false): valeur booléenne permettant la construction locale de l'image`
            `
            ";

# Calcul de la mémoire disponible de l'hôte, en GB, en évitant d'utiliser WMI
$memoireDisponible = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb;

# Détermine s'il faut afficher le message d'aide ou exécuter le script
if($help){    
    Write-Output $messageErreur;
}else{
    # Test permettant de valider le nombre de cœurs demande
    if($cœurs -lt 1 -or $cœurs -gt $env:NUMBER_OF_PROCESSORS){
        # Message d'erreur pour un nombre erroné de cœurs
        Write-Output "`
Le nombre de cœurs spécifiés doit être entre 1 et le nombre maximum disponible($env:NUMBER_OF_PROCESSORS).`
";
        exit;
    }
    # Test permettant de valider la quantité de mémoire demandée
    if($mémoire -lt 1 -or $mémoire -gt $memoireDisponible){
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
    # Exécuter le conteneur Docker avec un nombre de cœurs et une mémoire paramétrée et les
    # valeurs paramétrées passées au script du conteneur
    docker run `
    -v "${PWD}\Resultats\2 - Windows (Docker):C:\resultats" `
    -m $mémoire"g" `
    --cpus $coeurs `
    --isolation=process `
    -it jmrteluq/windowstests `
    powershell `
    .\testsConteneur.ps1 `
    -toutTests `$true;
}


