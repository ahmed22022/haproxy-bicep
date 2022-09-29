
$env = Read-Host 'Please enter the env name'
$vmName = Read-Host 'Please enter the VMname'
$osUsed =  read-host 'Please enter the os you will use'
$AdressPrefix =  read-host 'Please enter the vnet address prefix'
$SubnetAdressPrefix =  read-host 'Please enter the subnet address prefix'
$username = Read-Host 'please enter the username'
$vms = Read-Host 'please enter the number of vms'
$RG='haproxynextgen-rg-test'
# $RG= Read-Host 'Please enter the resource group name'
$deployment = New-AzResourceGroupDeployment -ResourceGroupName 'haproxynextgen-rg-test' -TemplateFile .\Main.bicep  -adminUsername $username -Name 'HaProxy-deploy' `
    -vmName $vmName -number_of_VMs $vms -addressPrefix $AdressPrefix `
    -subnetAddressPrefix $SubnetAdressPrefix -osUsed $osUsed -env $env

if ($deployment) {
    $slb=Get-AzLoadBalancer -Name "${vmName}-LB-${env}" -ResourceGroupName $RG
    for ($i = 1; $i -le $vms; $i++) {
        $port = 3021 + $i
        $slb  | Add-AzLoadBalancerInboundNatRuleConfig -Name "SSH-${i}" -FrontendIpConfiguration $slb.FrontendIpConfigurations[0] -Protocol tcp -FrontendPort $port -BackendPort 22
        $slb | Set-AzLoadBalancer
    }

}
$rulesID = $slb.InboundNatRules | Where-Object -FilterScript {$_.Name -Like "*ssh*"} | Select-Object -Property Id
$nics= Get-AzNetworkInterface -ResourceGroupName $RG | Where-Object -FilterScript {$_.Name -like '*haproxy*'}
for ($i = 0; $i -lt $nics.Count; $i++) {
    set-AzNetworkInterfaceIpConfig -Name $nics[$i].IpConfigurations.name -NetworkInterface $nics[$i] -SubnetId $nics[$i].IpConfigurations.subnet.Id -LoadBalancerInboundNatRuleId $rulesID[$i].ToString()
    $nics[$i] | Set-AzNetworkInterface
}
$nics[0].ipConfigurations[0].LoadBalancerInboundNatRules