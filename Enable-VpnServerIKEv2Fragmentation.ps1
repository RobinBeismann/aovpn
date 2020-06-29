<#

.SYNOPSIS
    Enable IKEv2 fragmentation support on Windows Server 1803 and later operating systems.

.PARAMETER Restart
    Restarts the RemoteAccess service.

.EXAMPLE
    .\Enable-VpnServerIKEv2Fragmentation.ps1

.DESCRIPTION
    Create a registry entry to enable IKEv2 fragmentation support on Windows Server 1803 and later operating systmes.

.LINK
    https://directaccess.richardhicks.com/2019/02/11/always-on-vpn-and-ikev2-fragmentation/

.NOTES
    Version:        1.1
    Creation Date:  August 3, 2019
    Last Updated:   January 25, 2020
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Web Site:       www.richardhicks.com

#>

[CmdletBinding()]

Param (

    [switch]$Restart

)

$OSVersion = (Get-CimInstance 'Win32_OperatingSystem').Version

# Must be running Windows Server 1803 or later to support IKEv2 fragmentation. Abort script if earlier release is detected.
If ($OSVersion -lt '10.0.17134') {

    Write-Warning 'IKEv2 VPN fragmentation is only supported on Windows Server 1803 (10.0.17134) or later operating systems. Exiting script.'
    Exit

}

# Registry settings
$Parameters = @{

    Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\Ikev2\'
    Name         = 'EnableServerFragmentation'
    PropertyType = 'DWORD'
    Value        = '1'

}

Write-Verbose 'Adding registry entry to enable IKEv2 fragmentation support...'

# Update registry
New-ItemProperty @Parameters -Force

# Restart RemoteAccess service
If ($Restart) {
    
    Write-Verbose 'Restarting the RemoteAccess service...'
    Restart-Service RemoteAccess -PassThru

}

Else {

    Write-Warning 'The RemoteAccess service must be restarted for these changes to take effect.'

}
