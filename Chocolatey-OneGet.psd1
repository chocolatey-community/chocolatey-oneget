#
# Module manifest for module 'Chocolatey-OneGet'
#

@{

    RootModule = 'Chocolatey-OneGet.psm1'
    ModuleVersion = '0.10.9' # aligned with choco.lib for now
    GUID = 'a628941d-1047-4fa2-917f-5c7e9fdb9189'
    Author = 'Chocolatey'
    CompanyName = 'Chocolatey'
    Copyright = '(c) 2018 Chocolatey'
    Description = 'The Official provider for Chocolatey 0.10.9 packages, that manages packages from https://www.chocolatey.org.'
    PowerShellVersion = '5.0'
    DotNetFrameworkVersion = '4.0'
    CLRVersion = '4.0'
    RequiredModules = @('PackageManagement')
    RequiredAssemblies = @("chocolatey.dll")
    NestedModules = @('Chocolatey-Helpers.psm1')

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    FunctionsToExport = @("Register-ChocoDefaultSource")

    # List of all files packaged with this module
    FileList = @("chocolatey.dll", "Chocolatey-OneGet.psd1", "Chocolatey-OneGet.psm1", "log4net.dll")

    # we dont support updatable help
    # HelpInfoURI = ''

    PrivateData = @{

        "PackageManagementProviders" = 'Chocolatey-OneGet.psm1'

        PSData = @{

            Tags = @("PackageManagement","Provider")
            LicenseUri = 'https://github.com/chocolatey/chocolatey-oneget/blob/master/LICENSE'
            ProjectUri = 'https://github.com/chocolatey/chocolatey-oneget'
            IconUri = 'https://raw.githubusercontent.com/chocolatey/choco/master/docs/logo/chocolateyicon.gif'
            ReleaseNotes = 'https://github.com/chocolatey/chocolatey-oneget/releases'
            ExternalModuleDependencies = @('PackageManagement')
        }
  }
}
