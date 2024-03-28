# REQUIRES
if Assert::functionExists initFacade; then
  initFacade
fi
Engine::Config::loadConfig
.INCLUDE "$(dynamicTemplateDir _includes/sudoerFileManagement.tpl)"
