###
# Lists
###

$appxpkgBloatware = @( # List of bloatware apps found in fresh Windows 10 installs
    "*Skype*"
    "*Zune*"
    "*Phone*"
    "*WindowsMaps*"
    "*Wallet*"
    "*People*"
    "*Office*"
    "*MixedReality*"
    "*MicrosoftStickyNotes*"
    "*Bing*"
    "*Microsoft.windowscommunicationsapps*"
    "*Alarms*"
    "*SpeechToText*"
    "*Xbox*"
    "*SoundRecorder*"
    "*Maps*"
    "*FeedbackHub*"
    "*ScreenSketch*"
    "*3DViewer*"
    "*GetHelp*"
    "*Getstarted*"
)

# Serves as a second-choice if some package is not in the Chocolatey store
# Must be .msi, and must be passed as args to dlinstallMsi
$urls = @{
    chrome = (
        "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B09B9C350-1334-3F2F-99A6-0A8B4646FAA9%7D%26lang%3Den%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi",
        "chrome.msi"
    );
    anydesk = (
        "https://download.anydesk.com/AnyDesk.msi",
        "anydesk.msi"
    );
    rgc = (
        "https://www.regisoft.com.ar/descargas/RCG_Educativo.msi",
        "rgc.msi"
    );
    tuxpaint = (
        "https://downloads.sourceforge.net/project/tuxpaint/tuxpaint/0.9.32/tuxpaint-0.9.32-windows-x86_64-installer.exe?ts=gAAAAABl4S5Dm4hYWZBvZPe-WLX1kyzpKjINRhJPRZi6_BBOgkoDCTE7dvKyyxyJHJwrR2EA7OIWZ-KAoTT-q_xsRlPASSHG8Q==&use_mirror=sitsa&r=",
        "tuxpaint.exe"
    );
    pilasbloques = (
        "https://github.com/Program-AR/pilas-bloques-app/releases/download/2.5.0/pilasbloques-2.5.0-win-portable.zip",
        "pilasbloques.zip"
    )
}

###
# Functions (WIP)
###

# Utilities

# Checks for Chocolatey existence and if not found, installs it from the Chocolatey website
function checkChoco {
    try {
        Get-Command -Name Choco -ErrorAction Stop
        Write-Host "Chocolatey found, proceeding..." -ForegroundColor Green
    }
    catch {
        Write-Host "Chocolatey not found, installing..." -ForegroundColor Red
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
   }
}

# Download and install a .msi file passively with a given URL and path
function dlinstallMsi { 
    # Example: dlinstallMsi -url $urls.anydesk[0] -path $urls.anydesk[1]
    param(
        [string]$url,
        [string]$path
    )
    $ProgressPreference = 'SilentlyContinue' # Supress progress bar which, for whatever reason, improves download speeds by a lot
    Invoke-WebRequest -Uri $url -OutFile $path
    Start-Process -FilePath $path -ArgumentList "/passive" -Wait
    Remove-Item -Path $path -Force
}

# Looks for explorer.exe independent of PID, kills it and starts explorer.exe again
function restartExplorer {
    taskkill /f /im explorer.exe
    Start-Process explorer.exe
}

###
# Messages
###

function messageError {
    Write-Host "$error" -ForegroundColor Red
}

function messageSuccess {
    Write-Host "Done!" -ForegroundColor Green
}

function messageStarting {
    Write-Host "Starting..." -ForegroundColor Green
}

function popupDone {
    [System.Windows.Forms.MessageBox]::Show("Done!")
}

###
# Debloating (WIP)
###

# Disable/Enable Windows explorer web search
# Tested and working on 22H2 19045.2006
function disableExplorerWebSearch { # Disable Bing web search on Start Menu through registry keys, if Registry Key exists, change their values so that web search gets disabled
    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
        New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
        New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search")){
        New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search")){
        New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    }

    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch")){
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1

    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\BingSearchEnabled")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "BingSearchEnabled" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 # For W10 1909 or older
}

function enableExplorerWebSearch {
        If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
            New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        }
    
        If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
            New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        }
    
        If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search")){
            New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        }
    
        If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search")){
            New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        }    
    
        If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch")){
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 0 -PropertyType "DWord"
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 0
    
        If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled")){
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "BingSearchEnabled" -Value 1 -PropertyType "DWord"
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 1 # For W10 1909 or older
}

# Disable/Enable Telemetry
# Tested and working on 22H2 19045.2006
function disableTelemetry {
    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
        New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    }
    Stop-Service -Name DiagTrack
    Set-Service -Name DiagTrack -StartupType Manual

    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation")){
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Value 0

    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry")){
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
}

function enableTelemetry {
        If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
            New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        }

        Start-Service -Name DiagTrack
        Set-Service -Name DiagTrack -StartupType Automatic

        If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation")){
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Value 1 -PropertyType "DWord"
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Value 1

        If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry")){
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1 -PropertyType "DWord"
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1
}

# Disable/Enable IPv6 functions
# Tested and working on 22H2 19045.2006
function disableIpv6functions {
    try {
        Stop-Service -Name iphlpsvc
        Set-Service -Name iphlpsvc -StartupType Manual
    }
    catch {
        messageError
    }
}

function enableIpv6functions {
    try {
        Start-Service -Name iphlpsvc
        Set-Service -Name iphlpsvc -StartupType Automatic
    }
    catch {
        messageError
    }
}

# Enable/Disable Light Theme
# Tested and working on 22H2 19045.2006
function disableLighttheme {
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
}

function enableLighttheme {
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
}

# Enable/Disable Notifications
# Tested and working on 22H2 19045.2006
function disableNotifications {
    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")){
        New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" # Test for Explorer, if not existing, create it
    }

    If(!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer\DisableNotificationCenter")){
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 1 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 1
    restartExplorer
}

function enableNotifications {
    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")){
        New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer\DisableNotificationCenter")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 0
    restartExplorer
}

###
# Non-Reversible tweaks
###

# Remove all the Windows programs specified the bloatware array
# Tested and working on 22H2 19045.2006
function removeBloatware { 
    foreach ($program in $appxpkgBloatware){
        Get-AppxPackage $program | Remove-AppxPackage
    }
}


# Uninstall Cortana and turn off registry keys related to the program
# Tested and working on 22H2 19045.2006
function removeCortana {
    $Cortana1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortanaAboveLock"
    $Cortana2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana"

    # Check for "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" existence
    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")){
        New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" # Test for Windows Search, if not existing, create it
    }

    If(!(Test-Path $Cortana1)) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Value 0

    If (!(Test-Path $Cortana2)) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
    
    # Removes Cortana as a program therefore removing the icon from the taskbar
    Get-AppxPackage *549981C3F5F10* | Remove-AppxPackage
}

# Clear Taskbar by modifying registry keys
# Tested and working on 22H2 19045.2006
function clearTaskbar {
    # Check for folders required for writing new keys, if non existing, create them
    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")){
        New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")){
        New-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    }

    If(!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")){
        New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
    }

    # Remove Meet Now button
    If(!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\HideSCAMeetNow")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 0

    # Remove News and Interests
    If(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\EnableFeeds")){
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0

    # Remove Windows Store button
    If(!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer\NoPinningStoreToTaskbar")){
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoPinningStoreToTaskbar" -Value 1 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoPinningStoreToTaskbar" -Value 1

    # Doesn't seem to be currently working.
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoShellSearchButton")){
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoShellSearchButton" -Value 1 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoShellSearchButton" -Value 1

    # Remove Huge Search button
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

    # Doesn't seem to be currently working either.
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\StoreAppsOnTaskbar")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StoreAppsOnTaskbar" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StoreAppsOnTaskbar" -Value 0

    # Remove Task View button
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

    # It's supposed to work the same as editing News and Interests from gpedit but, for some reason, it doesn't work at all.
    # Should work according to the official Microsoft documentation https://www.microsoft.com/en-us/download/details.aspx?id=104678
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\ShellFeedsTaskbarViewMode")){
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -PropertyType "DWord"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2

    restartExplorer
}

###
# Programs
###

###
# Browsers
###

function installChrome {
    choco install googlechrome -y
}

function installFirefox {
    choco install firefox -y
}

function installEdge {
    choco install microsoft-edge -y
}

function installChromium {
    choco install chromium -y
}

function installBrave {
    choco install brave -y
}

function installOpera {
    choco install opera -y
}

function installOperagx {
    choco install opera-gx -y
}

function installLibrewolf {
    choco install librewolf -y
}

###
# Productivity
###

function installAnydesk {
    dlinstallMsi -url $urls.anydesk[0] -path $urls.anydesk[1]
}

function installTeamviewer {
    choco install teamviewer -y
}

function installLibreoffice {
    choco install libreoffice-fresh -y
}

function installZoom {
    choco install zoom -y
}

function installMicrosoftteams {
    choco install microsoft-teams.install -y
}

function installSlack {
    choco install slack -y
}

function installAdobeacrobatreader {
    choco install adobereader -y
}

###
# Educational
###

function installScratch {
    choco install scratch -y
}

function installGcompris {
    choco install gcompris -y
}

function installTuxpaint {
    dlinstallMsi -url $urls.tuxpaint[0] -path $urls.tuxpaint[1]
}

function installPilasBloques {
    $desktopTarget = Join-Path $env:USERPROFILE 'Desktop\pilasbloques'
    $ProgressPreference = 'SilentlyContinue' # Supress progress bar which, for whatever reason, improves download speeds by a lot
    Invoke-WebRequest -Uri $urls.pilasbloques[0] -OutFile $urls.pilasbloques[1]
    Expand-Archive $urls.pilasbloques[1] -DestinationPath "./"
    Copy-Item '.\pilasbloques-win32-ia32' -Destination 'C:\Program Files\' -Recurse
    New-Item -ItemType SymbolicLink -Path $desktopTarget -Target "C:\Program Files\pilasbloques-win32-ia32\pilasbloques.exe"
    Remove-Item -Path $urls.pilasbloques[1] -Force
    Remove-Item -Path ".\pilasbloques-win32-ia32" -Force -Recurse
}

function installRegisoftcontabilidad {
    dlinstallMsi -url $urls.rgc[0] -path $urls.rgc[1]
}

###
# Utilities
###

function install7zip {
    choco install 7zip -y
}

function installWinrar {
    choco install winrar -y
}

function installQbittorrent {
    choco install qbittorrent -y
}


function installCcleaner {
    choco install ccleaner -y
}

function installVirtualbox {
    choco install virtualbox -y
}

###
# Development
###

function installPython {
    choco install python3 -y
}

function installDotNET {
    choco install dotnetfx -y
}

function installGit {
    choco install git.install -y
}

function installVscode {
    choco install vscode -y
}

###
# Tools
###

function installPutty {
    choco install putty -y
}

function installCrystaldiskinfo {
    choco install crystaldiskinfo -y
}


function installMalwarebytes {
    choco install malwarebytes -y
}

function installWiztree {
    choco install wiztree -y
}


# Multimedia

function installGimp {
    choco install gimp -y
}

function installAudacity {
    choco install audacity -y
}

function installVlc {
    choco install vlc -y
}

###
# GUI
###

# Generated with ConvertForm module version 2.0.0, all credit goes to LaurentDardenne
# https://github.com/LaurentDardenne
# Link to the repository for this tool: https://github.com/LaurentDardenne/ConvertForm

# Loading external assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



$FMmain = New-Object System.Windows.Forms.Form
$TCmain = New-Object System.Windows.Forms.TabControl
$TPutilities = New-Object System.Windows.Forms.TabPage
$BTclearall = New-Object System.Windows.Forms.Button
$BTruntweaks = New-Object System.Windows.Forms.Button
$GBmoretweaks = New-Object System.Windows.Forms.GroupBox
$CBcleartaskbar = New-Object System.Windows.Forms.CheckBox
$CBremovecortana = New-Object System.Windows.Forms.CheckBox
$CBremovebloat = New-Object System.Windows.Forms.CheckBox
$GBtweaks = New-Object System.Windows.Forms.GroupBox
$GBtweaknotifications = New-Object System.Windows.Forms.GroupBox
$RBenablenotifs = New-Object System.Windows.Forms.RadioButton
$RBdisablenotifs = New-Object System.Windows.Forms.RadioButton
$GBtweaklighttheme = New-Object System.Windows.Forms.GroupBox
$RBenablelighttheme = New-Object System.Windows.Forms.RadioButton
$RBdisablelighttheme = New-Object System.Windows.Forms.RadioButton
$GBtweakipv6 = New-Object System.Windows.Forms.GroupBox
$RBenableipv6services = New-Object System.Windows.Forms.RadioButton
$RBdisableipv6services = New-Object System.Windows.Forms.RadioButton
$GBtweaktelemetry = New-Object System.Windows.Forms.GroupBox
$RBenabletelemetry = New-Object System.Windows.Forms.RadioButton
$RBdisabletelemetry = New-Object System.Windows.Forms.RadioButton
$GBtweakstartmenu = New-Object System.Windows.Forms.GroupBox
$RBenablewebsearch = New-Object System.Windows.Forms.RadioButton
$RBdisablewebsearch = New-Object System.Windows.Forms.RadioButton
$TPprograms = New-Object System.Windows.Forms.TabPage
$BTinstallprograms = New-Object System.Windows.Forms.Button
$GBmultimedia = New-Object System.Windows.Forms.GroupBox
$CBinstallaudacity = New-Object System.Windows.Forms.CheckBox
$CBinstallgimp = New-Object System.Windows.Forms.CheckBox
$CBinstallvlc = New-Object System.Windows.Forms.CheckBox
$GBtools = New-Object System.Windows.Forms.GroupBox
$CBinstallwiztree = New-Object System.Windows.Forms.CheckBox
$CBinstallcrystaldisk = New-Object System.Windows.Forms.CheckBox
$CBinstallmalwarebytes = New-Object System.Windows.Forms.CheckBox
$CBinstallputty = New-Object System.Windows.Forms.CheckBox
$GBdevelopment = New-Object System.Windows.Forms.GroupBox
$CBinstallvscode = New-Object System.Windows.Forms.CheckBox
$CBinstallgit = New-Object System.Windows.Forms.CheckBox
$CBinstalldotnet = New-Object System.Windows.Forms.CheckBox
$CBinstallpython = New-Object System.Windows.Forms.CheckBox
$GButilities = New-Object System.Windows.Forms.GroupBox
$CBinstallqbittorrent = New-Object System.Windows.Forms.CheckBox
$CBinstallvirtualbox = New-Object System.Windows.Forms.CheckBox
$CBinstallccleaner = New-Object System.Windows.Forms.CheckBox
$CBinstallwinrar = New-Object System.Windows.Forms.CheckBox
$CBinstall7zip = New-Object System.Windows.Forms.CheckBox
$GBproductivity = New-Object System.Windows.Forms.GroupBox
$CBinstallslack = New-Object System.Windows.Forms.CheckBox
$CBinstalladobereader = New-Object System.Windows.Forms.CheckBox
$CBinstallteams = New-Object System.Windows.Forms.CheckBox
$CBinstallzoom = New-Object System.Windows.Forms.CheckBox
$CBinstalllibreoffice = New-Object System.Windows.Forms.CheckBox
$CBinstallteamviewer = New-Object System.Windows.Forms.CheckBox
$CBinstallanydesk = New-Object System.Windows.Forms.CheckBox
$GBeducational = New-Object System.Windows.Forms.GroupBox
$CBinstallregisoftcont = New-Object System.Windows.Forms.CheckBox
$CBinstallpilasbloques = New-Object System.Windows.Forms.CheckBox
$CBinstalltuxpaint = New-Object System.Windows.Forms.CheckBox
$CBinstallgcompris = New-Object System.Windows.Forms.CheckBox
$CBinstallscratch = New-Object System.Windows.Forms.CheckBox
$GBnavigation = New-Object System.Windows.Forms.GroupBox
$CBinstalloperagx = New-Object System.Windows.Forms.CheckBox
$CBinstalllibrewolf = New-Object System.Windows.Forms.CheckBox
$CBinstallopera = New-Object System.Windows.Forms.CheckBox
$CBinstallbrave = New-Object System.Windows.Forms.CheckBox
$CBinstallchromium = New-Object System.Windows.Forms.CheckBox
$CBinstalledge = New-Object System.Windows.Forms.CheckBox
$CBinstallfirefox = New-Object System.Windows.Forms.CheckBox
$CBinstallchrome = New-Object System.Windows.Forms.CheckBox
$TPhelp = New-Object System.Windows.Forms.TabPage
$menuStrip1 = New-Object System.Windows.Forms.MenuStrip
$menuStrip2 = New-Object System.Windows.Forms.MenuStrip
$MSmain = New-Object System.Windows.Forms.ToolStripMenuItem
$MSIgithub = New-Object System.Windows.Forms.ToolStripMenuItem
$GBdocumentationlink = New-Object System.Windows.Forms.GroupBox
$LBdocumentation = New-Object System.Windows.Forms.LinkLabel
$LBhelptext = New-object System.Windows.Forms.Label
$GBcat = New-Object System.Windows.Forms.GroupBox

# TCmain
$TCmain.Controls.Add($TPutilities)
$TCmain.Controls.Add($TPprograms)
$TCmain.Controls.Add($TPhelp)
$TCmain.Location = New-Object System.Drawing.Point(12, 27)
$TCmain.Name = "TCmain"
$TCmain.SelectedIndex = 0
$TCmain.Size = New-Object System.Drawing.Size(760, 511)
$TCmain.TabIndex = 0

# GBmoretweaks
$GBmoretweaks.Controls.Add($CBcleartaskbar)
$GBmoretweaks.Controls.Add($CBremovecortana)
$GBmoretweaks.Controls.Add($CBremovebloat)
$GBmoretweaks.Location = New-Object System.Drawing.Point(3, 317)
$GBmoretweaks.Name = "GBmoretweaks"
$GBmoretweaks.Size = New-Object System.Drawing.Size(743, 133)
$GBmoretweaks.TabIndex = 1
$GBmoretweaks.TabStop = $false
$GBmoretweaks.Text = "More Tweaks (Non-reversible)"


# TPutilities
$TPutilities.Controls.Add($BTclearall)
$TPutilities.Controls.Add($BTruntweaks)
$TPutilities.Controls.Add($GBmoretweaks)
$TPutilities.Controls.Add($GBtweaks)
$TPutilities.Location = New-Object System.Drawing.Point(4, 22)
$TPutilities.Name = "TPutilities"
$TPutilities.Padding = New-Object System.Windows.Forms.Padding(3, 3, 3, 3)
$TPutilities.Size = New-Object System.Drawing.Size(752, 485)
$TPutilities.TabIndex = 0
$TPutilities.Text = "Utilities"
$TPutilities.UseVisualStyleBackColor = $true


# BTclearall
$BTclearall.Location = New-Object System.Drawing.Point(380, 456)
$BTclearall.Name = "BTclearall"
$BTclearall.Size = New-Object System.Drawing.Size(100, 23)
$BTclearall.TabIndex = 3
$BTclearall.Text = "Clear All"
$BTclearall.UseVisualStyleBackColor = $true
$BTclearall.add_click({
    # Uncheck all
    $Controls = $null
    # Iterate over both Group Boxes in the first page and add their Controls
    Foreach ($GB in $GBtweaks.Controls){
        $Controls = $Controls + $GB.Controls # Access each GB's controls and add them to $Controls
    }

    Foreach ($CB in $GBmoretweaks.Controls){
        $Controls = $Controls + $CB # This one doesn't need any recursion 
    }

    # For every Control, if its state is true, reset to false
    Foreach ($control in $Controls) {
        If ($control.Checked -eq $true){
            $control.Checked = $false
        }
    }
})

# BTruntweaks
$BTruntweaks.FlatStyle = [System.Windows.Forms.FlatStyle]::System
$BTruntweaks.Location = New-Object System.Drawing.Point(274, 456)
$BTruntweaks.Name = "BTruntweaks"
$BTruntweaks.Size = New-Object System.Drawing.Size(100, 23)
$BTruntweaks.TabIndex = 2
$BTruntweaks.Text = "Run Tweaks"
$BTruntweaks.UseVisualStyleBackColor = $true
$BTruntweaks.add_click({
    messageStarting
    # Disable/Enable Start Menu Web Search
    If ($RBdisablewebsearch.Checked -eq $true) {
        disableExplorerWebSearch
    }
    Elseif ($RBenablewebsearch.Checked -eq $true){
        enableExplorerWebSearch
    }

    # Disable/Enable Telemetry
    If ($RBdisabletelemetry.Checked -eq $true) {
        disableTelemetry
    }
    Elseif ($RBenabletelemetry.Checked -eq $true){
        enableTelemetry
    }

    # Disable/Enable IPv6 Services
    If ($RBdisabletelemetry.Checked -eq $true) {
        disableTelemetry
    }
    Elseif ($RBenabletelemetry.Checked -eq $true){
        enableTelemetry
    }

    # Disable/Enable Light Theme
    If ($RBdisablelighttheme.Checked -eq $true) {
        disableLighttheme
    }
    Elseif ($RBenablelighttheme.Checked -eq $true){
        enableLighttheme
    }

    # Disable/Enable Notifications
    If ($RBdisablenotifs.Checked -eq $true) {
        disableNotifications
    }
    Elseif ($RBenablenotifs.Checked -eq $true){
        enableNotifications
    }

    # Remove Bloatware Apps
    If ($CBremovebloat.Checked -eq $true) {
        removeBloatware
    }

    # Remove Cortana
    If ($CBremovecortana.Checked -eq $true) {
        removeCortana
    }

    # Clear Taskbar
    If ($CBcleartaskbar.Checked -eq $true) {
        clearTaskbar
    }
    messageSuccess
    popupDone
})

# CBcleartaskbar
$CBcleartaskbar.AutoSize = $true
$CBcleartaskbar.Location = New-Object System.Drawing.Point(6, 65)
$CBcleartaskbar.Name = "CBcleartaskbar"
$CBcleartaskbar.Size = New-Object System.Drawing.Size(92, 17)
$CBcleartaskbar.TabIndex = 4
$CBcleartaskbar.Text = "Clear Taskbar"
$CBcleartaskbar.UseVisualStyleBackColor = $true

# CBremovecortana
$CBremovecortana.AutoSize = $true
$CBremovecortana.Location = New-Object System.Drawing.Point(6, 42)
$CBremovecortana.Name = "CBremovecortana"
$CBremovecortana.Size = New-Object System.Drawing.Size(106, 17)
$CBremovecortana.TabIndex = 2
$CBremovecortana.Text = "Remove Cortana"
$CBremovecortana.UseVisualStyleBackColor = $true

# CBremovebloat
$CBremovebloat.AutoSize = $true
$CBremovebloat.Location = New-Object System.Drawing.Point(6, 19)
$CBremovebloat.Name = "CBremovebloat"
$CBremovebloat.Size = New-Object System.Drawing.Size(143, 17)
$CBremovebloat.TabIndex = 1
$CBremovebloat.Text = "Remove Bloatware Apps"
$CBremovebloat.UseVisualStyleBackColor = $true

# GBtweaks
$GBtweaks.Controls.Add($GBtweaknotifications)
$GBtweaks.Controls.Add($GBtweaklighttheme)
$GBtweaks.Controls.Add($GBtweakipv6)
$GBtweaks.Controls.Add($GBtweaktelemetry)
$GBtweaks.Controls.Add($GBtweakstartmenu)
$GBtweaks.Location = New-Object System.Drawing.Point(6, 3)
$GBtweaks.Name = "GBtweaks"
$GBtweaks.Size = New-Object System.Drawing.Size(740, 308)
$GBtweaks.TabIndex = 0
$GBtweaks.TabStop = $false
$GBtweaks.Text = "Tweaks"

# GBtweaknotifications
$GBtweaknotifications.Controls.Add($RBenablenotifs)
$GBtweaknotifications.Controls.Add($RBdisablenotifs)
$GBtweaknotifications.Location = New-Object System.Drawing.Point(6, 223)
$GBtweaknotifications.Name = "GBtweaknotifications"
$GBtweaknotifications.Size = New-Object System.Drawing.Size(728, 45)
$GBtweaknotifications.TabIndex = 8
$GBtweaknotifications.TabStop = $false

# RBenablenotifs
$RBenablenotifs.AutoSize = $true
$RBenablenotifs.Location = New-Object System.Drawing.Point(513, 16)
$RBenablenotifs.Name = "RBenablenotifs"
$RBenablenotifs.Size = New-Object System.Drawing.Size(119, 17)
$RBenablenotifs.TabIndex = 4
$RBenablenotifs.Text = "Enable Notifications"
$RBenablenotifs.UseVisualStyleBackColor = $true

# RBdisablenotifs
$RBdisablenotifs.AutoSize = $true
$RBdisablenotifs.Location = New-Object System.Drawing.Point(6, 16)
$RBdisablenotifs.Name = "RBdisablenotifs"
$RBdisablenotifs.Size = New-Object System.Drawing.Size(121, 17)
$RBdisablenotifs.TabIndex = 3
$RBdisablenotifs.Text = "Disable Notifications"
$RBdisablenotifs.UseVisualStyleBackColor = $true

# GBtweaklighttheme
$GBtweaklighttheme.Controls.Add($RBenablelighttheme)
$GBtweaklighttheme.Controls.Add($RBdisablelighttheme)
$GBtweaklighttheme.Location = New-Object System.Drawing.Point(6, 172)
$GBtweaklighttheme.Name = "GBtweaklighttheme"
$GBtweaklighttheme.Size = New-Object System.Drawing.Size(728, 45)
$GBtweaklighttheme.TabIndex = 7
$GBtweaklighttheme.TabStop = $false

# RBenablelighttheme
$RBenablelighttheme.AutoSize = $true
$RBenablelighttheme.Location = New-Object System.Drawing.Point(513, 16)
$RBenablelighttheme.Name = "RBenablelighttheme"
$RBenablelighttheme.Size = New-Object System.Drawing.Size(120, 17)
$RBenablelighttheme.TabIndex = 4
$RBenablelighttheme.Text = "Enable Light Theme"
$RBenablelighttheme.UseVisualStyleBackColor = $true

# RBdisablelighttheme
$RBdisablelighttheme.AutoSize = $true
$RBdisablelighttheme.Location = New-Object System.Drawing.Point(6, 16)
$RBdisablelighttheme.Name = "RBdisablelighttheme"
$RBdisablelighttheme.Size = New-Object System.Drawing.Size(122, 17)
$RBdisablelighttheme.TabIndex = 3
$RBdisablelighttheme.Text = "Disable Light Theme"
$RBdisablelighttheme.UseVisualStyleBackColor = $true

# GBtweakipv6
$GBtweakipv6.Controls.Add($RBenableipv6services)
$GBtweakipv6.Controls.Add($RBdisableipv6services)
$GBtweakipv6.Location = New-Object System.Drawing.Point(6, 121)
$GBtweakipv6.Name = "GBtweakipv6"
$GBtweakipv6.Size = New-Object System.Drawing.Size(728, 45)
$GBtweakipv6.TabIndex = 6
$GBtweakipv6.TabStop = $false

# RBenableipv6services
$RBenableipv6services.AutoSize = $true
$RBenableipv6services.Location = New-Object System.Drawing.Point(513, 16)
$RBenableipv6services.Name = "RBenableipv6services"
$RBenableipv6services.Size = New-Object System.Drawing.Size(122, 17)
$RBenableipv6services.TabIndex = 4
$RBenableipv6services.Text = "Enable IPv6 Service"
$RBenableipv6services.UseVisualStyleBackColor = $true

# RBdisableipv6services
$RBdisableipv6services.AutoSize = $true
$RBdisableipv6services.Location = New-Object System.Drawing.Point(6, 16)
$RBdisableipv6services.Name = "RBdisableipv6services"
$RBdisableipv6services.Size = New-Object System.Drawing.Size(124, 17)
$RBdisableipv6services.TabIndex = 3
$RBdisableipv6services.Text = "Disable IPv6 Service"
$RBdisableipv6services.UseVisualStyleBackColor = $true

# GBtweaktelemetry
$GBtweaktelemetry.Controls.Add($RBenabletelemetry)
$GBtweaktelemetry.Controls.Add($RBdisabletelemetry)
$GBtweaktelemetry.Location = New-Object System.Drawing.Point(6, 70)
$GBtweaktelemetry.Name = "GBtweaktelemetry"
$GBtweaktelemetry.Size = New-Object System.Drawing.Size(728, 45)
$GBtweaktelemetry.TabIndex = 5
$GBtweaktelemetry.TabStop = $false

# RBenabletelemetry
$RBenabletelemetry.AutoSize = $true
$RBenabletelemetry.Location = New-Object System.Drawing.Point(513, 16)
$RBenabletelemetry.Name = "RBenabletelemetry"
$RBenabletelemetry.Size = New-Object System.Drawing.Size(107, 17)
$RBenabletelemetry.TabIndex = 4
$RBenabletelemetry.Text = "Enable Telemetry"
$RBenabletelemetry.UseVisualStyleBackColor = $true

# RBdisabletelemetry
$RBdisabletelemetry.AutoSize = $true
$RBdisabletelemetry.Location = New-Object System.Drawing.Point(6, 16)
$RBdisabletelemetry.Name = "RBdisabletelemetry"
$RBdisabletelemetry.Size = New-Object System.Drawing.Size(109, 17)
$RBdisabletelemetry.TabIndex = 3
$RBdisabletelemetry.Text = "Disable Telemetry"
$RBdisabletelemetry.UseVisualStyleBackColor = $true

# GBtweakstartmenu
$GBtweakstartmenu.Controls.Add($RBenablewebsearch)
$GBtweakstartmenu.Controls.Add($RBdisablewebsearch)
$GBtweakstartmenu.Location = New-Object System.Drawing.Point(6, 19)
$GBtweakstartmenu.Name = "GBtweakstartmenu"
$GBtweakstartmenu.Size = New-Object System.Drawing.Size(728, 45)
$GBtweakstartmenu.TabIndex = 2
$GBtweakstartmenu.TabStop = $false

# RBenablewebsearch
$RBenablewebsearch.AutoSize = $true
$RBenablewebsearch.Location = New-Object System.Drawing.Point(513, 16)
$RBenablewebsearch.Name = "RBenablewebsearch"
$RBenablewebsearch.Size = New-Object System.Drawing.Size(176, 17)
$RBenablewebsearch.TabIndex = 4
$RBenablewebsearch.Text = "Enable Start Menu Web Search"
$RBenablewebsearch.UseVisualStyleBackColor = $true

# RBdisablewebsearch
$RBdisablewebsearch.AutoSize = $true
$RBdisablewebsearch.Location = New-Object System.Drawing.Point(6, 16)
$RBdisablewebsearch.Name = "RBdisablewebsearch"
$RBdisablewebsearch.Size = New-Object System.Drawing.Size(178, 17)
$RBdisablewebsearch.TabIndex = 3
$RBdisablewebsearch.Text = "Disable Start Menu Web Search"
$RBdisablewebsearch.UseVisualStyleBackColor = $true

# TPprograms
$TPprograms.Controls.Add($BTinstallprograms)
$TPprograms.Controls.Add($GBmultimedia)
$TPprograms.Controls.Add($GBtools)
$TPprograms.Controls.Add($GBdevelopment)
$TPprograms.Controls.Add($GButilities)
$TPprograms.Controls.Add($GBproductivity)
$TPprograms.Controls.Add($GBeducational)
$TPprograms.Controls.Add($GBnavigation)
$TPprograms.Location = New-Object System.Drawing.Point(4, 22)
$TPprograms.Name = "TPprograms"
$TPprograms.Padding = New-Object System.Windows.Forms.Padding(3, 3, 3, 3)
$TPprograms.Size = New-Object System.Drawing.Size(752, 485)
$TPprograms.TabIndex = 1
$TPprograms.Text = "Programs"
$TPprograms.UseVisualStyleBackColor = $true

# BTinstallprograms
$BTinstallprograms.Location = New-Object System.Drawing.Point(609, 456)
$BTinstallprograms.Name = "BTinstallprograms"
$BTinstallprograms.Size = New-Object System.Drawing.Size(137, 23)
$BTinstallprograms.TabIndex = 13
$BTinstallprograms.Text = "Install Selection"
$BTinstallprograms.UseVisualStyleBackColor = $true
$BTinstallprograms.add_click({
    checkChoco
    messageStarting
    # Navigation
    If ($CBinstallchrome.Checked -eq $true) {
        installChrome
    }
    If ($CBinstallfirefox.Checked -eq $true) {
        installFirefox
    }
    If ($CBinstalledge.Checked -eq $true) {
        installEdge
    }
    If ($CBinstallchromium.Checked -eq $true) {
        installChromium
    }
    If ($CBinstallbrave.Checked -eq $true) {
        installBrave
    }
    If ($CBinstallopera.Checked -eq $true) {
        installOpera
    }
    If ($CBinstalloperagx.Checked -eq $true) {
        installOperagx
    }
    If ($CBinstalllibrewolf.Checked -eq $true) {
        installLibrewolf
    }

    # Productivity
    If ($CBinstallanydesk.Checked -eq $true) {
        installAnydesk
    }
    If ($CBinstallteamviewer.Checked -eq $true) {
        installTeamviewer
    }
    If ($CBinstalllibreoffice.Checked -eq $true) {
        installLibreoffice
    }
    If ($CBinstallzoom.Checked -eq $true) {
        installZoom
    }
    If ($CBinstallteams.Checked -eq $true) {
        installMicrosoftteams
    }
    If ($CBinstallslack.Checked -eq $true) {
        installSlack
    }
    If ($CBinstalladobereader.Checked -eq $true) {
        installAdobeacrobatreader
    }

    # Educational
    If ($CBinstallscratch.Checked -eq $true) {
        installScratch
    }
    If ($CBinstallgcompris.Checked -eq $true) {
        installGcompris
    }
    If ($CBinstalltuxpaint.Checked -eq $true) {
        installTuxpaint
    }
    If ($CBinstallpilasbloques.Checked -eq $true) {
        installPilasBloques
    }
    If ($CBinstallregisoftcont.Checked -eq $true) {
        installRegisoftcontabilidad
    }

    # Utilities
    If ($CBinstall7zip.Checked -eq $true) {
        install7zip
    }
    If ($CBinstallwinrar.Checked -eq $true) {
        installWinrar
    }
    If ($CBinstallqbittorrent.Checked -eq $true) {
        installQbittorrent
    }
    If ($CBinstallccleaner.Checked -eq $true) {
        installCcleaner
    }
    If ($CBinstallvirtualbox.Checked -eq $true) {
        installVirtualbox
    }

    # Development
    If ($CBinstallpython.Checked -eq $true) {
        installPython
    }
    If ($CBinstalldotnet.Checked -eq $true) {
        installDotNET
    }
    If ($CBinstallgit.Checked -eq $true) {
        installGit
    }
    If ($CBinstallvscode.Checked -eq $true) {
        installVscode
    }

    # Tools
    If ($CBinstallputty.Checked -eq $true) {
        installPutty
    }
    If ($CBinstallcrystaldisk.Checked -eq $true) {
        installCrystaldiskinfo
    }
    If ($CBinstallmalwarebytes.Checked -eq $true) {
        installMalwarebytes
    }
    If ($CBinstallwiztree.Checked -eq $true) {
        installWiztree
    }

    # Multimedia
    If ($CBinstallgimp.Checked -eq $true) {
        installGimp
    }
    If ($CBinstallaudacity.Checked -eq $true) {
        installAudacity
    }
    If ($CBinstallvlc.Checked -eq $true) {
        installVlc
    }
    messageSuccess
    popupDone
})

# GBmultimedia
$GBmultimedia.Controls.Add($CBinstallaudacity)
$GBmultimedia.Controls.Add($CBinstallgimp)
$GBmultimedia.Controls.Add($CBinstallvlc)
$GBmultimedia.Location = New-Object System.Drawing.Point(480, 6)
$GBmultimedia.Name = "GBmultimedia"
$GBmultimedia.Size = New-Object System.Drawing.Size(152, 217)
$GBmultimedia.TabIndex = 8
$GBmultimedia.TabStop = $false
$GBmultimedia.Text = "Multimedia"

# CBinstallaudacity
$CBinstallaudacity.AutoSize = $true
$CBinstallaudacity.Location = New-Object System.Drawing.Point(6, 42)
$CBinstallaudacity.Name = "CBinstallaudacity"
$CBinstallaudacity.Size = New-Object System.Drawing.Size(67, 17)
$CBinstallaudacity.TabIndex = 1
$CBinstallaudacity.Text = "Audacity"
$CBinstallaudacity.UseVisualStyleBackColor = $true

# CBinstallgimp
$CBinstallgimp.AutoSize = $true
$CBinstallgimp.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallgimp.Name = "CBinstallgimp"
$CBinstallgimp.Size = New-Object System.Drawing.Size(53, 17)
$CBinstallgimp.TabIndex = 0
$CBinstallgimp.Text = "GIMP"
$CBinstallgimp.UseVisualStyleBackColor = $true

# CBinstallvlc
$CBinstallvlc.AutoSize = $true
$CBinstallvlc.Location = New-Object System.Drawing.Point(6, 65)
$CBinstallvlc.Name = "CBinstallvlc"
$CBinstallvlc.Size = New-Object System.Drawing.Size(110, 17)
$CBinstallvlc.TabIndex = 5
$CBinstallvlc.Text = "VLC Media Player"
$CBinstallvlc.UseVisualStyleBackColor = $true

# GBtools
$GBtools.Controls.Add($CBinstallwiztree)
$GBtools.Controls.Add($CBinstallcrystaldisk)
$GBtools.Controls.Add($CBinstallmalwarebytes)
$GBtools.Controls.Add($CBinstallputty)
$GBtools.Location = New-Object System.Drawing.Point(322, 229)
$GBtools.Name = "GBtools"
$GBtools.Size = New-Object System.Drawing.Size(151, 250)
$GBtools.TabIndex = 12
$GBtools.TabStop = $false
$GBtools.Text = "Tools"

# CBinstallwiztree
$CBinstallwiztree.AutoSize = $true
$CBinstallwiztree.Location = New-Object System.Drawing.Point(6, 88)
$CBinstallwiztree.Name = "CBinstallwiztree"
$CBinstallwiztree.Size = New-Object System.Drawing.Size(66, 17)
$CBinstallwiztree.TabIndex = 11
$CBinstallwiztree.Text = "WizTree"
$CBinstallwiztree.UseVisualStyleBackColor = $true

# CBinstallcrystaldisk
$CBinstallcrystaldisk.AutoSize = $true
$CBinstallcrystaldisk.Location = New-Object System.Drawing.Point(6, 42)
$CBinstallcrystaldisk.Name = "CBinstallcrystaldisk"
$CBinstallcrystaldisk.Size = New-Object System.Drawing.Size(102, 17)
$CBinstallcrystaldisk.TabIndex = 5
$CBinstallcrystaldisk.Text = "Crystal Disk Info"
$CBinstallcrystaldisk.UseVisualStyleBackColor = $true

# CBinstallmalwarebytes
$CBinstallmalwarebytes.AutoSize = $true
$CBinstallmalwarebytes.Location = New-Object System.Drawing.Point(6, 65)
$CBinstallmalwarebytes.Name = "CBinstallmalwarebytes"
$CBinstallmalwarebytes.Size = New-Object System.Drawing.Size(92, 17)
$CBinstallmalwarebytes.TabIndex = 6
$CBinstallmalwarebytes.Text = "MalwareBytes"
$CBinstallmalwarebytes.UseVisualStyleBackColor = $true
$CBinstallmalwarebytes.Add_CheckedChanged( { OnCheckedChanged_CBinstallmalwarebytes } )


# CBinstallputty
$CBinstallputty.AutoSize = $true
$CBinstallputty.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallputty.Name = "CBinstallputty"
$CBinstallputty.Size = New-Object System.Drawing.Size(60, 17)
$CBinstallputty.TabIndex = 10
$CBinstallputty.Text = "PuTTY"
$CBinstallputty.UseVisualStyleBackColor = $true
$CBinstallputty.Add_CheckedChanged( { OnCheckedChanged_CBinstallputty } )


# GBdevelopment
$GBdevelopment.Controls.Add($CBinstallvscode)
$GBdevelopment.Controls.Add($CBinstallgit)
$GBdevelopment.Controls.Add($CBinstalldotnet)
$GBdevelopment.Controls.Add($CBinstallpython)
$GBdevelopment.Location = New-Object System.Drawing.Point(322, 6)
$GBdevelopment.Name = "GBdevelopment"
$GBdevelopment.Size = New-Object System.Drawing.Size(152, 217)
$GBdevelopment.TabIndex = 7
$GBdevelopment.TabStop = $false
$GBdevelopment.Text = "Development"

# CBinstallvscode
$CBinstallvscode.AutoSize = $true
$CBinstallvscode.Location = New-Object System.Drawing.Point(6, 88)
$CBinstallvscode.Name = "CBinstallvscode"
$CBinstallvscode.Size = New-Object System.Drawing.Size(115, 17)
$CBinstallvscode.TabIndex = 3
$CBinstallvscode.Text = "Visual Studio Code"
$CBinstallvscode.UseVisualStyleBackColor = $true

# CBinstallgit
$CBinstallgit.AutoSize = $true
$CBinstallgit.Location = New-Object System.Drawing.Point(6, 65)
$CBinstallgit.Name = "CBinstallgit"
$CBinstallgit.Size = New-Object System.Drawing.Size(39, 17)
$CBinstallgit.TabIndex = 2
$CBinstallgit.Text = "Git"
$CBinstallgit.UseVisualStyleBackColor = $true

# CBinstalldotnet
$CBinstalldotnet.AutoSize = $true
$CBinstalldotnet.Location = New-Object System.Drawing.Point(6, 42)
$CBinstalldotnet.Name = "CBinstalldotnet"
$CBinstalldotnet.Size = New-Object System.Drawing.Size(124, 17)
$CBinstalldotnet.TabIndex = 1
$CBinstalldotnet.Text = ".NET Framework 4.8"
$CBinstalldotnet.UseVisualStyleBackColor = $true

# CBinstallpython
$CBinstallpython.AutoSize = $true
$CBinstallpython.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallpython.Name = "CBinstallpython"
$CBinstallpython.Size = New-Object System.Drawing.Size(84, 17)
$CBinstallpython.TabIndex = 0
$CBinstallpython.Text = "Python 3.x.x"
$CBinstallpython.UseVisualStyleBackColor = $true

# GButilities
$GButilities.Controls.Add($CBinstallqbittorrent)
$GButilities.Controls.Add($CBinstallvirtualbox)
$GButilities.Controls.Add($CBinstallccleaner)
$GButilities.Controls.Add($CBinstallwinrar)
$GButilities.Controls.Add($CBinstall7zip)
$GButilities.Location = New-Object System.Drawing.Point(165, 229)
$GButilities.Name = "GButilities"
$GButilities.Size = New-Object System.Drawing.Size(151, 250)
$GButilities.TabIndex = 6
$GButilities.TabStop = $false
$GButilities.Text = "Utilities"

# CBinstallqbittorrent
$CBinstallqbittorrent.AutoSize = $true
$CBinstallqbittorrent.Location = New-Object System.Drawing.Point(5, 65)
$CBinstallqbittorrent.Name = "CBinstallqbittorrent"
$CBinstallqbittorrent.Size = New-Object System.Drawing.Size(74, 17)
$CBinstallqbittorrent.TabIndex = 6
$CBinstallqbittorrent.Text = "qBittorrent"
$CBinstallqbittorrent.UseVisualStyleBackColor = $true

# CBinstallvirtualbox
$CBinstallvirtualbox.AutoSize = $true
$CBinstallvirtualbox.Location = New-Object System.Drawing.Point(5, 111)
$CBinstallvirtualbox.Name = "CBinstallvirtualbox"
$CBinstallvirtualbox.Size = New-Object System.Drawing.Size(73, 17)
$CBinstallvirtualbox.TabIndex = 4
$CBinstallvirtualbox.Text = "VirtualBox"
$CBinstallvirtualbox.UseVisualStyleBackColor = $true

# CBinstallccleaner
$CBinstallccleaner.AutoSize = $true
$CBinstallccleaner.Location = New-Object System.Drawing.Point(5, 88)
$CBinstallccleaner.Name = "CBinstallccleaner"
$CBinstallccleaner.Size = New-Object System.Drawing.Size(69, 17)
$CBinstallccleaner.TabIndex = 8
$CBinstallccleaner.Text = "CCleaner"
$CBinstallccleaner.UseVisualStyleBackColor = $true

# CBinstallwinrar
$CBinstallwinrar.AutoSize = $true
$CBinstallwinrar.Location = New-Object System.Drawing.Point(5, 42)
$CBinstallwinrar.Name = "CBinstallwinrar"
$CBinstallwinrar.Size = New-Object System.Drawing.Size(68, 17)
$CBinstallwinrar.TabIndex = 7
$CBinstallwinrar.Text = "WinRAR"
$CBinstallwinrar.UseVisualStyleBackColor = $true

# CBinstall7zip
$CBinstall7zip.AutoSize = $true
$CBinstall7zip.Location = New-Object System.Drawing.Point(5, 19)
$CBinstall7zip.Name = "CBinstall7zip"
$CBinstall7zip.Size = New-Object System.Drawing.Size(50, 17)
$CBinstall7zip.TabIndex = 4
$CBinstall7zip.Text = "7-Zip"
$CBinstall7zip.UseVisualStyleBackColor = $true

# GBproductivity
$GBproductivity.Controls.Add($CBinstallslack)
$GBproductivity.Controls.Add($CBinstalladobereader)
$GBproductivity.Controls.Add($CBinstallteams)
$GBproductivity.Controls.Add($CBinstallzoom)
$GBproductivity.Controls.Add($CBinstalllibreoffice)
$GBproductivity.Controls.Add($CBinstallteamviewer)
$GBproductivity.Controls.Add($CBinstallanydesk)
$GBproductivity.Location = New-Object System.Drawing.Point(6, 229)
$GBproductivity.Name = "GBproductivity"
$GBproductivity.Size = New-Object System.Drawing.Size(152, 250)
$GBproductivity.TabIndex = 5
$GBproductivity.TabStop = $false
$GBproductivity.Text = "Productivity"

# CBinstallslack
$CBinstallslack.AutoSize = $true
$CBinstallslack.Location = New-Object System.Drawing.Point(6, 134)
$CBinstallslack.Name = "CBinstallslack"
$CBinstallslack.Size = New-Object System.Drawing.Size(53, 17)
$CBinstallslack.TabIndex = 7
$CBinstallslack.Text = "Slack"
$CBinstallslack.UseVisualStyleBackColor = $true

# CBinstalladobereader
$CBinstalladobereader.AutoSize = $true
$CBinstalladobereader.Location = New-Object System.Drawing.Point(6, 157)
$CBinstalladobereader.Name = "CBinstalladobereader"
$CBinstalladobereader.Size = New-Object System.Drawing.Size(135, 17)
$CBinstalladobereader.TabIndex = 9
$CBinstalladobereader.Text = "Adobe Acrobat Reader"
$CBinstalladobereader.UseVisualStyleBackColor = $true

# CBinstallteams
$CBinstallteams.AutoSize = $true
$CBinstallteams.Location = New-Object System.Drawing.Point(6, 111)
$CBinstallteams.Name = "CBinstallteams"
$CBinstallteams.Size = New-Object System.Drawing.Size(104, 17)
$CBinstallteams.TabIndex = 6
$CBinstallteams.Text = "Microsoft Teams"
$CBinstallteams.UseVisualStyleBackColor = $true

# CBinstallzoom
$CBinstallzoom.AutoSize = $true
$CBinstallzoom.Location = New-Object System.Drawing.Point(6, 88)
$CBinstallzoom.Name = "CBinstallzoom"
$CBinstallzoom.Size = New-Object System.Drawing.Size(53, 17)
$CBinstallzoom.TabIndex = 5
$CBinstallzoom.Text = "Zoom"
$CBinstallzoom.UseVisualStyleBackColor = $true

# CBinstalllibreoffice
$CBinstalllibreoffice.AutoSize = $true
$CBinstalllibreoffice.Location = New-Object System.Drawing.Point(6, 65)
$CBinstalllibreoffice.Name = "CBinstalllibreoffice"
$CBinstalllibreoffice.Size = New-Object System.Drawing.Size(77, 17)
$CBinstalllibreoffice.TabIndex = 4
$CBinstalllibreoffice.Text = "LibreOffice"
$CBinstalllibreoffice.UseVisualStyleBackColor = $true

# CBinstallteamviewer
$CBinstallteamviewer.AutoSize = $true
$CBinstallteamviewer.Location = New-Object System.Drawing.Point(6, 42)
$CBinstallteamviewer.Name = "CBinstallteamviewer"
$CBinstallteamviewer.Size = New-Object System.Drawing.Size(85, 17)
$CBinstallteamviewer.TabIndex = 3
$CBinstallteamviewer.Text = "TeamViewer"
$CBinstallteamviewer.UseVisualStyleBackColor = $true

# CBinstallanydesk
$CBinstallanydesk.AutoSize = $true
$CBinstallanydesk.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallanydesk.Name = "CBinstallanydesk"
$CBinstallanydesk.Size = New-Object System.Drawing.Size(69, 17)
$CBinstallanydesk.TabIndex = 2
$CBinstallanydesk.Text = "AnyDesk"
$CBinstallanydesk.UseVisualStyleBackColor = $true

# GBeducational
$GBeducational.Controls.Add($CBinstallregisoftcont)
$GBeducational.Controls.Add($CBinstallpilasbloques)
$GBeducational.Controls.Add($CBinstalltuxpaint)
$GBeducational.Controls.Add($CBinstallgcompris)
$GBeducational.Controls.Add($CBinstallscratch)
$GBeducational.Location = New-Object System.Drawing.Point(164, 6)
$GBeducational.Name = "GBeducational"
$GBeducational.Size = New-Object System.Drawing.Size(152, 217)
$GBeducational.TabIndex = 4
$GBeducational.TabStop = $false
$GBeducational.Text = "Educational"

# CBinstallregisoftcont
$CBinstallregisoftcont.AutoSize = $true
$CBinstallregisoftcont.Location = New-Object System.Drawing.Point(6, 111)
$CBinstallregisoftcont.Name = "CBinstallregisoftcont"
$CBinstallregisoftcont.Size = New-Object System.Drawing.Size(126, 17)
$CBinstallregisoftcont.TabIndex = 4
$CBinstallregisoftcont.Text = "Regisoft Contabilidad"
$CBinstallregisoftcont.UseVisualStyleBackColor = $true

# CBinstallpilasbloques
$CBinstallpilasbloques.AutoSize = $true
$CBinstallpilasbloques.Location = New-Object System.Drawing.Point(6, 88)
$CBinstallpilasbloques.Name = "CBinstallpilasbloques"
$CBinstallpilasbloques.Size = New-Object System.Drawing.Size(86, 17)
$CBinstallpilasbloques.TabIndex = 3
$CBinstallpilasbloques.Text = "PilasBloques"
$CBinstallpilasbloques.UseVisualStyleBackColor = $true

# CBinstalltuxpaint
$CBinstalltuxpaint.AutoSize = $true
$CBinstalltuxpaint.Location = New-Object System.Drawing.Point(6, 65)
$CBinstalltuxpaint.Name = "CBinstalltuxpaint"
$CBinstalltuxpaint.Size = New-Object System.Drawing.Size(68, 17)
$CBinstalltuxpaint.TabIndex = 2
$CBinstalltuxpaint.Text = "TuxPaint"
$CBinstalltuxpaint.UseVisualStyleBackColor = $true

# CBinstallgcompris
$CBinstallgcompris.AutoSize = $true
$CBinstallgcompris.Location = New-Object System.Drawing.Point(6, 42)
$CBinstallgcompris.Name = "CBinstallgcompris"
$CBinstallgcompris.Size = New-Object System.Drawing.Size(71, 17)
$CBinstallgcompris.TabIndex = 1
$CBinstallgcompris.Text = "GCompris"
$CBinstallgcompris.UseVisualStyleBackColor = $true

# CBinstallscratch
$CBinstallscratch.AutoSize = $true
$CBinstallscratch.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallscratch.Name = "CBinstallscratch"
$CBinstallscratch.Size = New-Object System.Drawing.Size(63, 17)
$CBinstallscratch.TabIndex = 0
$CBinstallscratch.Text = "Scratch"
$CBinstallscratch.UseVisualStyleBackColor = $true

# GBnavigation
$GBnavigation.Controls.Add($CBinstalloperagx)
$GBnavigation.Controls.Add($CBinstalllibrewolf)
$GBnavigation.Controls.Add($CBinstallopera)
$GBnavigation.Controls.Add($CBinstallbrave)
$GBnavigation.Controls.Add($CBinstallchromium)
$GBnavigation.Controls.Add($CBinstalledge)
$GBnavigation.Controls.Add($CBinstallfirefox)
$GBnavigation.Controls.Add($CBinstallchrome)
$GBnavigation.Location = New-Object System.Drawing.Point(6, 6)
$GBnavigation.Name = "GBnavigation"
$GBnavigation.Size = New-Object System.Drawing.Size(152, 217)
$GBnavigation.TabIndex = 0
$GBnavigation.TabStop = $false
$GBnavigation.Text = "Navigation"

# CBinstalloperagx
$CBinstalloperagx.AutoSize = $true
$CBinstalloperagx.Location = New-Object System.Drawing.Point(6, 157)
$CBinstalloperagx.Name = "CBinstalloperagx"
$CBinstalloperagx.Size = New-Object System.Drawing.Size(73, 17)
$CBinstalloperagx.TabIndex = 7
$CBinstalloperagx.Text = "Opera GX"
$CBinstalloperagx.UseVisualStyleBackColor = $true

# CBinstalllibrewolf
$CBinstalllibrewolf.AutoSize = $true
$CBinstalllibrewolf.Location = New-Object System.Drawing.Point(6, 180)
$CBinstalllibrewolf.Name = "CBinstalllibrewolf"
$CBinstalllibrewolf.Size = New-Object System.Drawing.Size(71, 17)
$CBinstalllibrewolf.TabIndex = 6
$CBinstalllibrewolf.Text = "LibreWolf"
$CBinstalllibrewolf.UseVisualStyleBackColor = $true

# CBinstallopera
$CBinstallopera.AutoSize = $true
$CBinstallopera.Location = New-Object System.Drawing.Point(6, 134)
$CBinstallopera.Name = "CBinstallopera"
$CBinstallopera.Size = New-Object System.Drawing.Size(55, 17)
$CBinstallopera.TabIndex = 5
$CBinstallopera.Text = "Opera"
$CBinstallopera.UseVisualStyleBackColor = $true

# CBinstallbrave
$CBinstallbrave.AutoSize = $true
$CBinstallbrave.Location = New-Object System.Drawing.Point(6, 111)
$CBinstallbrave.Name = "CBinstallbrave"
$CBinstallbrave.Size = New-Object System.Drawing.Size(54, 17)
$CBinstallbrave.TabIndex = 4
$CBinstallbrave.Text = "Brave"
$CBinstallbrave.UseVisualStyleBackColor = $true

# CBinstallchromium
$CBinstallchromium.AutoSize = $true
$CBinstallchromium.Location = New-Object System.Drawing.Point(6, 88)
$CBinstallchromium.Name = "CBinstallchromium"
$CBinstallchromium.Size = New-Object System.Drawing.Size(72, 17)
$CBinstallchromium.TabIndex = 3
$CBinstallchromium.Text = "Chromium"
$CBinstallchromium.UseVisualStyleBackColor = $true

# CBinstalledge
$CBinstalledge.AutoSize = $true
$CBinstalledge.Location = New-Object System.Drawing.Point(6, 65)
$CBinstalledge.Name = "CBinstalledge"
$CBinstalledge.Size = New-Object System.Drawing.Size(97, 17)
$CBinstalledge.TabIndex = 2
$CBinstalledge.Text = "Microsoft Edge"
$CBinstalledge.UseVisualStyleBackColor = $true

# CBinstallfirefox
$CBinstallfirefox.AutoSize = $true
$CBinstallfirefox.Location = New-Object System.Drawing.Point(6, 42)
$CBinstallfirefox.Name = "CBinstallfirefox"
$CBinstallfirefox.Size = New-Object System.Drawing.Size(57, 17)
$CBinstallfirefox.TabIndex = 1
$CBinstallfirefox.Text = "Firefox"
$CBinstallfirefox.UseVisualStyleBackColor = $true

# CBinstallchrome
$CBinstallchrome.AutoSize = $true
$CBinstallchrome.Location = New-Object System.Drawing.Point(6, 19)
$CBinstallchrome.Name = "CBinstallchrome"
$CBinstallchrome.Size = New-Object System.Drawing.Size(62, 17)
$CBinstallchrome.TabIndex = 0
$CBinstallchrome.Text = "Chrome"
$CBinstallchrome.UseVisualStyleBackColor = $true

# TPhelp
$TPhelp.Controls.Add($GBcat)
$TPhelp.Controls.Add($GBdocumentationlink)
$TPhelp.Location = New-Object System.Drawing.Point(4, 22)
$TPhelp.Name = "TPhelp"
$TPhelp.Size = New-Object System.Drawing.Size(752, 485)
$TPhelp.TabIndex = 2
$TPhelp.Text = "Help"
$TPhelp.UseVisualStyleBackColor = $true

# menuStrip1
$menuStrip1.ImageScalingSize = New-Object System.Drawing.Size(20, 20)
$menuStrip1.Location = New-Object System.Drawing.Point(0, 24)
$menuStrip1.Name = "menuStrip1"
$menuStrip1.Padding = New-Object System.Windows.Forms.Padding(4, 2, 0, 2)
$menuStrip1.Size = New-Object System.Drawing.Size(784, 24)
$menuStrip1.TabIndex = 1
$menuStrip1.Text = "menuStrip1"

# menuStrip2
$menuStrip2.ImageScalingSize = New-Object System.Drawing.Size(20, 20)
$menuStrip2.Items.AddRange(@(
$MSmain))
$menuStrip2.Location = New-Object System.Drawing.Point(0, 0)
$menuStrip2.Name = "menuStrip2"
$menuStrip2.Padding = New-Object System.Windows.Forms.Padding(4, 2, 0, 2)
$menuStrip2.Size = New-Object System.Drawing.Size(784, 24)
$menuStrip2.TabIndex = 2
$menuStrip2.Text = "menuStrip2"

# MSmain
$MSmain.DropDownItems.AddRange(@(
$MSIgithub))
$MSmain.Name = "MSmain"
$MSmain.Size = New-Object System.Drawing.Size(52, 20)
$MSmain.Text = "About"


# MSIgithub
$MSIgithub.Name = "MSIgithub"
$MSIgithub.Size = New-Object System.Drawing.Size(180, 22)
$MSIgithub.Text = "GitHub Repository"
$MSIgithub.add_click({
    # Link to the GitHub repo
    Start-Process "https://github.com/nicobucodiguito/dechoater/"
    # Opens link as a popup in main browser
})

#
# LBhelptext
#
$LBhelptext.AutoSize = $true
$LBhelptext.Location = New-Object System.Drawing.Point(6, 16)
$LBhelptext.Name = "LBhelptext"
$LBhelptext.Size = New-Object System.Drawing.Size(162, 13)
$LBhelptext.TabIndex = 1
$LBhelptext.Text = "You can read the documentation"


# LBdocumentation
$LBdocumentation.AutoSize = $true
$LBdocumentation.Location = New-Object System.Drawing.Point(172, 16)
$LBdocumentation.Name = "LBdocumentation"
$LBdocumentation.Size = New-Object System.Drawing.Size(31, 13)
$LBdocumentation.TabIndex = 1
$LBdocumentation.TabStop = $true
$LBdocumentation.Tag = "https://github.com"
$LBdocumentation.Text = "here!"
$LBdocumentation.add_click({
    Start-Process "https://github.com/nicobucodiguito/dechoater/blob/main/README.md"
})


# GBdocumentationlink
$GBdocumentationlink.Controls.Add($LBhelptext)
$GBdocumentationlink.Controls.Add($LBdocumentation)
$GBdocumentationlink.Location = New-Object System.Drawing.Point(3, 3)
$GBdocumentationlink.Name = "GBdocumentationlink"
$GBdocumentationlink.Size = New-Object System.Drawing.Size(746, 42)
$GBdocumentationlink.TabIndex = 0
$GBdocumentationlink.TabStop = $false

# GBcat
# Cat is stored in $base64ImageString as, you wouldn't believe it, a base64 string
# Amazing image to base64 conversion which is later read as a memory stream by [System.Drawing.Image]
# All credit goes to https://www.alkanesolutions.co.uk/2013/04/19/using-base-64-encoding-for-images-in-powershell/
$base64ImageString = "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"
$imageBytes = [Convert]::FromBase64String($base64ImageString)
$ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
$ms.Write($imageBytes, 0, $imageBytes.Length); # The stream is as long as it needs to be thanks to .Length
$GBcat.BackgroundImage = [System.Drawing.Image]::FromStream($ms, $true) # $true for Bool "useEmbeddedColorManagement"
$GBcat.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Center
$GBcat.Location = New-Object System.Drawing.Point(3, 51)
$GBcat.Name = "GBcat"
$GBcat.Size = New-Object System.Drawing.Size(746, 431)
$GBcat.TabIndex = 1
$GBcat.TabStop = $false
$GBcat.Text = "Or try asking this guy!"

# FMmain
$FMmain.ClientSize = New-Object System.Drawing.Size(784, 550)
$FMmain.Controls.Add($TCmain)
$FMmain.Controls.Add($menuStrip1)
$FMmain.Controls.Add($menuStrip2)
$FMmain.MainMenuStrip = $menuStrip1
$FMmain.Name = "FMmain"
$FMmain.Text = "Dechoater"
$FMmain.ShowIcon = $false
$FMmain.Add_FormClosing( {} )
$FMmain.Add_Shown({$FMmain.Activate()})
$FMmain.ShowDialog()
# Release the Form
$FMmain.Dispose()


