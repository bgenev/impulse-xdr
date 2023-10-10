# Impulse XDR
## Security Monitoring, Threat Detection & Response for Servers & Endpoints 

Impulse provides advanced host & network intrusion detection via self-hosted security events manager and fleet of native sensors that monitor and interact with hosts to protect them.

Whether your goal is to secure a single VPS server or large cloud network, Impulse will help you get there. Set up deep visibility and protection for your VPS / VPC / VMs / Droplets or Desktop in two steps: 

1. Install the self-hosted manager on one of your existing instances. It runs on all major Linux distributions and requires close to zero configuration.

2. Deploy a light or heavy sensor on each endpoint, depending on the capabilities that you need, and point it to the IP of the manager.

That's it. Security analytics start flowing to your screen! 

# Overview 
Impulese provides intrusion detection by monitoring every aspect of your environment - files, processes, connections, ports, users, authentications, installed packages, kernel modules, etc. every variable that could be an indicator of compromise is tracked, stored and analysed.

It consists of sensors, built on top of performant telemetry extraction and transportation tools (osquery, rsyslog, grpc), that run on your monitored endpoints and forward data to a self-hosted security events manager. The manager indexes, aggregates and analyzes the incoming information, then provides analytics, insights and active response.

It is highly specific to signals generated by the Linux operating system and its goal, as a project, is to help make Linux environments ultra secure and observable for every Linux user.

![main_short_v2](https://github.com/bgenev/impulse-siem/assets/129767083/ef135f13-6ad6-4acc-ba68-ce932b87fc72)

## Features: 

#### Security Analytics
Ingests telemetry data from its fleet of monitoring sensors and provides security analytics & insights.
#### Indicators of Compormise
Built-in core indicators of compromise track security events on hosts and alert you in case of anomalous activity. 
#### Network Visibility & IDS
Monitors network flows, detects intrusion attempts and automatically blocks offenders with active response.
#### File Integrity Monitoring
Tracks changes on the filesystem tree and notifies you about file or permission modifications.
#### Security Policies
Monitors system configuration settings to ensure compliance with preset core security policies.
#### Active Response
Automatically blocks suspicious IPs, stops processes, closes ports and quarantines files.
#### Fleet firewall
Fleet firewall blocks offenders across the fleet.
#### Malware scanner
Integrated with VirursTotal to scan for malicious files on your hosts.
#### Threat Intel
Integrated with several high-quality threat intelligence providers to enrich your context data.
#### Self-Hosted & Open-Core
Data never leaves you servers. 


## Deployment Scenarios

### Standalone mode on VPS Server / local VM / Laptop / PC
To just test, install in stadalone mode with "heavy".

If you don't care about what's happening on the network and just want to track key indicators of compromise and be alerted about anomalous activity on the machine, simply deploy the manager in standalone "light" mode. 

In that configuration it will use about 500mb RAM. Alternatively, to reduce resource consumption, deploy the manager on another host and install light sensor on the target device pointing to the public IP of the host. Light sensor's resource usage is about 100mb RAM which could be reduced further by increasing the time interval for events checks. 

impulse.conf should look like this:

```
...
IP_MANAGER=<PUBLIC_IP_MANAGER>
SETUP_TYPE=manager  
AGENT_TYPE=light 
...
```
If you want NIDS capabilities later on, change AGENT_TYPE to heavy and restart the manager. 

NOTE: to change the sensor type from light to heavy, you must regenerate it on the UI and then redeploy on the instance. 

### VPC cloud network 
Deploy the manager in standalone "light" mode inside the VPC (or on a VPS server somewhere else; it could be a different network and provider), and place light on every instance inside the VPC apart from the gateway instance, which should have a "heavy" to monitor traffic for the network.  

### Cluster of VPS server 
Be aware that monitoring a large amount of servers in a cluster configuration with heavy sensors requires a powerful host with background workers because network visibility and IDS generate 50x more events.

However, a 4GB RAM, 2CPUs manager can easily handle IOCs monitoring for 20-30 servers with light sensors. Thanks to events pre-filtering done on the edge, the manager only receives meaningful security-related events, typically about 2k per day/host. 


# Install the Manager

## Download 
Download Impulse from the official GitHub repository

```
wget https://github.com/bgenev/impulse-siem/releases/download/latest/impulse_siem_v1.1.9.tar.gz
```

## Move to /opt
Move the archive in /opt (must be in /opt) 

## Untar 
```
tar -xf impulse_siem_v1.1.9.tar.gz
```

## Enter your system's configuration values 
cd into /opt/impulse and modify the values in impulse.conf. Use your system's values for IP_MANAGER and HOST_INTERFACE. 

To get the IP and interface: 

```
ip a
```

e.g. impulse.conf manager:
```
...
IP_MANAGER=192.168.0.37
HOST_INTERFACE=eth1
...
```

## Start Installation 
Start the installation process with:

```
./install_manager.sh
```

It will ask you a few questions to verify the setup and then proceed. If you don't have Docker installed, it will install it for you.  

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
A number of standard system-generated events are whitelisted by default in the core osquery ruleset to reduce noise - OS processes, sock events, calls to the threat intel APIs, etc. that add up to tens of thousands per day.


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
