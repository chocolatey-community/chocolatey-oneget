Describe 'Chocolatey-OneGet Module API' {
    Context "Installed module" {
        BeforeEach {
            $chocolateyOneGet = "Chocolatey-OneGet"
            $expectedSourceName = "Chocolatey-TestScriptRoot"
            # If import failed, chocolatey.dll is locked and is necessary to reload powershell
            Import-PackageProvider $chocolateyOneGet -force
            Initialize-Provider

            Invoke-Expression "choco source remove -n=$expectedSourceName"
        }

        AfterEach {
            Invoke-Expression "choco source remove -n=$expectedSourceName"
        }

        It "It imports as PackageProvider" {
            $provider = Get-PackageProvider -Name $chocolateyOneGet
            $provider | Should -Not -be $null
        }

        It "It adds repository" {
            Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $PSScriptRoot
            #Debug:
            #Add-PackageSource -Name $expectedSourceName -Location $PSScriptRoot -Trusted $false

            $found = choco source list | Where-Object { $_.Contains($expectedSourceName)}
            $found | Should -Not -Be $null
        }

        It "It supports '.nupkg' file extension" {
            $provider = Get-PackageProvider $chocolateyOneGet
            $extensions = $provider.features["file-extensions"]
            $extensions | Should -Contain ".nupkg"
        }

        It "It supports 'http', 'https' and 'file' repository location types" {
            $provider = Get-PackageProvider $chocolateyOneGet
            $extensions = $provider.features["uri-schemes"]
            $extensions | Should -Be "http https file"
        }
    }
}