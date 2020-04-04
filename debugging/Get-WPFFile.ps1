function Add-FunctionsToGUI($GUI)
{
    $uis = Get-ChildItem -Path "$PSScriptRoot\..\functions\*\ui.xaml" 
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $alluis = $alluis + $add
    }
    $GUI = $GUI -replace "<!-- INSERT_FUNCTIONS_PLACEHOLDER -->", $alluis
    return $GUI
}

###GENERATING GUI
$inputXMLraw = Get-Content "$PSScriptRoot\..\data\gui\gui.xaml"
$inputXML = $inputXMLraw -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML = Add-FunctionsToGUI -GUI $inputXML

#Add Style
$style = Get-Content "$PSScriptRoot\..\data\gui\style.xaml"
$inputXML = $inputXML -replace "<!-- INSERT_STYLE_PLACEHOLDER -->", $style

Set-Clipboard -Value $inputXML

Write-Host "WPF has been copied to Clipboard"

Pause