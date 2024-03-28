# bash-dev-env

<!-- remove -->

> **_NOTE:_** Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/bash-dev-env/)

<!-- endRemove -->

> **_TIP:_** Checkout related projects of this suite
>
> - [Bash Tools Framework](https://fchastanet.github.io/bash-tools-framework/)
> - [Bash Tools](https://fchastanet.github.io/bash-tools/)
> - **[Bash Dev Env](https://fchastanet.github.io/bash-dev-env/)**

<!-- prettier-ignore-start -->
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
[![GitHubLicense](
  https://img.shields.io/github/license/Naereen/StrapDown.js.svg
)](
  https://github.com/fchastanet/bash-dev-env/blob/master/LICENSE
)
[![CI/CD](
  https://github.com/fchastanet/bash-dev-env/actions/workflows/lint-test.yml/badge.svg
)](
  https://github.com/fchastanet/bash-dev-env/actions?query=workflow%3A%22Lint+and+test%22+branch%3Amaster
)
[![ProjectStatus](
  http://opensource.box.com/badges/active.svg
)](
  http://opensource.box.com/badges
  'Project Status'
)
[![DeepSource](
  https://deepsource.io/gh/fchastanet/bash-dev-env.svg/?label=active+issues&show_trend=true
)](
  https://deepsource.io/gh/fchastanet/bash-dev-env/?ref=repository-badge
)
[![DeepSource](
  https://deepsource.io/gh/fchastanet/bash-dev-env.svg/?label=resolved+issues&show_trend=true
)](
  https://deepsource.io/gh/fchastanet/bash-dev-env/?ref=repository-badge
)
[![AverageTimeToResolveAnIssue](
  http://isitmaintained.com/badge/resolution/fchastanet/bash-dev-env.svg
)](
  http://isitmaintained.com/project/fchastanet/bash-dev-env
  'Average time to resolve an issue'
)
[![PercentageOfIssuesStillOpen](
  http://isitmaintained.com/badge/open/fchastanet/bash-dev-env.svg
)](
  http://isitmaintained.com/project/fchastanet/bash-dev-env
  'Percentage of issues still open'
)
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

- [1. Excerpt](#1-excerpt)
- [2. Install \& Configuration](#2-install--configuration)
  - [2.1. Windows (Recommended)](#21-windows-recommended)
  - [2.2. Virtualbox](#22-virtualbox)
  - [2.3. Dev-env install](#23-dev-env-install)
- [3. Features presentation](#3-features-presentation)
  - [3.1. Periodical updates](#31-periodical-updates)
  - [3.2. config files backup](#32-config-files-backup)
- [4. Additional documentation](#4-additional-documentation)
- [5. github page](#5-github-page)
- [6. Development](#6-development)
- [7. Acknowledgements](#7-acknowledgements)

## 1. Excerpt

Allows to install, upgrade, configure and automatically maintain main softwares
used by developers. You can use this script under wsl or virtualbox ubuntu based
images.

Follow these indications to [Install & Configure](#2-install--configuration).
You can see a non exhaustive list of features provided by this tool in this
chapter [Features presentation](#3-features-presentation).

This is a collection of several bash installation scripts using
[bash tools framework](https://fchastanet.github.io/bash-tools-framework/)
allowing to easily install several softwares on ubuntu based image (under wsl or
virtual box or native installation).

## 2. Install & Configuration

### 2.1. Windows (Recommended)

TODO

### 2.2. Virtualbox

TODO

### 2.3. Dev-env install

please follow [Dev-env Installation instructions](docs/Install.md)

## 3. Features presentation

This project will install, update and configure these non exhaustive
dependencies:

- [Awsume](https://awsu.me/) (alternative to Saml2Aws)
- [AwsCli](https://aws.amazon.com/cli/?nc1=h_ls)
  - Awscli with default ck configuration
- ShellBash with
  - pre configured aliases
  - default variables PATH, ...
  - completions
  - customized git prompt
  - fasd jump easily to directories/files
  - Kubectx + Kubeps1
- [BashTools](https://github.com/fchastanet/bash-tools) provides some useful
  bash tools:
  - cli -- tool to easily connect to your containers
  - dbImport -- tool to import database from aws or Mizar
  - dbQueryAllDatabases -- tool to execute a query on multiple databases
  - ...
- CodeCheckers
  - [shellcheck](https://www.shellcheck.net)
- Composer
  - php
  - php-curl
  - php-mbstring
  - php-xml
- ComposerDependencies
  - squizlabs/php_codesniffer
  - phpmd/phpmd
  - friendsofphp/php-cs-fixer
- ShellZsh: instead of using ShellBash, you can use Zsh shell with
  - pre configured aliases
  - default variables PATH, ...
  - completions
  - very powerful and efficient prompt powerlevel10k
  - oh-my-zsh plugins/themes manager
  - Fzf (search history)
- Fortune (display help message at each bash/zsh login based on the installed
  softwares)
- [Fzf](https://github.com/junegunn/fzf) - fzf is a general-purpose command-line
  fuzzy finder. It's an interactive Unix filter for command-line that can be
  used with any list; files, command history, processes, hostNames, bookmarks,
  git commits, etc. Fzf configuration comes with
  [fd](https://github.com/sharkdp/fd), fd is a program to find entries in your
  filesystem. It is a simple, fast and user-friendly alternative to find. While
  it does not aim to support all of find's powerful functionality, it provides
  sensible (opinionated) defaults for a majority of use cases.
- Git (default ~/.gitconfig with main branch, email, name, default aliases, ...)
- GitHook
  - configure [pre-commit](https://pre-commit.com/) to provide default commit
    linter
  - hook for default commit message prefix based on branch name
- [Hadolint](https://github.com/hadolint/hadolint) (docker linter)
- Java dependency needed by Plantuml
- Kubernetes
  - [Helm](https://helm.sh/)
  - [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
  - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- MandatorySoftwares
  - build-essential
  - curl
  - dos2unix
  - jq
  - mysql-client
  - parallel
  - putty-tools
  - pv
  - unzip
  - vim
  - vim-gui-common
  - vim-runtime
  - wget
- MLocate (command locate + indexing configuration) -
  - Mlocate deprecated in favor of fd (installed with Fzf dependency of
    ShellBash and ShellZsh) contrary to Mlocate, fd does not need to maintain a
    db of files
- Node (install n + nodejs)
- NodeDependencies
  - hjson
  - npm-check-updates
  - prettier
  - sass-lint
  - stylelint
- OpenVpn
- Oq
- Plantuml
- Python dependency for Awsume
- Saml2Aws (alternative to Awsume)
- VsCodeExtensionProfiles
  - install some useful extensions
  - configure VsCode with extensions profiles that can be activated
    independently in VsCode
    - Mandatory
    - Bash-Bats-Shellcheck-jq
    - Design API-UML
    - Python
    - Jenkinsfile-Docker-Helm
    - PHP-HTML-JS-twig-Vue
    - SQL
- Xvfb (not used in any profile for now, used to launch headless chrome by aws
  cli)
- Dependencies for WSL only

  - Anacron ability to run cron asynchronously (useful for wsl that has no
    systemd)
    - configured with a default weekly cron to run this install script for
      updating softwares
  - Dns (use with caution, beta version, use it if dns not working anymore on
    wsl)
  - DockerWslConfig (mainly configure /etc/wsl.conf)
  - Font install fonts that allows to displays special icons in zsh/bash prompts
  - **Note** VsCode is not needed in wsl, it has to be installed on windows and
    then accessible via `code` command from wsl prompt.
  - WslProfile (currently deactivated) - ability to configure windows terminal

- Dependencies for virtual box only
  - Chrome
  - Docker
  - DockerCompose
  - Firefox
  - JetbrainsToolbox (allows to install phpstorm)
  - LXDE
  - Terminator
  - VsCode

### 3.1. Periodical updates

`install` script has been designed to be executed several times over the time.
Anacron dependency configures a periodical execution of this script.

### 3.2. config files backup

`install` script can update or completely rewrite config files that can be
personal like `.bashrc` but don't worry these files are backed up in the
`backup` directory of this project.

## 4. Additional documentation

- [Contribute](docs/Contribute.md)
- [How does it work ?](docs/HowDoesItWork.md)
- [FAQ](docs/FAQ.md)
- [TODO](docs/TODO.md)

## 5. github page

The web page uses [Docsify](https://docsify.js.org/) to generate a static web
site.

It is recommended to install docsify-cli globally, which helps initializing and
previewing the website locally.

`npm i docsify-cli -g`

Run the local server with docsify serve.

`docsify serve pages`

Navigate to <http://localhost:3000/>

## 6. Development

Install new wsl distribution (from powershell):

```bash
wsl --install -d Ubuntu-22.04
```

As root:

```bash
# if necessary create user
adduser wsl

# change hostname to avoid confusion with your current distribution
oldName="$(hostname)"
newName="UbuntuTest"
hostname NewName
sed -i -E -e 's/${oldName}/${newName}/' /etc/hosts
```

The folder /mnt/wsl is shared between all the distro, we simply mount / in a
given folder each time we launch a shell if necessary:

- From UbuntuTest

```bash
mkdir "/mnt/wsl/${WSL_DISTRO_NAME}"
sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
```

- From your current distro

```bash
mkdir "/mnt/wsl/${WSL_DISTRO_NAME}"
sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
```

- allow folder to be shared between the 2 distros
  - from main distro, add these lines to .bashrc or .zshrc

```bash
if [[ ! -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
  mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}"
  sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
fi
```

- from UbuntuTest distro, add these lines to .bashrc or .zshrc The last command
  will link main distro home/wsl/fchastanet/bash-dev-env into this distro
  ~/projects/bash-dev-env folder every changes into ~/projects/bash-dev-env will
  be reflected into main distro and vice-versa

```bash
if [[ ! -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
  mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}"
  sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
fi
MASTER_DISTRO=Ubuntu-20.04
if [[ -d "/mnt/wsl/${MASTER_DISTRO}" ]]; then
  mkdir -p ~/projects/bash-dev-env
  sudo mount --bind \
    "/mnt/wsl/${MASTER_DISTRO}/home/wsl/fchastanet/bash-dev-env" \
    ~/projects/bash-dev-env
fi
```

## 7. Acknowledgements

This project is using [bash-tpl](https://github.com/TekWizely/bash-tpl) in order
to compile several bash files into one files.

Like so many projects, this effort has roots in many places.

I would like to thank particularly Bazyli Brzóska for his work on the project
[Bash Infinity](https://github.com/niieani/bash-oo-framework). Framework part of
this project is largely inspired by his work(some parts copied). You can see his
[blog](https://invent.life/project/bash-infinity-framework) too that is really
interesting
