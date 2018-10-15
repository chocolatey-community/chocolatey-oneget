. $PSScriptRoot\TestHelpers.ps1

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

    It "installs latest version" {
        $installedInChoco | Should -Be "TestPackage $latestVersion"
    }

    It "reports installed package" {
        $latest.Version | Should -Be $latestVersion
    }

    It "installs correct version" {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -RequiredVersion $previousVersion
        Find-InstalledTestPackage | Should -Be "TestPackage $previousVersion"
    }

    It "installs from correct source" {
        $installed = Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -Source $expectedSourceName
        $installed.Source -replace '/',"\" | Should -Be $testPackagesPath
    }

    It "installs prerelease version" {
        $installed = Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -PrereleaseVersions
        $installed.Version | Should -Be $prereleaseVersion
    }

    It "installs multiple versions side by side" {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -RequiredVersion $previousVersion -AllowMultipleVersions
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -AllowMultipleVersions
        $installed = Find-InstalledTestPackage | Sort-Object
        $installed | Should -Be @("TestPackage $previousVersion", "TestPackage $latestVersion")
    }

    It "uses package custom arguments" {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -PackageParameters '/customA:""Path spaced"" /customB:""value""'
        $installLog = "$env:ChocolateyInstall\lib\TestPackage\UsedParams.txt"

        $expected = ConvertFrom-Json '{ "customA":  "\"Path spaced\"", "customB":  "\"value\"" }'
        $installed = ConvertFrom-Json (-Join (Get-Content $installLog))
        $resultsEqual = $expected.custom -eq $installed.custom -and $expected.other -eq $installed.other
        $resultsEqual | Should -Be $true
    }

    It "upgrades package" {
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -RequiredVersion $previousVersion
        Install-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force `
            -Upgrade

        Find-InstalledTestPackage | Should -Be "TestPackage $latestVersion"
    }
}

Describe "Get installed package"  {
    BeforeAll {
        Clean-Sources
        Register-TestPackageSources
        Install-TestPackages
    }

    AfterAll {
        Uninstall-TestPackage
        Clean-Sources
    }

    It "finds all installed package versions" {
        $found = Get-Package -Name $testPackageName -ProviderName $chocolateyOneGet -AllVersions -Force
        $found.Count | Should -Be 3
    }

    It "finds installed package by name" {
        $found = Get-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Force
        $found.Name | Should -Be $testPackageName
    }

    It "finds required package version" {
        $found = Get-Package -Name $testPackageName -ProviderName $chocolateyOneGet -RequiredVersion $previousVersion
        $found.Version | Should -Be $previousVersion
    }

    It "finds by minimum version number" {
        # allversions switch cant be used here, so we test latest available
        $found = Get-Package -Name $testPackageName -ProviderName $chocolateyOneGet -MinimumVersion $prereleaseVersion
        $found.Version | Should -Be $prereleaseVersion
    }

    It "finds by maximum version number" {
        $found = Get-Package -Name $testPackageName -ProviderName $chocolateyOneGet -MaximumVersion $previousVersion
        $found.Version | Should -Be $previousVersion
    }
}

Describe "Uninstall package"  {
    BeforeAll {
        Clean-Sources
        Register-TestPackageSources
        Install-TestPackages
    }

    AfterAll {
        Uninstall-TestPackage
        Clean-Sources
    }

    $removed = Uninstall-Package -Name $testPackageName -ProviderName $chocolateyOneGet -RequiredVersion $latestVersion

    It "reports removed package name" {
        $removed.Name | Should -Be $testPackageName
    }

    It "reports removed package version" {
        $removed.Version | Should -Be $latestVersion
    }

    It "removes package from chocolatey" {
        $installed = Find-InstalledTestPackage | Sort-Object
        $installed | Should -Be @("TestPackage $previousVersion", "TestPackage $prereleaseVersion")
    }

    It "removes all versions" {
        Install-TestPackages
        Uninstall-Package -Name $testPackageName -ProviderName $chocolateyOneGet -AllVersions
        $installed = Find-InstalledTestPackage
        $installed | Should -Be $null
    }
}


Describe "Download package" {
    $downLoadDirectory = "$PSScriptRoot\..\Build\Output\Downloaded\"

    BeforeEach {
        Remove-Item $downLoadDirectory -Recurse -Force -ErrorAction Ignore
    }
    BeforeAll {
        Clean-Sources
        Register-TestPackageSources
    }

    AfterAll {
        Clean-Sources
    }

    It "copies from local path" {
        # Example paths:
        # web: "https://chocolatey.org/api/v2/package/chocolatey/0.10.11"
        # local "c:\Workspace\Build\Output\TestPackages\TestPackage.1.0.1.nupkg"
        # unc "\\localhost\c$\Workspaces\Chocolatey-OneGet_GitHub\Build\Output\TestPackages\TestPackage.1.0.1.nupkg"

        Save-Package -ProviderName $chocolateyOneGet -Name $testPackageName -Path $downLoadDirectory -Force
        $outputFile = Join-Path $downLoadDirectory "testPackage.1.0.3.nupkg" 
        $outputFile | Should -Exist
    }
}