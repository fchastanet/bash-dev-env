# Dev-env - TODO

- [1. Needed refactoring (WIP)](#1-needed-refactoring-wip)
  - [1.1. Refactor lib/loadAndCheckConfig.sh - loadAndCheckConfig](#11-refactor-libloadandcheckconfigsh---loadandcheckconfig)
  - [1.2. Refactor lib/loadAndCheckConfig.sh - loadProfile](#12-refactor-libloadandcheckconfigsh---loadprofile)
  - [1.3. Refactor installFile / installDir](#13-refactor-installfile--installdir)
  - [1.4. .env checksum](#14-env-checksum)
- [2. Missing features](#2-missing-features)
  - [2.1. add windows terminal configuration](#21-add-windows-terminal-configuration)
  - [2.5. Wslg](#25-wslg)
  - [2.6. configure some cleaning of wsl via scheduled tasks](#26-configure-some-cleaning-of-wsl-via-scheduled-tasks)
  - [2.7. windows files side effects](#27-windows-files-side-effects)
  - [2.8. vscode extensions](#28-vscode-extensions)
  - [2.9. PHPstorm](#29-phpstorm)
  - [2.13. Skills install](#213-skills-install)
  - [2.14. add .env default profile for upgrade](#214-add-env-default-profile-for-upgrade)
  - [2.15. install pre-commit](#215-install-pre-commit)
  - [2.16. remove Awsume](#216-remove-awsume)
  - [2.17. pre-commit config](#217-pre-commit-config)
  - [2.18. install python venv in pycharm](#218-install-python-venv-in-pycharm)
  - [2.19. Git config use phpstorm as diff and merge tool](#219-git-config-use-phpstorm-as-diff-and-merge-tool)
  - [2.20. install devcert](#220-install-devcert)
  - [2.26. install an undelete software](#226-install-an-undelete-software)
  - [2.28. add automatic ecr](#228-add-automatic-ecr)
  - [2.29. Functions::retryParameterized](#229-functionsretryparameterized)
  - [2.30. replace curl by aria2](#230-replace-curl-by-aria2)
  - [replace docker for windows](#replace-docker-for-windows)

## 1. Needed refactoring (WIP)

This section describes features that could be improved.

### 1.1. Refactor lib/loadAndCheckConfig.sh - loadAndCheckConfig

This function has too much responsibilities and has to be cut in more
specialized functions. Check that each `.env` variable validity is checked. What
happens if `USER_NAME` does not exists. Create /etc/sudoers.d/bash-dev-env
should be moved to Anacron configuration. Some complex computation like
`IPCONFIG`(not sure it is still useful by the way) should be computed in a
dedicated function (lazy load).

### 1.2. Refactor lib/loadAndCheckConfig.sh - loadProfile

this function has too much responsibilities. cut it in three:

- checkMissingScripts
- loadProfile that loads the profile file
- computeDependencies that computes configurations to load in order with
  dependencies

### 1.3. Refactor installFile / installDir

mode ask confirmation (new option) ability to override detect updated files upon
subsequent configuration algorithm

```text
detect updated files upon subsequent configuration
    compare md5 of the target file if exists with
        - md5 of the source config file
        - stored md5
            - if different it means the file has been customized
            - if same, we can override the file without confirmation
    ask confirmation if different
    store the md5 of the installed file
```

### 1.4. .env checksum

store current checksum in .checksums

```text
a4b4397dba583c497ff19d01463448a9  .env
```

in loadCheckAndConfig function

```text
if .checksums file exists
  if current md5sum .env.template != md5sum .env.template stored then
    check .env
    confirm .env has been updated
    store new checksum .checksums
  fi
else
  store new checksum .checksums
fi
```

first step, store md5sum of each file installed using installFile/installDir

## 2. Missing features

### 2.1. add windows terminal configuration

scripts/WslProfile/configure <https://github.com/microsoft/terminal/issues/237>
Add the following to your Windows Terminal config under the "keybindings"
section: { "command": "scrollUpPage", "keys": "shift+pageup" }, { "command":
"scrollDownPage", "keys": "shift+pagedown" },

### 2.5. Wslg

Needs Windows 11 <https://github.com/microsoft/wslg>

### 2.6. configure some cleaning of wsl via scheduled tasks

<https://ryanharrison.co.uk/2021/05/13/wsl2-better-managing-system-resources.html#:~:text=Setting%20a%20WSL2%20Memory%20Limit,wslconfig%20).>
or maybe special conf for cleaning ?

### 2.7. windows files side effects

when windows files are updated special conf OVERRIDE_WINDOWS_FILES=1 ?

### 2.8. vscode extensions

install vscode plugins from vscode settings clean plugins list from
VsCodeExtensionProfiles find a way to make VsCode extensions easily disabled
(extensions profiles)
[not working on wsl yet](https://github.com/mrsauravsahu/vscode-manager)
[not working](https://github.com/baincd/vscode-extension-profiles)
[seems actively developed](https://github.com/evald24/vscode-extensions-profiles)
=> but
[issue on wsl](https://github.com/evald24/vscode-extensions-profiles/issues/19)

### 2.9. PHPstorm

is there a way to install automatically plugins ?
<https://stackoverflow.com/a/24287585>

### 2.13. Skills install

postman automatically import collection + env

### 2.14. add .env default profile for upgrade

instead that upgrade uses last profile used, use .env to configure the profile
to use + remove -p option or simply save each packages installed in a file

### 2.15. install pre-commit

install pre-commit hook if .pre-commit-config.yaml

### 2.16. remove Awsume

- remove awsume auto complete in .bashrc

### 2.17. pre-commit config

add megalinter to pre-commit

### 2.18. install python venv in pycharm

<https://www.jetbrains.com/help/pycharm/using-wsl-as-a-remote-interpreter.html#enable-debugging>

### 2.19. Git config use phpstorm as diff and merge tool

### 2.20. install devcert

<https://github.com/davewasmer/devcert>

### 2.26. install an undelete software

### 2.28. add automatic ecr

<https://github.com/awslabs/amazon-ecr-credential-helper>

### 2.29. Functions::retryParameterized

message not displayed retry 3 actually retry 4

### 2.30. replace curl by aria2

### replace docker for windows

<https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html>
<https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9>

Podman ?
<https://dev.to/bowmanjd/using-podman-on-windows-subsystem-for-linux-wsl-58ji>
