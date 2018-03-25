$InstallDir='C:\ProgramData\chocoportable';
$env:ChocolateyInstall="$InstallDir";

Set-ExecutionPolicy Bypass -Scope Process;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

# Testing framework
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope "CurrentUser" -RequiredVersion 4.3.1;
Import-Module -Name Pester;
Install-Module -Name psake -Force -Scope "CurrentUser" -RequiredVersion 4.7.0;
Import-Module -Name psake;

choco install paket -y -version 5.133.0;