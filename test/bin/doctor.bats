setup() {
  load "$(pwd)/.bats_deps/bats-core/bats-support/load"
  load "$(pwd)/.bats_deps/bats-core/bats-assert/load"
  load "$(pwd)/.bats_deps/grayhemp/bats-mock/src/bats-mock"
}

@test "displays help message when --help is used" {
  run bin/doctor --help
  assert_success
  assert_line "Usage: bin/doctor [options]"
}

@test "advise to reinitialize devenv if pkgx is absent" {
  export _WHICH="$(mock_create)"
  mock_set_side_effect "$_WHICH" "case $1 in pkgx) exit 1;; esac"

  run bin/doctor

  assert_failure
  assert_line "Suggested remedy: dev off; dev || source bin/bootstrap"
  [[ "$(mock_get_call_args $_WHICH)" = pkgx ]]
}
