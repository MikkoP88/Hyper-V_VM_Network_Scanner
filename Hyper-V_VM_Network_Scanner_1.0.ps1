
#####################################################
#Scanner Start

function scannerScan ($clusterNode)
{
  Invoke-Command -ComputerName $clusterNode -ScriptBlock {

    $virtualMachines = Get-VM -VMName *

    $index = 0

    foreach ($virtualMachine in $virtualMachines)
    {
      $virtualMachineSelection = $virtualMachines.Name[$index]

      $netAdapterIndex = 1

      Write-Progress -Activity 'Scanning Network' -Id 1 -Status "VM: $virtualMachineSelection" -PercentComplete ((($index + 1) / ($virtualMachines.Count)) * 100)

      $vmNetworkAdapter = Get-VMNetworkAdapter -VMName $virtualMachineSelection

      foreach ($vmNetworkAdapter in $vmNetworkAdapter)
      {

        $vmNetwork = $vmNetworkAdapter
        $vmNetworkVlan = $vmNetworkAdapter.VlanSetting
        $vmVlanId = $vmNetworkAdapter.VlanSetting.AllowedVlanIdList
        $vmVlanNativeId = $vmNetworkAdapter.VlanSetting.NativeVlanId
        $vmVlanType = New-Object -TypeName PSObject

        if ($vmNetworkVlan.AccessVlanId)
        {
          $vlanAccess = $vmNetworkVlan.AccessVlanId
        }
        elseif ($vmVlanId)
        {
          $vlanAccess = "[$vmVlanNativeId] $vmVlanId"
        }

        #VM Network Scanning results
        $nodeResult += @([pscustomobject]@{ "Owner Node" = (Get-CimInstance CIM_ComputerSystem).Name; "VM Name" = $virtualMachineSelection; "Network Status" = $vmNetwork.Status; "Virtual Switch Name" = $vmNetwork.SwitchName; "Network Adapter Name" = $vmNetwork.Name; "Network Adapter ID" = $vmNetwork.AdapterId; "Mac-Address" = $vmNetwork.MacAddress; "Vlan Access List" = $vlanAccess; "IP-Address" = $vmNetwork.IpAddresses })
        $netAdapterIndex += 1
      }
      $index += 1
    }
    $nodeResult
  } -Credential $creds
  Write-Progress -Id 1 -Completed -Activity "Completed"
}
#Scanner End
#####################################################


#######################################################################################################################
#Interface Start

#Check is computer in cluster
$clusterNodes = Get-ClusterNode 3> $null -ErrorAction 'silentlycontinue'

#clearing existing results
$results = @()

#Interface when computer is in cluster
if ($clusterNodes)
{
  Write-Host ""
  Write-Host "This Computer is member of Hyper-V Cluster"
  Write-Host "This computer name is " (Get-CimInstance CIM_ComputerSystem).Name
  Write-Host ""
  Write-Host "All Cluster Nodes: " $clusterNodes
  Write-Host ""
  Write-Host "Use [A] to scan all nodes of cluster. This can be used only if scipt running on cluster member."
  Write-Host "Or enter node name what you want to scan."
  Write-Host ""
  $selectedNodes = Read-Host -Prompt "Node"

  #When selected scan all
  if ($selectedNodes -eq "A")
  {
    
    $creds = Get-Credential

    $nodeIndex = 0

    #Loop for scanning all nodes on cluster
    foreach ($clusterNodes in $clusterNodes)
    {
      Write-Progress -Activity 'Total process:' -Status "Scanning Node: $clusterNodes" -PercentComplete ((($nodeIndex) / ($clusterNodes.Count + 1)) * 100)

      $results += scannerScan ($clusterNodes.Name)

      $nodeIndex += 1
    }

    Write-Progress -Completed -Activity "Completed"

    #Selecting result view
    Write-Host ""
    Write-Host "[G] show result in Grid View, [T] show result in Table"
    Write-Host ""   
    $selectedResultView = Read-Host -Prompt "Input"

    #Results views
    if ($selectedResultView -eq "g")
    {
      $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Access","Network Status","Mac-Address","Vlan Access List","IP-Address" |
      Sort-Object -Property "VM Name" | Out-GridView -Title "VM Network Interfaces"
    }
    elseif ($selectedResultView -eq "t")
    {
      $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Access","Network Status","Mac-Address","Vlan Access List","IP-Address" |
      Sort-Object -Property "VM Name" | Format-Table
    }
  }
  else
  {
    #Loop for adding multiple nodes
    $nodeTable = @([pscustomobject]@{ Name = $selectedNodes })

    while ($selectedNodes)
    {
      Write-Host ""
      Write-Host "Add more nodes, or press Enter to scan."
      $selectedNodes = Read-Host -Prompt "Node"

      if ($selectedNodes)
      {
        $nodeTable += @([pscustomobject]@{ Name = $selectedNodes })
      }
    }

    $creds = Get-Credential

    $nodeIndex = 0

    #Loop for scanning all selected nodes
    foreach ($name in $nodeTable)
    {
      $thisNodeName = $nodeTable[$nodeIndex].Name
      Write-Progress -Activity 'Total process:' -Status "Scanning Node: $thisNodeName" -PercentComplete ((($nodeIndex) / ($nodeTable.Count + 1)) * 100)

      $results += scannerScan ($nodeTable[$nodeIndex].Name)

      $nodeIndex += 1
    }

    Write-Progress -Completed -Activity "Completed"

    #Selecting result view
    Write-Host ""
    Write-Host "[G] show result in Grid View, [T] show result in Table"
    Write-Host ""
    $selectedResultView = Read-Host -Prompt "Input"

    #Results views
    if ($selectedResultView -eq "g")
    {
      $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Status","Mac-Address","Vlan Access List","IP-Address" |
      Sort-Object -Property "VM Name" | Out-GridView -Title "VM Network Interfaces"
    }
    elseif ($selectedResultView -eq "t")
    {
      $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Status","Mac-Address","Vlan Access List","IP-Address" |
      Sort-Object -Property "VM Name" | Format-Table
    }
  }
}

#Interface when computer is not in cluster
else
{
  Write-Host ""
  Write-Host "Enter node name what you want to scan."
  Write-Host ""
  $selectedNodes = Read-Host -Prompt "Node"

  #Loop for adding multiple nodes
  $nodeTable = @([pscustomobject]@{ Name = $selectedNodes })

  while ($selectedNodes)
  {
    Write-Host ""
    Write-Host "Add more nodes, or press Enter to scan."
    $selectedNodes = Read-Host -Prompt "Node"

    if ($selectedNodes)
    {
      $nodeTable += @([pscustomobject]@{ Name = $selectedNodes })
    }
  }

  $creds = Get-Credential

  $nodeIndex = 0

  #Loop for scanning all selected nodes
  foreach ($name in $nodeTable)
  {
    $thisNodeName = $nodeTable[$nodeIndex].Name
    Write-Progress -Activity 'Total process:' -Status "Scanning Node: $thisNodeName" -PercentComplete ((($nodeIndex) / ($nodeTable.Count + 1)) * 100)

    $results += scannerScan ($nodeTable[$nodeIndex].Name)

    $nodeIndex += 1
  }

  Write-Progress -Completed -Activity "Completed"

  #Selecting result view
  Write-Host ""
  Write-Host "[G] show result in Grid View, [T] show result in Table"
  Write-Host ""
  $selectedResultView = Read-Host -Prompt "Input"

  #Results views
  if ($selectedResultView -eq "g")
  {
    $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Status","Mac-Address","Vlan Access List","IP-Address" |
    Sort-Object -Property "VM Name" | Out-GridView -Title "VM Network Interfaces"
  }
  elseif ($selectedResultView -eq "t")
  {
    $results | Select-Object -Property "Owner Node","VM Name","Virtual Switch Name","Network Adapter Name","Network Status","Mac-Address","Vlan Access List","IP-Address" |
    Sort-Object -Property "VM Name" | Format-Table
  }
}

#Interface End
#######################################################################################################################
