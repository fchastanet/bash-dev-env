#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - runs commands periodically"
}

helpLongDescription() {
  helpDescription
  echo
  echo "Anacron can be used to execute commands periodically,"
  echo "with a frequency specified in days. Unlike cron(8),"
  echo "it does not assume that the machine is running continuously."
  echo "Hence, it can be used on machines that aren't running 24 hours"
  echo "a day, to control daily, weekly, and monthly jobs that are"
  echo "usually controlled by cron."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}anacron${__RESET_COLOR}"
  echo -e "is the daemon that completes cron for computers that are not on at all times, check out"
  echo -e "some examples:${__HELP_EXAMPLE}"
  find /etc/cron.{hourly,daily,weekly,monthly,yearly} -type f 2>/dev/null |
    grep -v 0anacron | grep -v '.placeholder' | sed -E -e 's/^/  - /'
  echo -e "${__RESET_COLOR}"
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    anacron
}

testInstall() {
  Assert::commandExists anacron
}

configure() {
  sudo groupadd anacron || true
  sudo adduser "${USERNAME}" anacron || true
  sudo chown root:anacron /var/spool/anacron/
  sudo chmod 755 /var/spool/anacron/
}

testConfigure() {
  local -i failures=0
  anacron -T || {
    Log::displayError "anacron format not valid"
    ((failures++))
  }

  # check if user is part of anacron group
  groups "${USERNAME}" | grep -E ' anacron' || {
    Log::displayError "${USERNAME} is not part of anacron group"
    ((failures++))
  }
  Assert::dirExists /var/spool/anacron/ "root" "anacron" || ((failures++))

  if ! sudo service anacron start; then
    Log::displayError "unable to execute anacron service with user ${USERNAME}"
    ((failures++))
  fi

  return "${failures}"
}
