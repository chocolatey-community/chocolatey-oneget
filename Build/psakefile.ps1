$targetFolder = Join-Path $PSScriptRoot "Output"
$moduleName = "Chocolatey-OneGet"
$moduleFolder = Join-Path $targetFolder $moduleName
$outputRepository = "$moduleName-OutputRepository"
$installedModule = "$home\Documents\WindowsPowerShell\Modules\$moduleName"
$moduleVersion = "0.10.9"
$testsFilter = "*" # all by default
#$testsFilter = "Uninstall package"

Task Default -Depends `
    Build,`
    Test

Task Build -Depends `
    Clean-OutputRepository,`
    Clean,`
    Restore-Packages,`
    Register-OutputRepository, `
    Compile, `
    PublishTo-OutputRepository, `
    Compile-TestPackage

Task Restore-Packages {
    Exec {
        paket restore
    }
}

Task Clean {
    Remove-Item $targetFolder -Force -Recurse -ErrorAction SilentlyContinue
    # This needs to kill the Visual Studio code powershell instance, otherwise the chocolatey.dll is locked.
    Remove-Item $installedModule -Force -Recurse -ErrorAction SilentlyContinue
}

Task Compile {
    Copy-ToTargetFolder $moduleFolder
}

Task Clean-OutputRepository {
    Unregister-PSRepository $outputRepository -ErrorAction SilentlyContinue
}

Task Register-OutputRepository {
    mkdir "$targetFolder\$moduleName" | Out-Null

    if((Get-PSRepository | Where-Object { $_.Name -eq $outputRepository}) -eq $null){
        Register-PSRepository -Name $outputRepository -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null
    }
}

Task Compile-TestPackage {
    $testPackages = Join-Path $targetFolder "TestPackages"

    if(-Not (Test-Path $testPackages)){
        mkdir $testPackages | Out-Null
    }

    Exec {
        choco pack ..\TestPackage\TestPackage.nuspec --outputdirectory $testPackages --version=1.0.1
        choco pack ..\TestPackage\TestPackage.nuspec --outputdirectory $testPackages --version=1.0.2
        choco pack ..\TestPackage\TestPackage.nuspec --outputdirectory $testPackages --version=1.0.3
        choco pack ..\TestPackage\TestPackage.nuspec --outputdirectory $testPackages --version=1.1.0-beta1
    }
}

Task Import-CompiledModule {
    if((Get-Module -Name $moduleName) -eq $null){
        # equivalent to: Install-Module $moduleName -Repository $outputRepository -Force -AllowClobber -Scope "CurrentUser"
        $targetFolder = Join-Path $installedModule $moduleVersion
        Copy-ToTargetFolder $targetFolder

        Import-Module $moduleName -Force -Scope Local
    }
}

Task Test -Depends Import-CompiledModule {
    # Run Pester tests
    $testResults = Invoke-Pester ../Tests/* -PassThru -TestName $testsFilter

    if ($testResults.FailedCount -gt 0) {
        Write-Error -Message 'One or more Pester tests failed!'
    }
}

Task PublishTo-OutputRepository {
    Publish-Module -Path $moduleFolder -Repository $outputRepository -Force
}

Task Publish {
    # nugetApi key needs to be provided by chocolatey owners
    Publish-Module -Path $moduleFolder -NuGetApiKey ""
}

function Copy-ToTargetFolder(){
    param([String]$targetFolder)

    if(-Not (Test-Path $targetFolder)){
        mkdir $targetFolder | Out-Null
    }

    Copy-Item -Path "..\$moduleName.psd1" -Destination "$targetFolder\$moduleName.psd1" -Force
    Copy-Item -Path "..\$moduleName.psm1" -Destination "$targetFolder\$moduleName.psm1" -Force
    Copy-Item -Path "..\Chocolatey-Helpers.psm1" -Destination "$targetFolder\Chocolatey-Helpers.psm1" -Force
    Copy-Item -Path "..\packages\chocolatey.lib\lib\chocolatey.dll" -Destination "$targetFolder\chocolatey.dll" -Force
    Copy-Item -Path "..\packages\log4net\lib\net40-client\log4net.dll" -Destination "$targetFolder\log4net.dll" -Force
}