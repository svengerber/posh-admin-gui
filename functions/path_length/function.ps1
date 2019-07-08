function Get-LongFilePaths ($path, $max_length) {
    Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {$_.FullName.Length -gt $max_length} | Select-Object FullName, @{Name="Path_Length";Expression={ $_.FullName.Length }}
}
function Open-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OF = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{SelectedPath = "$PSScriptRoot"}
    $OF.ShowDialog() | Out-Null
    $OF.SelectedPath
}

function Save-CSVFile()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $SF = New-Object System.Windows.Forms.SaveFileDialog
    $SF.initialDirectory = $PSScriptRoot   
    $SF.title = "Save CSV File to Disk"  
    $SF.Filter = "CSV Files|*.csv"
    $SF.ShowDialog() | Out-Null
    $SF.FileName
}    
#Define GUI Items

$pathlength_form_path = $Form.FindName("pathlengthtextpath")
$pathlength_form_length = $Form.FindName("pathlengthtextlength")
$pathlength_form_searchbutton = $Form.FindName("pathlengthsearchbutton")
$pathlength_form_selectbutton = $Form.FindName("pathlengthselectbutton")
$pathlength_form_exportbutton = $Form.FindName("pathlengthexportbutton")
$pathlength_form_datagrid = $Form.FindName("pathlengthdatagrid")

$pathlength_form_searchbutton.Add_Click({
    $pathlength_form_datagrid.Clear()
    $max_length = $pathlength_form_length.Text -as [int]
    $results = Get-LongFilePaths -path $pathlength_form_path.Text -max_length $max_length
    foreach ($result in $results)
    {
        $pathlength_form_datagrid.AddChild($result)
    }
})

$pathlength_form_selectbutton.Add_Click({
    $folder = Open-Folder
    $pathlength_form_path.Text = $folder
})

$pathlength_form_exportbutton.Add_Click({
    $csvpath = Save-CSVFile
    $results = Get-LongFilePaths -path $pathlength_form_path.Text -max_length $pathlength_form_length.Text -as [int]
    $results | Export-CSV -Path $csvpath
})

##EXAMPLE CODE
#. "$PSScriptRoot\files-folders\f-path.ps1"
#$items = Get-LongFilePaths -path "C:\Users\svenu\OneDrive\Music" -max_length "10"
#$items | Export-CSV -Path $PSScriptRoot\long-file-paths.csv
