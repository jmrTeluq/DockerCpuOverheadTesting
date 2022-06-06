#!/bin/bash

########### Fonction d'aide ########################
Aide(){
    # Affichage d'un message d'aide
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

################ Définitions des adresses nécessaires #########################

# Adresse pour l'outil y-cruncher
testFlottantsAdr="Outils/flottants/Linux/y-cruncher v0.7.9.9509-static"

# Adresse pour l'outil linpack
testMemoireAdr="Outils/memoire/Linux/linpack"

# Adresse pour les résultats
resultatsAdr="Resultats/6 - Linux (Natif)"

############### Test sur les entiers ###########################

# Définition d'un nom unique basé sur la date pour le fichier de résultats
resultatsEntiersNom="Entiers$(date +"%Y%m%d%H%M").txt"

# Boucle de réchauffement dont les résultats sont ignorés
for ((i = 1 ; i <= $entierRechauffement ; i++)); do
    primesieve $entierLimite -c  $([[ $multicoeurEntier == "true" ]] &&echo "" || echo "--threads=1") \
    >> /dev/null
done

# Boucle de test envoyant les résultats dans un fichier texte au nom créé plus haut
for ((i = 1 ; i <= $entierRepetitions ; i++)); do
    primesieve $entierLimite -c --quiet --time $([[ $multicoeurEntier == "true" ]] && echo "" || echo "--threads=1") \
    >> "$resultatsAdr/$resultatsEntiersNom"
done

