# Bash-dev-env - Installation instructions

- [1. Important Notes to know before executing this script](#1-important-notes-to-know-before-executing-this-script)
- [2. Profiles](#2-profiles)
- [3. WSL install script](#3-wsl-install-script)
- [4. If needed, ability to install software one by one](#4-if-needed-ability-to-install-software-one-by-one)

## 1. Important Notes to know before executing this script

**Important note before beginning**

This software has only been tested under Ubuntu distribution.

Additionally to user and root home profile, this script will update some general
files of your distribution:

- update `/etc/hosts`
- add/update `/etc/wsl.conf`
- add `/etc/sudoers.d/${USERNAME}-upgrade-no-password`
- add `/etc/sudoers.d/bash-dev-env`
- update `/etc/inputrc`
- add file `${HOME}/.bash-dev-env` that contains every common environment
  variable for easier future update
- update `/etc/update-manager/release-upgrades` following UPGRADE_UBUNTU_VERSION
  .env variable chosen
- add `/etc/cron.weekly/upgrade`
- update `/etc/passwd` using chsh to change default shell following
  PREFERRED_SHELL .env variable chosen
- add files in `/etc/update-motd.d`
- update `/var/run/motd` via update-motd command and `/etc/update-motd.d/*`
  files
- add some apt sources list in `/etc/apt/sources.list.d/`

Only if LXDE configuration used (normally not used on wsl environment):

- `/etc/X11/default-display-manager`
- add `/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf`

On wsl environment, this script generates the following side effects on your
windows environment:

- updates `%USERPROFILE%\.wslconfig` updates memory limits and swap settings
  conforming to .env file
- install font mesloLGS_NF in
  `%USERPROFILE%\AppData\Local\Microsoft\Windows\Fonts`

These files are backed up in `<CURRENT_DIR>/backup` directory.

## 2. Profiles

Optionally you can create your own profile in order to add or remove some
dependencies.

Profile `profile.default.sh` is recommended for installing wsl environment.

Profile `profile.default.virtualBox.sh` actually does a full install of all the
dependencies. Note that some dependencies will only be installed on wsl though
(eg: WslProfile, DockerWslConfig, ...).

You can create your own profiles, files have to be named `profile.{name}.sh`

## 3. WSL install script

From wsl terminal

**eventually copy your ssh private/public key from windows**

```sh
mkdir -p ~/.ssh && cp "$(wslpath "$(wslvar USERPROFILE)")/.ssh/id_rsa"* ~/.ssh
```

**clone this repository**

```sh
mkdir -p ~/projects
git clone git@github.com:fchastanet/bash-dev-env.git ~/projects/bash-dev-env
```

**init configuration** note that your vscode installed in windows can be
launched from WSL using code command.

```sh
cd ~/projects/bash-dev-env
cp .env.template .env
code .env
```

**launch the installation for wsl and follow the instructions**

```sh
./install -p default
```

That's it, you're environment is installed and configured, you are ready to
develop !

## 4. If needed, ability to install software one by one

**You also have the ability to install and configure each software
independently** eg:

```sh
./install ShellZsh
```
