# Provider development

## Prerequisities

* Recommended development environnement is visual Studio Code with PowerShell extension
* Run build/prepareEnvironment.ps1 script to install all tools used for provider development, it installs used tools
* Used tools:
  * Pester - powershell testing framework
  * PackageManagement - Required dependency, we develop its plugin
  * Chocolatey - chocolatey library API
  * Paket - dependencies nuget packages downloader

## Development

* Build: Run ```build\build.ps1```
* Outcome is stored in "Build\Output"
* Use "Invoke-Psake Publish" from build directory to publish into PsGet online repository

## Debugging

* If you are unable to import the module, restart powershell, maybe the chocolatey.dll is in use by the process
* From Visual studio Code with powershell extension, you can launch the predefined tasks. Keep in mind to kill the terminal to be able restart debugging
* When debugging tests, breakpoint in the module script wouldnt hit directly, stop on break point in the test, then manually step into the provider method. After that breakpoint inside the provider should hit.
* To run only selected test add wildcard filter into the $testFilter parameter in psakeFile.ps1
* See also [OneGet debugging](https://github.com/OneGet/oneget/blob/WIP/docs/writepowershellbasedprovider.md#debugging-your-provider)