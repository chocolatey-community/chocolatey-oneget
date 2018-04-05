Describe 'Chocolatey-OneGet Module API' {
    Context "Installed module" {
        $chocolateyOneGet = "Chocolatey-OneGet"
        Import-PackageProvider $chocolateyOneGet -force
        Initialize-Provider

        It "It imports as PackageProvider" {
            $provider = Get-PackageProvider -Name $chocolateyOneGet
            $provider | Should -Not -be $null
        }

        It "It adds repository" {
            $expectedName = "Chocolatey-TestScriptRoot"
            choco source remove -n=$expectedName | Out-Null

            Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedName -Location $PSScriptRootPS
            #Debug:
            #Add-PackageSource -Name $expectedName -Location $PSScriptRoot -Trusted $false

            $found = choco source list | Where-Object { $_.Contains($expectedName)}
            $found | Should -Not -Be $null
            choco source remove -n=$expectedName | Out-Null
        }

        # It "It returns supported features" {
        #     $features = Get-Feature;
        #     $features.Length | Should -BeExactly 2;
        # }
    }
}