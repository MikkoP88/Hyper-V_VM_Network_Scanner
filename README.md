# Hyper-V VM Network Scanner
This tool provide easy and fast way to scan all virtual machines and their network interface settings on Hyper-V clusters.
### Note
- Tool can scan only Hyper-V Cluster environment.
- Tool can be used on remote machine and also not need to be domain joined.
- Tool is tested only with DNS names.
- Tool can scan all cluster nodes or single node.

## Usage
### Check before running
- Administrator privileges and Administrator credential. 
- Cluster node/nodes DNS names, this not needed if tool is startet on node what is member of cluster and you select scan all.

### Start scanning
When running scanner on non cluster member machine, you need do provide individually every cluster nodes DNS name. But if machine where tool is launched is member of cluster, tool provide shortcut for scan all nodes of cluster. 

Download Hyper-V_VM_Network_Scanner_1.0.ps1 file and run that with powershell.
```
cd <location of Hyper-V_VM_Network_Scanner_1.0.ps1 file>
.\Hyper-V_VM_Network_Scanner_1.0.ps1 
```

## Results
Result can be viewed on powershell table view or external sheet with grid view.

![This is an image](https://github.com/MikkoP88/Hyper-V_VM_Network_Scanner/blob/main/docs/choose_result_view_5.PNG)

### Result present following informations
- Node where VM is running
- VM Name
- Virtual switch name
- Network adabter name
- Network status
- Mac-address
- VLAN access list
- IP-address
