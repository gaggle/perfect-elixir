load run-scenario-helper.bash

@test "copies to clipboard" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'echo "\$(expr 1 + 1)" | clipboard; echo "\$(pbpaste)"' \
  "2"
}

@test "clipboard works with errexit & nounset, and they are preserved after running" {
  run_color_scenario color=true 'source bin/.shhelpers; set -eu' \
  'echo "\$(expr 1 + 1)" | clipboard; echo "\$(pbpaste)"; set -o | grep -E "errexit.*on|nounset.*on"' \
  "2" \
  "errexit" \
  "nounset"
}

@test "help message" {
  run_color_scenario color=false 'source bin/.shhelpers' \
  'clipboard --help' \
  "clipboard: copy text to clipboard" \
  "Usage: clipboard [options] <text>" \
  "EXAMPLES" \
  "  $ clipboard foo" \
  "  $ echo foo | clipboard"
}
