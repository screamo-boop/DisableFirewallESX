#Script to disable firewall using PowerCLI
#Install PowerCLI and set correct execution policy if not work
# 1. Initialize vars and configure PowerCLI
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple     `
                          -InvalidCertificateAction Ignore  `
                          -Confirm:$false
$esxuser = 'root'
$esxpass = 'P@ssw0rd'
# 2. read stands.txt file and pognali
$stands = Get-Content stands.txt
foreach ($stand in $stands) {
    #Connect
    Connect-VIServer -Server $stand -User $esxuser -Password $esxpass
    #Get existing policy
    $policy = Get-VMHostFirewallDefaultPolicy
    #Replace existing policy
    Set-VMHostFirewallDefaultPolicy -Policy $policy -AllowIncoming $true -AllowOutgoing $true
    #Start VMs and answer question
    $vms = Get-VM | Where-Object { $_.PowerState -eq 'PoweredOff' }
    foreach ($vm in $vms) {
        Get-VM $vm | Start-VM -ErrorAction Ignore
        Get-VM $vm | Get-VMQuestion | Set-VMQuestion -DefaultOption -Confirm:$false -ErrorAction Ignore
    }
    #Disconnect
    Disconnect-VIServer -Confirm:$false
    #repeat
}