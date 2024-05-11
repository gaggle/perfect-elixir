load run-scenario-helper.bash

s='echo -n ">"'  # start
e='echo -n "<"'  # end

@test "pads text" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  "$s; _pad 'ham' 10; $e" \
  ">ham       <"

  run_color_scenario color=true 'source bin/.shhelpers' \
  "$s; _pad 'bacon' 10; $e" \
  ">bacon     <"
}

@test "leftpads text" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  "$s; _leftpad 'ham' 10; $e" \
  ">       ham<"

  run_color_scenario color=true \
  "$s; _leftpad 'bacon' 10; $e" \
  ">     bacon<"
}

@test "clamps around text if text is shorter than padding" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  "$s; _pad 'ham' 1; $e" \
  ">ham<"

  run_color_scenario color=true 'source bin/.shhelpers' \
  "$s; _leftpad 'ham' 1; $e" \
  ">ham<"
}

@test "padding works with errexit & nounset, and they are preserved after running" {
  run_color_scenario color=true 'source bin/.shhelpers; set -eu' \
  "$s; _pad 'foo' 4; $e; set -o | grep -E \"errexit.*on|nounset.*on\"" \
  ">foo <" \
  "errexit" \
  "nounset"
}
