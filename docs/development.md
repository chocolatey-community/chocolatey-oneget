# Provider development

## Prerequisities

* Recommended development environement is visual Studio Code with PowerShell extension
* Run build/prepareEnvironment.ps1 script to install all tools used for provider development, it installs used tools
* Used tools:
  * Pester - powershell testing framework
  * PackageManagement - Required dependency, we develop its plugin
  * Chocolatey - chocolatey library API
  * Paket - dependencies nuget packages downloader

## Development

* Build: Run "powershell Invoke-Psake" from build directory
* Outcome is stored in "Build\Output"
* Use "Invoke-Psake Publish" from build directory to publish into PsGet online repository

## Debugging

* If you are unable to import the module, restart powershell, maybe the chocolatey.dll is in use by the process
* From Visual studio Code with powershell extension, you can launch the predefined tasks. Keep in mind to kill the terminal to be able restart debugging