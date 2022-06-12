# Script permettant la construction et l'utilisation de l'image Docker pour
# effectuer les tests de performance du processeur nécessaire pour évaluer
# la surcharge computationnelle due a l'usage de Docker.

# Définition des paramètres du script
param(

    ######################## Construction d'images #############################

    # Nombre de cœurs assignés au conteneur Docker (Défaut: maximum disponible)
    [int]$coeurs=$env:NUMBER_OF_PROCESSORS,
    # Quantité de mémoire assignée au conteneur Docker (Défaut: 8GB)
    [int]$memoire=8,
    # Est-ce que le script doit construire l'image localement avant d'effectuer
    # les tests?
    [switch]$construire=$false,

    ######################### Environnement d'exécution ########################

    # Paramètre contrôlant l'exécution des tests natifs
    [switch]$testsNatif=$false,

    # Paramètre contrôlant l'exécution des tests pour un conteneur utilisant le
    # moteur WSL 2 (doit être configuré avant le lancement du script) et
    # l'isolation hyperV par défaut
    [switch]$testsWSL2=$false,

    # Paramètre contrôlant l'exécution des tests pour un conteneur utilisant le
    # moteur WSL 2 (doit être configuré avant le lancement du script) et
    # l'isolation par processus
    [switch]$testsWSL2Processus=$false,

    # Paramètre contrôlant l'exécution des tests pour un conteneur utilisant le
    # moteur patrimonial (legacy) (doit être configuré avant le lancement du
    # script) et l'isolation hyperV par défaut
    [switch]$testsHyper=$false,

    # Paramètre contrôlant l'exécution des tests pour un conteneur utilisant le
    # moteur patrimonial (legacy) (doit être configuré avant le lancement du
    # script) et l'isolation par processus
    [switch]$testsHyperProcessus=$false,

    ################################### Tests ##################################

    ########################### Test pour entiers ##############################

    # Paramètre déterminant si le test sur les entiers sera effectué
    [switch]$testEntiers=$false,

    # Booléen déterminant si le test d'entiers sera multicœur
    [bool]$multicoeurEntier=$true,
    # Limite supérieure des nombres premiers recherchés (forme: 10e9)
    [string]$entierLimite=10e9,
    # Nombre entier de répétitions du test pour obtenir une valeur moyenne
    [int]$entierRepetitions=10,
    # Nombre entier d'itérations du test utilisées comme réchauffement
    [int]$entierRechauffement=5,

    ########################### Test pour flottants ############################

    # Paramètre déterminant si le test sur les flottants sera effectué
    [switch]$testFlottants=$false,

    # Booléen déterminant si le test pour les flottants sera multicœur
    [bool]$multicoeurFlottants=$true,
    # Définition du nombre de chiffres de Pi à calculer (25m, 50m, 100m, 250m, 
    # 500m, 1b sont les tailles disponibles avant d'excéder une mémoire vive
    # de 4GB)
    [string]$flottantLimite="25m",
    # Définition du nombre de répétitions à effectuer pour le réchauffement
    [int]$flottantRechauffement=2,
    # Définition du nombre de répétitions à effectuer pour le test
    [int]$flottantRepetitions=1,

    ############################### Test mémoire ###############################

    # Paramètre déterminant si le test sur la mémoire sera effectué
    [switch]$testMemoire=$false,

    # Nombre de variations de taille de problèmes calculées
    [int]$memoireNbrTests=2,
    # Liste des tailles de problèmes calculées
    [string]$memoireTaille="1000 2000",
    # Liste des dimensions correspondantes aux tailles des problèmes
    [string]$memoireDimension="1000 2000",
    # Liste du nombre de répétitions à calculer pour chaque problème
    [string]$memoireRepetition="10 10",
    # Alignement mémoire pour chaque problème
    [string]$memoireAlignement="4 4",

    ######################## Paramètres utilitaires ############################

    # Paramètre permettant d'exécuter tous les tests avec les valeurs par défaut
    # ou spécifiées
    [switch]$toutTests=$false,

    # Affiche une aide simple dans la console pour l'usage du script
    [switch]$help

)

# Fonction de nettoyage pour les fichiers texte de résultats
function nettoyage {

    param(
        $path
    )

    # Nettoyage pour les fichiers du test sur les flottants

    if($testFlottants -or $toutTests){
        # Création d'un fichier conteant les temps de calcul pour toutes les répétitions
        # du test
        Select-String -Path "$path\Pi*.txt" `
        -Pattern '(^Total Computation Time:[\s]+)([\d]+\.[\d]{3})' `
        | Select-Object -Expand Matches `
        | Select-Object -Expand Value `
        | Out-File -FilePath "$path\Flottants$(Get-Date -Format "yyyymmddHHmm").txt"
        # Effacement des fichiers de résultats individuels et du fichier de vérification
        Get-ChildItem $path `
        | Where-Object {$_.Name -Match "Pi*"} `
        | Remove-Item
    }
}

# Message d'erreur affiche lorsque le paramètre -help est invoqué
$messageErreur="`
Le script actuel permet de faciliter la construction et l'utilisation de l'image Docker pour effectuer les tests. `
`
Paramètres: `
`
    ######################## Construction d'images ############################# `
`
    -coeurs (défaut: nombre de processeurs de l'hôte): Nombre de cœurs assignés `
    au conteneur Docker `
    -memoire (défaut: 8): Quantité de mémoire assignée au conteneur Docker `
    -construire: paramètre contrôlant la construction d'une image Docker avant `
    l'exécution des tests `
`
    ######################### Environnements d'exécution ####################### `
`
    -testsNatifs: paramètre contrôlant l'exécution des tests dans `
    l'environnement natif `
`
    -testsWSL2: paramètre contrôlant l'exécution des tests pour un conteneur `
    utilisant le moteur WSL 2 (doit être configuré en utilisant le GUI avant le `
    lancement du script) et utilisant l'isolation HyperV par défaut `
`
    -testsWSL2Processus: paramètre contrôlant l'exécution des tests pour un `
    conteneur utilisant le moteur WSL 2 (doit être configuré en utilisant le `
    GUI avant le lancement du script) et utilisant l'isolation par `
    processus `
    `
    -testsHyper: paramètre contrôlant l'exécution des tests pour un conteneur `
    utilisant le moteur patrimonial (legacy) (doit être configuré en utilisant `
    le GUI avant le lancement du script) et l'isolation HyperV `
    par défaut `
    `
    -testsHyperProcessus: paramètre contrôlant l'exécution des tests pour un `
    conteneur utilisant le moteur patrimonial (legacy) (doit être `
    configuré en utilisant le GUI avant le lancement du script) et l'isolation `
    par processus `
`
################################### Tests ################################## `
`
########################### Test pour entiers ############################## `
`
    Test utilisant le programme primesieve pour calculer les nombres premiers `
    inférieurs à la limite spécifiés `
`
    -testEntiers: paramètre déterminant si le test sur les entiers sera effectué `
`
    -multicoeurEntier (défaut: `$true): Booléen déterminant si le test d'entiers `
    sera multicœur `
    -entierLimite (défaut: 10e9): Limite supérieure des nombres premiers `
    recherchés (forme: 10e9) `
    -entierRepetitions (défaut: 10): Nombre entier de répétitions du test pour `
    obtenir une valeur moyenne `
    -entierRechauffement (défaut: 5): Nombre entier d'itérations du test `
    utilisées comme réchauffement `
`
############################## Test pour flottants ############################ `
`
    Test utilisant le programme y-cruncher pour calculer Pi jusqu'a la position `
    spécifiée `
`
    -testFlottants: paramètre déterminant si le test sur les flottants sera `
    effectué `
`
    -multicoeurFlottants (défaut: `$true): Booléen déterminant si le test pour `
    les flottants sera multicœur `
    -flottantLimite (défaut: '25m'): Définition du nombre de chiffres de Pi `
    à calculer (25m, 50m, 100m, 250m, 500m, 1b sont les tailles disponibles `
    avant d'excéder une mémoire vive de 4GB) `
    -flottantRechauffement (défaut: 2): Définition du nombre de répétitions à `
    effectuer pour le réchauffement `
    -flottantRepetitions (défaut: 1): Définition du nombre de répétitions à `
    effectuer pour le test `
`
################################# Test mémoire ############################### `
`
    Test utilisant le programme LinPack pour résoudre une matrice d'une `
    dimension spécifiée `
`
    -testMemoire: paramètre déterminant si le test sur la mémoire sera effectué `
`
    -memoireNbrTests (défaut: 2): Nombre de variations de taille de problèmes `
    calculées `
    -memoireTaille (défaut: '1000 2000'): Liste des tailles de problèmes `
    calculés `
    -memoireDimension (défaut: '1000 2000'): Liste des dimensions `
    correspondantes aux tailles des problèmes `
    -memoireRepetition (défaut: '10 10'): Liste du nombre de répétitions à `
    calculer pour chaque problème `
    -memoireAlignement (défaut: '4 4'): Alignement mémoire en kB pour chaque `
    problème `
`
######################## Paramètres utilitaires ############################`
`
    -toutTests: paramètre permettant d'exécuter tous les tests avec les valeurs `
    par défaut ou spécifiées `
`
    -help: Affiche une aide simple dans la console pour l'usage du script `
`
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

    # Définition des paramètres de test à exécuter
    # Les paramètres switch sont traités avec l'équivalent d'un opérateur terniaire
    # et les paramètres booléen ou string sont manipulés pour que les valeurs soient
    # correctes après une évaluation par PowerShell
    $paramètresTests = $(if($toutTests){"-toutTests"}else{$null}),
                        $(if($testEntiers){"-testEntiers"}else{$null}),
                        $(if($testFlottants){"-testFlottants"}else{$null}),
                        $(if($testMemoire){"-testMemoire"}else{$null}),
                        "-multicoeurEntier", "`$$multicoeurEntier",
                        "-entierLimite", $entierLimite,
                        "-entierRepetitions", $entierRepetitions,
                        "-entierRechauffement", $entierRechauffement,                        
                        "-multicoeurFlottants", "`$$multicoeurFlottants",
                        "-flottantLimite", "'$flottantLimite'",
                        "-flottantRechauffement", $flottantRechauffement,
                        "-flottantRepetitions", $flottantRepetitions,
                        "-memoireNbrTests", $memoireNbrTests,
                        "-memoireTaille", "'$memoireTaille'",
                        "-memoireDimension", "'$memoireDimension'",
                        "-memoireRepetition", "'$memoireRepetition'", 
                        "-memoireAlignement", "'$memoireAlignement'"

    # Définition des paramètres communs aux conteneurs, incluant le nom du
    # script de test du conteneur
    $paramètresConteneur =  "-m", "$memoire`g",
                            "--cpus", "$coeurs",
                            "-it",
                            "jmrteluq/windowstests",
                            "powershell",
                            ".\testsConteneur.ps1"
    
    # Conditionel permettant l'exécution des tests natifs utilisant les paramètres
    # par défaut ou spécifiés
    if($testsNatif){
        Invoke-Expression "Scripts\Windows\testsNatifs.ps1 $paramètresTests"
        Nettoyage "Resultats\1 - Windows (Natif)"
    }

    # N.B. Docker n'offre pas d'interface CLI pour changer d'un moteur à l'autre,
    # donc, il faut effectuer le changement manuellement avant de lancer le script

    # Conditionel permettant l'exécution des tests sous moteur WSL 2
    if($testsWSL2){
        # Exécuter le conteneur Docker avec les paramètres de test et de conteneur
        # défini
        docker run `
        -v "${PWD}\Resultats\2 - Windows (WSL 2):C:\resultats" `
        $paramètresConteneur `
        $paramètresTests
        Nettoyage "Resultats\2 - Windows (WSL 2)"
    }

    # Conditionel permettant l'exécution des tests sous moteur WSL 2 avec isolation par processeur
    if($testsWSL2Processus){
        # Exécuter le conteneur Docker avec les paramètres de test et de conteneur
        # défini
        docker run `
        -v "${PWD}\Resultats\3 - Windows (WSL 2 - Process):C:\resultats" `
        --isolation=process `
        $paramètresConteneur `
        $paramètresTests
        Nettoyage "Resultats\3 - Windows (WSL 2 - Process)"
    }

    # Conditionel permettant l'exécution des tests sous moteur patrimonial HyperV
    if($testsHyper){
        # Exécuter le conteneur Docker avec les paramètres de test et de conteneur
        # défini
        docker run `
        -v "${PWD}\Resultats\4 - Windows (HyperV):C:\resultats" `
        $paramètresConteneur `
        $paramètresTests
        Nettoyage "Resultats\4 - Windows (HyperV)"
    }

    # Conditionel permettant l'exécution des tests sous moteur patrimonial HyperV avec isolation par processeur
    if($testsHyperProcessus){
        # Exécuter le conteneur Docker avec les paramètres de test et de conteneur
        # défini
        docker run `
        -v "${PWD}\Resultats\5 - Windows (HyperV - Process):C:\resultats" `
        --isolation=process `
        $paramètresConteneur `
        $paramètresTests
        Nettoyage "Resultats\5 - Windows (HyperV - Process)"
    }
    
}
