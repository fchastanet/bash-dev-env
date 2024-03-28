%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="installCommand"
declare help="Install or update softwares"
declare longDescription="""
Install or update softwares (kube, aws, composer, node, ...),
configure Home environnement (git config, kube, motd, ssh, dns, ...) and check configuration
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.profile.options.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.skip.options.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.prepareExport.option.tpl)"

%
Options::generateCommand "${options[@]}"
%

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
