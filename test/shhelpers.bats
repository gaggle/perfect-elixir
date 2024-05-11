load run-scenario-helper.bash

@test "can be sourced" {
  run_scenario '
send "source bin/.shhelpers\n"
exp_prompt
'
}

@test "can be sourced with errexit & nounset" {
  run_scenario '
send "set -eu; \n"
send "source bin/.shhelpers\n"
exp_prompt
send "set -o | grep errexit\n"
exp -re "errexit.*on"
send "set -o | grep nounset\n"
exp -re "nounset.*on"
'
}

@test "fails when executed" {
  run_scenario '
send "bin/.shhelpers\n"
exp "must be sourced, not executed directly"
exp_prompt
'
}
