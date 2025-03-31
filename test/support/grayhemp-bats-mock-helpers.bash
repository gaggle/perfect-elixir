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

assert_stub_call_order() {
  local expected=("$@");
  local i=0
  local log_lines=()
  mapfile -t log_lines < <(list_stub_calls | sed '/^$/d')
  # ↑ `sed` drops empty lines, this is so if no expected calls are provided
  #   AND the call order log is empty, the comparisons below succeeds.

  for line in "${log_lines[@]}"; do
    if [ "${expected[$i]}" = "$line" ]; then
      ((i++)) || :
      # ↑ The `|| :` construct is because the expressions can return 0,
      #   and that evaluates as false, and if `set -e` is enabled
      #   that would cause the script to exit. Oh Bash, you rascal ❤️
      [ "$i" -eq "${#expected[@]}" ] && break
    fi
  done

  if [ "$i" -ne "${#expected[@]}" ]; then
    echo "assert_stub_call_order failed: expected sequence \"${expected[*]}\" not found in call log:" >&2
    list_stub_calls >&2
    return 1
  fi
}
