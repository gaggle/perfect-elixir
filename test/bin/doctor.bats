# shellcheck disable=SC2120 # <- functions do get called with args, but dynamically

stub_which() {
  export _WHICH=$(stub_command_case which "$@" \
  "pkgx) echo /bin/pkgx" \
  "erl) echo .pkgx/erl" \
  "elixir) echo .pkgx/elixir" \
  "stat) echo .pkgx/stat")
}

stub_pgrep() {
  export _PGREP=$(stub_command_case pgrep "$@" "'-f bin/postgres') echo 12345")
}

stub_psql() {
  export _PSQL=$(stub_command_case psql "$@" \
  "'-U postgres -c \q') exit 0" \
  "'-U postgres -lqt') echo 'my_app_dev  | postgres | UTF8 '")
}

stub_mix() {
  export _MIX=$(stub_command_case mix "$@" \
  "archive) echo '* hex-2.1.1
Archives installed at: /Users/gaggle/.mix/archives'" \
  "deps) echo 'ok'")
}

stub_batsman() {
  export _BATSMAN=$(stub_command_case batsman "$@" "list) echo 'bats-core/bats-assert v2.1.0 (GitHub release) 78fa631d
  bats-core/bats-support v0.3.0 (GitHub release) 24a72e14
  grayhemp/bats-mock v1.0-beta.1 (GitHub release) ac1a4475'")
}


setup() {
  load "$(pwd)/test/test_helper"
  stub_which
  stub_pgrep
  stub_psql
  stub_mix
  stub_batsman
}

@test "displays help message when --help is used" {
  run bin/doctor --help
  assert_success
  assert_line "Usage: bin/doctor [options]"
}

@test "reports healthy system (all stubs are by default configured for success)" {
  run bin/doctor
  assert_success
  assert_line "✓ System is healthy & ready"
}

@test "executes all stubs in their expected order" {
  run bin/doctor
  assert_equal "$(list_stub_calls)" "which pkgx
which erl
which elixir
which stat
pgrep -f bin/postgres
psql -U postgres -c \\q
mix archive
mix deps
psql -U postgres -lqt
batsman list
batsman list"
}

@test "verifies Elixir is available before running mix" {
  run bin/doctor
  assert_stub_call_order "which elixir" "mix deps"
}

dyn_test_data=(
  'reinitialize devenv if pkgx is absent
stub_which "pkgx) exit 1"
dev off; dev || source bin/bootstrap'
  'reinitialize devenv if erl is absent
stub_which "erl) exit 1"
dev off; dev || source bin/bootstrap'
  'reinitialize devenv if elixir is absent
stub_which "elixir) exit 1"
dev off; dev || source bin/bootstrap'
  'toggle the devenv if stat is not provided by pkgx
stub_which "stat) echo /usr/bin/stat"
dev off; dev'
  'start the database server if pgrep cant connect
stub_pgrep "'\''-f bin/postgres'\'') exit 1"
bin/db start'
  'create a user when psql fails to connect
stub_psql "'\''-U postgres -c \q'\'') exit 2"
createuser -d postgres'
  'install hex if hex is not installed locally
stub_mix "archive) echo \"Archives installed at\""
mix local.hex --force'
  'run mix setup if mix dependencies are unavailable
stub_mix "deps) echo \"the dependency is not available\""
mix setup'
  'run mix setup if mix dependencies are outdated
stub_mix "deps) echo \"the dependency is out of date\""
mix setup'
  'run ecto if the database is missing
stub_psql "'\''-U postgres -lqt'\'') echo \"\""
mix ecto.create'
  'advise download Bats helpers if theyre missing
stub_batsman "list) echo \"\""
bin/batsman get-release bats-core/bats-assert v2.1.0 && bin/batsman get-release bats-core/bats-support v0.3.0 && bin/batsman get-release grayhemp/bats-mock v1.0-beta.1'
)

function dyn_test() {
  eval "$1"
  run bin/doctor
  assert_failure
  assert_line "$2"
}

for el in "${dyn_test_data[@]}"; do
  mapfile -t parts <<< "$el"
  test_name="${parts[0]}"
  stub="${parts[1]}"
  remedy="${parts[2]}"
  bats_test_function --description "advise to $test_name" -- dyn_test "$stub" "Suggested remedy: $remedy"
done
