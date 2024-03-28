%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="installScriptCommand"
helpDescriptionCallback() { :; }
declare help=helpDescriptionCallback
helpLongDescriptionCallback() { :; }
declare longDescription=helpLongDescriptionCallback
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.skip.options.tpl)"

%
options+=(
  --callback InstallScripts::command
)
Options::generateCommand "${options[@]}"
%

# default action called by the facade if no interface action recognized
defaultFacadeAction() {
  <% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
}

stringOrNone() {
  local string="$1"
  echo -e "${string:-${__HELP_EXAMPLE}None${__HELP_NORMAL}}"
}

helpDescriptionCallback() {
  helpDescription
  echo
}

helpLongDescriptionCallback() {
  helpDescription
  echo

  echo -e "${__HELP_TITLE}List of needed variables:${__HELP_NORMAL}"
  stringOrNone "$(helpVariables)"

  echo -e "${__HELP_TITLE}List of dependencies:${__HELP_NORMAL}"
  stringOrNone "$(dependencies)"
}
