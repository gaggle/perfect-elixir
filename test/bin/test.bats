# shellcheck disable=SC2120 # <- functions should be callable with args
stub_mix() {
  export _MIX=$(stub_command_case mix "$@" "test) echo 'Running mix tests...'")
}

stub_bats_test() {
  export _BATS_TEST=$(stub_command_case bats-test "$@" "'') echo 'Running bats tests...'")
}

setup() {
  load "$(pwd)/test/test_helper"
  stub_mix
  stub_bats_test
}

@test "runs mix tests and bats tests in sequence" {
  run bin/test
  assert_success
  assert_line "Running mix tests..."
  assert_line "Running bats tests..."
}

@test "propagates mix test failures" {
  stub_mix "test) exit 1"
  run bin/test
  assert_failure
}

@test "propagates bats-test failures" {
  stub_bats_test "'') exit 1"
  run bin/test
  assert_failure
}
