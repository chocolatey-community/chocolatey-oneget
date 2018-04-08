$chocolateyOneGet = "Chocolatey-OneGet"
$expectedSourceName = "Chocolatey-TestScriptRoot"
# If import failed, chocolatey.dll is locked and is necessary to reload powershell
Import-PackageProvider $chocolateyOneGet -force
#Initialize-Provider

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

Describe "Added packages source" {
    BeforeAll { 
        Invoke-Expression "choco source remove -n=$expectedSourceName"
    }

    AfterAll {
        Invoke-Expression "choco source remove -n=$expectedSourceName"
    }

    Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $PSScriptRoot `
    -Priority 10 -BypassProxy -AllowSelfService -VisibleToAdminsOnly
    #Debug:
    #Add-PackageSource -Name $expectedSourceName -Location $PSScriptRoot -Trusted $false

    $registeredSource = choco source list | Where-Object { $_.Contains($expectedSourceName)}

    It "is saved in choco" {
        $registeredSource | Should -Not -Be $Null
    }

    # It "saves Priority" {
    #     $registeredSource | Should -Match "Priority 10"
    # }

    # It "saves BypassProxy" {
    #     $registeredSource | Should -Match "Bypass Proxy - True"
    # }

    # It "saves AllowSelfService" {
    #     $registeredSource | Should -Match "Self-Service - True"
    # }

    # It "saves VisibleToAdminsOnly" {
    #     $registeredSource | Should -Match "Admin Only - True"
    # }
}