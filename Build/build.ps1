$targetFolder = Join-Path $PSScriptRoot "Output";
$module = Join-Path $PSScriptRoot "..\Chocolatey-OneGet";

paket restore;

# TODO compile
if(-not (Test-Path $targetFolder)) {
    md $targetFolder | Out-Null;
}


# TODO Publish the module to local PsGet repository
Register-PSRepository -Name TargetRepo -SourceLocation $targetFolder -PublishLocation $targetFolder -InstallationPolicy Trusted | Out-Null;
Publish-Module -Path $module -Repository TargetRepo -NuGetApiKey 'irrelevant';


Unregister-PSRepository TargetRepo -ErrorAction SilentlyContinue


# TODO Run Pester tests