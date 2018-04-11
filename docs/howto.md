# How to use Chocolatey-OneGet provider

## 1. Install the module

You can install the module from PowershellGet online repository:

```powershell
Import-Module -Name PackageManagement
Install-Module -Name Chocolatey-OneGet
```

You can also copy the provider directory to your modules folder, when the online galery isnt available (usually "$home\WindowsPowerShell\Modules").

```powershell
Import-Module Chocolatey-OneGet
Import-PackageProvider -Name Chocolatey-OneGet
```

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

> **NOTE**: All additional parameters used in this provider follow the chocolatey command line options, so for more details about their values usage, refer directly to [chocolatey documentation](https://github.com/chocolatey/choco/wiki/CommandsReference).

If your package source needs authenticate you can use credentials powershell object (as standard One-Get parameter) or crertificate via additional parameters. Both have the same behavior like chocolatey command line.

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

By default chocolatey installs default package source. When you install this provider only, no package source is added by default. Purpose for this is enterprice environment, where comapnies want to use their local package source only. Wildcards are supported in source names. When no filter is provided all sources are returned.
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