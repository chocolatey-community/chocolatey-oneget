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
    BeforeEach {
        Invoke-Expression "choco source remove -n=$expectedSourceName"
    }

    AfterEach {
        Invoke-Expression "choco source remove -n=$expectedSourceName"
    }

    It "is saved in choco" {
        Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $PSScriptRoot
        #Debug:
        #Add-PackageSource -Name $expectedSourceName -Location $PSScriptRoot -Trusted $false

        $found = choco source list | Where-Object { $_.Contains($expectedSourceName)}
        $found | Should -Not -Be $null
    }
}