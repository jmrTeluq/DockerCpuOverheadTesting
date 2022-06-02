# Script permettant la construction et l'utilisation de l'image Docker pour
# effecter les tests de performance du processeurs necessaire pour evaluer
# la surcharge computatitonnelle due a l'usage de Docker.

# Definition des parametres du script
param(
    # Nombre de coeurs assignes au conteneur Docker (Defaut: maximum disponible)
    [int]$coeurs=$env:NUMBER_OF_PROCESSORS,
    # Quantite de memoire assignee au conteneur Docker (Defaut: 8GB)
    [int]$memoire=8,
    # Est-ce que le script doit construire l'image localement avant d'effectuer
    # les tests?
    [bool]$construire=$false,
    # Affiche une aide simple dans la console pour l'usage du script
    [switch]$help
)

# Message d'erreur affiche lorsque le parametre -help est invoque
$messageErreur="`
`
Le script actuel permet de faciliter la construction et l'utilisation de l'image Docker pour effectuer les tests. `
`
Usage: .\constructeurImage.ps1 -coeurs -memoire -construire`
`
Parametres: -coeurs (defaut: maximum disponible): nombre de processeurs logiques assignes au conteneur utilisant l'image `
            -memoire (defaut: 8): quantite de memoire, en GB, assignee au conteneur utilisant l'image `
            -construire (defaut: $false): valeur booleenne permettant la construction locale de l'image`
            `
            ";

# Calcul de la memoire disponible de l'hote, en GB, en evitant d'utiliser WMI
$memoireDisponible = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb;

# Determine s'il faut afficher le message d'aide ou executer le script
if($help){    
    Write-Output $messageErreur;
}else{
    # Test permettant de valider le nombre de coeurs demande
    if($coeurs -lt 1 -or $coeurs -gt $env:NUMBER_OF_PROCESSORS){
        # Message d'erreur pour un nombre errone de coeurs
        Write-Output "`
Le nombre de coeurs specifies doit etre entre 1 et le nombre maximum disponible($env:NUMBER_OF_PROCESSORS).`
";
        exit;
    }
    # Test permettant de valider la quantite de memoire demandee
    if($memoire -lt 1 -or $memoire -gt $memoireDisponible){
        # Message d'erreur pour une quantite de memoire erronee
        Write-Output "`
La memoire allouee doit se situer entre 1GB (valeur minimale par defaut de Docker) et la quantite totale disponible de l'hote, soit $memoireDisponible GB.`
        ";
        exit;
    }
    # Construction, si necessaire, de l'image Docker
    if($construire){
        docker build -f Images/Windows/Dockerfile -t jmrteluq/windowstests:2004 -t jmrteluq/windowstests:latest .;
    }
    # Exécuter le conteneur Docker avec un nombre de coeurs et une mémoire paramétrée et les
    # valeurs paramétrées passée au script du conteneur
    docker run -v "${PWD}\Resultats\2 - Windows (Docker):C:\resultats" -m $memoire"g" --cpus $coeurs -it jmrteluq/windowstests powershell .\runme.ps1 -coeurs $coeurs -memoire $memoire;
}


