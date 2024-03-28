# Bash-dev-env, How does it work ?

- [1. Install command](#1-install-command)
- [2. Engine](#2-engine)
  - [2.1. lib/loadAndCheckConfig.sh - loadAndCheckConfig](#21-libloadandcheckconfigsh---loadandcheckconfig)
  - [2.2. lib/loadAndCheckConfig.sh - loadProfile](#22-libloadandcheckconfigsh---loadprofile)
- [3. Libraries](#3-libraries)
- [4. Configurations](#4-configurations)

## 1. Install command

this project consists of one simple command `install` that will

- load the profile provided in argument
- rotate logs
- execute each install/configure/test scripts (in order including the
  dependencies of each profile selected scripts)
- recapitulate duration, actions and important information

Some scripts are mandatory and are always executed, no matter what profile
chosen:

- \_Test - do some mandatory checks before running the process
- \_Upgrade (first) - upgrade apt packages
- MandatorySoftwares (second) - softwares mandatory for this whole system to
  work properly
- \_Clean (last) - clean apt, temp files, ...

## 2. Engine

### 2.1. lib/loadAndCheckConfig.sh - loadAndCheckConfig

The most important function is loadAndCheckConfig from
`lib/loadAndCheckConfig.sh` file.

This function is responsible for:

- loading `.env` file

  - checks `.env` file exists, exit on error
  - loads `.env` file
  - checks validity of each `.env` variables

- deducing some global variables

  - WSL only
    - `WINDOWS_PROFILE_DIR`
    - `LOCAL_APP_DATA`
    - `WINDOW_PATH` : converted windows PATH variable to linux compatible PATH

- exporting the following variables from .env:

  - USERGROUP
  - USERNAME
  - GIT_USER_MAIL
  - GIT_USERNAME
  - SSH_LOGIN
  - POWERSHELL_BIN

- deducing and export the following variables

  - USERID => computed from USERNAME provided by .env file
  - USERGROUP_ID => computed from USERGROUP provided by .env file
  - ROOT_DIR => `<full path to this project directory>`
  - HOSTIP
  - IPCONFIG => heavy computation of the right command to use for ipconfig
    depending environment

- following variables (with default values that could be overridden by .env
  file)

  - CONF_DIR => defaults to ${ROOT_DIR}/conf
  - LOGS_DIR => defaults to ${ROOT_DIR}/logs
  - PROJECTS_DIR => defaults to ${USER_HOME}/projects
  - BACKUP_DIR => defaults to ${ROOT_DIR}/backup
  - INSTALL_SCRIPTS_DIR => defaults to ${ROOT_DIR}/scripts

- setting sudoer without password temporarily

  - create a file in `/etc/sudoers.d` folder to avoid asking sudo password when
    it expires
  - create /etc/sudoers.d/bash-dev-env (check refactoring needed section)

- installing and configuring the file `${HOME}/.bash-dev-env`
  - the aim of this file is to provide common configuration variables for both
    ShellZsh and ShellBash
  - the main advantage of this file is that it can be automatically updated
    without risking to overwrite .bashrc file
  - the variable OVERWRITE_CONFIG_FILES is ignored
  - it provides the following environment variables, among others: PATH,
    COMPOSER_HOME, AWS_REGION, AWS_PROFILE, SSH_LOGIN, ...
  - all these variables can then be reused by all the different script
    configurations like ssh aliases, Saml2Aws, ...
  - this file loads this project .env file so variables like SHOW_FORTUNES and
    SHOW_MOTD can be taken into account by .bashrc, ...

Note: this function has too much responsibilities and has to be refactored (cut
in more specialized functions).

### 2.2. lib/loadAndCheckConfig.sh - loadProfile

This function :

- checks that no files are missing for each script configuration (install,
  configure, test)
- checks that each script dependency exists
- computes the order to run the scripts depending on `CONFIG_LIST` order and
  dependencies of each config script.

Loads the file `profile.default.sh` if PROFILE is default (-p parameter).
Providing `CONFIG_LIST` array of scripts to load.

## 3. Libraries

Some of the functions you can find:

- `lib/utils/Assert.sh` provides utility functions to do some checks.
- `Functions::aptInstall` use this function in order to be sure to use the
  correct default parameters it includes retry.
- `Functions::aptAddRepository`
- `getGithubLatestRelease` very useful in order to get last release version of a
  github project
- `upgradeGithubRelease`
- `Assert::wsl`
- `NetFunctions::addHost` add host in /etc/hosts and windows hosts file if wsl
  (backup file before updates)
- validator functions
- `Version::checkMinimal` and `Version::compare`: version comparison function
- log and logRotate functions
- backup function
- `installFile`/`installDir` install file or dir doing backup before and
  OVERRIDE_CONF variable aware
- `gitPullIfNoChanges`/`gitCloneOrPullIfNoChanges`

## 4. Configurations

Configurations are folders in the `scripts` directory. when you create a new
configuration, please be sure it sources the file `lib/common.sh`, as it
initializes correctly the environment, load the main libraries, load the profile
and set bash flags like errexit and pipefail.

Configuration should have the following files:

- `install`
- `configure`
- `test`

It could have also the following optional files:

- `fortunes`
- `dependencies`
- `breakOnConfigFailure` if present and config is failing, the whole process is
  stopped
- `breakOnTestFailure` if present and test is failing, the whole process is
  stopped
