#!/usr/bin/env bash

Linux::requireExecutedAsUser
LOAD_SSH_KEY=0 Engine::Config::loadConfig

AUTO_MOUNT_SCRIPT="$(
  cat <<'EOF'
if [[ ! -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
  mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}"
  sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
fi
EOF
)"

downloadDistro() {
  if ! command -v aria2c &>/dev/null; then
    Log::displayInfo "Installing aria2"
    Linux::Apt::installIfNecessary --no-install-recommends aria2
  fi
  local distroImageDir
  distroImageDir="$(getDistroImageDir)"
  local distroImageTargetZip="${TMPDIR:-/tmp}/${distroImageDir}"

  if [[ ! -f "${distroImageDir}/install.tar" ]]; then
    Log::displayInfo "File ${distroImageDir}/install.tar does not exist"
    Log::displayInfo "Downloading official ubuntu image from ${DISTRO_URL} ..."
    # https://github.com/aria2/aria2/issues/684
    (
      cd /
      aria2c -c --max-connection-per-server=8 --min-split-size=1M -o "${distroImageTargetZip}" "${DISTRO_URL}"
    )
    Log::displayInfo "Unzipping ubuntu image ..."
    if [[ "${DISTRO_URL##*.}" = "gz" ]]; then
      mkdir -p "${distroImageDir}"
      gunzip -c "${distroImageTargetZip}" >"${distroImageDir}/install.tar"
    else
      unzip "${distroImageTargetZip}" -d "${distroImageDir}"
    fi
  fi

  if [[ ! -f "${distroImageDir}/install.tar" ]]; then
    Log::displayInfo "Extracting install.tar from ubuntu image ..."
    (
      cd "${distroImageDir}" || exit 1
      rm -f Ubuntu_*ARM64.appx
      mv Ubuntu_*_x64.appx Ubuntu.zip
      unzip -p Ubuntu.zip install.tar.gz | gunzip >install.tar
    )

    Log::displayInfo "Cleaning"
    rm -f "${distroImageDir}"/Ubuntu.zip
    rm -f "${distroImageTargetZip}"
  fi

  if [[ ! -f "${distroImageDir}/install.tar" ]]; then
    Log::displayError "File '${distroImageDir}/install.tar' not found"
    exit 1
  fi
}

runWslCmd() {
  local user="${REMOTE_USER:-root}"
  local pwd="${REMOTE_PWD:-/root}"
  wsl.exe -d "${DISTRO_NAME}" -u "${user}" --cd "${pwd}" -- "$@" || return 1
}

installDistro() {
  Log::displayInfo 'Import Base ubuntu image in Wsl'
  local destDistroPath installTarPath
  mkdir -p "${BASE_MNT_C:-/mnt/c}/Programs"
  local distroImageDir
  distroImageDir="$(getDistroImageDir)"
  destDistroPath="$(wslpath -w "${BASE_MNT_C:-/mnt/c}/Programs/${DISTRO_NAME}")"
  installTarPath="$(wslpath -w "${distroImageDir}/install.tar")"
  powershell.exe -ExecutionPolicy Bypass -NoProfile \
    -Command "wsl.exe --import \"${DISTRO_NAME}\" \"${destDistroPath}\" \"${installTarPath}\" --version 2"
}

createDistroUser() {
  Log::displayInfo "Add user ${USERNAME} with default password 'wsl' in new distro"
  if runWslCmd getent group "${USERGROUP}" &>/dev/null; then
    runWslCmd groupdel "${USERGROUP}"
  fi
  if runWslCmd getent group "${USERGROUP_ID}" &>/dev/null; then
    runWslCmd groupdel "${USERGROUP_ID}"
  fi
  runWslCmd groupadd -g "${USERGROUP_ID}" "${USERGROUP}"
  # create user with the same uid/gid as local user
  runWslCmd useradd -m -s /bin/bash "-u${USER_ID}" "-g${USERGROUP_ID}" "${USERNAME}"
  runWslCmd usermod -aG sudo "${USERNAME}"
  echo "${USERNAME}:wsl" | runWslCmd chpasswd
}

# mount new distro / folder into current distro
mountDistroFolder() {
  sudo mkdir -p "/mnt/wsl/${DISTRO_NAME}"
  sudo mount -t drvfs -o "uid=$(id -un),gid=$(id -gn)" "\\\\wsl$\\${DISTRO_NAME}" "/mnt/wsl/${DISTRO_NAME}"
  mkdir -p "/mnt/wsl/${DISTRO_NAME}${HOME}/fchastanet"
  runWslCmd chown -R "${USERNAME}:${USERGROUP}" "${HOME}/fchastanet"
}

getDistroImageName() {
  echo "${DISTRO_URL##*/}"
}

getDistroImageDir() {
  echo "${DISTRO_IMAGE_TARGET_DIR}/$(getDistroImageName)"
}

getDistroFile() {
  local distroVersion
  distroVersion="$(Version::parse <<<"${DISTRO_VERSION}")"
  echo "$(getDistroImageDir)-${DISTRO_NAME}-export-${distroVersion}.tar.gz"
}

exportDistro() {
  local distroFile
  distroFile="$(getDistroFile)"
  Log::displayInfo "Shutting down wsl distribution ${DISTRO_NAME}"
  runWslCmd shutdown -h now
  Log::displayInfo "Waiting for distro ${DISTRO_NAME} to terminate"
  sleep 5
  Log::displayInfo "Terminating wsl distribution ${DISTRO_NAME}"
  wsl.exe --terminate "${DISTRO_NAME}"
  Log::displayInfo "Exporting wsl distribution to ${distroFile}"
  wsl.exe --export "${DISTRO_NAME}" - | gzip -9 >"${distroFile}"
  Log::displaySuccess "Wsl distribution has been exported to ${distroFile}"
}

isDistroSystemdRunning() {
  [[ "$(runWslCmd readlink -f /sbin/init)" = "/usr/lib/systemd/systemd" ]] || return 1
  runWslCmd systemctl status --no-pager &>/dev/null || return 1
}

waitUntilDistroTerminated() {
  # shellcheck disable=SC2317
  checkDistroTerminated() {
    WSL_UTF8=1 WSLENV="${WSLENV}:WSL_UTF8" wsl.exe -l -v |
      grep "${DISTRO_NAME}" |
      awk -F ' ' '{print $2}' |
      grep -q 'Stopped'
  }
  Retry::parameterized 40 1 "Waiting for distro ${DISTRO_NAME} to terminate" checkDistroTerminated
}

getSshPrivateKey() {
  if [[ "${AUTHORIZE_SSH_KEY_USAGE:-0}" = "1" ]]; then
    if [[ ! -f "${HOME}/.ssh/id_rsa" ]]; then
      Log::fatal "Your private ssh key '${HOME}/.ssh/id_rsa' is not available"
    fi
    base64 -w0 <"${HOME}/.ssh/id_rsa"
  fi
}

if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" ]]; then
  Log::displayError "please create ${BASH_DEV_ENV_ROOT_DIR}/.env.distro using ${BASH_DEV_ENV_ROOT_DIR}/.env.distro.template"
  Log::displayError echo "cp .env.distro.template .env.distro"
  Log::displayError echo "code .env.distro"
  exit 1
fi

# shellcheck source=/.env.template
source "${BASH_DEV_ENV_ROOT_DIR}/.env.distro"
if [[ ! "${DISTRO_NAME}" =~ ^[-_A-Za-z0-9]+$ ]]; then
  Log::fatal "DISTRO_NAME invalid value : '${DISTRO_NAME}'"
fi
if [[ ! "${DISTRO_URL}" =~ ^https://+ ]]; then
  Log::fatal "DISTRO_URL invalid value : '${DISTRO_URL}'"
fi
# The path where bash-dev-env project will be copied into target distro
DISTRO_BASH_DEV_ENV_TARGET_DIR="${BASH_DEV_ENV_ROOT_DIR}"
# shellcheck disable=SC1003
BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"

# shellcheck disable=SC2154
if [[ "${optionSkipDistro}" = "0" ]]; then
  downloadDistro
fi

declare existingDistroName
existingDistroName="$(
  WSL_UTF8=1 WSLENV="${WSLENV}":WSL_UTF8 wsl.exe -l -v 2>&1 |
    grep -E "^\s*${DISTRO_NAME}\s" | awk -F ' ' '{print $1}' || true
)"
if [[ "${optionSkipDistro}" = "1" ]]; then
  Log::displaySkipped "Distribution ${DISTRO_NAME} installation skipped"
  if [[ "${existingDistroName}" != "${DISTRO_NAME}" ]]; then
    Log::displayError "Distribution ${DISTRO_NAME} not installed"
    exit 1
  fi
elif [[ "${existingDistroName}" = "${DISTRO_NAME}" ]]; then
  Log::displaySkipped "Distribution ${DISTRO_NAME} already installed"
else
  installDistro
  createDistroUser
fi
REMOTE=runWslCmd Engine::Config::loadUserVariables
mountDistroFolder

Log::displayInfo "Enable automount of this distro's / in /mnt/wsl/<distro> of the remote distro"
echo "${AUTO_MOUNT_SCRIPT}" |
  tee -a "/mnt/wsl/${DISTRO_NAME}${HOME}/.bashrc" >/dev/null
Log::displayInfo 'Mounting / of this distro in remote distro /mnt/wsl/<distro> folder'

if [[ ! -d "/mnt/wsl/${DISTRO_NAME}/mnt/wsl/${DISTRO_NAME}" ]]; then
  runWslCmd mkdir -p "/mnt/wsl/${DISTRO_NAME}"
  runWslCmd mount --bind / "/mnt/wsl/${DISTRO_NAME}"
fi

Log::displayInfo "Delete folder ${DISTRO_BASH_DEV_ENV_TARGET_DIR} in distro ${DISTRO_NAME}"
runWslCmd rm -Rf "${DISTRO_BASH_DEV_ENV_TARGET_DIR}/"{*,.*} 2>/dev/null || true

Log::displayInfo "Prepare archive of current dir ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}/tmp"
(
  cd "${BASH_DEV_ENV_ROOT_DIR}" || exit 1

  tar -c --exclude-ignore=.tarignore \
    -f "/mnt/wsl/${WSL_DISTRO_NAME}/tmp/bashDevEnv.tar" .
  tar -rf "/mnt/wsl/${WSL_DISTRO_NAME}/tmp/bashDevEnv.tar" logs/.gitignore
)

Log::displayInfo "Syncing current dir to target distro ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
runWslCmd mkdir -p "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
runWslCmd chown "${USERNAME}:${USERGROUP}" "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
# un-tar file from current distro into the new
REMOTE_USER=wsl REMOTE_PWD="${DISTRO_BASH_DEV_ENV_TARGET_DIR}" runWslCmd tar xf "/mnt/wsl/${WSL_DISTRO_NAME}/tmp/bashDevEnv.tar"

Log::displayInfo "Fixing rights on target distro ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
runWslCmd chown -R "${USERNAME}:${USERGROUP}" "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"

Log::displayInfo "Copying .env.distro"
cp -v "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" "/mnt/wsl/${DISTRO_NAME}${DISTRO_BASH_DEV_ENV_TARGET_DIR}/.env"

declare systemdActivated=0
if isDistroSystemdRunning; then
  systemdActivated=1
fi
Log::displayInfo 'pre-configure /etc/wsl.conf in order to activate systemd'
sudo cp "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/WslDefaultConfig-conf/wsl.conf" \
  "/mnt/wsl/${DISTRO_NAME}/etc/wsl.conf"

# no need to restart the distro if systemd already active
if [[ "${systemdActivated}" = "0" ]]; then
  Log::displayInfo "Terminating the distro ${DISTRO_NAME} to enable Systemd"
  wsl.exe --terminate "${DISTRO_NAME}"

  waitUntilDistroTerminated || exit 1
  Log::displayInfo "Check if systemd has been enabled successfully"
  if ! isDistroSystemdRunning; then
    Log::fatal "Systemd is not running"
  fi
fi
declare -a installCmd=(
  ./install "${DISTRO_INSTALL_OPTIONS[@]}"
)
# shellcheck disable=SC2154
if [[ "${optionExport}" = "1" ]]; then
  installCmd+=(--prepare-export)
fi

# shellcheck disable=SC2154
if [[ "${SKIP_CONFIGURE}" = "1" ]]; then
  installCmd+=(--skip-configure)
fi

# shellcheck disable=SC2154
if [[ "${SKIP_TEST}" = "1" ]]; then
  installCmd+=(--skip-test)
fi

# shellcheck disable=SC2154
if [[ "${SKIP_DEPENDENCIES}" = "1" ]]; then
  installCmd+=(--skip-dependencies)
fi

# shellcheck disable=SC2154
if [[ "${SKIP_INSTALL}" = "1" ]]; then
  installCmd+=(--skip-install)
  Log::displayInfo "Install manually using :"
  echo "wsl.exe -d '${DISTRO_NAME}' -u wsl --cd '${DISTRO_BASH_DEV_ENV_TARGET_DIR}' -- ${installCmd[*]}"
fi

(
  # shellcheck disable=SC2034
  SUDO=""
  SUDOER_FILE="/mnt/wsl/${DISTRO_NAME}/etc/sudoers.d/bash-dev-env-no-password" \
    Linux::createSudoerFile

  Log::displayInfo "Installing ... using ${installCmd[*]}"
  REMOTE_USER=${USERNAME} \
    REMOTE_PWD="${DISTRO_BASH_DEV_ENV_TARGET_DIR}" \
    runWslCmd bash --noprofile -c "SSH_PRIVATE_KEY='$(getSshPrivateKey)' DISTRO_MODE=1 ${installCmd[*]}" || exit 1
) || exit 1
Log::displayInfo "Restarting wsl distribution ${DISTRO_NAME}"
wsl.exe --terminate "${DISTRO_NAME}"
waitUntilDistroTerminated || exit 1

if [[ "${optionExport}" = "1" ]]; then
  exportDistro
fi

# shellcheck disable=SC2154
if [[ "${optionUpload}" = "1" ]]; then
  declare distroFile
  distroFile="$(getDistroFile)"
  if [[ ! -f "${distroFile}" ]]; then
    Log::fatal "missing ${distroFile}, have you forgot --export option ?"
  fi
  Log::displaySkipped "Not implemented yet"
else
  Log::displaySkipped "upload option was not selected"
fi

Log::displaySuccess "Process successful"
