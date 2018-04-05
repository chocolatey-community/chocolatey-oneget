# How to use Chocolatey-OneGet package manager provider

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
$expectedName = "LocalProvider"
$sourceLocation "C:\LocalChocolateyPackages"
Register-PackageSource -ProviderName Chocolatey-OneGet -Name $expectedName -Location $sourceLocation
```