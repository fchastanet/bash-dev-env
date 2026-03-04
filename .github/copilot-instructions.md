# Copilot Instructions for bash-dev-env

## Project Overview

**bash-dev-env** is a comprehensive Bash-based development environment
installation and configuration system for Ubuntu-based distributions (WSL,
VirtualBox, or native). It uses
[bash-tools-framework](https://github.com/fchastanet/bash-tools-framework) and a
custom bash compiler to generate self-contained installation scripts.

**Key Concepts:**

- **Install Scripts**: Modular components that install, configure, and test
  software packages
- **Profiles**: Collections of install scripts (e.g., `profile.default.sh`)
- **Bash Compiler**: Compiles source files from `src/` into executable binaries
  in `bin/` and `installScripts/`
- **Framework Integration**: Uses namespaced functions from bash-tools-framework
  (e.g., `Log::`, `Assert::`, `Conf::`)

## Repository Structure

```text
.
├── .github/
│   ├── copilot-instructions.md     # This file
│   ├── instructions/               # Modular instruction files
│   └── workflows/                  # CI/CD pipelines
├── bin/                            # Compiled executable binaries (GENERATED)
├── installScripts/                 # Compiled install scripts (GENERATED)
├── src/                            # Source code (edit here)
│   ├── _installScripts/           # Install script sources
│   ├── _tools/                    # Tool sources (bin/ outputs)
│   ├── _commandDefinitions/       # Bash compiler templates
│   ├── InstallScripts/            # Install script interface
│   ├── Profiles/                  # Profile management
│   └── */                         # Framework modules (Log, Assert, UI, etc.)
├── profiles/                       # Profile definitions
├── content/                       # Hugo documentation content
│   ├── _index.md                  # Site home page
│   └── docs/                      # Documentation pages
├── configs/                       # Hugo configuration
│   └── site-config.yaml          # Site-specific config
├── assets/                        # Hugo assets
│   └── scss/                     # Custom SCSS
├── vendor/                        # External dependencies (git submodule)
│   └── bash-tools-framework/     # Framework (not committed)
├── .framework-config              # Framework configuration
├── .bash-compiler                 # Compiler configuration
├── install                        # Main installation script (GENERATED)
├── distro                         # Distribution script (GENERATED)
└── test.sh                        # BATS test runner
```

## General Workflow Instructions

### Chat vs Agent Mode

- **Chat Mode**: Only provide relevant code changes, not entire files
- **Agent Mode**: Always edit files directly, act as a senior developer

### Git Conventions

- **Default Branch**: Always use `master` (not `main`)
- **Generated Files**: Files in `bin/` and `installScripts/` are auto-generated
  by bash-compiler (DO NOT edit directly)
- **Commit Messages**: See
  [Commit Message Instructions](.github/commit-message.instructions.md)

## Working with Install Scripts

### Install Script Structure

All install scripts must implement the `InstallScripts` interface:

**Required Functions:**

```bash
helpDescription() { :; } # One-line description
install() { :; }         # Installation logic
testInstall() { :; }     # Verify installation (return 0=success)
configure() { :; }       # Configuration after install
testConfigure() { :; }   # Verify configuration
```

**Optional Functions:**

```bash
helpLongDescription() { :; } # Detailed description
dependencies() { :; }        # Return "installScripts/DependencyName"
fortunes() { :; }            # Post-install tips (% separated)
cleanBeforeExport() { :; }
testCleanBeforeExport() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
```

### Creating a New Install Script

1. **Create directory structure:**

```text
src/_installScripts/Category/ScriptName/
├── ScriptName.sh                # Main implementation
├── ScriptName-binary.yaml       # Compiler configuration
├── ScriptName-conf/             # Optional: config files to deploy
└── ScriptName-hooks/            # Optional: lifecycle hooks
```

2. **Implement required functions** in `ScriptName.sh`

3. **Configure binary.yaml** (see [Binary yaml Files](#binary-yaml-files))

4. **Add to profile** in `profiles/profile.*.sh`:

```bash
CONFIG_LIST+=(
  "installScripts/ScriptName"
)
```

5. **Compile**: Run `pre-commit run bash-compiler -a`

### Install Script Patterns

**GitHub Release Installation:**

```bash
# Use upgradeGithubRelease.yaml as base
extends:
- "${BASH_DEV_ENV_ROOT_DIR}/src/_commandDefinitions/upgradeGithubRelease.yaml"
```

**Config File Deployment:**

```bash
# @embed directive in .sh file
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Category/Name-conf" as conf_dir
Conf::copyStructure "${embed_dir_conf_dir}" "$(fullScriptOverrideDir)" ".bash-dev-env"
```

**Version Checking:**

```bash
Version::checkMinimal "binary-name" --version "1.2.3" || return 1
```

**Dependency Declaration:**

```bash
dependencies() {
  echo "installScripts/ParentScript"
  echo "installScripts/AnotherDependency"
}
```

### Binary yaml Files

Every script needs a `-binary.yaml` file for compilation:

```yaml
extends:
  - ${BASH_DEV_ENV_ROOT_DIR}/src/_commandDefinitions/installScript.yaml

vars:
  SRC_FILE_PATH: src/_installScripts/Category/Name-binary.yaml

compilerConfig:
  targetFile: ${BASH_DEV_ENV_ROOT_DIR}/installScripts/Name
  relativeRootDirBasedOnTargetDir: ..

binData:
  commands:
    default:
      functionName: NameCommand
      version: '3.0'
      copyrightBeginYear: 2024
      definitionFiles:
        11: ${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Category/Name.sh
      commandName: Name
```

## Framework Integration (bash-tools-framework)

### Key Namespaces

The framework provides namespaced functions (use these instead of reinventing):

- **`Log::`** - Logging (`Log::displayError`, `Log::displayInfo`,
  `Log::displayWarning`, `Log::headLine`)
- **`Assert::`** - Assertions (`Assert::fileExists`, `Assert::dirExists`,
  `Assert::commandExists`)
- **`Conf::`** - Configuration (`Conf::copyStructure`, `Conf::installFile`)
- **`UI::`** - UI/theming functions
- **`Version::`** - Version comparison (`Version::checkMinimal`,
  `Version::compare`)
- **`Linux::`** - Linux utilities (`Linux::Apt::installPackages`,
  `Linux::installDeb`)
- **`Github::`** - GitHub utilities (`Github::upgradeRelease`,
  `Github::getLatestRelease`)

### Framework Configuration

- **Location**: `.framework-config` (defines paths and compilation parameters)
- **Vendor Path**: `vendor/bash-tools-framework` (git submodule, not in repo)
- **Source Directories**: Both `src/` and framework `src/` are available

### Testing with Framework

Tests use BATS and load framework modules via `src/batsHeaders.sh`.

## Testing

### Test Structure

- **Test Files**: Co-located with source code as `*.bats` files
- **Test Runner**: `test.sh` (Docker-based BATS execution)
- **Test Data**: `testsData/` directory adjacent to `.bats` files

### Running Tests

```bash
# Run all tests
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30

# Run specific test file
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 src/Module/file.bats

# Show BATS help
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 --help
```

### Writing Tests

```bash
# Use #@test annotation
function MyFunction::testCase { #@test
  run MyFunction::someFunction "arg"
  assert_success
  assert_output "expected output"
}

# Setup/teardown
setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile="$(mktemp -p "${TMPDIR}" -t bats-$$-XXXXXX)"
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
}

teardown() {
  unstub_all # Clean up mocks
  rm -f "${logFile}"
}
```

**Common Assertions:**

- `assert_success` / `assert_failure [code]`
- `assert_output [--partial] "text"`
- `assert_line --index N "text"`
- `assert_lines_count N`

## Linting and Code Quality

### Pre-commit Hooks

Pre-commit hooks run automatically on commit (configured in
`.pre-commit-config.yaml`):

**Key Linters:**

- **shellcheck**: Bash linting (config: `.shellcheckrc`)
- **shfmt**: Bash formatting (2-space indent, `-i 2 -ci`)
- **prettier**: JS/YAML/JSON/HTML formatting (config: `.prettierrc.yaml`)
- **eslint**: JavaScript/JSON linting (config: `.eslintrc.js`)
- **mdformat**: Markdown formatting (80-char wrap)
- **actionlint**: GitHub Actions validation
- **bash-compiler**: Compiles binaries from source

**Manual Pre-commit Run:**

```bash
# Run all hooks
pre-commit run -a

# Run specific hook
pre-commit run shellcheck -a
pre-commit run bash-compiler -a
```

### MegaLinter

MegaLinter runs in CI and provides comprehensive validation:

- **Config**: `.mega-linter.yml`, `.mega-linter-githubAction.yml`
- **Auto-fixes**: Enabled (`APPLY_FIXES: all`)
- **Fix PRs**: Automatically created with `update/pre-commit-fixes-*` branch
  name

### Linter Configuration Files

| File                      | Purpose               |
| ------------------------- | --------------------- |
| `.shellcheckrc`           | Bash linting rules    |
| `.prettierrc.yaml`        | Code formatting       |
| `.eslintrc.js`            | JavaScript/JSON rules |
| `.yamllint.yml`           | YAML validation       |
| `.markdownlint.json`      | Markdown rules        |
| `.mega-linter.yml`        | MegaLinter config     |
| `.pre-commit-config.yaml` | Pre-commit hooks      |

**Key Settings:**

- **Line Length**: Generally 80 chars (Markdown: 120, YAML: 500)
- **Bash Indent**: 2 spaces
- **Exclusions**: `vendor/`, `srcAlt/`, `testsData/`, `node_modules/`,
  `.history/`

### Auto-formatting Before Commit

If pre-commit fixes issues, review the changes and commit again:

```bash
git add .
git commit -m "Your message"
# Pre-commit auto-fixes files
git add .
git commit -m "Your message" # Commit with fixes
```

## Bash Compiler Workflow

### Compilation Process

1. **Source Files**: Edit files in `src/` with corresponding `-binary.yaml`
2. **Pre-commit Trigger**: bash-compiler hook runs on commit
3. **Compilation**: Compiler generates binaries in `bin/` or `installScripts/`
4. **Generated Markers**: Output files marked with `# @generated` header

### Configuration Files

- **`.bash-compiler`**: Root directories and template locations
- **`.framework-config`**: Framework paths, compilation parameters, function
  ignore patterns

### Command Definition Files

Located in `src/_commandDefinitions/`:

- `default.yaml`: Base command structure
- `installScript.yaml`: Install script template
- `upgradeGithubRelease.yaml`: GitHub release updater template
- `frameworkConfig.yaml`: Framework-specific settings

**Your binary.yaml extends these with `extends:` directive**

### Generated Files - DO NOT EDIT

Files with this header are auto-generated:

```bash
# GENERATED FROM https://github.com/fchastanet/bash-dev-env/tree/master/src/_tools/install-binary.yaml
# DO NOT EDIT IT
# @generated
```

**Instead**: Edit the source file in `src/` and let compiler regenerate.

## CI/CD Workflows

### Main Workflow: lint-test.yml

**Sequence:**

1. **Setup**: Checkout, install requirements, configure environment
2. **Pre-commit**: Run all hooks (formatting, linting)
3. **MegaLinter**: Comprehensive validation (with auto-fix PR generation)
4. **Unit Tests**: BATS tests in Docker
5. **Reporting**: JUnit reports, test artifacts upload

**Key Environment Variables:**

- `APPLY_FIXES: all` - Enable auto-fixes
- `APPLY_FIXES_MODE: pull_request` - Create PRs for fixes
- `CI_MODE: 1` - CI environment flag

### Other Workflows

- `build-site.yml`: Deploy GitHub Pages documentation
- `main.yml`: Main workflow Test, Build and Deploy documentation
  for pushes and PRs
- `precommit-autoupdate.yml`: Auto-update pre-commit hooks
- `set-github-status-on-pr-approved.yml`: Status management

### Workflow Line Length

**For GitHub Actions workflows**: Split lines longer than 120 characters

Example:

```yaml
# Good
good: |
  some-command \
    --long-option value \
    --another-option value

# Bad
bad: some-command --long-option value --another-option value --another-option
```

## Common Workflows

### Adding a New Software Package

1. **Create install script** in `src/_installScripts/Category/Name/`
2. **Implement interface functions** (install, test, configure, etc.)
3. **Create binary.yaml** for compilation
4. **Add to profile** in `profiles/profile.*.sh`
5. **Write tests** in `Name.bats`
6. **Run pre-commit** to compile: `pre-commit run bash-compiler -a`
7. **Test**: `./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src`
8. **Commit** with proper message format

### Updating Framework Functions

1. **Edit source** in `src/ModuleName/function.sh`
2. **Update tests** in `src/ModuleName/function.bats`
3. **Run tests** to verify changes
4. **Run linters**: `pre-commit run -a`
5. **Commit** changes

### Fixing Linting Issues

1. **Run pre-commit**: `pre-commit run -a`
2. **Review auto-fixes**: Check what was changed
3. **Manual fixes**: Address issues that couldn't be auto-fixed
4. **Re-run**: `pre-commit run -a` to verify
5. **Commit** fixes

### Debugging Test Failures

1. **Check CI logs**: GitHub Actions → Failed job → Test Results
2. **Run locally**:

```bash
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 path/to/failing.bats
```

3. **Enable debug**:

```bash
KEEP_TEMP_FILES=1 ./test.sh ... # Keep temp files
```

4. **Fix issues** and re-run
5. **Commit** fixes

## Troubleshooting

### Common Issues

**Issue**: `vendor/bash-tools-framework` not found

- **Solution**: `git submodule update --init --recursive`

**Issue**: Pre-commit hook fails with "bash-compiler not found"

- **Solution**: Ensure pre-commit is installed and hooks are set up:

```bash
pre-commit install
pre-commit install --hook-type pre-push
```

**Issue**: Tests fail in Docker

- **Solution**: Ensure Docker image exists:

```bash
docker pull scrasnups/build:bash-tools-ubuntu-5.3
```

**Issue**: Generated files out of sync

- **Solution**: Recompile all binaries:

```bash
pre-commit run bash-compiler -a
```

**Issue**: MegaLinter creates unwanted fix PRs

- **Solution**: Add `skip fix` in commit message to prevent auto-fixes

## Documentation

### Key Documents

- **README.md**: Project overview and features
- **content/docs/install.md**: Installation instructions
- **content/docs/contribute.md**: Contribution guidelines
- **content/docs/how-does-it-work.md**: Architecture and internals

### Hugo Documentation Site

The project uses Hugo with the Docsy theme for documentation:

- **Configuration**: `configs/site-config.yaml` - Site-specific Hugo configuration
- **Content**: `content/` - Hugo-structured markdown documentation
- **Theme Override**: `assets/scss/_variables_project_override.scss` - Custom styling
- **Deployment**: `.github/workflows/build-site.yml` - Automated build and deployment

#### GitHub Pages

- Documentation site: <https://fchastanet.github.io/bash-dev-env/>
- Deployed via GitHub Actions using reusable workflow from fchastanet/my-documents

## Best Practices

### Do's

✅ Use framework functions (`Log::`, `Assert::`, `Conf::`) instead of raw Bash
commands\
✅ Write tests for all new functions\
✅ Follow naming conventions (PascalCase for install scripts)\
✅ Validate versions before installation (`Version::checkMinimal`)\
✅ Use `@embed` directives for config file deployment\
✅ Document dependencies in `dependencies()` function\
✅ Run `pre-commit run -a` before committing\
✅ Use emojis extensively in commit messages\
✅ Check CI/CD status after pushing

### Don'ts

❌ Don't edit files in `bin/` or `installScripts/` directly (they're generated)\
❌ Don't commit without running pre-commit hooks\
❌ Don't create install scripts without tests\
❌ Don't use plain `echo` for logging (use `Log::displayInfo`, etc.)\
❌ Don't hardcode paths (use variables from `.framework-config`)\
❌ Don't skip interface function implementation (even if empty, define stubs)\
❌ Don't forget to update `profile.*.sh` when adding new scripts\
❌ Don't commit secrets or sensitive data

## Additional Resources

- **bash-tools-framework**: <https://fchastanet.github.io/bash-tools-framework/>
- **bash-compiler**: <https://fchastanet.github.io/bash-compiler/>
- **BATS**: <https://github.com/bats-core/bats-core>
- **Pre-commit**: <https://pre-commit.com/>
- **MegaLinter**: <https://megalinter.io/>

## Quick Reference

### Essential Commands

```bash
# Run tests
./test.sh scrasnups/build:bash-tools-ubuntu-5.3 -r src -j 30

# Run linters
pre-commit run -a

# Compile binaries
pre-commit run bash-compiler -a

# Install requirements
./bin/installRequirements

# Run main installer
./install -p default

# Check install script interface
./checkInstallScripts.sh

# Local docs preview from my-documents folder
SITE=bash-dev-env make start-site
```

### File Patterns

- `src/_installScripts/**/*.sh` - Install script sources
- `src/_installScripts/**/*-binary.yaml` - Compiler configs
- `src/**/*.bats` - Test files
- `installScripts/*` - Compiled install scripts (GENERATED)
- `bin/*` - Compiled binaries (GENERATED)

### Key Variables (from .framework-config)

- `BASH_DEV_ENV_ROOT_DIR`: Project root directory
- `FRAMEWORK_ROOT_DIR`: Framework installation directory
- `BASH_FRAMEWORK_LOG_FILE`: Log file location
- `BASH_FRAMEWORK_DISPLAY_LEVEL`: Log verbosity (0-4)

______________________________________________________________________

**Remember**: This is a complex project with many moving parts. Take time to
understand the patterns before making changes. When in doubt, check existing
install scripts for examples.
