# Only output the used package parameters to text file
$packageArgs = Get-PackageParameters
Write-Host "Used Test package arguments:"
$packageArgs | ConvertTo-Json | Write-Host
$installLog = "$env:ChocolateyInstall\lib\TestPackage\UsedParams.txt"
$packageArgs | ConvertTo-Json | Out-File $installLog