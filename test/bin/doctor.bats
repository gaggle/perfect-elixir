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

@test "advise to create a user when psql fails to connect" {
  stub which \
    "pkgx : echo '/bin/pkgx'" \
    "erl : echo '.pkgx/erl'" \
    "elixir : echo '.pkgx/erl'" \
    "stat : echo '.pkgx/erl'"
  stub pgrep "-f bin/postgres : echo '12345'"
  stub psql '-U postgres -c "\q" : echo ""'

  run bin/doctor

  assert_failure
  assert_line "Suggested remedy: createuser -d postgres"

  unstub psql
  unstub pgrep
  unstub which
}
