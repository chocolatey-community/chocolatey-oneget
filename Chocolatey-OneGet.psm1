function Get-PackageProviderName { 
    return "Chocolatey-OneGet";
}

function Initialize-Provider { 
    $chocoBinary = Join-Path $PSScriptRoot "\\chocolatey.dll";
    Add-Type -Path $chocoBinary;
    $Script:choco = [chocolatey.Lets]::GetChocolatey();
}

function Resolve-PackageSource {
    $SourceName = $request.PackageSources;

    if(-not $SourceName) {
        $SourceName = "*";
    }

    foreach($src in $SourceName) {
        if($request.IsCanceled) { 
            return;
        }

        #TODO load and call chocolatey
    }
}

function Add-PackageSource {
    [CmdletBinding()]
    param
    (
        [string]
        $Name,

        [string]
        $Location,

        [bool]
        $Trusted
    )

    #TODO
}

function Remove-PackageSource {
    param
    (
        [string]
        $Name
    )

    #TODO
}

function Find-Package {
    param(
        [string] $name,
        [string] $requiredVersion,
        [string] $minimumVersion,
        [string] $maximumVersion
    )

    #TODO
}

function Get-InstalledPackage {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $RequiredVersion,

        [Parameter()]
        [string]
        $MinimumVersion,

        [Parameter()]
        [string]
        $MaximumVersion
    )

    #TODO
}

function Install-Package {
   [CmdletBinding()]
   param
   (
       [Parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]
       [string]
       $fastPackageReference
   )
   #TODO
 }

function UnInstall-Package {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $fastPackageReference
    )

     #TODO
}

function Download-Package {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FastPackageReference,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Location
    )

     #TODO
}

# TODO ensure it is part of provider API
# function Get-Feature {
#     Write-Output -InputObject (New-Feature -name "file-extensions" -values @(".nupkg"));
#     Write-Output -InputObject (New-Feature -name "uri-schemes" -values @("http", "https", "file"));
# }