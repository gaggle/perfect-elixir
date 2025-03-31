#!/usr/bin/env bats

stub_bats() {
  export _BATS=$(stub_command_case bats \
  "'-Tr -j 4 test/bin/example.bats') exit 0" \
  "'-Tr -j 4 test/bin/example.bats test/bin/example.bats') exit 0" \
  "'-Tr -j 4 test') exit 0")
}

stub_nproc() {
  export _NPROC=$(stub_command_case nproc "*) echo 4")
}

setup() {
  load "$(pwd)/test/test_helper"
  export TEST_FILE="test/bin/example.bats"
  stub_bats
  stub_nproc
}

@test "displays help message when -h or --help is used" {
  run bin/bats-test -h
  assert_success
  assert_line "Usage:"

  run bin/bats-test --help
  assert_success
  assert_line "Usage:"
}

@test "fails with unknown option" {
  run bin/bats-test --unknown
  assert_failure
  assert_line "Unknown option: --unknown"
}

@test "runs all tests when no path is provided" {
  run bin/bats-test
  assert_success
  assert_line "Running all tests (via 4 parallel jobs)..."
  assert_stub_call_order "bats -Tr -j 4 test"
}

@test "runs specific test file when path is provided" {
 run bin/bats-test "$TEST_FILE"
 assert_success
 assert_line "Running $TEST_FILE (via 4 parallel jobs)..."
 assert_stub_call_order "bats -Tr -j 4 $TEST_FILE"
}

@test "runs multiple specified test paths" {
 run bin/bats-test "$TEST_FILE" "$TEST_FILE"
 assert_success
 assert_line "Running $TEST_FILE $TEST_FILE (via 4 parallel jobs)..."
 assert_stub_call_order "bats -Tr -j 4 $TEST_FILE $TEST_FILE"
}
