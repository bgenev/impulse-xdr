


sc.exe stop impulse-agentd
sc.exe delete impulse-agentd

choco uninstall -y nxlog osquery

sc.exe stop nxlog
sc.exe delete nxlog

cd 'C:\Program Files'

Remove-Item 'C:\Program Files\impulse' -Recurse -Force
Remove-Item 'C:\Program Files\nxlog' -Recurse -Force -Confirm:$false

