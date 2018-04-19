function IsChocolateyInstalled() {
    $script:chocolateyDir = $null
    if ($env:ChocolateyInstall -ne $null) {
        $script:chocolateyDir = $env:ChocolateyInstall;
    }
    elseif (Test-Path (Join-Path $env:SYSTEMDRIVE Chocolatey)) {
        $script:chocolateyDir = Join-Path $env:SYSTEMDRIVE Chocolatey;
    }
    elseif (Test-Path (Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) Chocolatey)) {
        $script:chocolateyDir = Join-Path ([Environment]::GetFolderPath("CommonApplicationData")) Chocolatey;
    }

    Test-Path -Path $script:chocolateyDir;
}

function Register-ChocoDefaultSource(){
    Register-PackageSource -ProviderName chocolatey-oneget -Name choco -Location https://chocolatey.org/api/v2/
}