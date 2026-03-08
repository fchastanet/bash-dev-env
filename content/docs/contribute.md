---
title: How to Contribute
description: Guidelines for contributing to Bash Dev Env
weight: 30
categories: [documentation, development]
tags: [contribute, development, formatting, testing]
creationDate: 2026-03-01
lastUpdated: 2026-03-01
version: '1.0'
---

## 1. Formatting rules

before committing, be sure that pre-commit hooks are installed in the repository. It will ensure during commit to:

- format the files
- check for errors

## 2. How to prepare a new image

Here the solution to test this solution without impacting your current distribution or in order to generate a wsl
distribution

### 2.1. Prepare distribution

- Download ubuntu distribution archive and unpack it

```powershell
Remove-Item alias:curl
curl.exe -L -o ubuntu-2004.appx https://aka.ms/wslubuntu2004
Rename-Item ./ubuntu-2004.appx ./ubuntu-2004.zip
Expand-Archive ./ubuntu-2004.zip ./Ubuntu-2004
```

- If ubuntu distribution is not already installed on your computer, just run

```powershell
.\Ubuntu-2004\ubuntu.exe
```

- Else you have to import tar file

2 Optional steps: you can manually extract ./Ubuntu-2004/install.tar.gz to ./Ubuntu-2004/install.tar from 7Zip App.

(optional) first install 7zip for powershell using powershell as Administrator

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
Install-Module -Name 7Zip4PowerShell -Force
```

- (optional) Extract ./Ubuntu-2004/install.tar.gz to ./Ubuntu-2004/install.tar

```powershell
Expand-Archive ./Ubuntu-2004/install.tar.gz ./Ubuntu-2004/install.tar
Expand-7Zip -ArchiveFileName ./Ubuntu-2004/install.tar.gz -TargetPath ./Ubuntu-2004
```

- Import and run the distribution

```powershell
wsl --import UbuntuTest .\UbuntuTest ./Ubuntu-2004/install.tar --version 2
wsl -d UbuntuTest
```

- As root create wsl user and make wsl user as default login

```bash
useradd -m wslTest --create-home
chsh -s "$(which bash)" wslTest
# add user to group sudo
usermod -a -G sudo wslTest
passwd wslTest
```

- Finally launching distro will always launch terminal using root user

to use wsl as default, I suggest to create a terminal profile with the following command
`wsl.exe -d UbuntuTest -u wslTest`

### 2.2. install the project

Follow [Install instruction](https://bash-dev-env.devlab.top/docs/install/#3-wsl-install-script)

## 3. Prepare a tar image for sharing

Follow [Install instruction](https://bash-dev-env.devlab.top/docs/contribute/#2-how-to-prepare-a-new-image)

Ensure you are using wsl user login name instead of wslTest.

And install the project using this command

```sh
sudo ./install -p default --prepare-export
```

This will remove any sensitive files at the end of the process.

### 3.1. export the image

export the wsl image

```powershell
wsl --shutdown
wsl --export WslDevEnv WslDevEnv.tar
wsl.exe gzip /mnt/c/programs/WslDevEnv.tar
```

### 3.2. import the image

```powershell
mkdir C:\Programs\WslDevEnv
wsl.exe --import WslDevEnv C:\Programs\WslDevEnv C:\Programs\WslDevEnv.tar.gz
```

### 3.3. run again the installation

Follow [Install instruction](/docs/install/#3-wsl-install-script) it will build docker images and copy missing files on
the new computer
