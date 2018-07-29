function IsChocolateyInstalled() {
    $script:chocolateyDir = $null
    if ($null -ne $env:ChocolateyInstall) {
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
    # choco source add -n=choco -s=https://chocolatey.org/api/v2/
    Register-PackageSource -ProviderName chocolatey-oneget -Name choco -Location https://chocolatey.org/api/v2/
}