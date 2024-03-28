%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "skip software configuration" \
    --alt "--skip-config" \
    --alt "--skip-configure" \
    --alt "--skip-configuration" \
    --variable-name "SKIP_CONFIGURE" \
    --function-name optionSkipConfigureFunction

  Options::generateOption \
    --help "skip software installation" \
    --alt "--skip-install" \
    --alt "--skip-installation" \
    --variable-name "SKIP_INSTALL" \
    --function-name optionSkipInstallFunction

  Options::generateOption \
    --help "skip software installation test" \
    --alt "--skip-test" \
    --alt "--skip-tests" \
    --variable-name "SKIP_TEST" \
    --function-name optionSkipTestsFunction

  Options::generateOption \
    --help "install the software requested without resolving dependencies" \
    --alt "--skip-dependencies" \
    --alt "--skip-deps" \
    --variable-name "SKIP_DEPENDENCIES" \
    --function-name optionSkipDependenciesFunction

)
options+=(
  optionSkipConfigureFunction
  optionSkipInstallFunction
  optionSkipTestsFunction
  optionSkipDependenciesFunction
)
%

export SKIP_INSTALL
export SKIP_CONFIGURE
export SKIP_TEST
export SKIP_DEPENDENCIES
