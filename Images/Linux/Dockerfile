# Usage: à partir de la racine du projet, pour le contexte, exécuter la commande
# docker build -f Images/Linux/Dockerfile -t jmrteluq/linuxtools:22.04 -t jmrteluq/linuxtools:latest .

# Version officielle de l'image d'Ubuntu correspondant à l'environnement
# d'exécution natif utilisé
FROM ubuntu:22.04 as Base_Linux

######################  Configuration de l'environnement   #####################

# Élimine plusieurs messages d'erreurs durant l'installation silencieuse
# de plusieurs programmes
ARG DEBIAN_FRONTEND=noninteractive

# Ajuste l'encodage des caractères de bash en utilisant une des valeurs incluse
# avec l'image officiellle
ENV LANG=C.utf8

# Création de la liste de paquets relatifs à l'image officielle et mise à jour
# des paquets nécessaires
RUN apt update && apt upgrade -y

# Installation des paquets apt-utils(système), g++ et cmake(compilation). 
RUN apt install apt-utils -y && apt install g++ cmake -y

# Définition de l'adresse de l'archive pour le programme primesieve dans le projet
ARG primeSieveAdr="Outils/entiers/Linux/primesieve-7.9.tar.gz"

# Définition de l'adresse du dossier du programme y-cruncher dans le projet
ARG ycruncherAdr="Outils/flottants/Linux/y-cruncher v0.7.9.9509-static"

# Définition de l'adresse du dossier du programme linpack dans le projet
ARG linpackAdr="Outils/mémoire/Linux/benchmarks_2022.0.2"

# Création des dossiers nécessaires pour les différents tests et les résultats
RUN mkdir /tests /tests/entiers /tests/flottants /tests/mémoire /résultats

################ Installation du programme primesieve  #########################

# On utilise ici la copie locale du projet au lieu de simplement utiliser le
# dépot (apt install primesieve) pour pouvoir garantir que la version installée
# correspond à la version Windows utilisée

# Copie de l'archive primesieve du projet dans le dossier approprié
COPY $primeSieveAdr /tests/entiers

# Changement de dossier vers le dossier copié de primesieve
WORKDIR /tests/entiers

# Extraction de l'archive primesieve
RUN tar -xf primesieve-7.9.tar.gz

# Changement de dossier vers le dossier extrait
WORKDIR /tests/entiers/primesieve-7.9

# Création des fichiers cmake nécessaires, compilation et installation en
# utilisant make et vérification des bibliothèque en utilisant ldconfig
RUN cmake . && make -j && make install && ldconfig

# Changement de dossier vers la racine de l'image
WORKDIR /

# Effacement du dossier extrait de l'archive
RUN rm -rf /tests/entiers/primesieve-7.9

# Effacement de l'archive du programme primesieve
RUN rm -f /tests/entiers/primesieve-7.9.tar.gz

################### Installation du programme y-cruncher  ######################

# Copie du dossier du projet contenant le programme y-cruncher
COPY $ycruncherAdr /tests/flottants

################## Installation du programme LinPack ###########################

# Copie du dossier du projet contenant le programme linpack
COPY $linpackAdr /tests/mémoire

##################  Définition du programme de démarrage du conteneur ##########

# Sélection de la coquille bash
CMD ["bash"]