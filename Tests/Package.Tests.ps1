. $PSScriptRoot\TestHelpers.ps1

Describe "Find package" {
    BeforeAll { 
        Clean-Sources
        $buildOutput = Join-Path $PSScriptRoot "..\Build\Output\TestPackages"
        $buildOutput = $(Resolve-Path $buildOutput).Path
        Register-PackageSource -ProviderName $chocolateyOneGet -Name $expectedSourceName -Location $buildOutput
    }

    AfterAll { 
        Clean-Sources
    }

    It "finds package in Source" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -Source $expectedSourceName
        $found.Count | Should -Be 1
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
        $found.Count | Should -Be 2
    }

    It "finds prerelease versions" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -PrereleaseVersions
        $found.Version | Should -Be "1.1.0-beta1"
    }

    $expectedVersion = "1.0.2"

    It "finds package by required version" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -RequiredVersion $expectedVersion
        $found.Version | Should -Be $expectedVersion
    }

    It "finds package by min. version" {
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -AllVersions -MinimumVersion $expectedVersion
        $resolvedVersion = $found[$found.length - 1].Version
        $resolvedVersion | Should -Be $expectedVersion
    }

    It "finds package by max. version" {      
        $found = Find-Package -Name $testPackageName -ProviderName $chocolateyOneGet -MaximumVersion $expectedVersion
        $found.Version | Should -Be $expectedVersion
    }
}