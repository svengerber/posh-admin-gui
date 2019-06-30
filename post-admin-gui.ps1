#Powershell Admin GUI
#Functions
function Add-Functions($inputXML1)
{
    $uis = Get-ChildItem -Path "$PSScriptRoot\functions\*\ui.xaml" 
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $inputXML1 = $inputXML1 + $add
    }
    return $inputXML1
}

###LOADING FUNCTION PROPERTIES
$functions = Get-Content "$PSScriptRoot\functions\*\properties.json" | ConvertFrom-Json

Write-Host $functions
Pause



###GENERATING GUI
$inputXML1 = Get-Content "$PSScriptRoot\data\gui\gui-1.xaml"
$inputXML2 = Get-Content "$PSScriptRoot\data\gui\gui-2.xaml"
$inputXML1 = $inputXML1 -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML1 = Add-Functions -inputXML1 $inputXML1
$inputXML = $inputXML1 + $inputXML2

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
  
$xaml.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }

$form.ShowDialog() | Out-Null








###WEITERE Beispiele

########################
#Manipulate the XAML
########################

#$bSubmit.Content = "This Button"
#$lLabel.Content = "Ehhhh"
#$tbUsername.Text = "UserName"

########################
#Add Event Handlers
########################

#$bSubmit.Add_Click({
 #   
  ##  if ($tbUsername.Text -ne "" -and $tbUsername.Text -ne "UserName" -and $pbPassword.Password -ne "") {
#
 ###       $lLabel.Content = "You pressed the button."
#
 #       }
#
 #   })

#Show the Form

