OneGet package provider Sample
========================

Provider SDK for OneGet (C#)


Quick and dirty instructions:

###  Requires: 
    - vs 2013 
    - YOU MUST BE RUNNING THE Experimental build of ONEGET : http://oneget.org/install-oneget.exe 

### procedure
- fork the project at https://github.com/OneGet/ProviderSdk to your own account
- rename the project to something useful
- clone your project to your local machine
- edit the packageprovider.c# script and change the name in the source (ie https://github.com/OneGet/ProviderSdk/blob/master/PackageProvider.cs#L64 )
- you should also change the project output name in the `.csproj` to something other than `"SampleProvider.dll" `
- and update the install-provider.ps1 script with the correct output name. 

Once you build the provider script, run the install-provider.ps1 script and it will copy the assembly to the right spot.

Then:

``` powershell

# need to run the community build.
> ipmo oneget-edge 

# see if it loaded your provider assembly:
> get-packageprovider 

PS C:\root\oneget\output\v45\Debug\bin> get-packageprovider
WARNING: MSG:ProviderSwidtagUnavailable

Name                     Version          DynamicOptions
----                     -------          --------------
YourProvider           1.0.0.0          {}

```

Clone the project locally and you can then add an upstream remote:
    
``` bash
    git clone https://github.com/YOURNAME/YOURPROJECT.git
   
    git remote add remote upstream https://github.com/OneGet/provider-sdk-cs.git
    
```

Next, fill in the values for your project:

``` powershell
    .\initialize-project.ps1 -
```

When you need to, you can always pull updates to the OneGet provider SDK by simply:
    
``` bash
    git pull upstream master
    
```

