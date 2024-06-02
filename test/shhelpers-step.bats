load run-scenario-helper.bash

@test "simple step" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'step "step" "echo echo; true"' \
  "${ASCII_BULLET} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "simple step w. debug" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'DEBUG=true step "step" "echo echo; true"' \
  "${ASCII_BULLET} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}" \
  "${FAINT}DEBUG: ${RESET}echo${RESET}"
}

@test "step works with errexit & nounset, and they are preserved after running" {
  run_color_scenario color=true 'source bin/.shhelpers; set -eu' \
  'step "step" "echo echo; true"; set -o | grep -E "errexit.*on|nounset.*on"' \
  "${ASCII_BULLET} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}" \
  "errexit" \
  "nounset"
}

@test "failing step" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'step "step" "echo echo; false"' \
  "${ASCII_BULLET} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}"
}

@test "failing step w. debug" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'DEBUG=true step "step" "echo echo; false"' \
  "${ASCII_BULLET} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${RED}echo${RESET}" \
  "${FAINT}DEBUG: ${RESET}Done with 'step', exited 1${RESET}"
}

@test "step w. output" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'step --with-output "step" "echo echo; true"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "step w. output & debug" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'DEBUG=true step --with-output "step" "echo echo; true"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}"
}

@test "failing step w. output" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'step --with-output "step" "echo echo; false"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}"
}

#@test "failing step w. output & debug" {
#  run_color_scenario color=true 'source bin/.shhelpers' \
#  'DEBUG=true step --with-output "step" "echo echo; false"' \
#  "${ASCII_BULLET} step:${RESET}" \
#  "echo" \
#  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
#  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
#  "${FAINT}DEBUG: ${RESET}Done with 'step', exited 1${RESET}"
#}