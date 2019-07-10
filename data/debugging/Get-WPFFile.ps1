function Add-FunctionsToGUI($inputXML1)
{
    $uis = Get-ChildItem -Path "..\..\functions\*\ui.xaml" 
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $inputXML1 = $inputXML1 + $add
    }
    return $inputXML1
}


###GENERATING GUI
$inputXML1 = Get-Content "..\gui\gui-1.xaml"
$inputXML2 = Get-Content "..\gui\gui-2.xaml"
$inputXML1 = $inputXML1 -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML1 = Add-FunctionsToGUI -inputXML1 $inputXML1
$inputXML = $inputXML1 + $inputXML2
#Add Style
$style = Get-Content "..\gui\style.xaml"
$inputXML = $inputXML -replace "<!-- INSERT_STYLE -->", $style

Set-Clipboard -Value $inputXML

Write-Host "WPF has been copied to CLipboard"

Pause