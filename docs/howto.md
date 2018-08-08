# How to use Chocolatey-OneGet provider

## 1. Install the module

> **NOTE:** This module requires chocolatey application to be installed.

To install the provider follow one of these scenarios

### Online install

You can install the module directly from PowershellGet online repository:

```powershell
Import-Module -Name PackageManagement
Install-Module -Name Chocolatey-OneGet
Import-Module Chocolatey-OneGet
Import-PackageProvider -Name Chocolatey-OneGet
```

### Offline install

1. Download chocolatey package from https://chocolatey.org/packages/chocolatey
2. Download Chocolatey-OneGet provider package from ```TODO add link```
3. Execute following script from current directory, where the downloaded files reside

```powershell
Copy-Item .\chocolatey.0.10.9.nupkg chocolatey.0.10.9.zip
Expand-Archive .\chocolatey.0.10.9.zip
.\chocolatey.0.10.9\tools\chocolateyInstall.ps1
Register-PackageSource -ProviderName PowerShellGet -Name Downloaded  -Location $pwd
Install-Package chocolatey-oneget -Source Downloaded
Unregister-PackageSource -ProviderName PowerShellGet Downloaded
Import-Module Chocolatey-OneGet
Import-PackageProvider -Name Chocolatey-OneGet
```

> **NOTE:** If chocolatey is already installed, it is enough to copy the provider directory to your modules folder (usually "$HOME\Documents\WindowsPowerShell\Modules\").

To verify the provider is available:

```powershell
Get-PackageProvider -Name Chocolatey-OneGet
```

## 2. Register package source

To register chocolatey source you need path (can be local path or http url) and name for the new source.

```powershell
$sourceName = "LocalProvider"
$sourceLocation = "C:\LocalChocolateyPackages"
Register-PackageSource -ProviderName Chocolatey-OneGet -Name $sourceName -Location $sourceLocation
```

Register package source supports all other options you can use from chocolatey command line. All options to register package source are optional. How to use the dynamic options see related documentation. Following example shows how to use the extra parameters.

```powershell
Register-PackageSource -ProviderName $chocolateyOneGet -Name $sourceName -Location $sourceLocation `
    -Priority 10 -BypassProxy -AllowSelfService -VisibleToAdminsOnly
```

> **NOTE:** All additional parameters used in this provider follow the chocolatey command line options, so for more details about their values usage, refer directly to [chocolatey documentation](https://github.com/chocolatey/choco/wiki/CommandsReference).

If your package source needs authenticate you can use credentials powershell object (as standard One-Get parameter) or certificate via additional parameters. Both have the same behavior like chocolatey command line.

```powershell
$credentials = Get-Credential
Register-PackageSource -ProviderName Chocolatey-OneGet -Name $sourceName -Location $sourceLocation -Credential $credentials
```

or if your source needs certificate based authentication

```powershell
$certificate = "C:\Users\bob\Documents\bob.pfx"
$certificatePassword = "CertitificatePassword"
Register-PackageSource -ProviderName Chocolatey-OneGet -Name $sourceName -Location $sourceLocation -Certificate  $certificate -CertificatePassword $certificatePassword
```

## 3. List registered package sources

By default chocolatey installs default package source. When you install this provider only, no package source is added by default. Purpose for this is enterprise environment, where companies want to use their local package source only. Wildcards are supported in source names. When no filter is provided all sources are returned.
To see all already registered package sources

```powershell
$filter = "*Company*"
Get-PackageSource -ProviderName Chocolatey-OneGet $filter
```

## 4. Unregister package source

To remove package source, you only need to know the source name. Package source can be simply removed by

```powershell
Unregister-PackageSource -ProviderName Chocolatey-OneGet -Name $sourceName
```

## 5. Find package

To find package to be installed you have multiple options. The main difference when comparing to chocolatey command is usage of tags. Se following examples

```powershell
$packageName = "git"
# Find latest version of package by name or description in one source
Find-Package -Name $packageName -ProviderName Chocolatey-OneGet -Source $sourceName
# Find package by name or description in all sources
Find-Package -Name $packageName -ProviderName Chocolatey-OneGet
# Find all packages containing one of these tags
Find-Package -ProviderName Chocolatey-OneGet -Tag @("TagC", "TagA")
# Find all versions of package
Find-Package -Name $packageName -ProviderName Chocolatey-OneGet -AllVersions
# Find latest version of package including prerelease versions
Find-Package -Name $packageName -ProviderName Chocolatey-OneGet -PrereleaseVersions
# search for exact version (similar usage by -MinimumVersion or -MaximumVersion)
Find-Package -Name $packageName -ProviderName Chocolatey-OneGet -RequiredVersion 2.18.0
```

## 6. Install package

Because of wide range of chocolatey install arguments not all arguments are supported. Also keep in mind to [escape custom package parameters](https://github.com/chocolatey/choco/wiki/CommandsReference#how-to-pass-options--switches). See following examples

```powershell
# install latest version of package available on any registered compatible source
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet
# install required version
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -RequiredVersion 2.18.0
# install from required source
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -Source $sourceName
# install prerelease version
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -PrereleaseVersions
# install multiple versions side by side
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -AllowMultipleVersions
# install using custom package arguments
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -PackageParameters '/customA:""Path spaced"" /customB:""value""'
# upgrade package
Install-Package -Name $packageName -ProviderName Chocolatey-OneGet -Upgrade
```

## 7. Get installed package

To search for installed package is similar to searching for package in remote source by `Find-Package`. See examples

 > **NOTE:** Switch `-AllVersions` can't be used together with `-RequiredVersion` `-MinimumVersion` or `-MaximumVersion`

```powershell
# list all installed packages (only latest version per package)
Get-Package -ProviderName Chocolatey-OneGet
#find installed package by name
Get-Package -Name $packageName -ProviderName Chocolatey-OneGet
# find all installed package versions
Get-Package -Name $packageName -ProviderName Chocolatey-OneGet -AllVersions
# find required package version (similar usage by -MinimumVersion or -MaximumVersion)
Get-Package -Name $packageName -ProviderName Chocolatey-OneGet -RequiredVersion 2.18.0
```