# by default it will find the newest $providerName.dll and copy it to the right location
# (change the default value of $providerName when you change your provider name )
# otherwise you can say 'debug' or 'release' for the $build
Param( [string]$build = '', [string]$providerName = 'SampleProvider' )

$orig = (pwd)
cd $PSScriptRoot

$candidates = dir -recurse "output\$providerName.dll"  | sort -Descending -Property LastWriteTime

if( $build ) {
    $candidates = dir -recurse "output\$providerName.dll"  | sort -Descending -Property LastWriteTime | ?{ $_ -match $build }
}  else {
    $candidates = dir -recurse "output\$providerName.dll"  | sort -Descending -Property LastWriteTime
}

$provider = $candidates | select -first 1

if( -not $provider ) {
    write-host -fore red "Can't find matching provider '$providerName.dll' in output folder with '$build' somewhere in the path`n"
    cd $orig 
    return
}
$srcpath = $provider.Fullname
$filename = $provider.Name


$output = "$env:localappdata\oneget\providerassemblies\$fileName"
if( test-path $output ) {
    write-host -fore white "Deleting old provider from `n   '$output' `n"
    # delete the old provider assembly
    # even if it's in use.
    $tmpName = "$filename.delete-me.$(get-random)"
    $tmpPath = "$env:localappdata\oneget\providerassemblies\$tmpName"
    
    ren $output $tmpName -force -ea SilentlyContinue 
    erase -force -ea SilentlyContinue $tmpPath
    if( test-path $tmpPath ) {
        #locked. Move to temp folder
        write-host -fore yellow "Old provider is in use, moving to `n   '$env:TEMP' folder `n"
        move $tmpPath $env:TEMP
        write-host -fore yellow "Moved old provider out of the way, you must restart any processes using the it. `n"
    }
    
    if( test-path $output ) {
        write-host -fore red "Can't remove existing file: `n $output `n"
        cd $orig 
        return
    }
  
}

write-host -fore green "copying provider assembly `n   '$srcpath' `n=> '$output' `n"
copy -force $srcPath $output

cd $orig


