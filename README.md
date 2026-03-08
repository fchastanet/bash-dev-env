# bash-dev-env

> **_NOTE:_** **Documentation is best viewed on [https://bash-dev-env.devlab.top](https://bash-dev-env.devlab.top/)**

<!-- markdownlint-capture -->

<!-- markdownlint-disable MD013 -->

[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/fchastanet/bash-dev-env/blob/master/LICENSE)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![CI/CD](https://github.com/fchastanet/bash-dev-env/actions/workflows/main.yml/badge.svg)](https://github.com/fchastanet/bash-dev-env/actions/workflows/main.yml?query=branch%3Amaster)
[![Project status](https://opensource.box.com/badges/active.svg)](https://opensource.box.com/badges "Project status")
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-dev-env.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-dev-env/?ref=repository-badge)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-dev-env.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-dev-env/?ref=repository-badge)
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/fchastanet/bash-dev-env.svg)](https://isitmaintained.com/project/fchastanet/bash-dev-env "Average time to resolve an issue")
[![Percentage of issues still open](https://isitmaintained.com/badge/open/fchastanet/bash-dev-env.svg)](https://isitmaintained.com/project/fchastanet/bash-dev-env "Percentage of issues still open")

<!-- markdownlint-restore -->

<!--TOC-->

- [1. Overview & Installation](#1-overview--installation)
- [2. Features & Supported Software](#2-features--supported-software)
- [3. Usage, Updates & Migration](#3-usage-updates--migration)
- [4. Acknowledgements](#4-acknowledgements)

<!--TOC-->

Bash Dev Env is a modular Bash-based system for installing, configuring, and maintaining essential developer tools and
environments on Ubuntu-based systems (WSL, VirtualBox, or native). It leverages the Bash Tools Framework and a custom
compiler to automate setup, upgrades, and configuration for a wide range of developer software, shells, and utilities.
The project is designed for repeatable, reliable, and customizable environment management, with built-in backup and
update mechanisms.

> **_TIP:_** Checkout related projects of this suite
>
> - [My documents](https://devlab.top/)
> - [Bash Tools Framework](https://bash-tools-framework.devlab.top/)
> - [Bash Tools](https://bash-tools.devlab.top/)
> - **[Bash Dev Env](https://bash-dev-env.devlab.top/)**
> - [Bash Compiler](https://bash-compiler.devlab.top/)

## 1. Overview & Installation

Bash Dev Env provides a unified, automated way to install, configure, and maintain a comprehensive set of developer
tools and environments on Ubuntu-based systems (including WSL, VirtualBox, and native installs). It uses modular Bash
scripts and the Bash Tools Framework to manage everything from shells (Bash, Zsh), editors, version control, cloud
tools, and more. Installation is straightforward—just follow the
[installation instructions](https://bash-dev-env.devlab.top/docs/install/).

## 2. Features & Supported Software

This project automates the installation, configuration, and updating of a wide range of developer tools and
environments, including:

- Shells: Bash (with aliases, completions, custom prompts), Zsh (with plugins, themes, Fzf integration)
- Version control: Git (with default config, aliases, hooks, pre-commit integration)
- Cloud & DevOps: AWS CLI, Awsume, Saml2Aws, Kubernetes tools (Helm, Kind, Minikube), OpenVPN
- Editors & IDEs: Vim, VS Code (with extension profiles), Jetbrains Toolbox
- Utilities: Fzf, fd, jq, curl, dos2unix, parallel, pv, unzip, wget, mysql-client, putty-tools
- Linters & Checkers: ShellCheck, Hadolint, Composer dependencies, Node dependencies (prettier, stylelint, etc.)
- Misc: PlantUML, Fortune, Xvfb, Anacron (for WSL), Docker (VirtualBox), Chrome, Firefox, LXDE, Terminator, font
  installers

The system is designed for repeatable, idempotent installs and supports backup of config files before changes. It also
provides mechanisms for periodic updates and easy migration between distributions.

## 3. Usage, Updates & Migration

- **Usage:** Run the main install script to set up or update your environment. The process is safe to repeat and will
  only update what’s needed.
- **Updates:** Anacron (on WSL) can be configured for scheduled updates. The install script is designed for regular
  re-execution.
- **Migration:** Tools and scripts are provided to help migrate your environment and data between distributions using
  rsync and shared mounts. Config backups are stored in the `backup` directory for safety.

## 4. Acknowledgements

This project draws inspiration from many sources. Special thanks to Bazyli Brzóska for his work on
[Bash Infinity](https://github.com/niieani/bash-oo-framework), which inspired much of the framework design (and some
code). His [blog](https://invent.life/project/bash-infinity-framework) is also highly recommended for anyone interested
in advanced Bash scripting.
