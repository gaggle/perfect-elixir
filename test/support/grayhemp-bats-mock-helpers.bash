stub_command() {
  local cmd_name=$1; shift
  if [ -z "$cmd_name" ]; then
    echo "Error: command name is required" >&2
    return 1
  fi
  local side_effect="echo \"$cmd_name \$*\" >> \"$BATS_TEST_TMPDIR/stub_calls.log\"
$*"

  local mock_name=$(mock_create)
  mock_set_side_effect "$mock_name" "$side_effect"

  echo "$mock_name"
}

stub_command_case() {
  local cmd_name=$1; shift
  local cases_code=$(for el in "$@"; do printf '%s;;\n  ' "$el"; done)
  local case_statement="case \"\$*\" in
  $cases_code*) exit 1;;
esac"
  stub_command "$cmd_name" "$case_statement"
}

list_stub_calls() {
  cat "$BATS_TEST_TMPDIR/stub_calls.log" 2>/dev/null || echo ""
}
