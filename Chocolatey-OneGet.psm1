$optionPriority = "Priority"
$optionBypassProxy = "BypassProxy"
$optionAllowSelfService = "AllowSelfService"
$optionVisibleToAdminsOnly = "VisibleToAdminsOnly"
$optionCertificate = "Certificate"
$optionCertificatePassword = "CertificatePassword"
$optionTags = "Tag"
$optionAllVersions = "AllVersions"
$optionPreRelease = "PrereleaseVersions"
$optionAllowMultiple = "AllowMultipleVersions"
$optionForceDependencies = "ForceDependencies"
$optionPackageParameters = "PackageParameters"

$script:wildcardOptions = [System.Management.Automation.WildcardOptions]::CultureInvariant -bor `
                          [System.Management.Automation.WildcardOptions]::IgnoreCase

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
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionPriority -ExpectedType int -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionBypassProxy -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionAllowSelfService -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionVisibleToAdminsOnly -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionCertificate -ExpectedType string -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionCertificatePassword -ExpectedType string -IsRequired $false)
        }

        Package {
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionTags -ExpectedType StringArray -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionAllVersions -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionPreRelease -ExpectedType switch -IsRequired $false)
        }

        Install {
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionAllowMultiple -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionForceDependencies -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionPreRelease -ExpectedType switch -IsRequired $false)
            Write-Output -InputObject (New-DynamicOption -Category $category -Name $optionPackageParameters -ExpectedType string -IsRequired $false)
        }
    }
}

function Resolve-PackageSource {
    $SourceNames = $request.PackageSources

    if($SourceNames.Count -eq 0) {
        $SourceNames += "*"
    }

    $choco = Get-Chocolatey
    # fluent API of Set method returns it self,
    # without assignment it is written as output object and break Find-Package
    $choco = $choco.Set({
        param($config)

        $config.CommandName = "source"
        $config.SourceCommand.Command = [chocolatey.infrastructure.app.domain.SourceCommandType]::list
        $config.QuietOutput = $True
    });

    $method = $choco.GetType().GetMethod("List")
    $gMethod = $method.MakeGenericMethod([chocolatey.infrastructure.app.configuration.ChocolateySource])
    $registered = $gMethod.Invoke($choco, $Null)

    foreach($pattern in $SourceNames){
        if($request.IsCanceled) {
            return;
        }

        $wildcardPattern = New-Object System.Management.Automation.WildcardPattern $pattern, $script:wildcardOptions
        $filtered = $registered | Where-Object { $wildcardPattern.IsMatch($_.Id) -or $wildcardPattern.IsMatch($_.Value) }

        forEach($source in $filtered){
            $packageSource = New-PackageSource -Name $source.Id -Location $source.Value -Trusted $False -Registered $True
            Write-Output -InputObject $packageSource
        }

        if($iltered.Count -eq 0) {
            # if the path is valid isnt really not our responsibility, only for Url values
            $parsedUri = $null

            if([System.Uri]::TryCreate($pattern, [System.UriKind]::Absolute, [ref]$parsedUri)){
                $packageSource = New-PackageSource -Name $pattern -Location $pattern -Trusted $False -Registered $False
                Write-Output -InputObject $packageSource
            }
        }
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

    $priority = ParseDynamicOption $optionPriority 0
    $bypassProxy = ParseDynamicOption $optionBypassProxy $False
    $allowSelfService = ParseDynamicOption $optionAllowSelfService $False
    $visibleToAdminsOnly = ParseDynamicOption $optionVisibleToAdminsOnly $False
    $certificate = ParseDynamicOption $optionCertificate ""
    $certificatePassword = ParseDynamicOption $optionCertificatePassword ""

    $choco = Get-Chocolatey
    $choco = $choco.Set({
        param($config)

        $config.CommandName = "source"
        $config.SourceCommand.Command = [chocolatey.infrastructure.app.domain.SourceCommandType]::add
        $config.SourceCommand.Name = $Name
        $config.Sources = $Location
        $config.SourceCommand.Priority = $priority
        $config.SourceCommand.BypassProxy = $bypassProxy
        $config.SourceCommand.AllowSelfService = $allowSelfService
        $config.SourceCommand.VisibleToAdminsOnly = $visibleToAdminsOnly
        $config.SourceCommand.Certificate = $certificate
        $config.SourceCommand.CertificatePassword = $certificatePassword

        $credential = $request.Credential

        if ($Null -ne $credential){
            $config.SourceCommand.Username = $credential.UserName
            $config.SourceCommand.Password = $credential.GetNetworkCredential().Password
        }
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

    if([string]::IsNullOrEmpty($Name)) {
        ThrowError "System.ArgumentException" "Source Name is required"
        return
    }

    $choco = Get-Chocolatey
    $choco = $choco.Set({
        param($config)

        $config.CommandName = "source"
        $config.SourceCommand.Command = [chocolatey.infrastructure.app.domain.SourceCommandType]::remove
        $config.SourceCommand.Name = $Name
    });

    $choco.Run()
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

    $sourceNames = $Request.PackageSources
    $tags = ParseDynamicOption $optionTags @()
    $allVersions = ParseDynamicOption $optionAllVersions $false
    $preRelease = ParseDynamicOption $optionPreRelease $false
    $queryVersions = Parse-Version $RequiredVersion $MinimumVersion $MaximumVersion
    $allVersions = ($allVersions -or $queryVersions.defined)
    $byIdOnly = -not [string]::IsNullOrEmpty($Name) -or $queryVersions.defined

    if($sourceNames.Count -eq 0){
        Resolve-PackageSource | ForEach-Object{
            $sourceNames += $_.Name
        }
    }

    $source = [String]::Join(";", $sourceNames)

    $choco = Get-Chocolatey
    $choco = $choco.Set({
        param($config)

        $config.CommandName = "list"
        $config.Input = $Name
        $config.Sources = $source
        $config.ListCommand.ByIdOnly = $byIdOnly

        if($queryVersions.min -eq $queryVersions.max){
            $config.Version = $RequiredVersion
        }

        $config.AllVersions = $allVersions
        $config.Prerelease = $preRelease
    })

    $method = $choco.GetType().GetMethod("List")
    $gMethod = $method.MakeGenericMethod([chocolatey.infrastructure.results.PackageResult])
    $packages = $gMethod.Invoke($choco, $Null)

    foreach($found in $packages){
        if($request.IsCanceled) {
            return
        }

        # Choco has different usage fo the tag filtering option
        $package = $found.Package
        $packageTags = $package.Tags
        $tagFound = $tags.Count -eq 0

        foreach($tag in $tags){
            $tagFound = $tagFound -or $packageTags.Contains($tag)
        }

        if(-Not $tagFound){
            continue
        }

        [NuGet.SemanticVersion]$actual = $null;
        if ([NuGet.SemanticVersion]::TryParse($package.Version,[ref] $actual) `
             -and ($actual -lt $queryVersions.min -or $actual -gt $queryVersions.max)){
            continue
        }

        $packageReference = Build-FastPackageReference $found
        $identity = New-SoftwareIdentity $packageReference $found.Name $found.Version "semver" $source $found.Description
        Write-Output $identity
    }
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

   $packageReference = Parse-FastPackageReference $FastPackageReference
   $multipleVersions = ParseDynamicOption $optionAllowMultiple $false
   $packageArgs = ParseDynamicOption $optionPackageParameters ""

   #TODO needs to solve the source as trusted, otherwise automatic test is not able to execute

   $choco = Get-Chocolatey
   $choco = $choco.Set({
       param($config)

       $config.CommandName = "install"
       $config.PackageNames = $packageReference.Name
       $config.Version = $packageReference.Version
       $config.Sources = $packageReference.Source
       $config.PromptForConfirmation = $False
       $config.AllowMultipleVersions = $multipleVersions
       $config.PackageParameters = $packageArgs
   });

   $choco.Run()

   $identity = New-SoftwareIdentity $FastPackageReference $packageReference.Name `
        $packageReference.Version "semver" $packageReference.source
   Write-Output $identity
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

function ParseDynamicOption() {
    param(
        [string]
        $optionName,

        $defaultValue
    )

    $options = $request.Options

    if($options.ContainsKey($optionName)){
        return $options[$optionName]
    }

    return $defaultValue
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

function Parse-Version(){
    param([string]$requiredVersion,
          [string]$minimumVersion,
          [string]$maximumVersion
    )

    [NuGet.SemanticVersion]$min = $null
    [NuGet.SemanticVersion]$max = $null
    [NuGet.SemanticVersion]$actual = $nullon
    $defined = $false

    if (-Not [string]::IsNullOrEmpty($requiredVersion) -and [NuGet.SemanticVersion]::TryParse($requiredVersion, [ref] $actual)){
        $min = $max = $actual
        $defined = $true
    } else {
        if ([string]::IsNullOrEmpty($minimumVersion) -or -not [NuGet.SemanticVersion]::TryParse($minimumVersion, [ref] $min)){
            $version = New-Object Version
            $min = New-Object "NuGet.SemanticVersion" $version
        } else {
            $defined = $true
        }

        if ([string]::IsNullOrEmpty($maximumVersion) -or -not [NuGet.SemanticVersion]::TryParse($maximumVersion, [ref] $max)){
            $max = New-Object "NuGet.SemanticVersion" @([int32]::MaxValue, [int32]::MaxValue, [int32]::MaxValue, [int32]::MaxValue)
        } else {
            $defined = $true
        }
    }

    return @{ "min" = $min
              "max" = $max
              "defined" = $defined
    }
}

function Build-FastPackageReference($package){
    $name =$package.Name
    $version = $package.Version
    $source = $package.Source
    $parsedUri = $null

    # TODO check the same for UNC path
    if([System.Uri]::TryCreate($package.Source, [System.UriKind]::Absolute, [ref]$parsedUri) -and $parsedUri.IsFile){
        $source = $parsedUri.AbsolutePath
    }

    return  "$name|#|$version|#|$source"
}

function Parse-FastPackageReference($fastPackageReference){
    $pattern = "(?<Name>.*)\|#\|(?<Version>.*)\|#\|(?<Source>.*)"
    $regEx = [regex]::new($pattern, $wildcardOptions)
    $parsed = $regEx.Match($fastPackageReference)

    if($parsed.Success){
        $result = @{
            Name = $parsed.Groups["Name"].Value
            Version = $parsed.Groups["Version"].Value
            Source = $parsed.Groups["Source"].Value
        }

        return $result
    }

    return $null
}

#endregion