---
date: 2021-08-20
layout: post
title: "Things to do after fresh Ubuntu installation"
description: "installing min. required softwares"
category: [ubuntu, installation]
tags: [ubuntu, installation, softwares, guide]
---

After installing a fresh LTS version of Ubuntu, you need to do a minimum installation of softwares for development or for entertainment purpose. Here is a list for the same

- **remove snapstore & make default ubuntu software store**

  ```bash
  # check for installed snap packages
  snap list
  # remove snap packages
  sudo snap remove --purge <package-name>
  # remove snap cache
  sudo rm -rf /var/cache/snapd/
  # uninstall snap and snap GUI tool
  sudo apt autoremove --purge snapd gnome-software-plugin-snap
  # clear snap preferences
  sudo rm -fr ~/snap
  ```

- **install media codecs, vlc, FFmpeg**

  ```bash
  sudo apt install ubuntu-restricted-extras
  sudo apt-get update
  sudo apt-get install vlc
  sudo apt-get install ffmpeg
  ```

- **remove mail client**

  ```bash
  sudo apt-get purge thunderbird*
  ```

- **install package updates**

  ```bash
  sudo apt-get update && sudo apt-get dist-upgrade
  ```

- **download from sites**

  - [Google Chrome](https://www.google.com/chrome/)
  - [Visual studio code](https://code.visualstudio.com/download)
  - [Dropbox](https://www.dropbox.com/install-linux)
  - [Oracle Java JDK (LTS)](https://www.oracle.com/java/technologies/javase-downloads.html)
  - [Eclipse](https://www.eclipse.org/downloads/packages/)
  - [Skype](https://www.skype.com/en/get-skype/download-skype-for-desktop/)
  - [Zoom client](https://zoom.us/download)
  - [Jetbrains Toolbox](https://www.jetbrains.com/toolbox-app/) (PyCharm & IntelliJ)
  - [RStudio](https://www.rstudio.com/products/rstudio/download/)
  - [MySQL JDBC connector](https://dev.mysql.com/downloads/connector/j/)

- **install & configure (export path variables to .bashrc)**

  - Java

    ```bash
    sudo mkdir /usr/lib/jvm/
    sudo tar -xvzf jdk-11.0.12_linux-x64_bin.tar.gz -C /usr/lib/jvm/
    # path
    export JAVA_HOME=/usr/lib/jvm/jdk-11.0.12
    export PATH=$PATH:$JAVA_HOME/bin
    ```

  - Gradle

    ```bash
    sudo mkdir /opt/gradle
    sudo unzip -d /opt/gradle gradle-7.2-bin.zip
    # path
    export PATH=$PATH:/opt/gradle/gradle-7.2/bin
    ```

  - Go

    ```bash
    sudo tar -xvzf go1.16.4.linux-amd64.tar.gz -C /usr/local/
    # path
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    ```

  - Maven

    ```bash
    sudo tar -xvzf apache-maven-3.8.2-bin.tar.gz -C /opt/
    # path
    export M2_HOME=/opt/apache-maven-3.8.2
    export PATH=$PATH:$M2_HOME/bin
    ```

- **install additional archieve utilities**

  ```bash
  sudo apt install rar unrar p7zip-full p7zip-rar
  ```

- **install & configure open-ssh**

  ```bash
  sudo apt-get install openssh-client
  sudo apt-get install openssh-server
  # generate ssh keys
  ssh-keygen
  # enable SSH access to local machine
  cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
  ```

- **R install**

  ```bash
  sudo apt install r-base-core libcurl4-openssl-dev libssl-dev libxml2-dev
  sudo apt install libmariadbclient-dev # for RMySQL
  R
  install.packages("devtools")
  install.packages("rmarkdown")
  install.packages("RMySQL")
  ```

- **UNIX `ulimit` Settings**

  - "ulimits" prevent single users from using too many system resources such as threads, files, and network connections on a per-process and per-user basis

  - ```bash
    # check
    ulimit -a
    # check limit for max number of open file descriptors
    ulimit -Sn	# soft limit
    ulimit -Hn  # hard limi
    # increase Limit for Current Session
    ulimit -n 200000
    # permanently edit value for (nofile - max number of open file descriptors)
    sudo gedit /etc/security/limits.conf
    #* 	 soft     nofile         1024
    #* 	 hard     nofile         200000
    ```

- **configure git**

    - [create a personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)

    ```bash
    git config --global user.email <you@example.com>
    git config --global user.name <Your Name>
    ```

    - configure [git credential manager core](https://github.com/microsoft/Git-Credential-Manager-Core/) for PAT (Personel Access Token)

    ```bash
    git config --global credential.credentialStore plaintext
    git config --global credential.plaintextStorePath </pathToPAT/pat/credentials>
    # install
    sudo dpkg -i <path-to-package.deb>
    git-credential-manager-core configure
    ```

- check which Init system using

    ```bash
    ps --no-headers -o comm 1
    # systemd (which uses the systemctl command)
    # System V init (which uses the service command)
    ```

- **install gnome tweaks**

  ```bash
  sudo apt install gnome-tweaks
  ```

- **install Markdown (Typora)**

  ```bash
  wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
  # add Typora's repository
  sudo add-apt-repository 'deb https://typora.io/linux ./'
  sudo apt-get update
  # install typora
  sudo apt-get install typora
  ```

- **other things to do**

    - enable Night Light mode (Settings - > Display -> Night Light tab)
    - select default apps (Settings -> Default Applications)
    - connect to online account (Ubuntu one, Settings -> Online Accounts)
    - add your favorite apps to the dock
