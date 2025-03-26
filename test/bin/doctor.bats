setup() {
  load "$(pwd)/.bats_deps/bats-core/bats-support/load"
  load "$(pwd)/.bats_deps/bats-core/bats-assert/load"
}

@test "displays help message when --help is used" {
  run bin/doctor --help
  assert_success
  assert_line "Usage: bin/doctor [options]"
}
