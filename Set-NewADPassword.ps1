$Path = "$env:USERPROFILE\Desktop\"

<# This PowerShell script sets generated passwords for multiple AD accounts

__author__ = "buzz1n6m4xx"
__status__ = "Production"
__version__ = "0.1"

#>

# Importing Input File

$PWDs = Import-CSV -Path "$Path/Compromised_Passwords.csv"

<# - - -Remove line if needed - - -

# Removing old Export Files in Path

Remove-Item -Path "$Path/New-ADUserPWD.log" -ErrorAction SilentlyContinue
Remove-Item -Path "$Path/New_Passwords.csv" -ErrorAction SilentlyContinue 

- - - Remove Line if needed - - - #>

# Importing Namespace to manage passwords

Add-Type -AssemblyName System.Web

# Starting to log

Start-Transcript -Path "$Path\New-ADUserPWD.log" -Append

# Looping through each AD Account

foreach ($PWD in $PWDs) {

    # Generate a 16 digit password, with 2 non-alphanumeric characters

    $NewPWD = [System.Web.Security.Membership]::GeneratePassword(16,2)
    $UserName = $PWD.sAMAccountName

    # Write status to console
    
    Write-Host ("Setting new password for user " + $PWD.sAMAccountName) -ForegroundColor Green

    # Set password

    Set-ADAccountPassword -Identity $PWD.sAMAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPWD -Force)
    
    <# - - -Remove line if needed - - -

    # Set Account to force "User must change password at next logon"

    Set-ADUser -Identity $PWD.sAMAccountName -ChangePasswordAtLogon $True
    
    - - - Remove Line if needed - - - #>
    
    # Appending Account password to file

    $exportdata = ($UserName + ";" + $NewPWD) | Out-File -FilePath "$Path\New_Passwords.csv" -Append
    }

# Stop loggging

Stop-Transcript