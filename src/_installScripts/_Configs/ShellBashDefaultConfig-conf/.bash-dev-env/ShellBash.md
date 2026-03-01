# Bash

- [1. Sources](#1-sources)
- [2. Shell initialization files](#2-shell-initialization-files)
  - [2.1. Shell modes](#21-shell-modes)
  - [2.2. Shell init files](#22-shell-init-files)
  - [2.3. Startup files order](#23-startup-files-order)
  - [2.4. Practical guide to which files get sourced when](#24-practical-guide-to-which-files-get-sourced-when)
  - [2.5. Misc. things that affect `$PATH`](#25-misc-things-that-affect-path)
  - [2.6. Detect Login/Non-Login shell](#26-detect-loginnon-login-shell)
  - [2.7. Detect Interactive/Non interactive](#27-detect-interactivenon-interactive)
- [3. Bash-dev-env](#3-bash-dev-env)
  - [3.1. ~/.bash-dev-env directory structure](#31-bash-dev-env-directory-structure)

## 1. Sources

This file is a compilation of these internet sources:

- <https://phoenixnap.com/kb/bashrc-vs-bash-profile>
- <https://github.com/pyenv/pyenv/wiki/Unix-shell-initialization>
- <https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc>

## 2. Shell initialization files

Shell initialization files are ways to persist common shell configuration, such as:

- `$PATH` and other environment variables
- shell prompt
- shell tab-completion
- aliases, functions
- key bindings

### 2.1. Shell modes

Which initialization files get sourced by the shell is dependent on the combination of modes in which a particular shell
process runs. There are two main, non-exclusive modes:

- **login** - e.g. when user logs in to a system with non-graphical interface or via SSH;
- **interactive** - shell that has a prompt and whose standard input and error are both connected to terminals.

These modes can be manually activated with the following flags `-l` or `--login`.

Here are some common operations and shell modes they result in:

- log in to a remote system via SSH: **login + interactive**
- execute a script remotely, e.g. `ssh user@host 'echo $PWD'` or with
  <!-- markdownlint-disable-next-line MD052 -->
  [Capistrano](https://capistranorb.com/): **non‑login, non‑interactive**
- start a new shell process, e.g. `bash`: **non‑login, interactive**
- run a script, `bash myScript.sh`: **non‑login, non‑interactive**
- run an executable with `#!/usr/bin/env bash` shebang: **non‑login, non‑interactive**
- open a new graphical terminal window/tab: **non‑login, interactive**

### 2.2. Shell init files

In order of activation:

- **login** mode:
  - _1._ `/etc/profile`
  - _2._ `~/.bash_profile`, `~/.bash_login`, `~/.profile` (only first one that exists)
- **interactive non-login** mode:
  - _1._ `/etc/bash.bashrc` (some Linux; not on Mac OS X)
  - _2._ `~/.bashrc`
- **non-interactive** mode:
  - _1._ source file in `$BASH_ENV`

### 2.3. Startup files order

<!-- markdownlint-disable MD033 -->

|                  | Interactive<br>login | Interactive<br>non-login | Script |
| ---------------- | -------------------- | ------------------------ | ------ |
| /etc/profile     | A                    |                          |        |
| /etc/bash.bashrc |                      | A                        |        |
| ~/.bashrc        |                      | B                        |        |
| ~/.bash_profile  | B1                   |                          |        |
| ~/.bash_login    | B2                   |                          |        |
| ~/.profile       | B3                   |                          |        |
| BASH_ENV         |                      |                          | A      |
| ~/.bash_logout   | C                    |                          |        |

<!-- markdownlint-restore-->

Moral: put stuff in ~/.bashrc, and make ~/.bash_profile source it.

### 2.4. Practical guide to which files get sourced when

- Opening a new Terminal window/tab:
  - Linux: `.profile` (Ubuntu, once per desktop login session) + `.bashrc`
- Logging into a system via SSH:
  - `.bash_profile` or `.profile` (1st found)
- Executing a command remotely with `ssh` or Capistrano:
  - `.bashrc`
- Remote git hook triggered by push over SSH:
  - _no init files_ get sourced, since hooks are running [within a restricted shell](http://git-scm.com/docs/git-shell)
  - PATH will be roughly: `/usr/libexec/git-core:/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin`

### 2.5. Misc. things that affect `$PATH`

- `/etc/environment`

### 2.6. Detect Login/Non-Login shell

Bash executes different startup files depending on whether the shell is a login or non-login shell. To check the current
shell type, use the shopt command:

```bash
shopt -q login_shell && echo 'Login shell' || echo 'Non-login shell'
```

The output prints Login shell if the user:

Logs in from the terminal remotely (for example, via SSH). Logs in from the terminal locally (for example, using the
login command). Launches Bash with the -l option (bash -l).

### 2.7. Detect Interactive/Non interactive

When script is executed, the script is normally non interactive. If it is sourced in a login shell, the script becomes
interactive.

```bash
[[ $- == *i* ]] && echo Interactive || echo Non-interactive
```

## 3. Bash-dev-env

### 3.1. ~/.bash-dev-env directory structure

- `~/`

  - `~/.profile` : loads all the files .sh and .bash from

    - `~/.bash-dev-env/profile.d` : mainly environment variables

  - `~/.bashrc` : loads all the following files with .sh and .bash extension (if in interactive mode)

    - `~/.bash-dev-env/aliases.d` : bash aliases
    - `~/.bash-dev-env/completions.d` : bash completions
    - `~/.bash-dev-env/interactive.d` : These scripts load keybindings or prompts.

  - `~/.bash-dev-env/`:

    - `profile.d/` : contains all the script files that will load env variable related to specific products (Eg: load
      paths, ...)
    - `aliases.d/` : contains all the aliases
    - `completions.d/` : bash completions
    - `interactive.d/` : These scripts load keybindings or prompts.
    - `GitDefaultConfig/`
      - .gitconfig
      - .gitignore

Rules:

- Each directory can be overridden in `conf.override/<profile>/.bash-dev-env`
- Each file installed from `conf/**/.bash-dev-env` will be copied as read only
- (Later) `conf.override/**/.remove` allows to list files not needed
