# Impulse XDR 

#### Deep Security Visibility & Protection

ImpulseXDR is a complete security monitoring solution for servers and endpoints that comes with its own custom threat detection framework, indexing, storage and visualisation. 

Impulse takes a different approach to host intrusion detection that provides deeper visibility with minimal performance impact. Instead of looking for specific malware signatures, it uses trackers for indicators of compromise (implemented with osquery) that divide system activity into one of 50 different types. Malware comes in all shapes and forms but its output always falls into one of these categories - connections to C&C centers, modified files, systemd services, background tasks, auths, new processes, etc. Impulse assigns different metrics to each IoC group depending on its level of significance and aggregates them into detections. Therefore, it provides both a full history of everything important that has ever happened on the system and a filtered dashboard with high-severity detections.

Impulse uses high-performance, open-source components to deliver a solution that only needs 1-core, 1.5 GB RAM and can be installed on everything from cheap VPS/VMs, to laptops and Raspberry Pi.

It only takes two steps to set up deep security visibility and protection for your infrastucture and endpoints: 

1. Install the self-hosted security events manager on one of your existing instances. It runs on all major Linux distributions and requires close to zero configuration. 

2. Deploy a light or heavy sensor on each endpoint, depending on the features and level of visibility that you need. 

That's it. Security telemetry and analytics start flowing to your screen! 

[Documentation](https://impulse-xdr.com/docs/introduction/)

![fleet_firewall2](https://github.com/bgenev/impulse-xdr/assets/129767083/3c7c1865-5489-47c8-b099-9f9aef69aad7)

![detections_and_iocs](https://github.com/bgenev/impulse-xdr/assets/129767083/b0e8d299-6d71-438c-8eff-3c5b6eb80614)


## Main Features:

#### Security Analytics
Ingests telemetry data from its fleet of monitoring sensors and provides security analytics & insights.

#### Indicators of Compormise
Built-in core indicators of compromise track security events on hosts and alert you in case of anomalous activity.

Even if certain events don't generate a detection, they are still added to an "IOCs History" database which provides integrity monitoring for every aspect of your environment - files, processes, connections, ports, users, authentications, installed packages, kernel modules, etc. every variable that could be an indicator of compromise is tracked and analysed.

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
Integrates with high-quality threat intelligence providers to enrich your context data.

#### Vulnerability Scanning
Discovers installed packages and associated CVEs.

#### Self-Hosted & Open-Core
Data never leaves you servers.
