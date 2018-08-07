$chocolateyOneGet = "Chocolatey-OneGet"
$expectedSourceName = "Chocolatey-TestScriptRoot"
$expectedCertificateSource = "Chocolatey-CertificateTestScriptRoot"
$testPackageName = "TestPackage"

$testPackagesPath = Join-Path $PSScriptRoot "..\Build\Output\TestPackages"
$testPackagesPath = $(Resolve-Path $testPackagesPath).Path
$testPackagesPathWrong = "$testPackagesPath-Wrong"

# If import failed, chocolatey.dll is locked and is necessary to reload powershell
# Import-PackageProvider $chocolateyOneGet -force

function Get-ChocolateySource(){
    return choco source list | Where-Object { $_.Contains($expectedSourceName)}
}

function Clean-Sources (){
    Invoke-Expression "choco source remove -n=$expectedSourceName"
    Invoke-Expression "choco source remove -n=$expectedCertificateSource"
    # because chocolatey.dll is unable to reload config file, we need to clean up manually
    UnRegister-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -ErrorAction SilentlyContinue | Out-Null
    Unregister-PackageSource -ProviderName $chocolateyOneGet -Name $expectedCertificateSource -ErrorAction SilentlyContinue | Out-Null
}

function Register-TestPackageSources(){
    $userPassword = "UserPassword" | ConvertTo-SecureString -AsPlainText -Force
    $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "UserName", $userPassword

    Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $testPackagesPath `
        -Priority 10 -BypassProxy -AllowSelfService -VisibleToAdminsOnly `
        -Credential $credentials

    Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedCertificateSource -Location $testPackagesPathWrong `
        -Certificate "testCertificate" -CertificatePassword "testCertificatePassword"
}

function Uninstall-TestPackage(){
    # requires atleast one package source
    Invoke-Expression "choco uninstall $testPackageName -yf"
}

function Install-TestPackage(){
    # requires atleast one package source
    Invoke-Expression "choco install $testPackageName -yf"
}

function Find-InstalledTestPackage() {
    return choco list -localonly --allversions | findstr $testPackageName
}