#!/bin/bash

########### Fonction d'aide ########################
Aide(){
    # Affichage d'un message d'aide
    echo ""
    echo "Le script permet d'effectuer des tests de performance computationnelle"
    echo "sur un conteneur Docker ou dans un environnement natif Linux."
    echo ""
    echo "Paramètres:"
    echo ""
    echo "--coeurs (Défaut: nombre de coeurs disponibles)"
    echo "nombre de coeurs à assigner au conteneur."
    echo ""
    echo "--memoire (Défaut: 8)"
    echo "nombre de GB de mémoire vive à assigner au conteneur."
    echo ""
    echo "--construire (Défaut: false)"
    echo "booléen controlant la construction de l'image Docker utilisée pour"
    echo " générer le conteneur."
    echo ""
    echo "--help (Défaut: false)"
    echo "booléen controlant l'affichage du menu d'aide"
}

########### Valeurs par défaut des paramètres ###################

# Nombre de coeurs de processeur à utiliser
# nproc serait une solution plus simple mais il compte les coeurs logiques seulement
# et certains processeurs n'ont pas deux coeurs logiques par coeur physique
# ce qui rendrait la simple opération de divsion par 2 inadéquate
coeurs=${coeurs:-$(nproc)}
# Quantité de mémoire vive à assigner au conteneur
memoire=${memoire:-8}
# Booléen controlant la construction de l'image Docker
construire=${construire:-false}
# Booléen controlant l'affichage d'un menu d'aide
help=${help:-false}

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

# Conditionel permettant l'affichage du menu d'aide pour toute valeur du 
# paramètre help autre que la valeur par défaut puis la fin du script
if [[ $help != "false" ]]; then
    Aide
    exit 0
fi

# Validation du nombre de coeurs spécifié
if [[ $coeurs -lt 1 || $coeurs -gt $(nproc) ]]; then
    echo "Le nombre de coeurs doit être entre 1 et $(nproc)."
    exit 0
fi

# Validation de la quantité de mémoire spécifiée
# À noter que Linux n'a pas de fonction native equivalent à nproc pour la RAM
# disponible. Ainsi, on doit généralement parser les résultats d'un programme
# comme free ou du fichier meminfo.
# Or, comme meminfo est généralement plus stable d'une distribution à l'autre, 
# cette approche est plus compatible.
if [[ $memoire -lt 1 || $memoire -gt $(($(cat /proc/meminfo | grep -oP '^MemTotal:[\s]+\K([0-9]+)')/1000000)) ]]; then
    echo "La mémoire spécifiée doit être entre 1 et $(($(cat /proc/meminfo | grep -oP '^MemTotal:[\s]+\K([0-9]+)')/1000000)) GB."
    exit 0
fi

# Construction de l'image Docker si le paramètre construire à une autre valeur
# que false
if [[ $construire != "false" ]]; then
    docker build -f Images/Linux/Dockerfile -t jmrteluq/linuxtests:22.04 -t jmrteluq/linuxtests:latest .
fi

# Exécution d'un conteneur Docker avec l'image construite
# N.B. Le nombre de coeurs est diminué de 1 car le paramèter est indexé à 0
docker run -v "$(pwd)/Resultats/7 - Linux (Docker):/résultats" -m $memoire"G" --cpuset-cpus="0-$(($coeurs - 1))" -it jmrteluq/linuxtests