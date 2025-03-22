# shellcheck disable=SC2120 # <- functions should be callable with args
stub_gh() {
  export _GH=$(stub_command_case gh "$@" \
  "'api /repos/owner/repo/commits/v1.0.0 --jq .sha') echo abcdef1234567890" \
  "'release download v1.0.0 -R owner/repo --archive tar.gz -O release.tar.gz') touch release.tar.gz")
}

stub_tar() {
  export _TAR=$(stub_command_case tar "$@" \
  "'-xzf release.tar.gz --strip-components=1') touch stub_tar_content")
}

setup() {
  load "$(pwd)/test/test_helper"

  export BATS_DEPS_DIR
  BATS_DEPS_DIR="$(mktemp -d)"

  stub_gh
  stub_tar
}

teardown() {
  rm -rf "$BATS_DEPS_DIR"
}

@test "shows usage with --help/-h flag" {
  run bin/batsman --help
  assert_success
  assert_line "Bats manager to download helper libraries"
  output_copy=$output

  run bin/batsman -h
  assert_equal "$output" "$output_copy"
}

@test "shows usage when no arguments provided" {
  run bin/batsman
  assert_failure
  assert_line "Bats manager to download helper libraries"
}

@test "get-release downloads the requested release" {
  run bin/batsman get-release owner/repo v1.0.0
  assert_success
  assert_stub_call_order "gh api /repos/owner/repo/commits/v1.0.0 --jq .sha" \
    "gh release download v1.0.0 -R owner/repo --archive tar.gz -O release.tar.gz" \
    "tar -xzf release.tar.gz --strip-components=1"
}

@test "get-release outputs a summary of what it downloaded" {
  run bin/batsman get-release owner/repo v1.0.0
  assert_line "owner/repo v1.0.0 (GitHub release) abcdef12 -> $BATS_DEPS_DIR/owner/repo"
}

@test "get-release without tag uses latest release" {
  stub_gh "'release list -R owner/repo --limit 1 --json tagName --jq .[0].tagName') echo v2.0.0" \
    "'api /repos/owner/repo/commits/v2.0.0 --jq .sha') echo abcdef1234567890" \
    "'release download v2.0.0 -R owner/repo --archive tar.gz -O release.tar.gz') touch release.tar.gz"
  run bin/batsman get-release owner/repo
  assert_success
  assert_line "owner/repo v2.0.0 (GitHub release) abcdef12 -> $BATS_DEPS_DIR/owner/repo"
}

@test "get-release stores a '.bats_version.txt' with metadata" {
  run bin/batsman get-release owner/repo v1.0.0
  assert_equal "$(cat "$BATS_DEPS_DIR/owner/repo/.bats_version.txt")" "owner/repo v1.0.0 (GitHub release) abcdef12"
}

@test "list outputs what has been downloaded" {
  bin/batsman get-release owner/repo v1.0.0
  run bin/batsman list
  assert_output "owner/repo v1.0.0 (GitHub release) abcdef12"
}
