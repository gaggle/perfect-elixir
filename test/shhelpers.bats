load run_scenario_helper.bash

@test "can be sourced" {
  run_scenario '
send "source bin/.shhelpers\n"
exp_prompt
'
}

@test "can be sourced with -e" {
  run_scenario '
send "set -euo pipefail; \n"
send "source bin/.shhelpers\n"
exp_prompt
'
}

@test "fails when executed" {
  run_scenario '
send "bin/.shhelpers\n"
exp "must be sourced, not executed directly"
exp_prompt
'
}
