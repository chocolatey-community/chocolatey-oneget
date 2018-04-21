. $PSScriptRoot\TestHelpers.ps1

Describe "Add packages source" {
    BeforeAll { 
        Clean-Sources 
    }

    AfterAll {
        Clean-Sources 
    }
    
    Register-TestPackageSources

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
        Clean-Sources
        Register-TestPackageSources
    }

    AfterAll { 
        Clean-Sources
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
        Clean-Sources
        Register-TestPackageSources
    }

    AfterAll { 
        Clean-Sources
    }

    It "is removed" {
        Unregister-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName
        $registeredSource = Get-ChocolateySource
        $registeredSource | Should -Be $Null
    }
}