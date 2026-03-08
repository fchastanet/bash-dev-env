---
title: Bash Dev Env
linkTitle: Bash Dev Env
description: >
  Comprehensive Bash-based development environment installation and configuration system for Ubuntu-based distributions
type: docs
weight: 10
creationDate: 2026-03-01
lastUpdated: 2026-03-01
---

**Bash Dev Env** is a comprehensive Bash-based development environment installation and configuration system for
Ubuntu-based distributions (WSL, VirtualBox, or native).

## 1. Features

- **Automated Installation**: Install and configure main softwares used by developers
- **Profile-based Configuration**: Use pre-defined or custom profiles for different setups
- **Dependency Management**: Automatic dependency resolution and installation order
- **Periodic Updates**: Automated maintenance and updates via cron
- **Configuration Backup**: Automatic backup of system configuration files
- **WSL Integration**: Special support for Windows Subsystem for Linux

## 2. Quick Start

```bash
# Clone the repository
git clone git@github.com:fchastanet/bash-dev-env.git ~/projects/bash-dev-env

# Configure
cd ~/projects/bash-dev-env
cp .env.template .env
# Edit .env with your preferences

# Install
./install -p default
```

## 3. Related Projects

- [My documents](https://devlab.top/)
- [Bash Tools Framework](https://bash-tools-framework.devlab.top/)
- [Bash Tools](https://bash-tools.devlab.top/)
- [Bash Compiler](https://bash-compiler.devlab.top/)
