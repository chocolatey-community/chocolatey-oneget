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
}

Task Compile {
    md "$targetFolder\Chocolatey-OneGet" -ErrorAction SilentlyContinue | Out-Null;
    copy -Path "..\Chocolatey-OneGet.psd1" -Destination "$moduleFolder\Chocolatey-OneGet.psd1" -Force;
    copy -Path "..\Chocolatey-OneGet.psm1" -Destination "$moduleFolder\Chocolatey-OneGet.psm1" -Force;

    Register-PSRepository -Name TargetRepo -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null;
    Publish-Module -Path $moduleFolder -Repository TargetRepo -Force;
}

Task Clean-Repository {
    Unregister-PSRepository TargetRepo -ErrorAction SilentlyContinue;
}

Task Test {
    # TODO Run Pester tests
}

Task Publish {
    # nugetApi key needs to beprovided by chocolatey owners
    Publish-Module -Path $moduleFolder -NuGetApiKey ""; 
}
