#<
# Run this as a Computer Startup script to allow installing fonts from C:\InstallFont\
# Based on http://www.edugeek.net/forums/windows-7/123187-installation-fonts-without-admin-rights-2.html
# Run this as a Computer Startup Script in Group Policy
# Full details on my website - https://mediarealm.com.au/articles/windows-font-install-no-password-powershell/
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    # Specifies the font name to install.  Default value will install all fonts.
    [Parameter(Position=0)]
    [string[]]
    $SourceDir = ''
)

$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$TempFolder  = "$env:temp\Fonts"

# Create the source directory if it doesn't already exist
New-Item -ItemType Directory -Force -Path $SourceDir | Out-Null

New-Item $TempFolder -Type Directory -Force | Out-Null

Get-ChildItem -Path $Source -Include '*.ttf','*.ttc','*.otf' -Recurse | ForEach-Object {
    If (Test-Path "$($env:userprofile)\AppData\Local\Microsoft\Windows\Fonts\$($_.Name)") {
        Write-Verbose "Font $($_.Name) already installed"
    } Else {
        Write-Verbose "Installing Font $($_.Name) ..."
        $Font = "$TempFolder\$($_.Name)"

        # Copy font to local temporary folder
        Copy-Item $($_.FullName) -Destination $TempFolder

        # Install font
        $Destination.CopyHere($Font,0x10)

        # Delete temporary copy of font
        Remove-Item $Font -Force
        Write-Verbose "Font $($_.Name) Installed successfully"
    }
}
