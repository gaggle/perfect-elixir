#!/bin/sh

if test -n "$VERBOSE" -o -n "$GITHUB_ACTIONS" -a -n "$RUNNER_DEBUG"; then
  set -x
fi

########################################################################### formatting

if [ -t 1 ]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"
tty_underline="$(tty_escape "4;39")"

########################################################################### utils

confirm() {
  msg="${1:-Ok to proceed?}"

  printf "%s%s%s [%sy%s/%sn%s]: " "$tty_bold" "$msg" "$tty_reset" "$tty_green" "$tty_reset" "$tty_red" "$tty_reset"

  if [ "$NONINTERACTIVE" = "true" ]; then
    echo "Y (non-interactive)"
    return 0
  fi

  while true; do
    read -r reply
    case $reply in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer Y or N" ;;
    esac
  done
}

condition() {
  description=$1
  command=$2
  command_output=""

  printf "• %s… " "$description"
  command_output=$(eval "${command}" 2>&1)
  command_exit_code=$?

  printf "%s✓%s\n" "$tty_green" "$tty_reset"

  if [ "$DEBUG" = "true" ]; then
    printf "> Executed: %s%s%s (returned %s%s%s)" "$tty_red" "$command" "$tty_reset" "$tty_red" "$command_exit_code" "$tty_reset"
    printf "%s\n" "$command_output"
  fi
  return $command_exit_code
}

explain() {
  headline_length=$(printf "%s" "$1" | wc -m)
  printf "%s%s%s\n" "$tty_bold" "$1" "$tty_reset"
  printf '%*s\n' "${headline_length}" '' | tr ' ' '─'
  printf "%s\n\n" "$2"
}

fake() {
  eval "val=\"\$fake_$1\""
  if [ -z "$val" ]; then
      return 1
  else
      return 0
  fi
}

return_fake() {
  indirect="fake_$1"
  resolved=$(eval echo "\$$indirect")
  return "$resolved"
}

########################################################################### actions

explain_pkgx() {
  explain "pkgx is not installed" "$(
    cat <<EOS
${tty_bold}pkgx${tty_reset} is the package manager that handles system dependencies, and it is not currently installed.

The installation is simple, and does not require sudo or other forms of elevated permissions.

Read more about pkgx on ${tty_underline}https://pkgx.sh${tty_reset}
EOS
  )"
}

should_install_pkgx() {
  if fake should_install_pkgx; then
    return_fake should_install_pkgx
  else
    if [ ! -f /usr/local/bin/pkgx ]; then
      # Pkgx not installed, so yes install
      return 0
    elif pkgx_is_old >/dev/null 2>&1; then
      # Yes install
      return 0
    else
      # Up-to-date pkgx exists, nothing to install
      return 1
    fi
  fi
}

install_pkgx() {
  if fake install_pkgx; then
    echo "Fake install_pkgx"
    return_fake install_pkgx
  else
    curl -fsS https://pkgx.sh | sh
  fi
}

pkgx_is_old() {
  v="$(/usr/local/bin/pkgx --version || echo pkgx 0)"
  /usr/local/bin/pkgx --silent semverator gt \
    "$(curl -Ssf https://pkgx.sh/VERSION)" \
    "$(echo "$v" | awk '{print $2}')"
}

########################################################################### logic

main() {
  cat <<EOS
  This script sets up your machine for our development environment,
  prompting along the way for any changes it needs to do.
EOS
  if confirm "Ok to proceed?"; then
    if condition "Checking pkgx" "should_install_pkgx"; then
      printf "\n"
      explain_pkgx

      if confirm "Install pkgx?"; then
        install_pkgx
      else
        return 0
      fi
    fi
  else
    return 0
  fi
}

main
