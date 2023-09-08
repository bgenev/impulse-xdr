Impulse xSIEM is an open-core security monitoring software tailored for virtual private servers (VPS), cloud networks (VPC) and personal workstations.

It consists of a self-hosted security events manager and fleet of light and heavy sensors that monitor and interact with hosts to protect them. 

Here is what it can do for you: 

### Security Analytics
Ingests telemetry data from its fleet of monitoring sensors and provides security analytics & insights.

### Indicators of Compormise
Built-in core indicators of compromise track security events on hosts and alert you in case of anomalous activity. 

### Network Visibility & IDS
Monitors network flows, detects intrusion attempts and automatically blocks offenders with active response.

### File Integrity Monitoring
Tracks changes on the filesystem tree and notifies you about file or permission modifications.

### Security Policies
Monitors system configuration settings to ensure compliance with preset core security policies.

### Active Response
Automatically blocks suspicious IPs, stops processes, closes ports and quarantines files.

### Fleet firewall
Fleet firewall blocks offenders across the fleet.

### Malware scanner
Integrated with VirursTotal to scan for malicious files on your hosts.

### Active Response
Integrated with several high-quality threat intelligence providers to enrich your context data.

### Self-Hosted & Open-Core
Data never leaves you servers. 

# Install Manager

## Download 
Download Impulse from the official GitHub repository

```
wget https://github.com/bgenev/impulse-siem/releases/download/v1.1.5/impulse_siem_v1.1.5.tar.gz
```

## Move to /opt
Move the archive in /opt (must be in /opt) 

## Untar 
```
tar -xf impulse_v1.1.2.tar.gz
```

## Enter your system's configuration values 
Then cd into /opt/impulse and modify the values in impulse.conf. Use your system's values for IP_MANAGER and HOST_INTERFACE. 

To get the IP and interface: 

```
ip a
```

## Create basic whitelist

Prior to starting installation, open /opt/impulse/whitelisted.txt and add: 

- the public ip of the computer that you will use to connect to the UI (use whatsmyip.com or similar). 
- any VPN ip addresses that you might use to connect to the web interface.

## Turn off VPN
If you have a VPN application running, turn it off because it will interfere with Docker and prevent the installation process from starting.


## Start Installation 
Start the installation process with:

```
./install_manager.sh
```

It will ask you a few questions to verify the setup and then proceed.  

# Post-Install 

## Login credentials
Your impulse admin user credentials are generated automatically and will be displayed in the terminal window. 

You can also find them in:
```
/var/impulse/data/manager/manager_creds.txt
```

## Access User Interface 
You can login to the manager's interface by going to: 

```
https://<MANAGER_IP>:7001/
```

You will see a standard browser notification informing you that you are loading a website with self-signed certificate. After clicking proceed, you will be redirected to the login screen where you can authenticate using the credentials that were generated during the build. 


## IOCs baseline
When you first login expect to see a lot of IOC events and 1 detection with 100+ signals. This is normal and is just the baseline that osquery builds when it is first installed on the system. There will be a lot less events afterwards.

## Check status, stop or start the manager 
```
/opt/impulse/impulse-control.sh status
```
```
/opt/impulse/impulse-control.sh stop
```

```
/opt/impulse/impulse-control.sh start 
```

## IOCs whitelisting 

If you notice that some of the software that you are running creates too many events, create an IOC exception for it by going to the IOC event -> Add Rule Exception and choosing the parameter that you want to exclude on. 

## NOTE: default whitelisted events
A number of standard system-generated events are whitelisted by default in the core osquery ruleset to reduce noise. Osquery is practically unusable for threat detection unless generic system events are filtered out - OS processes, sock events, calls to the threat intel APIs, etc. which add up to tens of thousands per day. 


## Create free AbuseIPDB and VirusTotal accounts

Add your keys to /opt/impulse/impulse.conf

```
ABUSEIPDB_API_KEY=<key_string>
VIRUS_TOTAL_API_KEY=<key_string>
```

Then restart the manager 

```
/opt/impulse/impulse-control.sh stop
/opt/impulse/impulse-control.sh start 
```

You might get a Docker networking issue preventing the manager from starting. In this case simply restart Docker, then restart the manager. 

## Generate system events to test the installation 

Open new port: 
```
nc -lvp 4003
```

Create new group:
```
addgroup rdmgroup1
```

Add new file: 
```
touch /etc/program1.sh
```

Add new background task:
```
touch /etc/cron.d/malicious_cron
printf "*/10 * * * * sh /opt/example.sh" >> /etc/cron.d/malicious_cron
```

Install some package to generate many events for an all-around test:
```
apt install -y wordpress 
```

Sensors check for new events every 30 seconds, so expect a little delay. After that you will see the events appear in the "IOCs History" card of the /instance screen.

