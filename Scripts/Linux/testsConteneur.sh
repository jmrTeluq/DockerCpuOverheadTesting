#!/bin/bash

########### Fonction d'aide ########################
Aide(){
    # Affichage d'un message d'aide
    echo "Le script actuel permet de réaliser des tests de performance de processeur"
    echo "en utilisant un, ou plusieurs, programmes différents."
    echo ""
    echo "Programmes:"
    echo ""
    echo "primesieve 7.9: opérations sur les entiers en calculant des nombres premiers"
    echo "y-cruncher 7.9.9509: opérations sur les flottants en calculant Pi jusqu'à"
    echo "une précision définie"
    echo "Intel LinPack 2022-0-2-84: opérations de résolution d'une matrice pour"
    echo "tester l'utilisation de la mémoire vive"
    echo ""
    echo "Paramètres:"
    echo ""
    echo "############# Test pour entiers ##################"
    echo ""
    echo "--testEntiers (Défaut: false): Booléen déterminant si le test sur les entiers sera effectué"
    echo ""
    echo "--multicoeurEntier (Défaut: true): Booléen déterminant si le test d'entiers sera multicœur"
    echo "--entierLimite (Défaut: \"10e9\"): Limite supérieure des nombres premiers recherchés"
    echo "--entierRepetitions (Défaut: 10): Nombre entier de répétitions du test pour obtenir une valeur moyenne"
    echo "--entierRechauffement (Défaut: 5): Nombre entier d'itérations du test utilisées comme réchauffement"
    echo ""
    echo "############# Test pour flottants ##################"
    echo ""
    echo "--testFlottants (Défaut: false): Booléen déterminant si le test sur les flottants sera effectué"
    echo ""
    echo "--multicoeurFlottants (Défaut: true): Booléen déterminant si le test pour les flottants sera multicœur"
    echo "--flottantLimite (Défaut: \"25m\"): Définition du nombre de chiffres de Pi à calculer (25m, 50m, 100m, 250m...)"
    echo "--flottantRechauffement (Défaut: 2): Définition du nombre de répétitions à effectuer pour le réchauffement"
    echo "--flottantRepetitions (Défaut: 1): Définition du nombre de répétitions à effectuer pour le test"
    echo ""
    echo "########### Test mémoire ####################"
    echo ""
    echo "--testMemoire (Défaut: false): Booléen déterminant si le test sur la mémoire sera effectué"
    echo ""
    echo "--memoireNbrTests (Défaut: 2): Nombre de variations de taille de problèmes calculées"
    echo "--memoireTaille (Défaut: \"1000 2000\"): Liste des tailles de problèmes calculées"
    echo "--memoireDimension (Défaut: \"1000 2000\"): Liste des dimensions correspondantes aux tailles des problèmes"
    echo "--memoireRepetition (Défaut: \"10 10\"): Liste du nombre de répétitions à calculer pour chaque problème"
    echo "--memoireAlignement (Défaut: \"4 4\"): Alignement mémoire pour chaque problème"
    echo ""
    echo "############# Paramètres utilitaires ##################"
    echo ""
    echo "--help (Défaut: false): Paramètre contrôlant l'affichage du menu d'aide"
    echo ""
    echo "--toutTests (Défaut: false): Booléen contrôlant l'exécution séquentielle de tous les tests"
    echo ""
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
    # Liste des dimensions correspondantes aux tailles des problèmes
    memoireDimension=${memoireDimension:-"1000 2000"}
    # Liste du nombre de répétitions à calculer pour chaque problème
    memoireRepetition=${memoireRepetition:-"10 10"}
    # Alignement mémoire pour chaque problème
    memoireAlignement=${memoireAlignement:-"4 4"}

############# Paramètres utilitaires ##################

    # Paramètre contrôlant l'affichage du menu d'aide
    help=${help:-false}
    # Booléen contrôlant l'exécution de tous les tests
    toutTests=${toutTests:-false}

# Les scripts bash n'ont pas de fonctionnalités natives similaires à PowerShell
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
        # assignation de la valeur donnée au nom obtenu
        declare $param="$2"
    fi
    # fonction bash native passant au prochain argument
    shift
done

if [[ $help != "false" || ($testEntiers == "false" && $testFlottants == "false" && $testMemoire == "false" && $toutTests == "false") ]]; then
    Aide
    exit 0
fi

################ Définitions des adresses nécessaires #########################

# Adresse pour l'outil y-cruncher
testFlottantsAdr="/tests/flottants"

# Adresse pour l'outil linpack
testMemoireAdr="/tests/mémoire"

# Adresse pour les résultats
resultatsAdr="/résultats"

############### Test sur les entiers ###########################

# Test permettant de n'exécuter les tests pour entier que lorsque nécessaire
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

# Test permettant de n'exécuter les tests pour flottants que lorsque nécessaire
if [[ $testFlottants != "false" || $toutTests != "false" ]]; then

    # Boucle d'exécution du réchauffement où les résultats sont ignorés
    # N. B. la valeur de priorité "3" n'est pas documentée mais, lorsque combinée
    # avec sudo, permet une priorité RT
    for ((i=1; i <= $flottantRechauffement; i++)); do
        "$testFlottantsAdr/y-cruncher" \
        skip-warnings \
        priority:3 \
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
    # approprié
    # N. B. la valeur de priorité "3" n'est pas documentée mais, lorsque combinée
    # avec sudo, permet une priorité RT
    for ((i=1; i <= $flottantRepetitions; i++)); do
        "$testFlottantsAdr/y-cruncher" \
        skip-warnings \
        priority:3 \
        bench \
        $flottantLimite \
        $([[ $multicoeurFlottants == "true" ]] \
        && echo "" \
        || echo "-TD:1 -PF:none") \
        -o "$resultatsAdr" \
        >> /dev/null
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
    # noverbose (équivalent au nowarnings utilisé dans l'exemple fourni par la bibliothèque): affichage
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
    export KMP_AFFINITY=noverbose,scatter,0,0,granularity=fine

    # Exécution du test linpack à partir du fichier de configuration créé et
    # exportation des résultats dans le fichier de résultats désigné
    $testMemoireAdr/xlinpack_xeon64 "$fichierConfig" > "$fichierResultats"

fi
