---
title: "macOS Fresh Install Setup: Complete Developer Tools & Apps Guide"
description: "Comprehensive guide for setting up macOS after fresh installation. Install essential developer tools, configure Homebrew, Git, Python, Java, and must-have apps."
author: sagarnikam123
date: 2022-03-23 12:00:00 +0530
categories: [macos, developer-tools, setup-guide]
tags: [macos-setup, homebrew, developer-environment, fresh-install, productivity-tools]
image:
  path: assets/img/posts/20220323/macos-fresh-install-setup-guide.webp
  lqip: data:image/webp;base64,UklGRmoAAABXRUJQVlA4IF4AAADQBACdASogACAAPzmQvFYvKiYjsBgIAeAnCUAZdI0r+A2MVfYra1wninYMm2JYAAD++Kyorzv53bndByrFHH+EFfjPModAVwjFXHD0ln1IksSbKwcUS2J4LT+p0fAA
  alt: Complete macOS Fresh Install Setup Guide for Developers - Essential Tools and Applications
---

Setting up a **fresh macOS installation** can be overwhelming for developers and power users. This **complete macOS setup guide** covers essential **developer tools**, **Homebrew installation**, and **productivity apps** to get your Mac development-ready quickly.

Whether you're a seasoned developer or just starting your coding journey, this comprehensive guide provides step-by-step instructions for configuring the perfect development environment on your new Mac. From package managers to programming languages, we'll cover everything you need for a productive workflow.

## Table of Contents
- [System Information & Setup](#system-information--setup)
- [Package Managers](#package-managers)
- [Terminal Configuration](#terminal-configuration)
- [Development Tools](#development-tools)
- [Essential Applications](#essential-applications)
- [Programming Languages & Frameworks](#programming-languages--frameworks)
- [Git Configuration](#git-configuration)
- [DevOps Tools](#devops-tools)
- [Quick Setup Script](#quick-setup-script)
- [Common Issues & Solutions](#common-issues--solutions)
- [Keep Your System Updated](#keep-your-system-updated)
- [Frequently Asked Questions](#frequently-asked-questions)
- [Conclusion](#conclusion)

## System Information & Setup

### Check macOS Version
Verify your macOS version and system information:

```bash
sw_vers
```

```bash
system_profiler SPSoftwareDataType
```

```bash
uname -a
```

### Configure System Names
Customize your computer's identity for network and terminal display:

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

# Flush DNS Cache (Optional but Recommended)
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

### Configure Trackpad Settings
Enable right-click functionality on trackpad:

1. Open **System Settings** (or System Preferences on older macOS)
2. Click **Trackpad** in the sidebar
3. In "Point & Click" section, find **Secondary click**
4. Select **"Click or Tap with Two Fingers"**

## Package Managers

### Install Homebrew (Recommended)
[Homebrew](https://brew.sh/) is the most popular package manager for macOS, making it easy to install and manage developer tools.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Why Homebrew?** Simplifies software installation, handles dependencies automatically, and keeps packages updated.

> **Tip — Upgrade Bash:** macOS ships with Bash 3.2 (2007) due to licensing. Many modern scripts require Bash 4+. Install the latest version via Homebrew:
> ```bash
> brew install bash
> ```
> Then add Homebrew's `bin` to your PATH (see [Terminal Configuration](#terminal-configuration)) so `bash` resolves to the new version.
{: .prompt-tip }

**Visual Interface:** [Coldbrew](https://coldbrew.lil.run/) - A visual interface to quickly install your favorite macOS apps from Homebrew Cask.

### Install MacPorts (Alternative)
[MacPorts](https://www.macports.org/install.php) is an alternative package manager (optional if you're using Homebrew):

```bash
sudo port selfupdate # update port
port installed # list all installed ports
port outdated # list outdated ports
port upgrade vim # upgrade specific port
```

## Terminal Configuration

### Create .zshrc File
Set up your shell configuration file:

```bash
nano ~/.zshrc
```

### Enable Terminal Colors
Colorize terminal output for better readability:

```bash
echo 'export CLICOLOR=1' >> ~/.zshrc
source ~/.zshrc
```

### Shell Configuration
Change shell if needed (macOS uses Zsh by default):

```bash
# List available shells
cat /etc/shells

# Change to Bash (if needed)
chsh -s /bin/bash

# Change back to Zsh
chsh -s /bin/zsh
```

### Prioritise Homebrew Bash in PATH
macOS's built-in `/bin/bash` is version 3.2. After `brew install bash`, ensure the Homebrew version is found first:

```bash
# Add to ~/.zshrc (or ~/.bash_profile if Bash is your login shell)
export PATH="/opt/homebrew/bin:$PATH"   # Apple Silicon
# export PATH="/usr/local/bin:$PATH"    # Intel Macs
```

Reload and verify:
```bash
source ~/.zshrc
bash --version   # Should show 5.x
which bash        # Should show /opt/homebrew/bin/bash
```

> **Tip — Portable shebangs:** Use `#!/usr/bin/env bash` instead of `#!/bin/bash` in your shell scripts. `env` looks up `bash` in PATH, so the same script works on macOS (Homebrew bash) and Linux (`/usr/bin/bash`) without changes.
{: .prompt-tip }

### Install Oh My Zsh (Recommended)
Enhance your Zsh experience with themes and plugins:

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Popular themes to try (edit ~/.zshrc)
# ZSH_THEME="robbyrussell"  # Default
# ZSH_THEME="agnoster"      # Popular choice
# ZSH_THEME="powerlevel10k/powerlevel10k"  # Advanced

# Useful plugins (edit ~/.zshrc)
# plugins=(git brew docker kubectl python)
```

## Development Tools

### Install Xcode Command Line Tools
Essential for development and Git (install this BEFORE Homebrew):

```bash
xcode-select --install
# Or trigger installation with:
git --version
```

### Install UV (Python Package Manager)
[UV](https://docs.astral.sh/uv/#highlights) is a fast Python package manager for managing multiple Python versions (covered in detail in Python Development section):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.10 3.11 3.12 3.13
```

## Essential Applications

### Install via Homebrew (Recommended)

#### CLI Tools & Utilities
```bash
brew install wget tmux openssh ffmpeg webp imagemagick
```

#### Terminal Emulators
```bash
brew install --cask iterm2 termius
```

#### Browsers
```bash
brew install --cask google-chrome firefox brave-browser microsoft-edge opera
```

#### Code Editors & IDEs
```bash
brew install --cask visual-studio-code kiro cursor antigravity
brew install --cask jetbrains-toolbox eclipse-ide android-studio
```

#### AI Coding & Local LLMs
```bash
brew install --cask claude-code codex-app openclaw
brew install anomalyco/tap/opencode
brew install ollama
brew install --cask gpt4all lm-studio
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

#### Git Tools
```bash
brew install --cask github-desktop sourcetree git-credential-manager
```

#### Programming Languages & Runtimes
```bash
brew install openjdk@21 openjdk@25
brew install python@3.12 python@3.14
brew install node go r rustup
brew install --cask dotnet-sdk android-commandlinetools
```

#### Databases
```bash
brew install sqlite
brew install --cask dbeaver-community mysqlworkbench tableplus db-browser-for-sqlite
```

#### DevOps & Containers
```bash
brew install awscli helm gradle minikube ngrok fluent-bit
brew tap hashicorp/tap
brew install hashicorp/tap/terraform tfenv
brew install --cask docker orbstack rancher podman-desktop lens
```

#### API Clients
```bash
brew install --cask postman insomnia
```

#### Cloud CLIs
```bash
brew install --cask google-cloud-sdk
```

#### Virtualization
```bash
brew install --cask virtualbox
```

#### VPN & Networking
```bash
brew install wireshark
brew install --cask tunnelblick openvpn-connect
```

#### Data Science & 3D
```bash
brew install --cask rstudio blender
```

#### Design
```bash
brew install --cask figma gimp inkscape
```

#### Media
```bash
brew install --cask vlc handbrake obs audacity spotify
```

#### Productivity
```bash
brew install --cask alfred rectangle dropbox notion
```

#### Communication
```bash
brew install --cask slack zoom microsoft-teams discord whatsapp telegram signal
```

#### Documents & Downloads
```bash
brew install --cask mactex folx
```

### Manual Downloads (If Homebrew Not Available)

#### Browsers
- [Google Chrome](https://www.google.com/chrome/)
- [Firefox](https://www.mozilla.org/en-US/firefox/mac/)

#### Code Editors & IDEs
- [Visual Studio Code](https://code.visualstudio.com/download)
  - After installation, add `code` command to PATH:
    1. Open VS Code
    2. Press `Cmd+Shift+P` to open Command Palette
    3. Type "Shell Command: Install 'code' command in PATH"
    4. Select and run the command
    5. Restart terminal and test with `code --version`
- [Cursor](https://cursor.com/downloads)
- [JetBrains Toolbox](https://www.jetbrains.com/toolbox-app/) (PyCharm & IntelliJ)
- [Eclipse](https://www.eclipse.org/downloads/packages/)
- [Android Studio](https://developer.android.com/studio) (Android development)

#### Terminal Tools
- [iTerm2](https://iterm2.com/) (Advanced terminal replacement)
- Oh My Zsh: See [Terminal Configuration](#terminal-configuration) section for complete setup

#### Git GUI Clients
- [GitHub Desktop](https://desktop.github.com/) (Official GitHub client)

#### Communication Tools
- [Slack](https://slack.com/intl/en-in/downloads/mac)
- [Zoom](https://zoom.us/download)
- [Microsoft Teams](https://www.microsoft.com/en-in/microsoft-teams/download-app)
- [Discord](https://discord.com/download) (Developer communities)
- [WhatsApp](https://www.whatsapp.com/download) (Messaging)
- [Telegram](https://telegram.org/apps) (Messaging)
- [Skype](https://www.skype.com/en/get-skype/download-skype-for-desktop/)

#### Database Tools
- [MySQL Community](https://dev.mysql.com/downloads/mysql/)
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
- [DBeaver](https://dbeaver.io/download/)
- [TablePlus](https://tableplus.com/) (Modern database client)

#### Design & Collaboration
- [Figma](https://www.figma.com/downloads/) (Design collaboration)

#### Productivity Tools
- [Alfred](https://www.alfredapp.com/) (Spotlight replacement with workflows)
- [Rectangle](https://rectangleapp.com/) (Window management)
- [Maccy](https://maccy.app/) (Lightweight clipboard manager)
- [NearDrop](https://github.com/grishka/NearDrop) (Nearby Share for macOS)
- [AppCleaner](https://freemacsoft.net/appcleaner/) (Complete app uninstaller)
- [The Unarchiver](https://theunarchiver.com/) (Archive extraction tool)
- [TRex](https://trex.ameba.co/) (OCR text extraction from images/videos)
- [Apparency](https://apparency.macupdate.com/) (App security analysis tool)

#### DevOps & API Tools
- [Docker](https://www.docker.com/products/docker-desktop/)
- [Lens](https://k8slens.dev/)
- [Postman](https://www.postman.com/downloads/)
- [UTM](https://mac.getutm.app/) (Virtualization for Windows/Linux on Mac)

#### Development & Productivity
- [Node.js LTS](https://nodejs.org/en/download)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Zettlr](https://www.zettlr.com/) (Markdown editor)

#### Media & Content Creation
- [OBS Studio](https://obsproject.com/) (Video recording and live streaming)

#### Data Science & Analytics
- [R](https://cran.r-project.org/bin/macosx/)
- [RStudio](https://www.rstudio.com/products/rstudio/download/)

## Programming Languages & Frameworks

### Java Development
Choose from multiple OpenJDK distributions:

#### OpenJDK Options (LTS Recommended)

| Distribution                                                                      | Provider            |
| --------------------------------------------------------------------------------- | ------------------- |
| [Eclipse Adoptium](https://adoptium.net/)                                         | Eclipse Foundation  |
| [Amazon Corretto](https://aws.amazon.com/corretto/)                               | Amazon Web Services |
| [Azul Zulu](https://www.azul.com/downloads/?package=jdk#zulu)                     | Azul Systems        |
| [Microsoft Build of OpenJDK](https://www.microsoft.com/openjdk)                   | Microsoft           |
| [Red Hat OpenJDK](https://developers.redhat.com/products/openjdk/download)        | Red Hat             |
| [Oracle Java JDK](https://www.oracle.com/java/technologies/javase-downloads.html) | Oracle Corporation  |

#### Install Multiple Java Versions via Homebrew
```bash
# Install Java 21 (LTS) and Java 25
brew install openjdk@21 openjdk@25

# Verify installed JDKs
/usr/libexec/java_home -V
```

#### Configure Java Version Switching in ~/.zshrc
Add the following to your `~/.zshrc`:

```bash
# Java version paths
export JAVA_21_HOME=/opt/homebrew/Cellar/openjdk@21/21.0.10/libexec/openjdk.jdk/Contents/Home
export JAVA_25_HOME=/opt/homebrew/Cellar/openjdk/25.0.2/libexec/openjdk.jdk/Contents/Home

# Default to Java 21 (LTS)
export JAVA_HOME=$JAVA_21_HOME
export PATH=$JAVA_HOME/bin:$PATH

# Switch functions — run in terminal to switch Java version
# To switch to Java 21: java21
# To switch to Java 25: java25
java21() { export JAVA_HOME=$JAVA_21_HOME && export PATH=$JAVA_HOME/bin:$PATH && java -version; }
java25() { export JAVA_HOME=$JAVA_25_HOME && export PATH=$JAVA_HOME/bin:$PATH && java -version; }
```

Apply changes:
```bash
source ~/.zshrc
```

#### Switching Java Versions
```bash
java21   # switch to Java 21 (LTS) — default
java25   # switch to Java 25

java -version   # confirm active version
```

> **Note:** The path versions (e.g. `21.0.10`, `25.0.2`) may differ based on what Homebrew installs.
> Run `/usr/libexec/java_home -V` to get the exact paths on your machine.

### Python Development
Choose from multiple Python installation methods:

#### Option 1: UV Package Manager (Recommended for Developers)
[UV](https://docs.astral.sh/uv/) is a fast, modern Python package and project manager — handles multiple Python versions, virtual environments, and package installs in one tool:

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# Install multiple Python versions
uv python install 3.10 3.11 3.12 3.13

# List installed versions
uv python list

# Create virtual environment with specific version
uv venv --python 3.11
source .venv/bin/activate
```

#### Option 2: Pyenv (Version Management)
[Pyenv](https://github.com/pyenv/pyenv) allows you to easily switch between Python versions:

```bash
# Install pyenv via Homebrew
brew install pyenv

# Add to ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc

# Install Python versions
pyenv install 3.11.7
pyenv install 3.12.1

# Set global Python version
pyenv global 3.11.7

# Verify installation
python --version
```

#### Option 3: Homebrew Installation
```bash
# Install specific Python versions via Homebrew
brew install python@3.12 python@3.14

# Verify installation
python3 --version
pip3 --version

# Update pip
pip3 install --upgrade pip
```

#### Option 4: Official Python Installer (Simplest)
[Download Python](https://www.python.org/downloads/macos/) from the official website:

1. Visit [python.org/downloads](https://www.python.org/downloads/)
2. Download the latest stable version (3.12+ recommended)
3. Run the installer and follow the setup wizard
4. Configure PATH:

```bash
# Python path configuration (adjust version as needed)
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.12/bin

# Add to ~/.zshrc
echo 'export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.12/bin' >> ~/.zshrc
source ~/.zshrc

# Verify installation
python3 --version
pip3 --version
```

#### pipx (Global Tool Installation / pip3 Fallback)
[pipx](https://pipx.pypa.io/) installs Python tools in isolated environments — useful when `pip3` fails due to system restrictions or conflicts:

```bash
# Install pipx
brew install pipx
pipx ensurepath
source ~/.zshrc

# Use pipx instead of pip3 for global tools
pipx install package_name

# List installed tools
pipx list
```

#### Essential Python Packages
Install commonly used Python packages:

```bash
# Upgrade pip first
pip3 install --upgrade pip

# Essential packages
pip3 install virtualenv virtualenvwrapper
pip3 install jupyter notebook ipython
pip3 install requests pandas numpy matplotlib
pip3 install black flake8 pytest  # Development tools

# For web development
pip3 install django flask fastapi

# For data science
pip3 install scikit-learn tensorflow pytorch
```

#### Configure Virtual Environments
```bash
# Create project virtual environment
python3 -m venv myproject
source myproject/bin/activate

# Install packages in virtual environment
pip install -r requirements.txt

# Deactivate virtual environment
deactivate
```

### Go Development
[Download Go](https://go.dev/dl/) and configure:

```bash
# Set Go environment variables
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Add to ~/.zshrc
echo 'export GOROOT=/usr/local/go' >> ~/.zshrc
echo 'export GOPATH=$HOME/go' >> ~/.zshrc
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.zshrc
```

### Maven Build Tool
[Download Maven](https://maven.apache.org/download.cgi) and configure:

```bash
# Extract and move Maven
tar xzvf apache-maven-3.8.5-bin.tar.gz
sudo mv apache-maven-3.8.5 /opt/

# Configure Maven environment
export MAVEN_HOME=/opt/apache-maven-3.8.5
export PATH=$PATH:$MAVEN_HOME/bin

# Add to ~/.zshrc
echo 'export MAVEN_HOME=/opt/apache-maven-3.8.5' >> ~/.zshrc
echo 'export PATH=$PATH:$MAVEN_HOME/bin' >> ~/.zshrc
```

### Protocol Buffers
[Download Protocol Buffers](https://github.com/protocolbuffers/protobuf/releases) and configure:

```bash
unzip protoc-3.20.0-osx-x86_64.zip
sudo mv protoc-3.20.0-osx-x86_64 /opt/

# Configure protoc path
PROTOC_HOME=/opt/protoc-3.20.0-osx-x86_64
export PATH=$PATH:$PROTOC_HOME/bin

# Verify installation
protoc --version
```

### Jekyll & Ruby
For static site generation:

```bash
# Install Ruby version manager
brew install rbenv ruby-build
rbenv init  # Follow instructions to add to ~/.zshrc

# Install Ruby and Jekyll
rbenv install 3.4.1
rbenv global 3.4.1
ruby -v

# Install Jekyll
gem install jekyll

# For Jekyll themes (example)
cd your-jekyll-site
bundle install
bundle exec jekyll serve
```

## Git Configuration

### Basic Git Setup
Configure Git with your identity:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

After setting up your identity, choose one of the authentication methods below. GitHub no longer supports password authentication — you must use either SSH keys or a Personal Access Token.

### Authentication Methods

#### Option 1: SSH Keys (Recommended)
SSH keys provide secure, password-free Git operations. This is the preferred method for daily development.

**Generate and configure SSH key:**
```bash
# Generate SSH key (replace with your GitHub email)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

**Add SSH key to GitHub:**
1. Go to [GitHub SSH Settings](https://github.com/settings/ssh/new)
2. Click "New SSH key"
3. Paste the copied key and give it a title
4. Click "Add SSH key"

**Configure SSH for automatic keychain use:**
```bash
# Create/edit SSH config
nano ~/.ssh/config

# Add these lines:
Host github.com
  AddKeysToAgent yes
  IgnoreUnknown UseKeychain
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

**Test SSH connection:**
```bash
ssh -T git@github.com
```

**Clone repos using SSH:**
```bash
git clone git@github.com:username/repo.git
```

#### Option 2: HTTPS with Personal Access Token
If you prefer HTTPS, use a [Personal Access Token (PAT)](https://github.com/settings/personal-access-tokens) instead of a password.

**Set up credential caching:**
```bash
# Use macOS Keychain to store credentials
git config --global credential.helper osxkeychain
```

**Clone or push — enter your PAT when prompted for password:**
```bash
git clone https://github.com/username/repo.git
# Username: your-github-username
# Password: <paste your Personal Access Token>
```

The token will be cached in the Keychain automatically for future operations.

[Generate Personal Access Token here](https://github.com/settings/personal-access-tokens)

### Switch Existing Repo from HTTPS to SSH
If you cloned a repository using HTTPS and want to switch to SSH (avoids token prompts):

```bash
# Check current remote URL
git remote -v

# Switch from HTTPS to SSH
git remote set-url origin git@github.com:username/repo.git

# Verify the change
git remote -v
```

## DevOps Tools

### Containers & Kubernetes

#### Container Runtimes
- [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/) - Full Docker experience
- [Rancher Desktop](https://rancherdesktop.io/) - Docker alternative with Kubernetes
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) - Local Kubernetes cluster

#### Kubernetes Tools
```bash
# Install via Homebrew
brew install kubectl helm
brew install --cask lens  # Kubernetes IDE
```

### Monitoring & Observability
- [Grafana](https://grafana.com/grafana/download?edition=oss)
- [Prometheus](https://prometheus.io/download/)
- [Jenkins](https://www.jenkins.io/download/)

### AI Development
- [AWS MCP Servers](https://awslabs.github.io/mcp/)
  ```bash
  # Configure AWS MCP Server
  ~/.aws/amazonq/mcp.json
  ```

## Quick Setup Script
For experienced users, here's a comprehensive setup script:

```bash
#!/usr/bin/env bash
# macOS Fresh Install Quick Setup

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools
brew install git node python3 wget

# Install applications
brew install --cask google-chrome visual-studio-code docker
brew install --cask slack zoom notion

# Install development tools
brew install --cask jetbrains-toolbox postman dbeaver-community

# Configure Git (replace with your details)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper osxkeychain

echo "Setup complete! Please restart your terminal."
```

## Common Issues & Solutions

### Homebrew Installation Issues
- **Error: Command Line Tools not installed**
  ```bash
  xcode-select --install
  ```

### PATH Issues
- **Commands not found after installation**
  ```bash
  # Reload shell configuration
  source ~/.zshrc
  # Or restart terminal
  ```

### Permission Issues
- **Permission denied errors**
  ```bash
  # Use sudo for system-level installations
  sudo command_name

  # Fix Homebrew permissions
  sudo chown -R $(whoami) /usr/local/share/zsh
  ```

### Git Authentication
- **Authentication failed**
  - Use Personal Access Token instead of password
  - Ensure token has appropriate permissions
  - Clear keychain if needed: `git config --global --unset credential.helper`

## Keep Your System Updated

### Update Homebrew Packages
```bash
# Update Homebrew and packages
brew update && brew upgrade

# Clean up old versions
brew cleanup
```

### Update macOS
```bash
# Check for macOS updates
softwareupdate -l

# Install updates
softwareupdate -i -a
```

### Update Development Tools
```bash
# Update Node.js packages
npm update -g

# Update Python packages
pip3 list --outdated
pip3 install --upgrade package_name

# Update UV and Python versions
uv self update
uv python install 3.12  # Install latest versions
```

## Frequently Asked Questions

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What should I install first on a new Mac?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Start with Xcode Command Line Tools and Homebrew package manager. These are foundational tools that most other software depends on. Run 'git --version' to trigger Xcode tools installation, then install Homebrew using the official script."
      }
    },
    {
      "@type": "Question",
      "name": "How long does a complete macOS setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A complete developer setup typically takes 2-3 hours, depending on your internet speed and the number of applications you install. The basic setup (Homebrew, Git, Python, Node.js) can be completed in 30-45 minutes."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use Homebrew or download apps manually?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Homebrew is recommended for most installations as it handles dependencies automatically, keeps software updated, and allows easy uninstallation. Use manual downloads only for apps not available via Homebrew or when you need specific versions."
      }
    },
    {
      "@type": "Question",
      "name": "Which Python installation method is best?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For beginners, use the official Python installer from python.org. For advanced users managing multiple projects, pyenv or UV provide better version management. Homebrew Python is good for general development work."
      }
    },
    {
      "@type": "Question",
      "name": "How do I keep my development environment updated?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run 'brew update && brew upgrade' monthly to update Homebrew packages. Use 'softwareupdate -l' for macOS updates. For Python packages, use 'pip3 list --outdated' to check for updates. Set up a monthly maintenance routine."
      }
    },
    {
      "@type": "Question",
      "name": "What if I encounter permission errors during installation?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use 'sudo' for system-level installations, but avoid using 'sudo' with Homebrew. If you get Homebrew permission errors, run 'sudo chown -R $(whoami) /usr/local/share/zsh' to fix ownership issues."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this guide for Apple Silicon (M1/M2) Macs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, this guide works for both Intel and Apple Silicon Macs. Homebrew automatically detects your architecture and installs the appropriate versions. Some older software may require Rosetta 2 for compatibility."
      }
    },
    {
      "@type": "Question",
      "name": "How do I backup my development environment?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use 'brew bundle dump' to create a Brewfile listing all installed packages. Export your shell configuration files (.zshrc, .bashrc). Consider using dotfiles repositories on GitHub to version control your configuration."
      }
    }
  ]
}
</script>

### What should I install first on a new Mac?
Start with **Xcode Command Line Tools** and **Homebrew package manager**. These are foundational tools that most other software depends on. Run `git --version` to trigger Xcode tools installation, then install Homebrew using the official script.

### How long does a complete macOS setup take?
A complete **developer setup** typically takes 2-3 hours, depending on your internet speed and the number of applications you install. The basic setup (Homebrew, Git, Python, Node.js) can be completed in 30-45 minutes.

### Should I use Homebrew or download apps manually?
**Homebrew is recommended** for most installations as it handles dependencies automatically, keeps software updated, and allows easy uninstallation. Use manual downloads only for apps not available via Homebrew or when you need specific versions.

### Which Python installation method is best?
For beginners, use the **official Python installer** from python.org. For advanced users managing multiple projects, **pyenv** or **UV** provide better version management. Homebrew Python is good for general development work.

### How do I keep my development environment updated?
Run `brew update && brew upgrade` monthly to update Homebrew packages. Use `softwareupdate -l` for macOS updates. For Python packages, use `pip3 list --outdated` to check for updates. Set up a monthly maintenance routine.

### What if I encounter permission errors during installation?
Use `sudo` for system-level installations, but avoid using `sudo` with Homebrew. If you get Homebrew permission errors, run `sudo chown -R $(whoami) /usr/local/share/zsh` to fix ownership issues.

### Can I use this guide for Apple Silicon (M1/M2) Macs?
Yes, this guide works for both **Intel and Apple Silicon Macs**. Homebrew automatically detects your architecture and installs the appropriate versions. Some older software may require Rosetta 2 for compatibility.

### How do I backup my development environment?
Use `brew bundle dump` to create a Brewfile listing all installed packages. Export your shell configuration files (.zshrc, .bashrc). Consider using dotfiles repositories on GitHub to version control your configuration.

## Conclusion

This comprehensive **macOS setup guide** provides everything needed for a productive development environment on your fresh Mac installation. From essential **developer tools** like Homebrew and Git to programming languages like Python and Java, you now have a solid foundation for any development project.

Key takeaways from this guide:
- **Start with fundamentals**: Xcode Command Line Tools and Homebrew
- **Use package managers**: Homebrew simplifies installation and maintenance
- **Configure your environment**: Proper PATH setup and shell configuration
- **Keep everything updated**: Regular maintenance ensures security and performance

Bookmark this guide for future reference and share it with fellow developers setting up new Macs. A well-configured development environment is the foundation of productive coding.

**What's Next?**
- Explore macOS productivity tips and shortcuts to boost your workflow
- Learn about development workflow optimization for your specific tech stack
- Set up automated backup solutions to protect your development work

Happy coding on your newly configured Mac! 🚀
