# Usage: docker build --memory=2g -t jmrteluq/windowstools:2004 -t jmrteluq/windowstools:latest .

# Version officielle la plus récente permettant l'isolation par processus pour
# Windows 10 21H2 (19044.1706)
FROM mcr.microsoft.com/windows:2004 AS Base_Windows

# Définition de la console par défaut de l'image pour être compatible avec
# le traitement par lot (batch) requis pour l'installation des programmes
# de compilation
SHELL ["cmd", "/S", "/C"]

# Installation des outils de compilations de Visual Studio
# Référence directe de la documentation Microsoft pour Docker
# https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2022
# et de la référence pour les "workflows" disponibles
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022
RUN \
    # Téléchargement du fichier d'installation
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe \
    \
    # Installation des outils de compilations en excluant les outils connus
    # comme incompatibles.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache \
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" \
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended  \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
        --remove Microsoft.VisualStudio.Component.Windows81SDK \
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) \
    \
    # Nettoyage du fichier d'installation
    && del /q vs_buildtools.exe

# Initialisation des variables nécessaires aux outils de compilation de Visual
# Studio et passage des paramètres nécessaires à Powershell
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
