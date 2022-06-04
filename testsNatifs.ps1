param(
)

################ Définitions des adresses nécessaires #########################

# Adresse pour l'outil primesieve
$testEntiersAdr="Outils\entiers\Windows\primesieve-7.9-win-x64"

# Adresse pour l'outil y-cruncher
$testFlottantsAdr="Outils\flottants\Windows\y-cruncher v0.7.9.9509"

# Adresse pour l'outil linpack
$testMemoireAdr="Outils\memoire\Windows\linpack"

# Adresse pour les résultats
$resultatsAdr="Resultats\1 - Windows (Natif)"
<#
######################### Tests sur les entiers  ##############################

# Définition d'un nom unique basé sur la date pour le fichier de résultats
$resultatsEntiersNom=Entiers(Get-Date -Format "yyyymmddHHmm")

# Définition de la limite jusqu'à laquelle le programme primesieve va chercher
# des nombres premiers
$entierLimite=10e9

# Définition du nombre de répétitions à effectuer pour obtenir une valeur moyenne
# représentative du temps de test
$entierRepetitions=10

# Définition du nombre de répétitions à effectuer pour la phase de réchauffement
$entierRechauffement=5

# Boucle d'exécution du réchauffement où les résultats sont ignorés
for($i=1; $i -le $entierRechauffement; $i++){
    &$testEntiersAdr\primesieve.exe $entierLimite `
    -c `
    --quiet
}

# Boucle de test où les résultats sont acheminés dans le fichier texte approprié
# du dossier de résultats
for($i=1; $i -le $entierRepetitions; $i++){
    &$testEntiersAdr\primesieve.exe `
    $entierLimite `
    -c `
    --quiet `
    --time `
    >> $resultatsAdr\$resultatsEntiersNom.txt
}

##################### Test sur les flottants  #################################

# Les expressions suivantes permettant de calculer Pi avec un seul processeur et
# tous les processeurs disponibles, respectivement. La documentation pour les
# paramètres vient du fichier Command Lines.txt inclus avec le programme.

# Booléen commandant un test multiprocesseur
$testFlottantsMulti=$true

# Définition du nombre de chiffres de Pi à calculer (25m, 50m, 100m, 250m, 500m,1b sont les tailles disponibles avant
# d'excéder une mémoire vive de 4GB)
$flottantLimite="25m"

# Définition de l'adresse du programme
$testFlottantProgram="$testFlottantsAdr\y-cruncher.exe"

# Définition des paramètres nécessaires au programme pour agir comme multiprocesseur
# ou comme processeur unique
if($testFlottantsMulti){
    $params=@("skip-warnings", "priority:3", "bench", $flottantLimite, "-o", "$resultatsAdr")
}else{
    $params=@("skip-warnings", "priority:3", "bench", $flottantLimite, "-TD:1", "-PF:none", "-o", "$resultatsAdr")
}

# Définition du nombre de répétitions à effectuer pour le réchauffement
$flottantRechauffement=5

# Définition du nombre de répétitions à effectuer pour le test
$flottantRepetitions=10

# Boucle d'exécution du réchauffement où les résultats sont ignorés
for($i=1; $i -le $flottantRechauffement; $i++){
    # On note ici un problème de redirection avec Powershell. En effet, idéalement,
    # la sortie du programme pourrait être capturée dans un fichier texte, mais la
    # façon dont le programme gère son affichage rend cette capture problématique.
    # Ainsi, la sortie du programme est simplement redirigée vers null.
    &$testFlottantProgram $params > $null
}

# Effacement des fichiers de réchauffement
Get-ChildItem $resultatsAdr | Where-Object {$_.Name -Match "Pi - [0-9-]{15,15}.txt"} | Remove-Item

# Boucle de test où les résultats sont acheminés dans les fichiers texte appropriés
# du dossier de résultats
for($i=1; $i -le $flottantRepetitions; $i++){
    # Même problème de redirection que pour la boucle de réchauffement
    &$testFlottantProgram $params > $null
}
#>

################## Test sur la mémoire   ###################################

$memoireNbrTests=2

$memoireTaille=@(1000,2000)

$memoireDimension=@(1000,2000)

$memoireRepetition=@(10,10)

$memoireAlignement=@(4,4)

$ficherConfig="$testMemoireAdr\config.txt"

$fichierResultats="$resultatsAdr\memoire.txt"

"# Ligne ignoree par le programme" | `
Out-File -FilePath $ficherConfig -Encoding utf8
"# Resultat du test Linpack optimise pour Intel" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append
"$memoireNbrTests # nombre de problemes" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append
($memoireTaille -join " ") + " # tailles des problemes" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append
($memoireDimension -join " ") + " # dimensions" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append
($memoireRepetition -join " ") + " # nombre de repetitions par probleme" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append
($memoireAlignement -join " ") + " # allignement en kB" | `
Out-File -FilePath $ficherConfig -Encoding utf8 -Append

$env:KMP_AFFINITY="noverbose,compact,1,3,granularity=fine"

&$testMemoireAdr\linpack_xeon64.exe $ficherConfig | `
Out-File -FilePath $fichierResultats -Encoding utf8

$env:KMP_AFFINITY=$null
