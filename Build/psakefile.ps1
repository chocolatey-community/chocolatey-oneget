$targetFolder = Join-Path $PSScriptRoot "Output"
$moduleFolder = Join-Path $targetFolder "Chocolatey-OneGet"
$outputRepository = "Chocolatey-OneGet-OutputRepository"

Task Default -Depends `
    Build,`
    Test;

Task Build -Depends `
    Clean-OutputRepository,`
    Clean,`
    Restore-Packages,`
    Register-OutputRepository, `
    Compile

Task Restore-Packages {
    Exec {
        paket restore;
    }
}

Task Clean {
    Remove-Item $targetFolder -Force -Recurse -ErrorAction SilentlyContinue
    # This needs to kill the Visual Studio code powershell instance, otherwise the chocolatey.dll is locked.
    $installedModule = "$home\Documents\WindowsPowerShell\Modules\Chocolatey-OneGet"
    Remove-Item $installedModule -Force -Recurse -ErrorAction SilentlyContinue
}

Task Compile {
    Copy-Item -Path "..\Chocolatey-OneGet.psd1" -Destination "$moduleFolder\Chocolatey-OneGet.psd1" -Force
    Copy-Item -Path "..\Chocolatey-OneGet.psm1" -Destination "$moduleFolder\Chocolatey-OneGet.psm1" -Force
    Copy-Item -Path "..\packages\chocolatey.lib\lib\chocolatey.dll" -Destination "$moduleFolder\chocolatey.dll" -Force
    Copy-Item -Path "..\packages\log4net\lib\net40-client\log4net.dll" -Destination "$moduleFolder\log4net.dll" -Force

    Publish-Module -Path $moduleFolder -Repository $outputRepository -Force
}

Task Clean-OutputRepository {
    Unregister-PSRepository $outputRepository -ErrorAction SilentlyContinue
}

Task Register-OutputRepository {
    mkdir "$targetFolder\Chocolatey-OneGet" -ErrorAction SilentlyContinue | Out-Null

    if((Get-PSRepository | Where-Object { $_.Name -eq $outputRepository}) -eq $null){
        Register-PSRepository -Name $outputRepository -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null
    }
}

Task Import-CompiledModule {
    if((Get-Module -Name Chocolatey-OneGet) -eq $null){
        Install-Module Chocolatey-OneGet -Repository $outputRepository -Force -AllowClobber -Scope "CurrentUser"
        Import-Module Chocolatey-OneGet -Force
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