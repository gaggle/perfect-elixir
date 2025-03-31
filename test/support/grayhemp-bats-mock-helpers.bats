setup() {
  load "$(pwd)/test/test_helper"
}

@test "stub_command executes side effect and logs call" {
  stub=$(stub_command foo "echo 'foo executed'")

  run $stub arg1
  assert_success
  assert_output "foo executed"
}

@test "stub_command fails when no command name is provided" {
  run stub_command
  assert_failure
  assert_output "Error: command name is required"
}

@test "stub_command logs all calls" {
  stub=$(stub_command foo)

  run $stub arg1
  run $stub arg2

  run list_stub_calls
  assert_success
  assert_output "foo arg1
foo arg2"
}

@test "stub_command_case accepts case statements" {
  stub=$(stub_command_case foo "arg1) echo 'arg1 case'" "arg2) echo 'arg2 case'; exit 2")

  run $stub arg1
  assert_success
  assert_output "arg1 case"

  run $stub arg2
  assert_failure 2
  assert_output "arg2 case"

  run $stub arg3
  assert_failure
}

@test "stub_command_case logs multiple calls" {
  stub=$(stub_command_case "foo" "arg1) echo 'arg1 case'")

  run $stub arg1
  run list_stub_calls
  assert_success
  assert_output "foo arg1"

  run $stub arg1
  run list_stub_calls
  assert_output "foo arg1
foo arg1"
}

@test "stub_command_case with no configuration exits 1" {
  # (because it's supposed to have cases, and its an error to hit an unspecified case)
  stub=$(stub_command_case foo)

  run $stub
  assert_failure
  assert_equal "$output" ""
}

@test "list_stub_calls returns empty string if no calls were made" {
  run list_stub_calls
  assert_success
  assert_output ""
}

@test "assert_stub_call_order succeeds with exact call order match" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg2
  run $stub arg3

  run assert_stub_call_order "foo arg1" "foo arg2" "foo arg3"
  assert_success
}

@test "assert_stub_call_order succeeds with non-consecutive calls that appear in order" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg2
  run $stub arg3
  run $stub arg4

  run assert_stub_call_order "foo arg1" "foo arg3"
  assert_success
}

@test "assert_stub_call_order succeeds if no calls are expected and the call log is empty" {
  run assert_stub_call_order
  assert_success
}

@test "assert_stub_call_order fails with incorrect call order" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg2
  run $stub arg3

  run assert_stub_call_order "foo arg2" "foo arg1"
  assert_failure
}

@test "assert_stub_call_order fails if expecting missing call" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg2

  run assert_stub_call_order "foo arg1" "foo arg3"
  assert_failure
}

@test "assert_stub_call_order fails if calls are expected but log is empty" {
  run assert_stub_call_order "foo arg1"
  assert_failure
}

@test "assert_stub_call_order handles single call" {
  stub=$(stub_command foo)
  run $stub arg1

  run assert_stub_call_order "foo arg1"
  assert_success
}

@test "assert_stub_call_order handles multiple identical calls" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg1
  run $stub arg1

  run assert_stub_call_order "foo arg1" "foo arg1" "foo arg1"
  assert_success
}

@test "assert_stub_call_order outputs the full call log when it fails" {
  stub=$(stub_command foo)
  run $stub arg1
  run $stub arg2

  run assert_stub_call_order "foo arg2" "foo arg1"
  assert_failure
  assert_output 'assert_stub_call_order failed: expected sequence "foo arg2 foo arg1" not found in call log:
foo arg1
foo arg2'
}
