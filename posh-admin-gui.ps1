#Powershell Admin GUI
#Creator: Sven Gerber



# -------------------- Adding Prerequisites
Add-Type -AssemblyName System.Drawing, PresentationFramework, System.Windows.Forms, WindowsFormsIntegration



# -------------------- Global variables
$searchcomboxname = "searchcombox"
$searchcombox = $Form.$searchcomboxname
$pathfunctionuis = "$PSScriptRoot\functions\*\ui.xaml"
$pathguixmlraw = "$PSScriptRoot\data\gui\gui.xaml"
$pathstylexml = "$PSScriptRoot\data\gui\style.xaml"



# -------------------- Functions
function Add-FunctionsToGUI($GUI)
{
    $uis = Get-ChildItem -Path $pathfunctionuis
    foreach ($ui in $uis)
    {
        $add = Get-Content -Path $ui.FullName
        $alluis = $alluis + $add
    }
    $GUI = $GUI -replace "<!-- INSERT_FUNCTIONS_PLACEHOLDER -->", $alluis
    return $GUI
}



# -------------------- Preparing GUI 
#Generating XML to render
$inputXMLraw = Get-Content -Path $pathguixmlraw
$inputXML = $inputXMLraw -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
$inputXML = Add-FunctionsToGUI -GUI $inputXML

#Adding style to XML
$style = Get-Content -Path $pathstylexml
$inputXML = $inputXML -replace "<!-- INSERT_STYLE_PLACEHOLDER -->", $style

#Creating form with xml 
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

#Set Icon
$base64 = Get-Content "$PSScriptRoot\data\gui\icon.txt"
$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
$bitmap.EndInit()
$bitmap.Freeze()
$Form.Icon = $bitmap



# -------------------- Loading and adding functions 
#Loading Functions in Array with Properties name,creator,gridname
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

#Adding Funcions to Searchbox
Foreach ($function in $functions)
{
    $searchcombox.Items.Add($function.name)
}

#Set homegrid as visible
$homeGridname = "homegrid"
$Form.FindName($homeGridname).Visibility = "Visible"
$global:currentGRID = $Form.FindName($homeGridname)

#Loading ps1 scripts from functions
$func_files = Get-ChildItem -Recurse "$PSScriptRoot\functions\*\function.ps1"
foreach ($func_file in $func_files)
{
    . $func_file.FullName
}



# -------------------- Adding events to form
#Change GRID visibility based on selection
$searchcombox.add_SelectionChanged({
    $global:currentGRID.Visibility = "hidden"
    $selectedfuntion = ($functions | Where-Object {$_.Name -eq $searchcombox.SelectedItem})
    $global:currentGRID = $Form.FindName($selectedfuntion.gridname)
    $global:currentGRID.Visibility = "Visible"
})



# -------------------- Showing GUI

#With POSH Console for debugging
$form.ShowDialog() | Out-Null

#Without POSH Console
#$Form.Add_Closing({[System.Windows.Forms.Application]::Exit(); Stop-Process $pid})
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru 
#null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
#[System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($Form)
#$Form.Show()
#$Form.Activate()
#$appContext = New-Object System.Windows.Forms.ApplicationContext 
#[void][System.Windows.Forms.Application]::Run($appContext)