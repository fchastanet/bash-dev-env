#!/bin/bash

# ensure last command exit code is caught
if [[ ! ${PROMPT_COMMAND} =~ ^LAST_EXIT_CODE=.* ]]; then
  PROMPT_COMMAND="LAST_EXIT_CODE=\$?; ${PROMPT_COMMAND}"
fi

if [[ ! ${PROMPT_COMMAND} =~ __construct_prompt_awesome ]]; then
  # add a ; if needed
  PROMPT_COMMAND="$(echo "${PROMPT_COMMAND:-true}" | sed -r "s/[\t ]*;{0,1}[\t ]*$/;/") __construct_prompt_awesome;"
fi

if [[ "$(type -t __git_ps1 2>/dev/null)" != "function" ]]; then
  return
fi

git_status=""

__fn() {
  if [[ $# != 0 ]]; then
    echo "${git_status}" | grep -c "$1"
  else
    echo "${git_status}" | sed '/^\s*$/d' | wc -l
  fi
}

__modified() {
  __fn "^ M"
}

__added() {
  __fn "^ A"
}

__deleted() {
  __fn "^ D"
}

__renamed() {
  __fn "^ R"
}

__copied() {
  __fn "^ C"
}

__total() {
  __fn
}

__color() {
  local fg="$1"
  local bg="$2"
  if [[ -n "${bg}" ]]; then
    bg=";48;${bg}"
  fi
  printf "\[\e[1;38;%s%sm\]" "${fg}" "${bg}"
}

__add_git_info() {
  if [[ ! -d .git ]]; then
    return 0
  fi
  git_status=$(git status --porcelain 2>/dev/null)

  # colors
  local git_green_fg="2;12;220;12"
  local git_red_fg="2;250;12;12"
  local git_cyan_fg="2;12;220;250"
  local git_yellow_fg="2;240;230;2"
  local git_purple_fg="2;200;66;245"
  local git_gray_fg="2;200;200;200"

  # Color assignments
  local git_modified_clr=${git_yellow_fg}
  local git_added_clr=${git_green_fg}
  local git_deleted_clr=${git_red_fg}
  local git_renamed_clr=${git_purple_fg}
  local git_copied_clr=${git_cyan_fg}
  local git_total_clr=${git_gray_fg}

  local f1=''
  local f2=''
  local f3=''
  local f4=''
  local f5=''
  local f6=''

  local flags="${PS1AW_GIT_INFO}"

  if [[ -n "${flags}" ]]; then
    shopt -s nocasematch
    if [[ "${flags}" =~ "m" ]]; then
      f1=" $(__color "${git_modified_clr}") $(__modified) "
    fi
    if [[ "${flags}" =~ "a" ]]; then
      f2=" $(__color "${git_added_clr}") $(__added) "
    fi
    if [[ "${flags}" =~ "d" ]]; then
      f3=" $(__color "${git_deleted_clr}") $(__deleted) "
    fi
    if [[ "${flags}" =~ "r" ]]; then
      f4=" $(__color "${git_renamed_clr}") $(__renamed) "
    fi
    if [[ "${flags}" =~ "c" ]]; then
      f5=" $(__color "${git_copied_clr}") $(__copied) "
    fi
    if [[ "${flags}" =~ "t" ]]; then
      f6=" $(__color "${git_total_clr}") $(__total) "
    fi
  fi

  PS1+='$(__git_ps1 "'"$(__color "${git_green_fg}") %s"' '"${f1}${f2}${f3}${f4}${f5}${f6}"'\[\e[1;38;2;0;0;0m\] ")'
}

__construct_prompt_1() {
  PS1=''
  __add_git_info
}

__construct_prompt_awesome() {
  local bad_exit_code_bg_color="2;175;25;0"
  local good_exit_code_bg_color="2;110;210;5"
  local bad_exit_code_fg_color="2;255;200;200"
  local good_exit_code_fg_color="2;10;50;12"
  local exit_code_bg_color=${bad_exit_code_bg_color}
  local exit_code_fg_color=${bad_exit_code_fg_color}

  if [[ ${LAST_EXIT_CODE} -eq 0 ]]; then
    exit_code_bg_color=${good_exit_code_bg_color}
    exit_code_fg_color=${good_exit_code_fg_color}
  fi

  local git_green_fg="2;12;220;12"
  local _2_color="2;194;114;39"
  local _3_color="2;255;150;50"
  local _4_color="2;70;70;70"

  local dark_grey="2;24;24;24"

  local reset_color='\[\e[0m\]'

  local _ps1
  _ps1="$(__color "${dark_grey}" "${_2_color}") \u $(__color "${_2_color}" "${_3_color}")"
  local _ps2
  _ps2="$(__color "${dark_grey}" "${_3_color}") \w "
  local _ps1_symbol
  _ps1_symbol="$(__color "${git_green_fg}" "${_4_color}") $ "

  PS1="$(__color "${exit_code_fg_color}" "${exit_code_bg_color}")$(printf "%3s" "${LAST_EXIT_CODE}")$(__color "${exit_code_bg_color}" "${_2_color}")"
  PS1+="${_ps1}${_ps2}$(__color "${_3_color}" "${_4_color}")"
  __add_git_info "${_4_color}"
  PS1+="${_ps1_symbol}"
  PS1+="$(__color "${_4_color}" "${exit_code_bg_color}")$(__color "${exit_code_bg_color}")${reset_color} "
}
