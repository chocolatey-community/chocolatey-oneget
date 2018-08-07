$installLog = "$env:ChocolateyInstall\lib\TestPackage\UsedParams.txt"
Remove-Item $installLog -ErrorAction SilentlyContinue | Out-Null