setup() {
  load "$(pwd)/.bats_deps/bats-core/bats-support/load"
  load "$(pwd)/.bats_deps/bats-core/bats-assert/load"
  load "$(pwd)/.bats_deps/jasonkarns/bats-mock/stub"
}

@test "displays help message when --help is used" {
  run bin/doctor --help
  assert_success
  assert_line "Usage: bin/doctor [options]"
}

@test "advise to reinitialize devenv if pkgx is absent" {
  stub which "pkgx : exit 1"

  run bin/doctor

  assert_failure
  assert_line "Suggested remedy: dev off; dev || source bin/bootstrap"

  unstub which
}
