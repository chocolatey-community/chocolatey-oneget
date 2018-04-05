$targetFolder = Join-Path $PSScriptRoot "Output"
$moduleName = "Chocolatey-OneGet"
$moduleFolder = Join-Path $targetFolder $moduleName
$outputRepository = "$moduleName-OutputRepository"

Task Default -Depends `
    Build,`
    Test

Task Build -Depends `
    Clean-OutputRepository,`
    Clean,`
    Restore-Packages,`
    Register-OutputRepository, `
    Compile

Task Restore-Packages {
    Exec {
        paket restore
    }
}

Task Clean {
    Remove-Item $targetFolder -Force -Recurse -ErrorAction SilentlyContinue
    # This needs to kill the Visual Studio code powershell instance, otherwise the chocolatey.dll is locked.
    $installedModule = "$home\Documents\WindowsPowerShell\Modules\$moduleName"
    Remove-Item $installedModule -Force -Recurse -ErrorAction SilentlyContinue
}

Task Compile {
    Copy-Item -Path "..\$moduleName.psd1" -Destination "$moduleFolder\$moduleName.psd1" -Force
    Copy-Item -Path "..\$moduleName.psm1" -Destination "$moduleFolder\$moduleName.psm1" -Force
    Copy-Item -Path "..\packages\chocolatey.lib\lib\chocolatey.dll" -Destination "$moduleFolder\chocolatey.dll" -Force
    Copy-Item -Path "..\packages\log4net\lib\net40-client\log4net.dll" -Destination "$moduleFolder\log4net.dll" -Force

    Publish-Module -Path $moduleFolder -Repository $outputRepository -Force
}

Task Clean-OutputRepository {
    Unregister-PSRepository $outputRepository -ErrorAction SilentlyContinue
}

Task Register-OutputRepository {
    mkdir "$targetFolder\$moduleName" -ErrorAction SilentlyContinue | Out-Null

    if((Get-PSRepository | Where-Object { $_.Name -eq $outputRepository}) -eq $null){
        Register-PSRepository -Name $outputRepository -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null
    }
}

Task Import-CompiledModule {
    if((Get-Module -Name $moduleName) -eq $null){
        Install-Module $moduleName -Repository $outputRepository -Force -AllowClobber -Scope "CurrentUser"
        Import-Module $moduleName -Force -Scope Local
    }
}

Task Test -Depends Import-CompiledModule {
    # Run Pester tests
    $testResults = Invoke-Pester ..\Tests\ModuleTests.ps1 -PassThru
    if ($testResults.FailedCount -gt 0) {
        Write-Error -Message 'One or more Pester tests failed!'
    }
}

Task Publish {
    # nugetApi key needs to beprovided by chocolatey owners
    Publish-Module -Path $moduleFolder -NuGetApiKey ""
}