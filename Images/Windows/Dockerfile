# Usage: à partir de la racine du projet, pour le contexte, exécuter la commande:
# docker build -f Images/Windows/Dockerfile -t jmrteluq/windowstools:2004 -t jmrteluq/windowstools:latest .

# Version officielle la plus récente permettant l'isolation par processus pour
# Windows 10 21H2 (19044.1706)
FROM mcr.microsoft.com/windows:2004 AS Base_Windows

########## ---------- Variables de construction ---------- ##########

# Adresse du fichier exécutable nécessaire pour le programme primesieve
ARG primesieveExeAdr="Outils\\entiers\\Windows\\primesieve-7.9-win-x64"

# Adresse des fichiers exécutables nécessaires pour le programme y-cruncher
ARG ycruncherAdr="Outils\\flottants\\Windows\\y-cruncher v0.7.9.9509"

# Adresse des fichiers exécutables nécessaires pour le programme linpack
ARG linpackAdr="Outils\\mémoire\\Windows"

# Adresse permanente du fichier du runtime C++ x64
ARG vc_redistAdr="https://aka.ms/vs/17/release/vc_redist.x64.exe"

########## ---------- Installation des prérequis ---------- ##########

# Installation de l'environnement d'exécution pour C++
# L'utilisation de ADD, basé sur les capacité de l'hôte, permet la compatibilité
# avec des images de base n'ayant pas de logiciels de téléchargement spécialisé
# inclus (i.e. curl)
ADD $vc_redistAdr /vc_redist.x64.exe
# Utilisation de la forme shell pour la substitution d'argument et clareté
RUN start /wait \
    C:\vc_redist.x64.exe /quiet /install \
    && \
    del C:\vc_redist.x64.exe

########## ---------- Création des dossiers ---------- ##########

# Création du dossier contenant les différents programmes de test sous forme shell
RUN mkdir \
    tests\entiers \
    tests\flottants \
    tests\mémoire

########## ---------- Copie des fichiers nécessaires ---------- ##########

# Copie du programme primesieve dans le dossier approprié
COPY $primesieveExeAdr "C:\\tests\\entiers"

# Copie du programme y-cruncher dans le dossier approprié
COPY $ycruncherAdr "C:\\tests\\flottants"

# Copie du programme linpack dans le dossier approprié
COPY $linpackAdr "C:\\tests\\mémoire"

########## ---------- Définition du programme de démarrage ---------- ##########

# Initialisation de PowerShell au démarrage du conteneur
CMD [ "powershell" ]
