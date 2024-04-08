<div align=center>
<h1>Welcome to Impulse XDR!</h1>
<h2>
<a href="https://impulse-xdr.com/docs/get-started/install_manager">Quickstart</a> |
<a href="https://impulse-xdr.com/docs/introduction">Docs</a> |
<a href="https://impulse-xdr.com">Web</a> |    
<a href="https://github.com/bgenev/impulse-xdr/releases">Releases</a>
</h2>
</div>


## 🌟 Deep Security Visibility & Protection

Impulse is a fully automated SIEM/XDR with real-time threat detection sensors, storage and visualisation. It detects malware from behavioural patterns rather than signatures and enables deeper visibility than legacy tools. It can be deployed on any device or VM running Linux such as cloud VMs in VPC networks, VPS servers or personal workstations and IoTs. 

It’s organised around a self-hosted, manager-sensor architecture that provides traditional SIEM capabilities like centralized log storage, indexing and normalization, but also automated log-correlation and real-time threat detection via its open-source EDR sensors. It installs in 5 mins on as little as 1.5 gb RAM, 1-core VM.

![instance_with_detection](https://github.com/bgenev/impulse-xdr/assets/129767083/fea77d03-5fc3-4d66-b402-53abf90dd629)


## What makes it better at threat detection? 

Instead of looking for specific malware signatures, it tracks indicators of compromise via their on-disk forensic artefacts. Malware comes in all shapes and forms but its output is always the same - connections to C&C centres, modified files, new processes, modified services/background tasks, authentications, etc. Impulse assigns different metrics/weight to each IOC group (implemented with osquery) depending on its level of significance and continuously monitors for new events. It then aggregates bursts of events, indicative of anomalous activity, into detections. 

This approach provides a much deeper visibility and allows detections of unknown threats from behavioural activity patterns rather than constantly updated signatures. Users get a full historical chain of events with everything important that has ever happened on the system and a filtered dashboard with high-severity detections. 

## Components

![edr_diagram_v5](https://github.com/bgenev/impulse-xdr/assets/129767083/8fdfda63-392e-438c-9d07-004d5c1d7c16)


**Host Sensor (EDR)**

Tracks every important variable that could be indicator of compromise and filters noise at the edge. Core version detects:

- Processes & Background Tasks
- Authentications & SSH Activity
- Connections & Socket Events
- Shell History & Root Commands
- Ports & Interfaces
- Services & Crons
- Files & Permissions
- Users & Groups
- DEP/RPM/Python Packages
- Kernel Modules
- Offensive Tools

**Network Sensor (NDR)**

Network monitoring & intrusion detection with turnkey Suricata solution, optimised for performance and ease-of-use. Completely decoupled from the rest of the setup and can be installed on host or VM with custom CPU/RAM and NIC:

- Detects Malicious Traffic & Generates Alerts
- Enriches logs with IP threat intelligence
- Shows Signature Payloads & Packet Flows
- Maps Attacker Geolocation
- Create & distribute custom rulesets
- Automatically blocks attackers via distributed nftables-based fleet firewall
- Extracts Files from Flows
- Tracks DNS, HTTP and DHCP requests

**Threat Detection Engine** 

Threat Detection Engine correlates signals and aggregates them into detections.



## 🚴‍♂️ Main Features

- **Security Analytics**: Ingests telemetry data from its fleet of monitoring sensors and provides security analytics & insights.
- **Indicators of Compormise**: Built-in core indicators of compromise track security events on hosts and alert you in case of anomalous activity. Even if certain events don't generate a detection, they are still added to an "IOCs History" database which provides integrity monitoring for every aspect of your environment - files, processes, connections, ports, users, authentications, installed packages, kernel modules, etc. every variable that could be an indicator of compromise is tracked and analysed.
- **Network Visibility & IDS**: Monitors network flows, detects intrusion attempts and automatically blocks offenders with active response.
- **File Integrity Monitoring**: Tracks changes on the filesystem tree and notifies you about file or permission modifications.
- **Security Policies**: Monitors system configuration settings to ensure compliance with preset core security policies.
- **Active Response**: Automatically blocks suspicious IPs, stops processes, closes ports and quarantines files.
- **Fleet Firewall**: Fleet firewall blocks offenders across the fleet.
- **Threat Intel**: Integrates with high-quality threat intelligence providers to enrich your context data.
- **Vulnerability Scanning**: Discovers installed packages and associated CVEs.
- **Self-Hosted & Open-Core**: Data never leaves you servers.


## 🛠️ Use Cases  

1. **Cloud VMs in VPC.** Works with any cloud provider including AWS, DigitalOcean, Azure, GCP, Alibaba, etc.

2. **VPS server.** Either deploy in standalone mode or deploy the manager on one VPS and then place a sensor on the target VPS.

3. **Cluster of VPS servers.** If you have multiple VPS servers spread across various providers, simply choose one of them as the manager and place light/heavy sensors on the rest.

4. **Website host.** Install in standalone mode to lockdown your host and reduce load by blocking port scanners.

5. **Monitor personal workstation.** The Impulse EDR provides real-time threat-detection & integrity monitoring for personal computers. A hardened Linux Desktop such as Debian with Impulse EDR monitoring is one of the most secure configurations that you can get.

6. **IOT device, Raspberry Pi or similar.** Light sensors can be installed on any Linux device that provides ssh access. 

7. **Install on local VM and learn cybersecurity/sysadmin.** The level of visibility provided by Impulse means that you can use it to learn and play around with Linux environments. Deploy on localhost VM, then modify system settings or try to attack the VM and observe what changes in the “IOT History” dashboard.

## 📘 How to get started and documentation

Set up deep security visibility and protection for your infrastructure in two steps:

1. Install the self-hosted security events manager on one of your existing machines (this could be any VM, VPS, laptop or Raspberry Pi with 1-core, 1.5gb RAM). It runs on all major Linux distributions and requires close to zero configuration.
    
2. Deploy a light or heavy sensor on each endpoint, depending on the features and level of visibility that you need.
That's it. Security telemetry and analytics start flowing to your screen!


[Setup & Documentation](https://impulse-xdr.com/docs/introduction/)


## How does it compare with other security monitoring tools?

| Feature                                                                                  | Other Tools                                              | Impulse XDR                         |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Able to detect known and unknown malware from system behaviour                               | No                                                       | Yes                                                                          |
| Visibility level                                                                              | Tell you only when something really, really bad happens. | Full historical chain of events for every potential indicator of compromise. |
| Traditional SIEM features with centralized log storage, indexing and storage                  | Some                                                     | Yes                                                                          |
| Light, open-source sensors with host and network intrusion detection baked-in                 | No                                                       | Yes                                                                          |
| File Integrity Monitoring                                                                     | Some                                                     | Yes                                                                          |
| Secure Configuration Management                                                               | Basic                                                    | Yes                                                                          |
| Can work on as little as 1.5 GB RAM, 1-core CPU                                               | No way                                                   | Yes                                                                          |
| Purpose-built interface for presenting security information in digestible form                | No                                                       | Yes                                                                          |
| Flexible installation on any Linux OS instance with Docker containers and SystemD services    | Some                                                     | Yes                                                                          |
| Create and distribute custom monitoring policies                                              | Some                                                     | Yes                                                                          |
| Active response with fleet firewall, asset isolation and remote script execution              | No                                                       | Yes                                                                          |
| Easy self-host installation                                                                   | No                                                       | Yes                                                                          |
| Future proof, built with best in class components: Postgres, gRPC, Rsyslog, Osquery, Suricata | No                                                       | Yes                                                                          |
| Pricing                                                                                       | Bill shock                                               | Free version and affordable premium                                          |

**Demo**

![fleet_firewall2](https://github.com/bgenev/impulse-xdr/assets/129767083/1341ffdb-9842-4151-8d37-8d216104b58a)


**Fleet**

![fleet_overview](https://github.com/bgenev/impulse-xdr/assets/129767083/c4137bf1-d899-48ab-8ace-c1e46bfa2782)


**Detections** 

![detections_v1](https://github.com/bgenev/impulse-xdr/assets/129767083/25559b6b-8000-4d16-8365-b8e02af4adc5)


**Network IDS**

![nids_alerts_v1](https://github.com/bgenev/impulse-xdr/assets/129767083/3a499ece-b03e-47b4-9964-b0ebe6306290)


**Secure Configuration**

![sca_v1](https://github.com/bgenev/impulse-xdr/assets/129767083/227a0490-37d1-4cc5-bb16-5ee5e7c3cb36)


**Live Query**
![distrib_query_v1](https://github.com/bgenev/impulse-xdr/assets/129767083/3095c112-7021-4c68-b1ac-659fc9f686f7)
