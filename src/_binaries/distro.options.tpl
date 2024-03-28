%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="distroCommand"
declare help="Launch wsl distribution"
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "skip creating distro ${DISTRO_NAME}" \
    --alt "--skip-distro" \
    --alt "-d" \
    --variable-name "optionSkipDistro" \
    --function-name optionSkipDistroFunction

  Options::generateOption \
    --help "skip softwares installation" \
    --alt "--skip-install" \
    --alt "-i" \
    --variable-name "optionSkipInstall" \
    --function-name optionSkipInstallFunction

  Options::generateOption \
    --help "prepare the wsl image for export (remove all sensitive files)" \
    --alt "--export" \
    --alt "-e" \
    --variable-name "optionExport" \
    --function-name optionExportFunction

  Options::generateOption \
    --help "upload the wsl compressed image to s3 bucket" \
    --alt "--upload" \
    --alt "-u" \
    --variable-name "optionUpload" \
    --function-name optionUploadFunction
)
options+=(
  optionSkipDistroFunction
  optionSkipInstallFunction
  optionExportFunction
  optionUploadFunction
)
Options::generateCommand "${options[@]}"
%

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
