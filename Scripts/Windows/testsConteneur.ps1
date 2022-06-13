param(

    ############# Test pour entiers ##################

    # Booléen déterminant si le test sur les entiers sera effectué
    [switch]$testEntiers=$false,

    # Booléen déterminant si le test d'entiers sera multicœur
    [bool]$multicoeurEntier=$true,
    # Limite supérieure des nombres premiers recherchés (forme: 10e9)
    [string]$entierLimite=10e9,
    # Nombre entier de répétitions du test pour obtenir une valeur moyenne
    [int]$entierRepetitions=10,
    # Nombre entier d'itérations du test utilisées comme réchauffement
    [int]$entierRechauffement=5,

    ########### Test pour flottants ##################

    # Booléen déterminant si le test sur les flottants sera effectué
    [switch]$testFlottants=$false,

    # Booléen déterminant si le test pour les flottants sera multicœur
    [bool]$multicoeurFlottants=$true,
    # Définition du nombre de chiffres de Pi à calculer (25m, 50m, 100m, 250m, 
    # 500m,1b sont les tailles disponibles avant d'excéder une mémoire vive de 4GB)
    [string]$flottantLimite="25m",
    # Définition du nombre de répétitions à effectuer pour le réchauffement
    [int]$flottantRechauffement=2,
    # Définition du nombre de répétitions à effectuer pour le test
    [int]$flottantRepetitions=1,

    ########### Test mémoire ####################

    # Booléen déterminant si le test sur la mémoire sera effectué
    [switch]$testMemoire=$false,

    # Nombre de variations de taille de problèmes calculées
    [int]$memoireNbrTests=2,
    # Liste des tailles de problèmes calculées
    [string]$memoireTaille="1000 2000",
    # Liste des dimensions correspondantes au tailles des problèmes
    [string]$memoireDimension="1000 2000",
    # Liste du nombre de répétitions à calculer pour chaque problème
    [string]$memoireRepetition="10 10",
    # Alignement mémoire pour chaque problème
    [string]$memoireAlignement="4 4",

    ########### Paramètres utilitaires ###########

    # Booléen permettant d'exécuter tous les tests avec les valeurs par défaut
    # ou spécifiées
    [switch]$toutTests=$false,
    
    # Paramètre permettant l'affichage du texte d'aide
    [switch]$help=$false
)

$messageAide=@"

############## Script de test pour l'environnement natif ######################

############# Test pour entiers ##################

Test utilisant le programme primesieve pour calculer les nombres premiers inférieurs
à la limite spécifiés

    -testEntiers: paramètre déterminant si le test sur les entiers sera effectue

    -multicoeurEntier: Booleen déterminant si le test d'entiers sera multicœur (Défaut: `$true)
    -entierLimite: Limite supérieure des nombres premiers recherches (forme: 10e9) (Défaut: 10e9)
    -entierRepetitions: Nombre entier de répétitions du test pour obtenir une valeur moyenne (Défaut: 10)
    -entierRechauffement: Nombre entier d'itérations du test utilisées comme réchauffement (Défaut: 5)

########### Test pour flottants ##################

Test utilisant le programme y-cruncher pour calculer Pi jusqu'a la position spécifiée

    -testFlottants: paramètre déterminant si le test sur les flottants sera effectué

    -multicoeurFlottants: Booléen déterminant si le test pour les flottants sera multicœur (Défaut: `$true)
    -flottantLimite: Définition du nombre de chiffres de Pi à calculer (forme: '25m') (Défaut: '25m')
    -flottantRechauffement: Définition du nombre de répétitions à effectuer pour le réchauffement (Défaut: 2)
    -flottantRepetitions: Définition du nombre de répétitions à effectuer pour le test (Défaut: 1)

########### Test mémoire ####################

Test utilisant le programme LinPack pour résoudre une matrice d'une dimension spécifiée

    -testMemoire: paramètre déterminant si le test sur la mémoire sera effectué

    -memoireNbrTests: Nombre de variations de taille de problèmes calculées (Défaut: 2)
    -memoireTaille: Liste des tailles de problèmes calculées (Défaut: '1000 2000')
    -memoireDimension: Liste des dimensions correspondantes aux tailles des problèmes (Défaut: '1000 2000')
    -memoireRepetition: Liste du nombre de répétitions à calculer pour chaque problème (Défaut: '10 10')
    -memoireAlignement: Alignement mémoire pour chaque problème (Défaut: '4 4')

########### Paramètres utilitaires ###########

Paramètres utilitaires pour faciliter l'usage du script

    -toutTests: paramètre permettant d'exécuter tous les tests avec les valeurs par défaut ou spécifiées

    -help: Paramètre permettant l'affichage du texte d'aide
    
"@

if($help){
    Write-Output $messageAide
}else{
    ################ Définitions des adresses nécessaires #########################

    # Adresse pour l'outil primesieve
    $testEntiersAdr="tests\entiers"

    # Adresse pour l'outil y-cruncher
    $testFlottantsAdr="tests\flottants"

    # Adresse pour l'outil linpack
    $testMemoireAdr="tests\memoire"

    # Adresse pour les résultats
    $resultatsAdr="resultats"

    if($testEntiers -or $toutTests){

        ######################### Tests sur les entiers  ###########################

        # Les expressions suivantes permettent de calculer tous les nombres premiers
        # inférieur à la limite spécifiée. La documentation pour les paramètres
        # vient du fichier readme.txt incus avec le programme.

        # Définition d'un nom unique basé sur la date pour le fichier de résultats
        $resultatsEntiersNom="Entiers" + (Get-Date -Format "yyyymmddHHmm")

        # Boucle d'exécution du réchauffement où les résultats et l'affichage sont
        # ignorés
        for($i=1; $i -le $entierRechauffement; $i++){
            &$testEntiersAdr\primesieve.exe `
            $entierLimite `
            -c `
            --quiet `
            $(if($multicoeurEntier){$null}else{"--threads=1"}) `
            > $null
        }

        # Boucle de test où les résultats sont acheminés dans le fichier texte approprié
        # du dossier de résultats
        for($i=1; $i -le $entierRepetitions; $i++){
            &$testEntiersAdr\primesieve.exe `
            $entierLimite `
            -c `
            --quiet `
            --time `
            $(if($multicoeurEntier){$null}else{"--threads=1"}) `
            | Out-File -FilePath "$resultatsAdr\$resultatsEntiersNom.txt" `
            -Encoding utf8 `
            -Append
        }
    }

    if($testFlottants -or $toutTests){

        ##################### Test sur les flottants  ##############################

        # Les expressions suivantes permettant de calculer Pi avec un seul processeur
        # ou tous les processeurs disponibles, respectivement. La documentation pour
        # les paramètres viennent du fichier Command Lines.txt inclus avec le programme.

        # Boucle d'exécution du réchauffement où les résultats sont ignorés
        for($i=1; $i -le $flottantRechauffement; $i++){
            # On note ici un problème de redirection avec Powershell. En effet, 
            # idéalement, la sortie du programme pourrait être capturée dans un
            # fichier texte, mais la façon dont le programme gère son affichage rend
            # cette capture problématique. Ainsi, la sortie du programme est
            # simplement redirigée vers null.
            &"$testFlottantsAdr\y-cruncher.exe" `
            skip-warnings `
            priority:3 `
            bench `
            $flottantLimite `
            $(if($multicoeurFlottants){$null}else{"-TD:1 -PF:none"}) `
            -o "$resultatsAdr" `
            > $null
        }

        # Effacement des fichiers de réchauffement mais pas du fichier de validation
        Get-ChildItem $resultatsAdr `
        | Where-Object {$_.Name -Match "Pi - [0-9-]{15,15}.txt"} `
        | Remove-Item

        # Boucle de test où les résultats sont acheminés dans les fichiers texte
        # appropriés du dossier de résultats
        for($i=1; $i -le $flottantRepetitions; $i++){
            # Même problème de redirection que pour la boucle de réchauffement
            &"$testFlottantsAdr\y-cruncher.exe" `
            skip-warnings `
            priority:3 `
            bench `
            $flottantLimite `
            $(if($multicoeurFlottants){$null}else{"-TD:1 -PF:none"}) `
            -o "$resultatsAdr" `
            > $null
        }

    }if($testMemoire -or $toutTests){
        
        ################## Test sur la mémoire   ###################################

        # Nom du fichier de configuration généré par les paramètres fournis
        $ficherConfig="$testMemoireAdr\config.txt"

        # Nom du fichier de résultats
        $fichierResultats="$resultatsAdr\Memoire$(Get-Date -Format "yyyymmddHHmm").txt"

        #### Génération du fichier de configuration respectant la norme du programme####

        # 1) Ligne de commentaire qui sera ignorée par le programme
        "# Ligne ignorée par le programme" | `
        Out-File -FilePath $ficherConfig -Encoding utf8
        # 2) Ligne qui sera utilisée comme en-tête du fichier de résultats
        "# Résultat du test Linpack optimise pour Intel" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append
        # 3) Ligne indiquant le nombre de problèmes
        "$memoireNbrTests # nombre de problèmes" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append
        # 4) Ligne indiquant la taille des problèmes
        "$memoireTaille # tailles des problèmes" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append
        # 5) Ligne indiquant les dimensions des problèmes
        "$memoireDimension # dimensions" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append
        # 6) Ligne indiquant le nombre de répétitions pour chaque problème
        "$memoireRepetition # nombre de répétitions par problème" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append
        # 7) Ligne indiquant l'alignement de mémoire pour chaque problème
        "$memoireAlignement # alignement en kB" | `
        Out-File -FilePath $ficherConfig -Encoding utf8 -Append

        # Variable environnementale utilisée pour maximiser la performance de la
        # bibliothèque utilisée par le test
        # noverbose (équivalent au nowarnings utilisé dans l'exemple): affichage
        # des propriétés du système relatives au processeur
        # compact: relatif à la densité des fils par rapport aux cœurs (alternatives
        # scatter et none)
        # premier chiffre: permute: valeur par défaut 0, contrôle le mappage entre la
        # topologie du système et le nombre de niveaux
        # deuxième chiffre: offset: valeur par défaut 0, contrôle la position du premier
        # fil à assigner
        # granularity: contrôle le niveau d'accès de la bibliothèque à la topologie du
        # système (alternatives core et thread)
        # Référence: https://www.cita.utoronto.ca/~merz/intel_c10b/main_cls/mergedProjects/optaps_cls/common/optaps_openmp_thread_affinity.htm
        $env:KMP_AFFINITY="noverbose,scatter,0,0,granularity=fine"

        # Exécution du test en utilisant le fichier de configuration créé et le fichier de 
        # résultats spécifié
        &$testMemoireAdr\linpack_xeon64.exe $ficherConfig | `
        Out-File -FilePath $fichierResultats -Encoding utf8

        # Remise à zéro des variables environnementales définies pour le test
        $env:KMP_AFFINITY=$null
    }
}

