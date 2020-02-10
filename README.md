# Chocolatey Provider for PowerShell PackageManagement

This is the official Chocolatey provider for PackageManagement (aka OneGet).

## Features

* search/find installed/install/uninstall packages
* upgrade packages
* download package
* manage package sources
* online/offline installation

## [How to use it](/docs/howto.md)

## [License](LICENSE)

# [Development](/docs/contributing.md)

## Progress

* [x] Implement metadata
* [x] Implement install able skeleton
* [x] Prepare build and test infrastructure
* API:
  * [x] Get-ProviderName
  * [x] Initialize-Provider
  * [x] Resolve-PackageSource
  * [x] Add-PackageSource
  * [x] Remove-PackageSource
  * [x] Find-Package
  * [x] Install-Package
  * [x] Get-InstalledPackage
  * [x] UnInstall-Package
  * [ ] Download-Package - IN PROGRESS

## Not implemented
* Trusted package sources
* Disable package source
* Custom credentials in Find-Package
* Advanced chocolatey switches

## Contribution

> **NOTE:** Seeking maintainers to help finish this Provider. Please inquire on the issues list or on Gitter (see the chat room below). Thanks!

Come join in the conversation about Chocolatey in our Gitter Chat Room.

[![Join the chat at https://gitter.im/chocolatey/chocolatey-oneget](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/chocolatey/chocolatey-oneget?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
