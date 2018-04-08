# Chocolatey Provider for PowerShell PackageManagement

This is the official Chocolatey provider for PackageManagement (aka OneGet).

**NOTE:** For now, you may be more interested in using the ChocolateyGet provider as a stop gap solution until this provider is ready. See https://github.com/jianyunt/ChocolateyGet for details.

## Native powershell implementation

This part contains plain PowerShell implementation of the provider, development is done only in this part.

### [How to use it](/docs/howto.md)

### [Development](/docs/contributing.md)

### Progress

* Implement metadata - DONE
* Implement install able skeleton - DONE
* Prepare build and test infrastructure - DONE
* API:
  * Get-ProviderName - DONE
  * Initialize-Provider - DONE
  * Find-Package - TODO
  * Install-Package - TODO
  * Get-InstalledPackage - TODO
  * UnInstall-Package - TODO
  * Download-Package - TODO
  * Resolve-PackageSource - TODO
  * Add-PackageSource - IN PROGRESS
  * Remove-PackageSource - TODO

## C# implementation - OBSOLETE

The provider written in C# is obsolete. Requires windows SDK, which contains mt.exe to be able compile the project. No future development here is expected. Related files will be remoted later.

### Development Requires:

* Visual Studio 2013+
* Any official PackageManagement build from February 2015 or later.

## Contribution

**NOTE:** Seeking maintainers to help finish this Provider. Please inquire on the issues list or on Gitter (see the chat room below). Thanks!

Come join in the conversation about Chocolatey in our Gitter Chat Room.

[![Join the chat at https://gitter.im/chocolatey/chocolatey-oneget](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/chocolatey/chocolatey-oneget?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
