---
layout: post
title: "Commands for Linux troubleshooting"
description: "imp commands used during troubleshooting"
date: 2016-06-14 12:00:00 +0530
categories: [linux]
tags: [troubleshooting, commands]
---

### system information
```bash
cat /etc/os-release # OS version and distribution info
cat /etc/centos-release # OS specific

nproc # No of processing units available (typically logical cores including hyperthreading)
lscpu # Detailed CPU architecture info (number of physical cores, threads, and sockets)
lcpu | grep "^CPU\(s\):" | awk '{print $2}'

uname -m  # prints architecture
arch  # architecture
cat /proc/cpuinfo | grep "processor" | wc -l  # Lists each CPU core
```

### resource utilization

- top 10 CPU/memory users (sorted by %CPU/%MEM descending)

```bash
ps aux --sort -%cpu | head -10  # cpu
top -o %CPU | head -n 16  # cpu

ps aux --sort -%mem | head -10  # memory
top -o %MEM | head -n 16  # memory
```

- interactive real-time process viewer

```bash
htop  # colored, sortable
top -i  # hide idle processes
```

### process

- find specific process by name (shows PID, CPU%, MEM%)
```bash
ps aux | grep <automationName>
ps aux | grep java
```
- Force kill process (SIGKILL - cannot be ignored)
```bash
kill -9 <pid>
```

- force kill process with process name (with pid)
```bash
ps aux | grep -i firefox | awk {'print $2'} | xargs kill -9
```

### systemD Service

#### list services
- all installed unit files
  ```shell
  systemctl list-unit-files
  systemctl list-unit-files --all
  ```

- list services by type
  ```shell
  systemctl list-units --type=service # all loaded services
  systemctl list-units --type=service --all # all services (loaded/inactive)
  ```

- list services by state
  ```shell
  sudo systemctl list-unit-files --type=service --state=enabled # enabled services
  sudo systemctl list-unit-files --type=service --state=disabled  # disabled services
  sudo systemctl list-units --type=service --state=active # active services
  sudo systemctl list-units --type=service --state=running  # running services
  sudo systemctl list-units --type=service --state=failed # failed services
  sudo systemctl list-units --type=service --state=exited # exited services
  ```

- filter services
  ```shell
  systemctl list-unit-files | grep enabled  # enabled only
  systemctl list-unit-files | grep disabled # disabled only
  ```

#### service management
- reload systemd configuration
```shell
sudo systemctl daemon-reload
```

- enable/disable services
```shell
sudo systemctl enable <service-name>  # enable service
sudo systemctl disable <service-name> # disable service
```

- start/stop/restart services (systemctl)
```shell
sudo systemctl start <service-name> # start service
sudo systemctl stop <service-name>  # stop service
sudo systemctl restart <service-name> # restart service
sudo systemctl status <service-name>  # service status
```

- start/stop/restart services (service command)
```shell
sudo service <service-name> start # start service
sudo service <service-name> stop  # stop service
sudo service <service-name> restart # restart service
sudo service <service-name> status  # service status
```

#### create custom service
- service file locations:
  - System services: `/etc/systemd/system/`
  - User services: `/usr/lib/systemd/system/`

- Loki service

```shell
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

- Fluent-bit service

```shell
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

- after creating service file
```shell
sudo systemctl daemon-reload
sudo systemctl enable loki.service
sudo systemctl start loki.service
```

#### view service logs (journalctl)
- view logs for specific service
```shell
journalctl -u <service-name>  # all logs for service
journalctl -u <service-name> | head -50 # first 50 lines
journalctl -u <service-name> | tail -50 # last 50 lines
journalctl -u <service-name> -n 10  # last 10 lines
```

- view logs by time
```shell
journalctl --since=yesterday -u <service-name>
journalctl --since "1 hour ago" -u <service-name>
journalctl --since "2025-01-01 10:00:00" --until "2025-01-01 11:00:00" -u <service-name>
```

- filter logs
```shell
journalctl -u <service-name> | grep "error"
journalctl -u <service-name> | grep "started"
```

- follow logs in real-time
```shell
journalctl -u <service-name> -f
```

- view logs by priority level
```shell
journalctl -u <service-name> -p err  # error and above
journalctl -u <service-name> -p warning  # warning and above
journalctl -u <service-name> -p info  # info and above
```

- view logs with additional details
```shell
journalctl -u <service-name> -o verbose  # detailed output
journalctl -u <service-name> -o json  # JSON format
journalctl -u <service-name> -o json-pretty  # formatted JSON
journalctl -u <service-name> -x  # with explanatory help texts
```

- view logs by boot
```shell
journalctl -u <service-name> -b  # current boot
journalctl -u <service-name> -b -1  # previous boot
journalctl --list-boots  # list available boots
```

- view system-wide logs
```shell
journalctl  # all system logs
journalctl -k  # kernel messages only
journalctl -b  # current boot logs
journalctl --disk-usage  # journal disk usage
```

### memory
```bash
free -g # Memory usage in GB (total, used, free, available)
vmstat  # Virtual memory statistics (swap, I/O, CPU)
cat /proc/meminfo # Detailed memory info from kernel
```

### networking

#### assign static ip

- Check if it is configured
```bash
sudo ifdown eth0
```

- Edit like this (just the important lines) - `sudo gedit /etc/network/interfaces`

```bash
auto eth0
  iface eth0 inet static
  address <static IP address>
  netmask <netmask>
  gateway <default gateway>
  pre-up sleep 2
```

- activate the new IP
```bash
sudo ifup eth0
```

### port

#### list open ports

```bash
sudo netstat -tulpn | grep LISTEN
```

#### view port number and mapped service

```bash
cat /etc/services
grep -w '80/tcp' /etc/services
grep -w '443/tcp' /etc/services
grep -E -w '22/(tcp|udp)' /etc/services
grep -E -w '2020/(tcp|udp)' /etc/services
cat /etc/services | grep 8080
```

#### list the programs that utilize listening ports

```bash
# Display a list of ports in use
sudo lsof -nP -iTCP -sTCP:LISTEN

# Check a specific port number is in use
# If the port is free, the command shows no output
sudo lsof -nP -i :8080
sudo lsof -nP -iUDP:53 # to check if the UDP port 53 is open

sudo fuser 9092/tcp
sudo fuser -n tcp 9092

# display the listening ports/sockets by checking the State column
sudo netstat -tunpl
sudo netstat -ant | grep :2181
sudo netstat -peanut | grep ":5140"
```

#### kill process on specific port

```bash
fuser -k 8080/tcp
kill -9 $(lsof -t -i:8080)

kill -9 $(lsof -t -i:9092)
fuser -k 9092/tcp
```

#### connecting to open port

```bash
sudo yum install telnet
telnet localhost 8080
```

#### scanning port for open port & running services on it

```bash
sudo yum install nmap
sudo nmap -sT -O localhost
sudo nmap -sT -O 127.0.0.1  # list open TCP ports
sudo nmap -sU -O 192.168.2.254  # list open UDP ports
sudo nmap -sTU -O 192.168.2.24
```
#### viewing port info using iptables

```bash
# list out all of the active iptables rules by specification
sudo iptables -S
# output all of the active iptables rules in a table
sudo iptables -L
```

#### Opening a Port on Linux to Allow TCP Connections

```bash
# accept all traffic on your loopback interface
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allowing All Incoming fluent-bit port (2020)
sudo iptables -A INPUT -p tcp --dport 2020 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 2020 -m conntrack --ctstate ESTABLISHED -j ACCEPT
```

---

### permission

#### Changing the ownership of all subdirectories

```bash
sudo chown -R snikam:snikam ./Prod/
```
---

### shutdown/restart

- Restart now
  ```bash
  sudo shutdown -r now
  ```

- shutdown now (immediately)
  ```bash
  sudo ?
  ```

### file size

- Show human-readable file size:
  ```shell
  du -h yourfile.txt  # disk usage format (K, M, G, T)
  ls -lh yourfile.txt # file details with human-readable size
  stat -c%s yourfile.txt  # actual file size in bytes
  ```

- `du -b yourfile.txt` bytes
- `du -k yourfile.txt` kilobytes
- `du -m yourfile.txt` megabytes
- `du -BG yourfile.txt` gigabytes
- `du -BT yourfile.txt` terabytes

### file content statistics

  ```shell
  wc -l yourfile.txt  # Number of lines in file
  wc -w yourfile.txt  # Number of words in file
  wc -c yourfile.txt  # Number of characters/bytes in file
  ```

### longest line analysis

- length of the longest line (number only)
  ```shell
  awk '{ print length }' yourfile.txt | sort -nr | head -n 1
  ```

- longest line itself
  ```shell
  awk '{ if ( length > max ) { max = length; longest = $0 } } END { print longest }' yourfile.txt
  ```

- line number and length of longest line
  ```shell
  awk '{ if ( length > max ) { max = length; line = NR } } END { print "Line", line, "Length:", max }' yourfile.txt
  ```

### view specific lines

- Show single line from file - line 42
  ```shell
  sed -n '42p' yourfile.txt
  awk 'NR==42' yourfile.txt
  head -n 42 yourfile.txt | tail -n 1
  ```
- Show range of lines from file - line 42 tp 45
  ```shell
  sed -n '42,45p' yourfile.txt
  awk 'NR>=42 && NR<=45' yourfile.txt
  ```

### folder size analysis

- show all folders in current directory (human-readable)
  ```shell
  du -sh */ # unsorted
  du -sh */ | sort -hr  # sorted largest first
  ```
- show all folders in current directory (KB)
  ```shell
  du -s */  # unsorted
  du -s */ | sort -nr # sorted largest first
  ```

- show specific folder size in different units
  ```shell
  du -sh /path/to/folder     # human-readable (K, M, G, T)
  du -s /path/to/folder      # KB
  du -sm /path/to/folder     # MB
  du -sg /path/to/folder     # GB
  ```

- show files in current folder by size (descending)
  ```shell
  ls -lhS # human-readable
  ls -lS  # bytes
  du -ah . | sort -hr # all files/folders, human-readable
  ```

- show files in specific folder by size (descending)
  ```shell
  ls -lhS /path/to/folder/  # human-readable
  du -ah /path/to/folder/ | sort -hr  # all files/folders, human-readable
  ```

- show all files/folders sorted by size
  ```shell
  du -ah . | sort -hr # all items
  du -ah . | sort -hr | head -10 # top 10 largest
  ```

- disk usage summary
  ```shell
  df -h # filesystem usage
  du -sh .  # current directory total
  ```

### python

- `ModuleNotFoundError: no module named <X> Error`
  ```shell
  import sys
  import os

  # add dir to PYTHONPATH
  sys.path.append(os.getcwd())
  ```

  ```shell
  export PYTHONPATH=${PYTHONPATH}:${HOME}/abcPythonModule
  ```

### vs code
- vs code - column selection on Mac
  ```bash
  Shift + option + Command + Right/Left
  ```

### minikube

- view Minikube resource allocation when started
  ```bash
  minikube config view
  ```

- actual allocated resources
  ```bash
  minikube ssh -- 'grep -E "cpu|mem|disk" /proc/meminfo /proc/cpuinfo && df -h'
  ```

- inspect the VM directly (depending on the driver) - VirtualBox, HyperKit, VMware, etc.
  ```bash
  minikube ssh
  nproc # CPU
  free -h # Memory
  df -h / # Disk
  ```

- Kubernetes Resource View (optional)

  ```bash
  kubectl describe node

  # Capacity → Total allocatable CPU/memory
  # Allocatable → Resources available to pods
  # Allocated resources → What is used
  ```

- when starting minikube (for future reference)
  ```bash
  minikube start --cpus=4 --nodes=2 --memory=8192 --disk-size=32g
  minikube start --kubernetes-version=v1.32.0 --cpus=4 --memory=8192 --disk-size=30g --vm-driver=hyperkit
  ```

### aws

- Cloudwatch - Metrics - CPU Utilization
  ```shell
  aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization  \
  --period 3600 --statistics Maximum --dimensions Name=InstanceId,Value=i-0b100699f2321e6U1 \
  --region us-west-1 --profile 583168538690_AWS_Readonly --color on --start-time 2024-08-24T1:39:06 --end-time 2024-08-24T10:39:06
  ```
