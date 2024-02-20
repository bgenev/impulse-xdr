
#Requires -RunAsAdministrator

Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force -Confirm:$false

# Install chocolately if not available 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install agent deps
choco feature enable -n=allowGlobalConfirmation
choco install -y python3 nxlog 
choco install -y osquery --params='/InstallService'

# Copy config files 
Copy-Item "C:\Program Files\impulse\build\nxlog\nxlog.conf" -Destination "C:\Program Files\nxlog\conf\nxlog.conf"
Copy-Item "C:\Program Files\impulse\build\nxlog\ca-cert.pem" -Destination "C:\Program Files\nxlog\cert"
Copy-Item "C:\Program Files\impulse\build\osquery\osquery.conf" -Destination "C:\Program Files\osquery\osquery.conf"


# Restart services 
Restart-Service -Name osqueryd
Restart-Service -Name nxlog

# Refresh Env Vars
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

# Create virtual environment 
cd 'C:\Program Files\impulse'
python -m venv venv

# Activate venv 
.\venv\Scripts\Activate.ps1
 
# Update pip and install requirements 
python -m pip install --upgrade setuptools
pip3 install --no-cache-dir  --force-reinstall -Iv grpcio grpcio-tools osquery configparser PyJWT schedule

# Install service 
cd 'C:\Program Files\impulse\build\nssm-2.24\win64'
.\nssm install "impulse-agentd" "C:\Program Files\impulse\impulse-service.bat"

sc.exe start impulse-agentd

