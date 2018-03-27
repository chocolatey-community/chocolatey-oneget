Describe 'Chocolatey-OneGet Module API' {
    Context "Installed module" {
        Import-Module Chocolatey-OneGet -Force
        
        It "It is loaded" {
            Get-Module Chocolatey-OneGet | Should -Not -Be $null;
        }

        It "It names it self as Chocolatey-OneGet" {
            $name = Get-PackageProviderName;
            $name | Should -be "Chocolatey-OneGet";
        }

        It "It sucessfully initializes provider" {
            { 
                Initialize-Provider;
            } | Should -Not -Throw;
        }

        It "It adds repository" {
            $expectedName = "Chocolatey-TestScriptRoot"
            choco source remove -n=$expectedName | Out-Null

            Add-PackageSource -Name $expectedName -Location $PSScriptRoot -Trusted $false
            
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