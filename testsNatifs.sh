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

