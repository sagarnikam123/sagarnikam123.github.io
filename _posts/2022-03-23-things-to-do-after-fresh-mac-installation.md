---
title: "Things to do after fresh MacOS installation"
description: "installing min. required softwares"
date: 2022-03-23 12:00:00 +0530
categories: [mac, macos]
tags: [installation, softwares, guide]
---

After installing a fresh version of MacOS, you need to do a minimum installation of softwares for development or for different entertainment purpose. Here is a list for the same

- macOS version

  ```bash
  sw_vers
  ```

  ```bash
  system_profiler SPSoftwareDataType
  ```

  ```bash
  uname -a
  ```

- change Computer Name, System Hostname, Local Hostname

  ```bash
  # Computer Name (User-Friendly Name)
  sudo scutil --get ComputerName
  sudo scutil --set ComputerName "Your New Computer Name"
  
  # System Hostname (what the Terminal prompt often shows)
  sudo scutil --get HostName
  sudo scutil --set HostName "your-new-system-hostname"
  
  # Local Hostname (Bonjour Name)
  sudo scutil --get LocalHostName
  sudo scutil --set LocalHostName "your-new-local-hostname"
  
  # Flush DNS Cache (Optional but Recommended)-ensure network services recognize the change
  sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
  ```
- install **[Homebrew](https://brew.sh/)** - a package manager for mac

  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- install **[MacPorts](https://www.macports.org/install.php)** (optional, as alternative to Homebrew)

  ```bash
  sudo port selfupdate # to update port
  port installed # all installed ports
  port outdated # list of outdated ports
  port upgrade vim # upgrade installed port
  ```

- create **.zshrc** file in home directory

  ```bash
  nano ~/.zshrc
  ```

- colorize terminal output (folders & files with diff. colors) (optional)

  ```bash
  nano ~/.zshrc
  export CLICOLOR=1
  ```

- change shell from **zshrc** to **bash** (Only if you want to change shell, else leave it.)

  ```bash
  # list of included shells
  cat /etc/shells

  # change default shell to Bash
  chsh -s /bin/bash

  # change default shell back to Zsh
  chsh -s /bin/zsh
  ```

- install **xcode command-line tools** (it prompts to install)

  ```bash
  git --version
  ```

- install **[uv](https://docs.astral.sh/uv/#highlights)** (python package manager) - to manage different python version

  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source $HOME/.local/bin/env
  uv python install 3.10 3.11 3.12 3.13
  ```
  
- **download from sites**

  - [Google Chrome](https://www.google.com/chrome/)
  - [Firefox](https://www.mozilla.org/en-US/firefox/mac/)
  - [Visual studio code](https://code.visualstudio.com/download)
    - After installation, add `code` command to PATH:
      1. Open VS Code
      2. Press `Cmd+Shift+P` to open Command Palette
      3. Type "Shell Command: Install 'code' command in PATH"
      4. Select and run the command
      5. Restart terminal and test with `code --version`
  - [Cursor](https://cursor.com/downloads)
  - [Jetbrains Toolbox](https://www.jetbrains.com/toolbox-app/) (PyCharm & IntelliJ)
  - [Eclipse](https://www.eclipse.org/downloads/packages/)
  - [Slack](https://slack.com/intl/en-in/downloads/mac)
  - [Zoom client](https://zoom.us/download)
  - [Skype](https://www.skype.com/en/get-skype/download-skype-for-desktop/)
  - [Dropbox](https://www.dropbox.com/downloading)
  - [RStudio](https://www.rstudio.com/products/rstudio/download/)
  - [MySQL community](https://dev.mysql.com/downloads/mysql/)
  - [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
  - [DBeaver](https://dbeaver.io/download/)
  - [MySQL JDBC connector](https://dev.mysql.com/downloads/connector/j/)
  - [R](https://cran.r-project.org/bin/macosx/)
  - [RStudio](https://www.rstudio.com/products/rstudio/download/)
  - [Zettlr](https://www.zettlr.com/) (Markdown editor)
  - [cmake](https://cmake.org/download/)
  - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - [Notion Desktop](https://www.notion.com/desktop)
  - [Lens for Mac](https://k8slens.dev/download) - IDE for Kubernetes
  - [Microsoft Teams](https://www.microsoft.com/en-in/microsoft-teams/download-app)
  - [Node.js LTS](https://nodejs.org/en/download)

- **install & configure (export path variables to .zshrc/.bashrc)**

  - [OpenJDK (LTS)](https://openjdk.org/)
    - [Eclipse Adoptium](https://adoptium.net/)
    - [Amazon Corretto](https://aws.amazon.com/corretto/)
    - [Azul-Java Zulu](https://www.azul.com/downloads/?package=jdk#zulu)
    - [Microsoft Build of OpenJDK](https://www.microsoft.com/openjdk)
    - [Red Hat build of OpenJDK](https://developers.redhat.com/products/openjdk/download)

  - [Oracle Java JDK (LTS)](https://www.oracle.com/java/technologies/javase-downloads.html)

    ```bash
    # JAVA_HOME
    export JAVA_HOME=$(/usr/libexec/java_home)
    export PATH=$PATH:$JAVA_HOME/bin

    # export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.14.jdk/Contents/Home
    ```

  - [Python](https://www.python.org/)
    ```bash
    # Python - depending on your version & location
    export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin
    # export PATH=$PATH:/$HOME/Library/Python/3.9/bin
    ```

  - [Go](https://go.dev/dl/)

    ```bash
    # GOROOT & GOPATH
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    ```

  - [Maven](https://maven.apache.org/download.cgi)

    ```bash
    # check JAVA_HOME
    tar xzvf apache-maven-3.8.5-bin.tar.gz
    sudo mv apache-maven-3.8.5 /opt/
    # path
    export MAVEN_HOME=/opt/apache-maven-3.8.5
    export PATH=$PATH:$MAVEN_HOME/bin
    ```

  - [Protocol Buffers](https://github.com/protocolbuffers/protobuf/releases)

    ```bash
    unzip protoc-3.20.0-osx-x86_64.zip
    sudo mv protoc-3.20.0-osx-x86_64 /opt/
    # path
    PROTOC_HOME=/opt/protoc-3.20.0-osx-x86_64
    export PATH=$PATH:$PROTOC_HOME
    # check
    protoc --version
    ```

- **configure git**

  - [create a personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) <- click here to create

    ```bash
    git config --global user.email <you@example.com>
    git config --global user.name <your user name>
    ```

  - configure [git credential manager core](https://github.com/microsoft/Git-Credential-Manager-Core/) for PAT (Personel Access Token)
  - [generate PAT](https://github.com/settings/personal-access-tokens) here
    ```bash
    # tell Git you want to store credentials in the osxkeychain
    git config --global credential.helper osxkeychain

    # add your access token to the osxkeychain- by using pull/push
    # when prompted for password, instead enter access token(it get cached in the osxkeychain automatically)
    git clone https://github.com/username/repo.git
    ```

- **install & configure open-ssh**

  ```bash
  sudo port install openssh
  sudo port load openssh
  ```

- **install/uninstall with brew**

  ```bash
  brew install wget
  brew install openjdk
  brew install openssh
  brew install db-browser-for-sqlite
  brew install --cask dbeaver-community
  brew install minikube hyperkit

  # lists apps installed by brew
  brew list

  # uninstall
  brew uninstall wget
  ```

- **DevOps tools**
  - **containers & kubernetes**
    - install [Docker Desktop on Mac](https://docs.docker.com/desktop/install/mac-install/)
    - install [Rancher Desktop](https://rancherdesktop.io/)  (docker without _Docker Desktop_)
    - install [Minikube](https://minikube.sigs.k8s.io/docs/start/)
      - *container runtime* of your choice (containerd or dockerd) - free
      - kubernetes, Traefik
      - docker(cli), docker-compose, docker-buildx
      - kubectl, helm, nerdctl, rdctl
  - [Jenkins](https://www.jenkins.io/download/)
  - [Grafana](https://grafana.com/grafana/download?edition=oss)
  - [Prometheus](https://prometheus.io/download/)

- **AI**
  - [AWS MCP servers](https://awslabs.github.io/mcp/)
    ```bash
    # Core MCP Server
    ~/.aws/amazonq/mcp.json
    # https://awslabs.github.io/mcp/servers/core-mcp-server/
    ```

- **Jekyll**
  - install ruby version manager
    ```bash
    brew install rbenv ruby-build
    rbenv init  # add it to .zprofile
    cat ~/.zprofile
    rbenv install 3.4.1
    rbenv global 3.4.1
    ruby -v
    ```
  - install jekyll
    ```bash
    gem install jekyll
    cd jekyll-theme-chirpy
    bundle install
    bundle exec jekyll serve
    ```
