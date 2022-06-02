param(
    [int]$coeurs,
    [int]$memoire
)

Write-Output $coeurs
Write-Output $memoire
Write-Output $env:NUMBER_OF_PROCESSORS
systeminfo | select-string 'Total Physical Memory'
