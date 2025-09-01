---
title: "Essential Linux Commands for System Troubleshooting & Monitoring"
description: "Master essential Linux troubleshooting commands for system administrators. Complete guide covering process management, service control, and network diagnostics."
author: sagarnikam123
date: 2016-06-14 12:00:00 +0530
categories: [linux, system-administration, troubleshooting]
tags: [linux-commands, systemd, performance-monitoring, network-troubleshooting, devops]
image:
  path: assets/img/posts/20160614/linux-troubleshooting-commands-guide.webp
  lqip: data:image/webp;base64,UklGRqoAAABXRUJQVlA4IJ4AAAAwBQCdASogACAAPzmCt1SvKCUjMBgMAeAnCUAAfKLv38IgxRK9jxBzSWwhOR6Wv6LI2AD++hETG04Md1BOAsnxIRE6iHcpWSyOpkalMMROZBnEHNTMYIWMeHOuIZq4UwSa+BjkBzPmKrYgbXvecEC7i7oExVYcsM82doWxcD0isi6FW+xA8wrl1QYlk17GTEZOgYpn8KmuNoXx2XkAAA==
  alt: Essential Linux Commands for System Troubleshooting & Monitoring Guide
---

Mastering **Linux troubleshooting commands** is essential for system administrators and DevOps engineers. This comprehensive guide covers the most important **Linux system administration commands** for diagnosing issues, monitoring performance, and maintaining healthy systems.

Whether you're troubleshooting performance issues, managing services, or diagnosing network problems, these commands will help you quickly identify and resolve system issues.

## Table of Contents
- [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)
- [Safety Guidelines](#safety-guidelines)
- [System Information & Hardware](#system-information--hardware)
- [Performance Monitoring & Resource Usage](#performance-monitoring--resource-usage)
- [Process Management](#process-management)
- [SystemD Service Management](#systemd-service-management)
- [Memory Analysis](#memory-analysis)
- [Network Configuration & Troubleshooting](#network-configuration--troubleshooting)
- [Port Management & Network Services](#port-management--network-services)
- [File System Operations](#file-system-operations)
- [Permissions & Ownership](#permissions--ownership)
- [System Control](#system-control)
- [Development Environment](#development-environment)
- [Cloud & Container Tools](#cloud--container-tools)
- [Common Troubleshooting Scenarios](#common-troubleshooting-scenarios)
- [Log Management & Analysis](#log-management--analysis)
- [Security & Intrusion Detection](#security--intrusion-detection)
- [Distribution-Specific Commands](#distribution-specific-commands)
- [Troubleshooting Decision Tree](#troubleshooting-decision-tree)
- [Conclusion](#conclusion)
- [Quick Command Reference](#quick-command-reference)
- [Related Articles](#related-articles)
- [Additional Learning Resources](#additional-learning-resources)

## Quick Reference Cheat Sheet

### Emergency Commands (⚠️ Use with caution)

**Medium Risk:**
- `kill -9 <pid>` - Force kill process (cannot be ignored)
- `pkill -9 <process_name>` - Force kill all matching processes

**High Risk:**
- `sudo reboot` - Restart system immediately
- `sudo iptables -F` - Flush all firewall rules
- `sudo systemctl stop <critical_service>` - Stop critical system service

**NEVER USE:**
- `rm -rf /` - Delete everything (system destruction)
- `dd if=/dev/zero of=/dev/sda` - Wipe disk completely

### Most Used Commands
```bash
# System status
htop                    # Interactive process viewer
free -h                 # Memory usage
df -h                   # Disk usage
systemctl status        # Service status

# Quick troubleshooting
journalctl -f           # Follow system logs
netstat -tulpn         # List open ports
ps aux | head -10      # Top processes
lsof -i                # Network connections
```

## Safety Guidelines

> ⚠️ **Warning:** Commands marked with this symbol can cause system damage or data loss.

> 💡 **Tip:** Always test commands in a non-production environment first.

> 🔒 **Security:** Never run unknown scripts with sudo privileges.

### Before Running Destructive Commands:
1. **Backup critical data**
2. **Test in staging environment**
3. **Have rollback plan ready**
4. **Inform team members**

## System Information & Hardware

### Operating System Information
Get detailed information about your Linux distribution and version:

```bash
# OS version and distribution info
cat /etc/os-release
cat /etc/centos-release  # CentOS/RHEL specific
lsb_release -a          # Ubuntu/Debian specific
```

### CPU Architecture & Core Information
Analyze CPU specifications and architecture:

```bash
# Number of processing units (logical cores with hyperthreading)
nproc

# Detailed CPU architecture information
lscpu

# Extract CPU count from lscpu output
lscpu | grep "^CPU(s):" | awk '{print $2}'

# System architecture
uname -m
arch

# Count physical CPU cores
cat /proc/cpuinfo | grep "processor" | wc -l
```

## Performance Monitoring & Resource Usage

### Top Resource Consumers
Identify processes consuming the most CPU and memory:

```bash
# Top 10 CPU consumers
ps aux --sort -%cpu | head -10
top -o %CPU | head -n 16

# Top 10 memory consumers
ps aux --sort -%mem | head -10
top -o %MEM | head -n 16
```

### Interactive Process Monitoring
Real-time system monitoring tools:

```bash
# Enhanced process viewer (colored, sortable)
htop

# Standard process viewer
top -i  # hide idle processes
top     # show all processes
```

## Process Management

### Finding Processes
Locate specific processes by name or pattern:

```bash
# Find process by name (shows PID, CPU%, MEM%)
ps aux | grep <process_name>
ps aux | grep java
ps aux | grep nginx

# Alternative process search methods
pgrep <process_name>     # returns PIDs only
pidof <process_name>     # returns PIDs only
```

### Terminating Processes
Safely and forcefully terminate processes:

```bash
# Graceful termination (SIGTERM)
kill <pid>

# Force kill process (SIGKILL - cannot be ignored)
kill -9 <pid>

# Kill all processes matching name
pkill <process_name>
pkill -9 <process_name>  # force kill

# Kill process by name with PID extraction
ps aux | grep -i firefox | awk '{print $2}' | xargs kill -9
```

## SystemD Service Management

### Listing Services
View and filter system services:

```bash
# All installed unit files
systemctl list-unit-files
systemctl list-unit-files --all

# List services by type
systemctl list-units --type=service      # loaded services
systemctl list-units --type=service --all # all services

# List services by state
sudo systemctl list-unit-files --type=service --state=enabled
sudo systemctl list-unit-files --type=service --state=disabled
sudo systemctl list-units --type=service --state=active
sudo systemctl list-units --type=service --state=running
sudo systemctl list-units --type=service --state=failed
sudo systemctl list-units --type=service --state=exited

# Filter services
systemctl list-unit-files | grep enabled
systemctl list-unit-files | grep disabled
```

### Service Control Operations
Manage service lifecycle and configuration:

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable/disable services (auto-start on boot)
sudo systemctl enable <service-name>
sudo systemctl disable <service-name>

# Service lifecycle management (systemctl)
sudo systemctl start <service-name>
sudo systemctl stop <service-name>
sudo systemctl restart <service-name>
sudo systemctl reload <service-name>    # reload config without restart
sudo systemctl status <service-name>

# Alternative service command (legacy)
sudo service <service-name> start
sudo service <service-name> stop
sudo service <service-name> restart
sudo service <service-name> status
```

### Creating Custom Services
Create and manage custom systemd services:

#### Service File Locations
- System services: `/etc/systemd/system/`
- User services: `/usr/lib/systemd/system/`

#### Example: Loki Service
```bash
sudo tee /etc/systemd/system/loki.service<<EOF
[Unit]
Description=Loki service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/loki -config.file=/opt/loki/config/loki-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

#### Example: Fluent-bit Service
```bash
sudo tee /etc/systemd/system/fluent-bit.service<<EOF
[Unit]
Description=Fluent Bit
Documentation=https://docs.fluentbit.io/manual/
Requires=network.target
After=network.target

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/fluent-bit
EnvironmentFile=-/etc/default/fluent-bit
ExecStart=/opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

#### Activating Custom Services
```bash
sudo systemctl daemon-reload
sudo systemctl enable <service-name>
sudo systemctl start <service-name>
```

### Service Log Analysis (journalctl)
Analyze service logs for troubleshooting:

#### Basic Log Viewing
```bash
# View all logs for specific service
journalctl -u <service-name>
journalctl -u <service-name> | head -50  # first 50 lines
journalctl -u <service-name> | tail -50  # last 50 lines
journalctl -u <service-name> -n 10       # last 10 lines
```

#### Time-based Log Filtering
```bash
# View logs by time range
journalctl --since=yesterday -u <service-name>
journalctl --since "1 hour ago" -u <service-name>
journalctl --since "2025-01-01 10:00:00" --until "2025-01-01 11:00:00" -u <service-name>
```

#### Log Content Filtering
```bash
# Filter logs by content
journalctl -u <service-name> | grep "error"
journalctl -u <service-name> | grep "started"

# Real-time log monitoring
journalctl -u <service-name> -f
```

#### Log Priority Levels
```bash
# View logs by severity
journalctl -u <service-name> -p err      # error and above
journalctl -u <service-name> -p warning  # warning and above
journalctl -u <service-name> -p info     # info and above
```

#### Advanced Log Formats
```bash
# Detailed log output formats
journalctl -u <service-name> -o verbose      # detailed output
journalctl -u <service-name> -o json         # JSON format
journalctl -u <service-name> -o json-pretty  # formatted JSON
journalctl -u <service-name> -x             # with help texts
```

#### Boot-specific Logs
```bash
# View logs by boot session
journalctl -u <service-name> -b     # current boot
journalctl -u <service-name> -b -1  # previous boot
journalctl --list-boots             # list available boots
```

#### System-wide Log Analysis
```bash
# System-wide log commands
journalctl              # all system logs
journalctl -k           # kernel messages only
journalctl -b           # current boot logs
journalctl --disk-usage # journal disk usage
```

## Memory Analysis

### Memory Usage Overview
Monitor system memory consumption and availability:

```bash
# Memory usage in human-readable format
free -h    # human-readable (KB, MB, GB)
free -g    # memory usage in GB
free -m    # memory usage in MB

# Virtual memory statistics
vmstat     # swap, I/O, CPU statistics
vmstat 1 5 # update every 1 second, 5 times

# Detailed memory information
cat /proc/meminfo
```

### Memory Performance Monitoring
```bash
# Memory usage by process
ps aux --sort=-%mem | head -10

# System memory pressure
sar -r 1 10  # memory utilization every 1 second
```

## Network Configuration & Troubleshooting

### Network Interface Management
Configure and manage network interfaces:

```bash
# View network interfaces
ip addr show
ifconfig

# View routing table
ip route show
route -n

# Network interface statistics
ip -s link show
```

### Static IP Configuration
Configure static IP addresses:

#### Method 1: Network Interfaces File (Debian/Ubuntu)
```bash
# Check current configuration
sudo ifdown eth0

# Edit network interfaces file
sudo nano /etc/network/interfaces

# Add static IP configuration:
auto eth0
iface eth0 inet static
address <static_IP_address>
netmask <netmask>
gateway <default_gateway>
pre-up sleep 2

# Activate new configuration
sudo ifup eth0
```

#### Method 2: Netplan (Ubuntu 18.04+)
```bash
# Edit netplan configuration
sudo nano /etc/netplan/01-network-manager-all.yaml

# Apply configuration
sudo netplan apply
```

### Network Connectivity Testing
```bash
# Test connectivity
ping -c 4 google.com
ping -c 4 8.8.8.8

# DNS resolution testing
nslookup google.com
dig google.com

# Network path tracing
traceroute google.com
mtr google.com  # continuous traceroute
```

## Port Management & Network Services

### Listing Open Ports
Identify active network services and listening ports:

```bash
# List all listening ports
sudo netstat -tulpn | grep LISTEN
sudo ss -tulpn | grep LISTEN  # modern alternative

# List all network connections
sudo netstat -tunpl
sudo ss -tunpl
```

### Port-to-Service Mapping
Identify services associated with port numbers:

```bash
# View system service-to-port mappings
cat /etc/services

# Search for specific ports
grep -w '80/tcp' /etc/services
grep -w '443/tcp' /etc/services
grep -E -w '22/(tcp|udp)' /etc/services
grep -E -w '2020/(tcp|udp)' /etc/services
cat /etc/services | grep 8080
```

### Process-to-Port Analysis
Identify which processes are using specific ports:

```bash
# List programs using listening ports
sudo lsof -nP -iTCP -sTCP:LISTEN

# Check specific port usage
sudo lsof -nP -i :8080        # TCP port 8080
sudo lsof -nP -iUDP:53        # UDP port 53
sudo fuser 9092/tcp           # process using TCP port 9092
sudo fuser -n tcp 9092        # alternative syntax

# Network connections with process info
sudo netstat -tunpl
sudo netstat -ant | grep :2181
sudo netstat -peanut | grep ":5140"
```

### Terminating Port-specific Processes
Kill processes using specific ports:

```bash
# Kill process using specific port
fuser -k 8080/tcp
kill -9 $(lsof -t -i:8080)

# Multiple port examples
kill -9 $(lsof -t -i:9092)
fuser -k 9092/tcp
```

### Port Connectivity Testing
Test network service availability:

```bash
# Install telnet client
sudo yum install telnet     # RHEL/CentOS
sudo apt install telnet     # Ubuntu/Debian

# Test port connectivity
telnet localhost 8080
telnet example.com 80

# Alternative connectivity tests
nc -zv localhost 8080       # netcat port scan
curl -I http://localhost:8080  # HTTP service test
```

### Port Scanning & Service Discovery
Scan for open ports and running services:

```bash
# Install nmap
sudo yum install nmap       # RHEL/CentOS
sudo apt install nmap       # Ubuntu/Debian

# Port scanning examples
sudo nmap -sT -O localhost           # TCP scan localhost
sudo nmap -sT -O 127.0.0.1          # TCP ports
sudo nmap -sU -O 192.168.2.254      # UDP ports
sudo nmap -sTU -O 192.168.2.24      # both TCP and UDP

# Service version detection
nmap -sV localhost
nmap -A localhost  # aggressive scan with OS detection
```

### Firewall Configuration
Manage firewall rules for port access:

```bash
# View current iptables rules
sudo iptables -S  # rules by specification
sudo iptables -L  # rules in table format

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Open specific ports
sudo iptables -A INPUT -p tcp --dport 2020 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 2020 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Save iptables rules (varies by distribution)
sudo iptables-save > /etc/iptables/rules.v4  # Debian/Ubuntu
sudo service iptables save                    # RHEL/CentOS
```

## File System Operations

### File Size Analysis
Analyze file and directory sizes:

```bash
# Human-readable file size
du -h yourfile.txt          # disk usage format (K, M, G, T)
ls -lh yourfile.txt         # file details with readable size
stat -c%s yourfile.txt      # actual file size in bytes

# Specific size units
du -b yourfile.txt          # bytes
du -k yourfile.txt          # kilobytes
du -m yourfile.txt          # megabytes
du -BG yourfile.txt         # gigabytes
du -BT yourfile.txt         # terabytes
```

### File Content Statistics
Analyze file content metrics:

```bash
# File content analysis
wc -l yourfile.txt          # number of lines
wc -w yourfile.txt          # number of words
wc -c yourfile.txt          # number of characters/bytes
```

### Longest Line Analysis
Find and analyze the longest lines in files:

```bash
# Length of longest line (number only)
awk '{ print length }' yourfile.txt | sort -nr | head -n 1

# Display the longest line itself
awk '{ if ( length > max ) { max = length; longest = $0 } } END { print longest }' yourfile.txt

# Line number and length of longest line
awk '{ if ( length > max ) { max = length; line = NR } } END { print "Line", line, "Length:", max }' yourfile.txt
```

### Viewing Specific Lines
Extract specific lines from files:

```bash
# Show single line (line 42)
sed -n '42p' yourfile.txt
awk 'NR==42' yourfile.txt
head -n 42 yourfile.txt | tail -n 1

# Show range of lines (42 to 45)
sed -n '42,45p' yourfile.txt
awk 'NR>=42 && NR<=45' yourfile.txt
```

### Directory Size Analysis
Analyze directory and folder sizes:

```bash
# Show all folders in current directory
du -sh */                   # human-readable, unsorted
du -sh */ | sort -hr        # sorted largest first
du -s */                    # KB, unsorted
du -s */ | sort -nr         # KB, sorted largest first

# Specific folder size in different units
du -sh /path/to/folder      # human-readable (K, M, G, T)
du -s /path/to/folder       # KB
du -sm /path/to/folder      # MB
du -sg /path/to/folder      # GB

# Files by size (descending)
ls -lhS                     # human-readable
ls -lS                      # bytes
du -ah . | sort -hr         # all files/folders, human-readable
du -ah . | sort -hr | head -10  # top 10 largest

# Disk usage summary
df -h                       # filesystem usage
du -sh .                    # current directory total
```

## Permissions & Ownership

### Changing File Ownership
Modify file and directory ownership:

```bash
# Change ownership recursively
sudo chown -R username:groupname ./directory/
sudo chown -R snikam:snikam ./Prod/

# Change ownership for single file
sudo chown username:groupname filename

# Change only user ownership
sudo chown username filename

# Change only group ownership
sudo chgrp groupname filename
```

### File Permissions
Manage file and directory permissions:

```bash
# View permissions
ls -la filename
stat filename

# Change permissions (numeric)
chmod 755 filename          # rwxr-xr-x
chmod 644 filename          # rw-r--r--
chmod 600 filename          # rw-------

# Change permissions (symbolic)
chmod u+x filename          # add execute for user
chmod g-w filename          # remove write for group
chmod o+r filename          # add read for others

# Recursive permission changes
chmod -R 755 directory/
```

## System Control

### System Shutdown & Restart
Safely shutdown and restart the system:

```bash
# Restart system
sudo shutdown -r now        # restart immediately
sudo reboot                 # alternative restart command
sudo systemctl reboot       # systemd restart

# Shutdown system
sudo shutdown -h now        # shutdown immediately
sudo poweroff               # alternative shutdown
sudo systemctl poweroff     # systemd shutdown

# Scheduled shutdown/restart
sudo shutdown -r +10        # restart in 10 minutes
sudo shutdown -h 20:30      # shutdown at 8:30 PM
sudo shutdown -c            # cancel scheduled shutdown
```

## Development Environment

### Python Development
Resolve common Python development issues:

```bash
# Fix ModuleNotFoundError
export PYTHONPATH=${PYTHONPATH}:${HOME}/your_python_module
export PYTHONPATH=${PYTHONPATH}:$(pwd)

# Add to Python script
import sys
import os
sys.path.append(os.getcwd())

# Virtual environment management
python3 -m venv myenv
source myenv/bin/activate  # Linux/Mac
deactivate                 # exit virtual environment

# Package management
pip install package_name
pip freeze > requirements.txt
pip install -r requirements.txt
```

### Code Editor Tips
Useful shortcuts and configurations:

```bash
# VS Code column selection (Mac)
# Shift + Option + Command + Right/Left

# VS Code command line integration
code filename.txt          # open file in VS Code
code .                     # open current directory
```

## Cloud & Container Tools

### Minikube Management
Manage local Kubernetes development environment:

```bash
# View Minikube configuration
minikube config view

# Check actual allocated resources
minikube ssh -- 'grep -E "cpu|mem|disk" /proc/meminfo /proc/cpuinfo && df -h'

# Inspect VM resources directly
minikube ssh
nproc      # CPU count
free -h    # Memory usage
df -h /    # Disk usage

# Kubernetes resource view
kubectl describe node
# Shows: Capacity, Allocatable, and Allocated resources

# Start Minikube with custom resources
minikube start --cpus=4 --nodes=2 --memory=8192 --disk-size=32g
minikube start --kubernetes-version=v1.32.0 --cpus=4 --memory=8192 --disk-size=30g --vm-driver=hyperkit
```

### AWS CLI Operations
Monitor AWS resources from command line:

```bash
# CloudWatch metrics - CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --period 3600 \
  --statistics Maximum \
  --dimensions Name=InstanceId,Value=i-0b100699f2321e6U1 \
  --region us-west-1 \
  --profile your_profile \
  --start-time 2024-08-24T01:39:06 \
  --end-time 2024-08-24T10:39:06

# List EC2 instances
aws ec2 describe-instances --region us-west-1

# S3 bucket operations
aws s3 ls
aws s3 sync ./local-folder s3://bucket-name/
```

## Common Troubleshooting Scenarios

### Scenario 1: High CPU Usage
**Problem:** Server running slow, high load average

**Solution Steps:**
1. `htop` - Identify CPU-intensive processes
2. `ps aux --sort -%cpu | head -10` - List top CPU consumers
3. `kill -15 <pid>` - Gracefully terminate problematic process
4. `systemctl restart <service>` - Restart if it's a service

**Example Output:**
```bash
$ htop
# Look for processes with high CPU% (>80%)
# Note the PID of problematic processes

$ ps aux --sort -%cpu | head -5
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1234 95.2  2.1 123456  8192 ?        R    10:30   5:23 problematic_app
```

### Scenario 2: Out of Memory
**Problem:** Applications crashing, system unresponsive

**Solution Steps:**
1. `free -h` - Check available memory
2. `ps aux --sort -%mem | head -10` - Find memory hogs
3. `sudo swapoff -a && sudo swapon -a` - Clear swap cache
4. `systemctl restart <memory-intensive-service>`

**Example Output:**
```bash
$ free -h
              total        used        free      shared  buff/cache   available
Mem:           7.7G        7.5G        100M        180M        200M        50M
Swap:          2.0G        1.8G        200M
```
**Interpretation:** Critical - only 50M available memory, swap heavily used

### Scenario 3: Network Connectivity Issues
**Problem:** Cannot reach external services

**Solution Steps:**
1. `ping 8.8.8.8` - Test internet connectivity
2. `ip route show` - Check routing table
3. `systemctl status NetworkManager` - Check network service
4. `sudo systemctl restart NetworkManager` - Restart networking

### Scenario 4: Service Won't Start
**Problem:** Critical service fails to start

**Solution Steps:**
1. `systemctl status <service>` - Check service status
2. `journalctl -u <service> -n 50` - View recent logs
3. Check configuration files for syntax errors
4. `systemctl daemon-reload` - Reload if config changed

## Log Management & Analysis

### Critical Log Locations
```bash
/var/log/syslog         # System messages (Ubuntu/Debian)
/var/log/messages       # System messages (CentOS/RHEL)
/var/log/auth.log       # Authentication logs
/var/log/kern.log       # Kernel messages
/var/log/cron.log       # Cron job logs
/var/log/nginx/         # Web server logs
/var/log/apache2/       # Apache logs
```

### Log Analysis Commands
```bash
# Find errors in logs
grep -i error /var/log/syslog
grep -i "failed\|error\|critical" /var/log/messages

# Monitor logs in real-time
tail -f /var/log/syslog
multitail /var/log/syslog /var/log/auth.log

# Search logs by date
journalctl --since "2024-01-01" --until "2024-01-02"
journalctl --since "1 hour ago"

# Count error occurrences
grep -c "error" /var/log/syslog
grep "error" /var/log/syslog | wc -l

# Find large log files
find /var/log -type f -size +100M -exec ls -lh {} \;
```

### Log Rotation Management
```bash
# Check logrotate configuration
cat /etc/logrotate.conf
ls /etc/logrotate.d/

# Manually rotate logs
sudo logrotate -f /etc/logrotate.conf

# Check log rotation status
sudo logrotate -d /etc/logrotate.conf
```

## Security & Intrusion Detection

### Failed Login Attempts
```bash
# Check failed SSH attempts
grep "Failed password" /var/log/auth.log
grep "Invalid user" /var/log/auth.log

# Count failed attempts by IP
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# Check successful logins
grep "Accepted password" /var/log/auth.log
last -n 20  # Last 20 logins
who         # Currently logged in users
```

### Process Security Analysis
```bash
# Check for suspicious processes
ps aux | grep -E "(nc|netcat|ncat)"
ps aux | grep -v "\[.*\]" | awk '{print $11}' | sort | uniq -c | sort -nr

# Check listening ports and associated processes
netstat -tulpn | grep LISTEN
lsof -i -P -n | grep LISTEN

# Check for unusual network connections
netstat -an | grep ESTABLISHED
ss -tuln | grep LISTEN
```

### File System Security
```bash
# Find files with unusual permissions
find / -perm -4000 -type f 2>/dev/null  # SUID files
find / -perm -2000 -type f 2>/dev/null  # SGID files
find / -perm -777 -type f 2>/dev/null   # World writable files

# Check for recently modified files
find /etc -mtime -1 -type f  # Modified in last 24 hours
find /home -name ".*" -type f # Hidden files in home directories
```

## Distribution-Specific Commands

### Package Management

**Ubuntu/Debian:**
```bash
apt update && apt upgrade    # Update packages
apt install <package>        # Install package
apt search <package>         # Search package
apt remove <package>         # Remove package
apt list --installed         # List installed packages
```

**CentOS/RHEL:**
```bash
yum update                   # Update packages (CentOS 7)
dnf update                   # Update packages (CentOS 8+)
yum install <package>        # Install package
yum search <package>         # Search package
yum remove <package>         # Remove package
```

**Arch Linux:**
```bash
pacman -Syu                  # Update packages
pacman -S <package>          # Install package
pacman -Ss <package>         # Search package
pacman -R <package>          # Remove package
pacman -Q                    # List installed packages
```

**openSUSE:**
```bash
zypper update                # Update packages
zypper install <package>     # Install package
zypper search <package>      # Search package
zypper remove <package>      # Remove package
```

### Service Management

**Modern Systems (systemd):**
```bash
systemctl start <service>    # Start service
systemctl stop <service>     # Stop service
systemctl status <service>   # Service status
systemctl enable <service>   # Enable on boot
systemctl disable <service>  # Disable on boot
```

**Legacy Systems (SysV):**
```bash
service <service> start      # Start service
service <service> stop       # Stop service
service <service> status     # Service status
chkconfig <service> on       # Enable on boot
chkconfig <service> off      # Disable on boot
```

### Network Configuration

**Ubuntu 18.04+ (Netplan):**
```bash
sudo nano /etc/netplan/01-network-manager-all.yaml
sudo netplan apply           # Apply configuration
netplan status               # Check status
```

**CentOS/RHEL (NetworkManager):**
```bash
nmcli connection show        # Show connections
nmcli device status          # Device status
sudo firewall-cmd --list-all # Firewall status
```

**Arch Linux (systemd-networkd):**
```bash
sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-resolved
sudo iptables -L             # Firewall rules
```

## Troubleshooting Decision Tree

```
System Issue?
├── Performance Problem?
│   ├── High CPU → Check processes (htop, ps aux --sort -%cpu)
│   │   └── Kill problematic process (kill -15 <pid>)
│   ├── High Memory → Check memory usage (free -h, ps aux --sort -%mem)
│   │   └── Restart memory-intensive services
│   └── High I/O → Check disk usage (iotop, df -h)
│       └── Clean up disk space or optimize I/O
├── Network Problem?
│   ├── No connectivity → Check interfaces (ip addr show)
│   │   └── Restart NetworkManager (systemctl restart NetworkManager)
│   ├── Slow connection → Check routing (traceroute, mtr)
│   │   └── Investigate network path issues
│   └── Port issues → Check listening ports (netstat -tulpn)
│       └── Configure firewall or restart services
├── Service Problem?
│   ├── Won't start → Check logs (journalctl -u <service>)
│   │   └── Fix configuration or dependencies
│   ├── Crashes → Check system logs (journalctl -p err)
│   │   └── Investigate error messages
│   └── Config issues → Validate config files
│       └── Test configuration syntax
└── Security Issue?
    ├── Unauthorized access → Check auth logs (/var/log/auth.log)
    │   └── Block suspicious IPs, change passwords
    ├── Suspicious processes → Check running processes (ps aux)
    │   └── Investigate and terminate if malicious
    └── File changes → Check file integrity (find, checksums)
        └── Restore from backup if compromised
```

---

## Conclusion

This comprehensive guide covers essential **Linux troubleshooting commands** for system administrators and DevOps engineers. Regular practice with these commands will improve your ability to quickly diagnose and resolve system issues.

### Key Takeaways:
- **System monitoring**: Use `htop`, `top`, and `ps` for process analysis
- **Service management**: Master `systemctl` and `journalctl` for service control
- **Network troubleshooting**: Leverage `netstat`, `lsof`, and `nmap` for network issues
- **Performance analysis**: Utilize `free`, `vmstat`, and `du` for resource monitoring
- **Log analysis**: Use `journalctl` with various filters for effective troubleshooting

Bookmark this guide for quick reference during system troubleshooting sessions. Regular use of these commands will make you more efficient at maintaining Linux systems.

## Quick Command Reference

```bash
# Emergency troubleshooting one-liners
htop                                    # System overview
journalctl -f                          # Live system logs
netstat -tulpn | grep LISTEN           # Open ports
ps aux --sort -%cpu | head -5          # Top CPU users
free -h && df -h                       # Memory and disk
systemctl --failed                     # Failed services
```

## Related Articles

### Development Workflow Integration
- **[Complete Git Workflows Guide]({% post_url 2023-01-31-git-workflows-guide %}){:target="_blank"}** - Master Git commands and workflows for version control in your Linux development environment
- **[Ubuntu Fresh Install Setup Guide]({% post_url 2021-08-20-ubuntu-fresh-install-setup-guide %}){:target="_blank"}** - Complete Ubuntu development environment setup and system configuration

### System Administration
These Linux troubleshooting commands are essential for managing development servers, CI/CD pipelines, and production environments. Master both system setup and troubleshooting for complete Linux administration expertise.

## Additional Learning Resources
- [Linux System Administration Best Practices](https://www.redhat.com/sysadmin/)
- [Advanced SystemD Service Management](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Network Security with iptables](https://netfilter.org/documentation/HOWTO/packet-filtering-HOWTO.html)
- [Performance Monitoring Tools Guide](https://www.brendangregg.com/linuxperf.html)
- [Linux Security Hardening Guide](https://www.cisecurity.org/controls/)
- [Container Troubleshooting with Docker](https://docs.docker.com/engine/logging/)
- [Kubernetes Debugging Commands](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Red Hat System Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs)
- [Arch Linux Wiki](https://wiki.archlinux.org/)

---

**Happy troubleshooting!** 🚀
