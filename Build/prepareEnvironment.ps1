$InstallDir='C:\ProgramData\chocoportable';
$env:ChocolateyInstall="$InstallDir";

Set-ExecutionPolicy Bypass -Scope Process;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

# Testing framework
Install-Module -Name Pester -Force -SkipPublisherCheck;
Import-Module -Name Pester;

choco install paket -y;