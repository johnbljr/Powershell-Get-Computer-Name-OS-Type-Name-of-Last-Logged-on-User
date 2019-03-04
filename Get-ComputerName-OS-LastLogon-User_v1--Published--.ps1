<#
------------------------------------------------------------
Author: John Leger
Date: March 1, 2019
Powershell Version Built/Tested on: 5.1
Title: Get Computer Name, OS Type, Name of Last Logged on User
Website: https://github.com/johnbljr
License: GNU General Public License v3.0
------------------------------------------------------------
#>  


# Search AD for Computers where the operating system contain 10 (For Windows 10) 
# Change the filter as you need to for your environment
# Returns "OS","Computer","LastLogon","User"

$computers = Get-ADComputer -filter * -Properties * | Where-Object {$_.OperatingSystem -like "*10*"} -PV Name
foreach ($comp in $computers) { 
$pcname = Get-ADComputer $comp.Name -Properties * | Select-Object operatingsystem, name, @{Name="Lastlogon";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
$lastuserlogoninfo = Get-WmiObject -Class Win32_UserProfile -ComputerName $pcname.name | Select-Object -First 1
$SecIdentifier = New-Object System.Security.Principal.SecurityIdentifier ($lastuserlogoninfo.SID)
$user = $SecIdentifier.Translate([System.Security.Principal.NTAccount]) 

[pscustomobject]@{
        OS = $pcname.OperatingSystem
        Computer = $pcname.name
        LastLogon = $pcname.LastLogon
        User = $user.value
        } | Export-csv c:\temp\pclogoninfo.csv -append -notypeinformation
} 