setup() {
  case "${TEST_SHELL}" in
    "zsh")
      shell="zsh -f"
      ;;
    *)
      shell="bash --noprofile --norc"
      ;;
  esac
}

@test "no to proceed" {
  run_scenario '
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "n\n"
exp_prompt'
}

@test "pkgx not installed" {
  run_scenario '
which pkgx|1|pkgx not found
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "pkgx is not installed"
exp "User action required: Install pkgx"
exp_prompt
'
}

@test "pkgx is too old" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|0|
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "pkgx is not installed"
exp "User action required: Install pkgx"
exp_prompt
'
}

@test "pkgx is missing dev integration" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|1|dev not found
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "pkgx is not shell integrated"
exp "User action required: Activate pkgx shell integration"
exp_prompt
'
}

@test "pkgx is missing env integration" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|1|env not found
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "pkgx is not shell integrated"
exp "User action required: Activate pkgx shell integration"
exp_prompt
'
}

@test "folder is not a repository" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|1|
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Repository is not available"
exp "User action required: Clone gaggle/perfect-elixir repository"
exp_prompt
'
}

@test "remote is not expected repository" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|git@foo.git
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Repository is not available"
exp "User action required: Clone gaggle/perfect-elixir repository"
exp_prompt
'
}

@test "no erl so should activate dev" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|git@github.com:gaggle/perfect-elixir.git
command -v erl|1|
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Development environment not active"
exp "User action required: Activate developer environment"
exp_prompt
'
}

@test "no elixir so should activate dev" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|git@github.com:gaggle/perfect-elixir.git
command -v erl|0|bin/erl
command -v elixir|1|
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Development environment not active"
exp "User action required: Activate developer environment"
exp_prompt
'
}

@test "no psql so should activate dev" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|git@github.com:gaggle/perfect-elixir.git
command -v erl|0|bin/erl
command -v elixir|0|bin/elixir
command -v psql|1|
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Development environment not active"
exp "User action required: Activate developer environment"
exp_prompt
'
}

@test "good to go with git remote" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|git@github.com:gaggle/perfect-elixir.git
command -v erl|0|bin/erl
command -v elixir|0|bin/elixir
command -v psql|0|bin/psql
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Bootstrapping is done"
exp "bin/doctor"
exp_prompt
'
}

@test "good to go with https remote" {
  run_scenario '
which pkgx|0|/usr/bin/pkgx
_pkgx_is_old|1|
which dev|0|dev()
which env|0|env()
_is_git_folder|0|
git config --get remote.origin.url|0|https://github.com/gaggle/perfect-elixir.git
command -v erl|0|bin/erl
command -v elixir|0|bin/elixir
command -v psql|0|bin/psql
' \ '
send "source bin/bootstrap\n"
exp "Ok to proceed?"
send "y\n"
exp "Bootstrapping is done"
exp "bin/doctor"
exp_prompt
'
}

run_scenario() {
  local mock=$(cat <<< "$1" | test/mcall configure)
  local scenario=$(cat <<< "$2")

  run test/run-expect-scenario "$scenario" "$shell" "export MOCK=$mock && source test/mcall"
  if [ "$DEBUG" == "true" ]; then
    echo "$output" >&3
  fi
  [ "$status" -eq 0 ]
  MOCK=$mock test/mcall assert
  rm $mock
}
