function Get-PackageProviderName { 
    return "Chocolatey-OneGet"
}

function Initialize-Provider { 
    $chocoBinary = Join-Path $PSScriptRoot "\\chocolatey.dll"
    Add-Type -Path $chocoBinary
}

function Get-Chocolatey{ 
    $choco = [chocolatey.Lets]::GetChocolatey()
    return $choco
}

function Resolve-PackageSource {
    $SourceName = $request.PackageSources

    if(-not $SourceName) {
        $SourceName = "*"
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
    param(
        [string]
        $Name,

        [string]
        $Location,

        [bool]
        $Trusted
    )

    if([string]::IsNullOrEmpty($Name)) {
        ThrowError "System.ArgumentException" "Source Name is required"
        return
    }

    if([string]::IsNullOrEmpty($Location)) {
        ThrowError "System.ArgumentException" "Source Location is required"
        return
    }

    $choco = Get-Chocolatey
    $choco.Set({
        param($config)

        $config.CommandName = "source"
        $config.SourceCommand.Command = 2
        $config.SourceCommand.Name = $Name
        $config.Sources = $Location
        })

    $choco.Run()

    $created = New-Object PSCustomObject -Property (@{
        Name = $Name
        Location = $Location
        Trusted = $False
        Registered = $True
    })

    Write-Output -InputObject $created
}

function Remove-PackageSource {
    [CmdletBinding()]
    param
    (
        [string]
        $Name
    )

    #TODO
}

function Find-Package {
    [CmdletBinding()]
    param(
        [string]
        $Name,
        
        [string]
        $RequiredVersion,
        
        [string]
        $MinimumVersion,
        
        [string]
        $MaximumVersion
    )

    #TODO
}

function Get-InstalledPackage {
    [CmdletBinding()]
    param(
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
   param(
       [Parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]
       [string]
       $FastPackageReference
   )
   #TODO
 }

function UnInstall-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FastPackageReference
    )

     #TODO
}

function Download-Package {
    [CmdletBinding()]
    param(
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
#     Write-Output -InputObject (New-Feature -name "file-extensions" -values @(".nupkg"))
#     Write-Output -InputObject (New-Feature -name "uri-schemes" -values @("http", "https", "file"))
# }

function ThrowError(){
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $exceptionType,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $exceptionMessage
    )

    $exception = New-Object $exceptionType $exceptionMessage
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "Chocolatey", $errorCategory, $Null    
    $PSCmdlet.ThrowTerminatingError($errorRecord)
}