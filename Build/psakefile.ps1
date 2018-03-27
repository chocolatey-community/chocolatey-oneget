$targetFolder = Join-Path $PSScriptRoot "Output";
$moduleFolder = Join-Path $targetFolder "Chocolatey-OneGet";

Task Default -Depends `
    Clean-Repository,`
    Clean,`
    Restore-Packages,`
    Compile,`
    Test;

Task Restore-Packages {
    Exec {
        paket restore;
    }
}

Task Clean {
    Remove-Item $targetFolder -Force -Recurse -ErrorAction SilentlyContinue;
    # This needs to kill the Visual Studio code powershell instance, otherwise the chocolatey.dll is locked.
    $installedModule = "$home\Documents\WindowsPowerShell\Modules\Chocolatey-OneGet";
    Remove-Item $installedModule -Force -Recurse -ErrorAction SilentlyContinue;
}

Task Compile {
    md "$targetFolder\Chocolatey-OneGet" -ErrorAction SilentlyContinue | Out-Null;
    copy -Path "..\Chocolatey-OneGet.psd1" -Destination "$moduleFolder\Chocolatey-OneGet.psd1" -Force;
    copy -Path "..\Chocolatey-OneGet.psm1" -Destination "$moduleFolder\Chocolatey-OneGet.psm1" -Force;
    copy -Path "..\packages\chocolatey.lib\lib\chocolatey.dll" -Destination "$moduleFolder\chocolatey.dll" -Force;
    copy -Path "..\packages\log4net\lib\net40-client\log4net.dll" -Destination "$moduleFolder\log4net.dll" -Force;

    Register-PSRepository -Name TargetRepo -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null;
    Publish-Module -Path $moduleFolder -Repository TargetRepo -Force;
}

Task Clean-Repository {
    Unregister-PSRepository TargetRepo -ErrorAction SilentlyContinue;
}

Task Test {
    # Run Pester tests
    $testResults = Invoke-Pester ..\Tests\ModuleTests.ps1 -EnableExit -PassThru;
    if ($testResults.FailedCount -gt 0) {
        Write-Error -Message 'One or more Pester tests failed!';
    }
}

Task Publish {
    # nugetApi key needs to beprovided by chocolatey owners
    Publish-Module -Path $moduleFolder -NuGetApiKey ""; 
}
