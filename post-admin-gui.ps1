#Powershell Admin GUI
#Functions
function Add-FunctionsGUI($inputXML1)
{
    $uis = Get-ChildItem -Path "$PSScriptRoot\functions\*\ui.xaml" 
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $inputXML1 = $inputXML1 + $add
    }
    return $inputXML1
}

#DEFINE FORM ITEMS
$searchcomboxname = "searchcombox"

$searchcombox = $Form.$searchcomboxname


###GENERATING GUI
$inputXML1 = Get-Content "$PSScriptRoot\data\gui\gui-1.xaml"
$inputXML2 = Get-Content "$PSScriptRoot\data\gui\gui-2.xaml"
$inputXML1 = $inputXML1 -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML1 = Add-FunctionsGUI -inputXML1 $inputXML1
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





###LOADING FUNCTION PROPERTIES IN ARRAY
$prop_files = Get-ChildItem -Recurse "$PSScriptRoot\functions\*\properties.json"
$functions = @()
foreach ($prop_file in $prop_files)
{
    $props = (Get-Content $prop_file.FullName | ConvertFrom-Json)
    $object = New-Object -TypeName PSObject
    $object | Add-Member -Name 'name' -MemberType Noteproperty -Value $props.name
    $object | Add-Member -Name 'creator' -MemberType Noteproperty -Value $props.creator
    $object | Add-Member -Name 'gridname' -MemberType Noteproperty -Value $props.gridname
    $functions += $object
}


###Adding Funcions to Searchbox
Foreach ($function in $functions)
{
    $searchcombox.Items.Add($function.name)
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

