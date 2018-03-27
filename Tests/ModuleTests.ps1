Describe 'Chocolatey-OneGet Module API' {
    It "It installs" {
        Install-Module Chocolatey-OneGet -Repository TargetRepo -Force -AllowClobber -Scope "CurrentUser";
        Import-Module Chocolatey-OneGet -Force;
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

    # It "It returns supported features" {
    #     $features = Get-Feature;
    #     $features.Length | Should -BeExactly 2;
    # }
}