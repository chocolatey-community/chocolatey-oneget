. $PSScriptRoot\TestHelpers.ps1

$previousVersion = "1.0.2"
$latestVersion = "1.0.3"
$prereleaseVersion = "1.1.0-beta1"

Describe "Find package" {
    BeforeAll { 
        Clean-Sources
        Register-TestPackageSources
    }

    AfterAll { 
        Clean-Sources
    }

    It "finds package in Source" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Source $expectedSourceName
        $packagesUri = (New-Object "System.Uri" $testPackagesPath).AbsolutePath
        $found.FastPackageReference | Should -Be "TestPackage|#|1.0.3|#|$packagesUri"
    }

    It "finds package from all sources" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet
        $found.Count | Should -Be 1
    }

    It "finds package by tags" {
        $found = Find-Package -ProviderName $chocolateyOneGet -Tag @("TagC", "TagA")
        $found.Count | Should -Be 1
    }

    It "finds all package versions" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -AllVersions
        $found.Count | Should -Be 3
    }

    It "finds prerelease versions" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -PrereleaseVersions
        $found.Version | Should -Be $prereleaseVersion
    }

    It "finds package by required version" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -RequiredVersion $previousVersion
        $found.Version | Should -Be $previousVersion
    }

    It "finds package by min. version" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -AllVersions -MinimumVersion $previousVersion
        $resolvedVersion = $found[$found.length - 1].Version
        $resolvedVersion | Should -Be $previousVersion
    }

    It "finds package by max. version" {      
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -MaximumVersion $previousVersion
        $found.Version | Should -Be $previousVersion
    }
}

Describe "Install package"  {
    BeforeAll { 
        Clean-Sources
        Register-TestPackageSources
    }

    BeforeEach {
        Uninstall-TestPackage
    }

    AfterEach {
        Uninstall-TestPackage
    }

    AfterAll { 
        Clean-Sources
        Uninstall-TestPackage
    }

    $latest = Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force
    $installedInChoco = Find-InstalledTestPackage 

    It "installs latest version" -Skip {      
        $installedInChoco | Should -Be "TestPackage $latestVersion"
    }

    It "reports installed package" -Skip {      
        $latest.Version | Should -Be $latestVersion
    }

    It "installs correct version" -Skip {      
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -RequiredVersion $previousVersion
        Find-InstalledTestPackage | Should -Be "TestPackage $previousVersion"
    }

    It "installs from correct source" -Skip {      
        $installed = Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -Source $expectedSourceName 
        $installed.Source -replace '/',"\" | Should -Be $testPackagesPath
    }

    It "installs prerelease version" -Skip {
        $installed = Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -PrereleaseVersions 
        $installed.Version | Should -Be $prereleaseVersion
    }

    It "installs multiple versions side by side"  -Skip {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -RequiredVersion $previousVersion -AllowMultipleVersions
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -AllowMultipleVersions
        $installed = Find-InstalledTestPackage | Sort-Object
        $installed | Should -Be @("TestPackage $previousVersion", "TestPackage $latestVersion")
    }

    It "uses package custom arguments" {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -PackageParameters '"/custom:""Path spaced"" /other:value"'
        $installLog = "$env:ChocolateyInstall\lib\TestPackage\UsedParams.txt" 
        
        $parametersJson = '
{
    "custom":  "Path spaced",
    "other":  "value"
}'
        
        $installLog | Should -FileContentMatch $parametersJson
    }

    # TODO Upgrade package
}