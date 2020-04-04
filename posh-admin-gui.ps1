#Powershell Admin GUI
#Functions
function Add-FunctionsToGUI($GUI)
{
    $uis = Get-ChildItem -Path "$PSScriptRoot\functions\*\ui.xaml" 
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $alluis = $alluis + $add
    }
    $GUI = $GUI -replace "<!-- INSERT_FUNCTIONS_PLACEHOLDER -->", $alluis
    return $GUI
}

#DEFINE FORM ITEMS
$searchcomboxname = "searchcombox"
$searchcombox = $Form.$searchcomboxname

Add-Type -AssemblyName System.Drawing, PresentationFramework, System.Windows.Forms, WindowsFormsIntegration
$base64 = Get-Content "$PSScriptRoot\data\gui\icon.txt"
$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
$bitmap.EndInit()
$bitmap.Freeze()

###GENERATING GUI
$inputXMLraw = Get-Content "$PSScriptRoot\data\gui\gui.xaml"
$inputXML = $inputXMLraw -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML = Add-FunctionsToGUI -GUI $inputXML

#Add Style
$style = Get-Content "$PSScriptRoot\data\gui\style.xaml"
$inputXML = $inputXML -replace "<!-- INSERT_STYLE_PLACEHOLDER -->", $style

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

###Set Icon
$Form.Icon = $bitmap

###Adding Funcions to Searchbox
Foreach ($function in $functions)
{
    $searchcombox.Items.Add($function.name)
}

#Loading Functions
$func_files = Get-ChildItem -Recurse "$PSScriptRoot\functions\*\function.ps1"
foreach ($func_file in $func_files)
{
    . $func_file.FullName
}

###Define Current GRID and Creator Name
$searchcombox.add_SelectionChanged({
    $global:currentGRID.Visibility = "hidden"
    $selectedfuntion = ($functions | Where-Object {$_.Name -eq $searchcombox.SelectedItem})
    $global:currentGRID = $Form.FindName($selectedfuntion.gridname)
    $global:currentGRID.Visibility = "Visible"
})

##Show Home Grid
$homeGridname = "homegrid"
$Form.FindName($homeGridname).Visibility = "Visible"
$global:currentGRID = $Form.FindName($homeGridname)


###Für Darstellung mit Konsole
$form.ShowDialog() | Out-Null


###Für Darstellung ohne Powershell Konsole
#$Form.Add_Closing({[System.Windows.Forms.Application]::Exit(); Stop-Process $pid})
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru 
#null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
#[System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($Form)
#$Form.Show()
#$Form.Activate()
#$appContext = New-Object System.Windows.Forms.ApplicationContext 
#[void][System.Windows.Forms.Application]::Run($appContext)