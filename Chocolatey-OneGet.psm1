function Get-PackageProviderName { 
    return "Chocolatey-OneGet";
}

function Initialize-Provider { 
    #nothing to do here.
}

function Get-Feature {
    Write-Output -InputObject (New-Feature -name "file-extensions" -values @(".nupkg"));
    Write-Output -InputObject (New-Feature -name "uri-schemes" -values @("http", "https", "file"));
}