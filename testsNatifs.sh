#!/bin/bash

########### Fonction d'aide ########################
Aide(){
    # Affichage d'un message d'aide
    echo "Menu d'aide"
}

########### Valeurs par défaut des paramètres ###################

############# Test pour entiers ##################

    # Booléen déterminant si le test sur les entiers sera effectué
    testEntiers=${testEntiers:-false}
    # Booléen déterminant si le test d'entiers sera multicœur
    multicoeurEntier=${multicoeurEntier:-true}
    # Limite supérieure des nombres premiers recherchés (forme: 10e9)
    entierLimite=${entierLimite:-"10e9"}
    # Nombre entier de répétitions du test pour obtenir une valeur moyenne
    entierRepetitions=${entierRepetitions:-10}
    # Nombre entier d'itérations du test utilisées comme réchauffement
    entierRechauffement=${entierRechauffement:-5}

############# Test pour flottants ##################

    # Booléen déterminant si le test sur les flottants sera effectué
    testFlottants=${testFlottants:-false}
    # Booléen déterminant si le test pour les flottants sera multicœur
    multicoeurFlottants=${multicoeurFlottants:-true}
    # Définition du nombre de chiffres de Pi à calculer (25m, 50m, 100m, 250m, 
    # 500m,1b sont les tailles disponibles avant d'excéder une mémoire vive de 4GB)
    flottantLimite=${flottantLimite:-"25m"}
    # Définition du nombre de répétitions à effectuer pour le réchauffement
    flottantRechauffement=${flottantRechauffement:-2}
    # Définition du nombre de répétitions à effectuer pour le test
    flottantRepetitions=${flottantRepetitions:-1}

########### Test mémoire ####################

    # Booléen déterminant si le test sur la mémoire sera effectué
    testMemoire=${testMemoire:-false}
    # Nombre de variations de taille de problèmes calculées
    memoireNbrTests=${memoireNbrTests:-2}
    # Liste des tailles de problèmes calculées
    memoireTaille=${memoireTaille:-"1000 2000"}
    # Liste des dimensions correspondantes au tailles des problèmes
    memoireDimension=${memoireDimension:-"1000 2000"}
    # Liste du nombre de répétitions à calculer pour chaque problème
    memoireRepetition=${memoireRepetition:-"10 10"}
    # Alignement mémoire pour chaque problème
    memoireAlignement=${memoireAlignement:-"4 4"}

############# Paramètres utilitaires ##################

    # Paramètre controlant l'affichage du menu d'aide
    help=${help:-false}
    # Booléen controlant l'exécution de tous les tests
    toutTests=${toutTests:-false}

# Les scripts bash n'ont pas de fonctionalité native similaire à PowerShell
# en ce qui concerne les arguments nommés. On peut toutefois émuler cette
# fonctionnalité en utilisant plusieurs approches. L'approche choisie ici, soit
# celle d'une boucle basée sur la décomposition itérative des arguments nommés
# utilisant la syntaxe -- vient de la référence suivante et est choisie pour
# sa simplicité et sa compatibilité.
# Référence: https://www.brianchildress.co/named-parameters-in-bash/

# tant qu'il y a des arguments
while [ $# -gt 0 ]; do

    # si le premier argument commence par --
    if [[ $1 == *"--"* ]]; then
        # substitution de -- par null pour obtenir le nom du paramètre
        param="${1/--/}"
        # assignation de la valeur donné au nom obtenu
        declare $param="$2"
    fi
    # fonction bash native passant au prochain argument
    shift
done

if [[ $help != "false" ]]; then
    Aide
    exit 0
fi

################ Définitions des adresses nécessaires #########################

# Adresse pour l'outil y-cruncher
testFlottantsAdr="Outils/flottants/Linux/y-cruncher v0.7.9.9509-static"

# Adresse pour l'outil linpack
testMemoireAdr="Outils/memoire/Linux/linpack"

# Adresse pour les résultats
resultatsAdr="Resultats/6 - Linux (Natif)"

############### Test sur les entiers ###########################

# Test permettant de n'exécuter les tests pour entier que lorsque nécessaires
if [[ $testEntiers != "false" || $toutTests != "false" ]]; then
    # Définition d'un nom unique basé sur la date pour le fichier de résultats
    resultatsEntiersNom="Entiers$(date +"%Y%m%d%H%M").txt"

    # Boucle de réchauffement dont les résultats sont ignorés
    for ((i = 1 ; i <= $entierRechauffement ; i++)); do
        primesieve \
        $entierLimite -c \
        $([[ $multicoeurEntier == "true" ]] \
                                    && echo "" \
                                    || echo "--threads=1") \
        >> /dev/null
    done

    # Boucle de test envoyant les résultats dans un fichier texte au nom généré
    for ((i = 1 ; i <= $entierRepetitions ; i++)); do
        primesieve \
        $entierLimite -c \
        --quiet \
        --time \
        $([[ $multicoeurEntier == "true" ]] \
                                    && echo "" \
                                    || echo "--threads=1") \
        >> "$resultatsAdr/$resultatsEntiersNom"
    done
fi

##################### Test sur les flottants  ##############################

# Test permettant de n'exécuter les tests pour flottants que lorsque nécessaires
if [[ $testFlottants != "false" || $toutTests != "false" ]]; then

    # Boucle d'exécution du réchauffement où les résultats sont ignorés
    for ((i=1; i <= $flottantRechauffement; i++)); do
        "$testFlottantsAdr/y-cruncher" \
        skip-warnings \
        priority:0 \
        bench \
        $flottantLimite \
        $([[ $multicoeurFlottants == "true" ]] \
        && echo "" \
        || echo "-TD:1 -PF:none") \
        -o "$resultatsAdr" \
        >> /dev/null
    done

    # Effacement des fichiers de réchauffement
    find "$resultatsAdr" -type f -name 'Pi - 2*.txt' -delete

    # Boucle d'exécution de test où les résultats sont acheminés dans le dossier
    # approprié et l'affichage des sorties du programmes durant son exécution
    # sont sauvegardés à des fins diagnostiques dans un fichier séparé.
    for ((i=1; i <= $flottantRepetitions; i++)); do
        "$testFlottantsAdr/y-cruncher" \
        skip-warnings \
        priority:0 \
        bench \
        $flottantLimite \
        $([[ $multicoeurFlottants == "true" ]] \
        && echo "" \
        || echo "-TD:1 -PF:none") \
        -o "$resultatsAdr" \
        >> "$resultatsAdr/detailsFlottants"
    done
fi

##################### Test sur la mémoire  ##############################

if [[ $testMemoire != "false" || $toutTests != "false" ]]; then

    # Nom du fichier de configuration généré par les paramètres fournis
    fichierConfig="$resultatsAdr/config.txt"

    # Nom du fichier de résultats
    fichierResultats="$resultatsAdr/Memoire$(date +"%Y%m%d%H%M").txt"

    #### Génération du fichier de configuration respectant la norme du programme####

    # 1) Ligne de commentaire qui sera ignorée par le programme
    echo "# Ligne ignorée par le programme" > "$fichierConfig"
    # 2) Ligne qui sera utilisée comme en-tête du fichier de résultats
    echo "# Résultat du test Linpack optimisé pour Intel" >> "$fichierConfig"
    # 3) Ligne indiquant le nombre de problèmes
    echo "$memoireNbrTests # nombre de problèmes" >> "$fichierConfig"
    # 4) Ligne indiquant la taille des problèmes
    echo "$memoireTaille # tailles des problèmes" >> "$fichierConfig"
    # 5) Ligne indiquant les dimensions des problèmes
    echo "$memoireDimension # dimensions" >> "$fichierConfig"
    # 6) Ligne indiquant le nombre de répétitions pour chaque problème
    echo "$memoireRepetition # nombre de répétitions par problème" >> "$fichierConfig"
    # 7) Ligne indiquant l'alignement de mémoire pour chaque problème
    echo "$memoireAlignement # alignement en kB" >> "$fichierConfig"

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
    export KMP_AFFINITY=noverbose,compact,1,3,granularity=fine

    #"$testMemoireAdr/xlinpack_xeon64" $fichierConfig

    $testMemoireAdr/xlinpack_xeon64 "$fichierConfig"

fi