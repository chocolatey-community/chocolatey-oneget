$chocolateyOneGet = "Chocolatey-OneGet"
$expectedSourceName = "Chocolatey-TestScriptRoot"
$expectedCertificateSource = "Chocolatey-CertificateTestScriptRoot"

# If import failed, chocolatey.dll is locked and is necessary to reload powershell
# Import-PackageProvider $chocolateyOneGet -force

function Get-ChocolateySource(){
    return choco source list | Where-Object { $_.Contains($expectedSourceName)}
}

Describe "Imported module" {
    $provider = Get-PackageProvider -Name $chocolateyOneGet

    It "is loaded as PackageProvider" {
        $provider | Should -Not -be $null
    }

    It "supports '.nupkg' file extension" {
        $extensions = $provider.features["file-extensions"]
        $extensions | Should -Contain ".nupkg"
    }

    It "supports 'http', 'https' and 'file' repository location types" {
        $extensions = $provider.features["uri-schemes"]
        $extensions | Should -Be "http https file"
    }
}

Describe "Add packages source" {
    BeforeAll { 
        Invoke-Expression "choco source remove -n=$expectedSourceName"
        Invoke-Expression "choco source remove -n=$expectedCertificateSource"
    }

    AfterAll {
        Invoke-Expression "choco source remove -n=$expectedSourceName"
        Invoke-Expression "choco source remove -n=$expectedCertificateSource"
    }
    
    $userPassword = "UserPassword" | ConvertTo-SecureString -AsPlainText -Force
    $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "UserName", $userPassword

    Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $PSScriptRoot `
                        -Priority 10 -BypassProxy -AllowSelfService -VisibleToAdminsOnly `
                        -Credential $credentials

    Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedCertificateSource -Location $PSScriptRoot `
                        -Certificate "testCertificate" -CertificatePassword "testCertificatePassword"

    $registeredSource = Get-ChocolateySource

    It "is saved in choco" {
        $registeredSource | Should -Not -Be $Null
    }

    It "saves Priority" {
        $registeredSource | Should -Match "Priority 10"
    }

    It "saves BypassProxy" {
        $registeredSource | Should -Match "Bypass Proxy - True"
    }

    It "saves AllowSelfService" {
        $registeredSource | Should -Match "Self-Service - True"
    }

    # Requires business edition
    It "saves VisibleToAdminsOnly" -Skip {
        $registeredSource | Should -Match "Admin Only - True"
    }

    # Not possible to test user name value was set propertly this way
    It "saves user credential properties" {
        $registeredSource | Should -Match "(Authenticated)"
    }

    It "saves user certificate properties" {
        $certificateSource = choco source list | Where-Object { $_.Contains($expectedCertificateSource)}
        $certificateSource | Should -Match "(Authenticated)"
    }
}

Describe "Get package sources" {
    BeforeAll { 
        Invoke-Expression "choco source add -n=$expectedSourceName -s=""$PSScriptRoot"""
        Invoke-Expression "choco source add -n=$expectedCertificateSource -s=""$PSScriptRoot"""
    }

    AfterAll { 
        Invoke-Expression "choco source remove -n=$expectedSourceName"
        Invoke-Expression "choco source remove -n=$expectedCertificateSource"
    }

    It "lists all registered sources" {
        $registeredSources = Get-PackageSource -ProviderName $chocolateyOneGet
        $resolved = $registeredSources | Where-Object { $_.Name -eq $expectedSourceName }
        $resolved -ne $Null -and $registeredSources.Count -ge 2 | Should -Be $True
    }

    It "lists only sources by wildcard" {
        $filteredSources = Get-PackageSource -ProviderName $chocolateyOneGet $expectedCertificateSource*
        $resolved = $filteredSources | Where-Object { $_.Name -eq $expectedCertificateSource }
        $resolved.Count | Should -Be 1 
    }

    It "lists sources by location" {
        $byPathSources = Get-PackageSource -ProviderName $chocolateyOneGet -Location $PSScriptRoot
        $byPathSources.Count | Should -Be 2
    }
}

Describe "Unregister package source" {
    BeforeAll { 
        Invoke-Expression "choco source add -n=$expectedSourceName -s=""$PSScriptRoot"""
    }

    AfterAll { 
        Invoke-Expression "choco source remove -n=$expectedSourceName"
    }

    It "is removed" {
        Unregister-PackageSource -ProviderName Chocolatey-OneGet -Name $expectedSourceName
        $registeredSource = Get-ChocolateySource
        $registeredSource | Should -Be $Null
    }
}