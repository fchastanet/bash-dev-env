# Zsh

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
- [4. Going further](#4-going-further)
  - [4.1. Zsh](#41-zsh)
  - [4.2. Zinit](#42-zinit)
  - [4.3. find keyboard key](#43-find-keyboard-key)

## 1. Sources

This file is a compilation of these internet sources:

- <https://thevaluable.dev/zsh-install-configure-mouseless/>
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

These modes can be manually activated with the flag `-i`.

Here are some common operations and shell modes they result in:

- log in to a remote system via SSH: **login + interactive**

<!-- markdownlint-disable-next-line MD052 -->

- execute a script remotely, e.g. `ssh user@host 'echo $PWD'` or with [Capistrano](https://capistranorb.com/):
  **non‑login, non‑interactive**
- start a new shell process, e.g. `zsh`: **non‑login, interactive**
- run a script, `zsh myScript.sh`: **non‑login, non‑interactive**
- run an executable with `#!/usr/bin/env zsh` shebang: **non‑login, non‑interactive**
- open a new graphical terminal window/tab: **non‑login, interactive**

### 2.2. Shell init files

In order of activation:

- `/etc/zsh/zshenv`
- `~/.zshenv`
- **login** mode:
  - _1._ `/etc/zsh/zprofile`
  - _2._ `~/.zprofile`
- **interactive**:
  - _1._ `/etc/zsh/zshrc`
  - _2._ `~/.zshrc`
- **login** mode:
  - _1._ `/etc/zsh/zlogin`
  - _2._ `~/.zlogin`

### 2.3. Startup files order

<!-- markdownlint-disable MD033 -->

|               | Interactive<br>login | Interactive<br>non-login | Script |
| ------------- | -------------------- | ------------------------ | ------ |
| /etc/zshenv   | A                    | A                        | A      |
| ~/.zshenv     | B                    | B                        | B      |
| /etc/zprofile | C                    |                          |        |
| ~/.zprofile   | D                    |                          |        |
| /etc/zshrc    | E                    | C                        |        |
| ~/.zshrc      | F                    | D                        |        |
| /etc/zlogin   | G                    |                          |        |
| ~/.zlogin     | H                    |                          |        |
| ~/.zlogout    | I                    |                          |        |
| /etc/zlogout  | J                    |                          |        |

<!-- markdownlint-restore-->

### 2.4. Practical guide to which files get sourced when

- Opening a new Terminal window/tab:
  - Linux: `.profile` (Ubuntu, once per desktop login session) + `.zshenv` + `.zshrc`
- Logging into a system via SSH:
  - `.zshenv` + `.zprofile` + `.zshrc`
- Executing a command remotely with `ssh` or Capistrano:
  - `.zshenv`
- Remote git hook triggered by push over SSH:
  - _no init files_ get sourced, since hooks are running [within a restricted shell](http://git-scm.com/docs/git-shell)
  - PATH will be roughly: `/usr/libexec/git-core:/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin`

### 2.5. Misc. things that affect `$PATH`

- `/etc/environment`

### 2.6. Detect Login/Non-Login shell

ash executes different startup files depending on whether the shell is a login or non-login shell. To check the current
shell type, use the `[[ -o option ]]` syntax:

```zsh
[[ -o login ]] && echo 'Login shell' || echo 'Non-login shell'
```

The output prints Login shell if the user:

Logs in from the terminal remotely (for example, via SSH). Logs in from the terminal locally (for example, using the
login command). Launches zsh with the -l option (zsh -l).

### 2.7. Detect Interactive/Non interactive

When script is executed, the script is normally non interactive. If it is sourced in a login shell, the script becomes
interactive.

```zsh
[[ -o interactive ]] && echo Interactive || echo Non-interactive
```

## 3. Bash-dev-env

### 3.1. ~/.bash-dev-env directory structure

- `~/`

  - `~/.zprofile` : loads all the files from

    - `~/.bash-dev-env/profile.d` : mainly environment variables

  - `~/.zshrc` : loads all the following files (if in interactive mode)

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
- you can use chmod -x on a script to avoid the file from being loaded
- (Later) `conf.override/**/.remove` allows to list files not needed

## 4. Going further

### 4.1. Zsh

[faster zsh](https://htr3n.github.io/2018/07/faster-zsh/)
[Zsh plugins doc](https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)

### 4.2. Zinit

[Zinit](https://github.com/zdharma-continuum/zinit)
[Zinit for-syntax](https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/)
[zinit wiki](https://zdharma-continuum.github.io/zinit/wiki)
[Oh-My-Zsh plugin list](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)

### 4.3. find keyboard key

run this command so `Alt+V` allows to describe a type key

```bash
bindkey '^[v' .describe-key-briefly
```
