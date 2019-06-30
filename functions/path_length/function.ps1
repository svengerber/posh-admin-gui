function Get-LongFilePaths ($path, $max_length) {
    Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName.Length -gt $max_length} | Select-Object FullName, @{Name="Path_Length";Expression={ $_.FullName.Length }}
}

##EXAMPLE CODE
#. "$PSScriptRoot\files-folders\f-path.ps1"
#$items = Get-LongFilePaths -path "C:\Users\svenu\OneDrive\Music" -max_length "10"
#$items | Export-CSV -Path $PSScriptRoot\long-file-paths.csv
