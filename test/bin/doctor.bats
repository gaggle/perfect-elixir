setup() {
  load "$(pwd)/test/test_helper"
}

mock() {
  local mock_name
  mock_name=$(mock_create)
  mock_set_side_effect "$mock_name" "$1"
  echo "$mock_name"
}

assert_mock_called_with() {
  if [ "$(mock_get_call_args "$1")" != "$2" ]; then
    fail "Expected mock call with '$2', but got '$(mock_get_call_args "$1")'"
  fi
}

@test "displays help message when --help is used" {
  run bin/doctor --help
  assert_success
  assert_line "Usage: bin/doctor [options]"
}

@test "advise to reinitialize devenv if pkgx is absent" {
  export _WHICH="$(mock "case $1 in pkgx) exit 1;; esac")"

  run bin/doctor

  assert_failure
  assert_line "Suggested remedy: dev off; dev || source bin/bootstrap"
  assert_mock_called_with "$_WHICH" "pkgx"
}
