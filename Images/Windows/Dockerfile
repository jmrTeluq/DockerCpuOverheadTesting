# Usage: à partir de la racine du projet, exécuter la commande:
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
ARG linpackAdr="Outils\\mémoire\\Windows\\benchmarks_2022.0.2"

########## ---------- Installation des prérequis ---------- ##########

# Installation de l'environnement d'exécution pour C++
ADD https://aka.ms/vs/17/release/vc_redist.x64.exe /vc_redist.x64.exe
RUN C:\vc_redist.x64.exe /quiet /install

########## ---------- Création des dossiers ---------- ##########

# Création du dossier contenant les différents programmes de test
RUN ["powershell",\
                    "mkdir",\
                    "tests,",\
                    "tests\\entiers,",\
                    "tests\\flottants,",\
                    "tests\\mémoire"]

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
