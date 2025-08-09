---
layout: post
title: "commands for linux troubleshooting"
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

### port

##### List open ports

```bash
sudo netstat -tulpn | grep LISTEN
```

##### view port number and mapped service

```bash
cat /etc/services
grep -w '80/tcp' /etc/services
grep -w '443/tcp' /etc/services
grep -E -w '22/(tcp|udp)' /etc/services
grep -E -w '2020/(tcp|udp)' /etc/services
cat /etc/services | grep 8080
```

##### list the programs that utilize listening ports

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

##### kill process on specific port

```bash
fuser -k 8080/tcp
kill -9 $(lsof -t -i:8080)

kill -9 $(lsof -t -i:9092)
fuser -k 9092/tcp
```

##### connecting to open port

```bash
sudo yum install telnet
telnet localhost 8080
```

##### scanning port for open port & running services on it

```bash
sudo yum install nmap
sudo nmap -sT -O localhost
sudo nmap -sT -O 127.0.0.1 #[ list open TCP ports ]##
sudo nmap -sU -O 192.168.2.254 #[ list open UDP ports ]##
sudo nmap -sTU -O 192.168.2.24
```
##### viewing port info using iptables

```bash
# list out all of the active iptables rules by specification
sudo iptables -S
# output all of the active iptables rules in a table
sudo iptables -L
```

##### Opening a Port on Linux to Allow TCP Connections

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

##### Changing the ownership of all sub-directories

```bash
sudo chown -R snikam:snikam ./Prod/
```
---

### resource utilization

- Top 10 CPU/memory users (sorted by %CPU/%MEM descending)
```bash
ps aux --sort -%cpu | head -10  # cpu
top -o %CPU | head -n 16  # cpu

ps aux --sort -%mem | head -10  # memory
top -o %MEM | head -n 16  # memory
```

- Interactive real-time process viewer
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

### memory
```bash
free -g # Memory usage in GB (total, used, free, available)
vmstat  # Virtual memory statistics (swap, I/O, CPU)
cat /proc/meminfo # Detailed memory info from kernel
```

### Shutdown/Restart

- Restart now
  ```bash
  sudo shutdown -r now
  ```

- shutdown now (immediately)
  ```bash
  sudo ?
  ```

### networking

##### Assign static ip

- Check if it is configured
```bash
sudo ifdown eth0
```

- Edit like this (just the important lines):
```bash
sudo gedit /etc/network/interfaces

auto eth0
  iface eth0 inet static
  address <static IP address>
  netmask <netmask>
  gateway <default gateway>
  pre-up sleep 2
```

- Activate the new IP
```bash
sudo ifup eth0
```

#### Python

- `ModuleNotFoundError: no module named <X> Error`
  ```python
  import sys
  import os

  # add dir to PYTHONPATH
  sys.path.append(os.getcwd())
  ```

  ```python
  export PYTHONPATH=${PYTHONPATH}:${HOME}/abcPythonModule
  ```

### other

#### vs code - column selction on Mac
  ```bash
  Shift + option + Command + Right/Left
  ```

### Minikube

#### View Minikube resource allocation when started

```bash
minikube config view
```

#### actual allocated resources

```bash
minikube ssh -- 'grep -E "cpu|mem|disk" /proc/meminfo /proc/cpuinfo && df -h'
```

#### inspect the VM directly (depending on the driver) - VirtualBox, HyperKit, VMware, etc.

```bash
minikube ssh

# CPU
nproc

# Memory
free -h

# Disk
df -h /
```

#### Kubernetes Resource View (optional)

```bash
kubectl describe node
```
- Capacity → Total allocatable CPU/memory
- Allocatable → Resources available to pods
- Allocated resources → What is used

#### When Starting Minikube (for future reference)

```bash
minikube start --cpus=4 --nodes=2 --memory=8192 --disk-size=32g
minikube start --kubernetes-version=v1.32.0 --cpus=4 --memory=8192 --disk-size=30g --vm-driver=hyperkit
```


### AWS

- Cloudwatch - Metrics - CPU Utilization
```shell
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization  \
--period 3600 --statistics Maximum --dimensions Name=InstanceId,Value=i-0b100699f2321e6U1 \
--region us-west-1 --profile 583168538690_AWS_Readonly --color on --start-time 2024-08-24T1:39:06 --end-time 2024-08-24T10:39:06
```
