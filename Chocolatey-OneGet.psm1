function Get-PackageProviderName { 
    return "Chocolatey-OneGet"
}

function Initialize-Provider { 
    $chocoBinary = Join-Path $PSScriptRoot "\\chocolatey.dll"
    Add-Type -Path $chocoBinary
}

function Get-Feature {
    # New-Feature commes from PackageProvider functions
    Write-Output -InputObject (New-Feature -name "file-extensions" -values @(".nupkg"))
    Write-Output -InputObject (New-Feature -name "uri-schemes" -values @("http", "https", "file"))
}

function Get-DynamicOptions{
    param(
        [Microsoft.PackageManagement.MetaProvider.PowerShell.OptionCategory]
        $category
    )

    Write-Debug ("Get-DynamicOptions")      
    switch($category){
        Source {
            # $config.SourceCommand.Username = source.UserName;
            # $config.SourceCommand.Password = source.Password;
            # $config.SourceCommand.Certificate = source.Certificate;
            # $config.SourceCommand.CertificatePassword = source.CertificatePassword;

            Write-Output -InputObject (New-DynamicOption -Category $category -Name "Priority" -ExpectedType int -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name "BypassProxy" -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name "AllowSelfService" -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name "VisibleToAdminsOnly" -ExpectedType switch -IsRequired $false)
        }
    }
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
        $config.SourceCommand.Command = [chocolatey.infrastructure.app.domain.SourceCommandType]::add
        $config.SourceCommand.Name = $Name
        $config.Sources = $Location

        # TODO load from dynamic options
        # $config.SourceCommand.Username = source.UserName;
        # $config.SourceCommand.Password = source.Password;
        # $config.SourceCommand.Certificate = source.Certificate;
        # $config.SourceCommand.CertificatePassword = source.CertificatePassword;
        # $config.SourceCommand.Priority = source.Priority;
        # $config.SourceCommand.BypassProxy = source.BypassProxy;
        # $config.SourceCommand.AllowSelfService = source.AllowSelfService;
        # $config.SourceCommand.VisibleToAdminsOnly = source.VisibleToAdminsOnly;
        })

    $choco.Run()

    $created = New-Object PSCustomObject -Property (@{
        Name = $Name
        Location = $Location
        Trusted = $False
        Registered = $True
    })

    $created =  New-PackageSource -Name $Name -Location $Location -Trusted $False -Registered $True
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

#region Helper functions

function Get-Chocolatey{ 
    $choco = [chocolatey.Lets]::GetChocolatey()
    return $choco
}

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

#endregion