load run-scenario-helper.bash

@test "simple check" {
  run_color_scenario color=true \
  'check "check" "echo echo; true" "n/a"' \
  "${ASCII_BULLET} check${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "simple check w. debug" {
  run_color_scenario color=true \
  'DEBUG=true check "check" "echo echo; true" "n/a"' \
  "$ASCII_BULLET check${RESET}${GREEN_BRIGHT}${BOLD} $ASCII_CHECKMARK${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}" \
  "${FAINT}DEBUG: ${RESET}echo${RESET}"
}

@test "simple silent check w. debug" {
  run_color_scenario color=true \
  'DEBUG=true check "check" "true" "n/a"' \
  "$ASCII_BULLET check${RESET}${GREEN_BRIGHT}${BOLD} $ASCII_CHECKMARK${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: true${RESET}" \
  "${FAINT}DEBUG: ${RESET}"
}

@test "failing check" {
  run_color_scenario color=true \
  'check "check" "echo echo; false" "remedy"' \
  "${ASCII_BULLET} check${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${RED}echo${RESET}" \
  "${RESET}" \
  "${YELLOW}Suggested remedy: ${RESET}${YELLOW}${BOLD}remedy${RESET}" \
  "${YELLOW}(Copied to clipboard)${RESET}"
}

@test "failing check w. debug" {
  run_color_scenario color=true \
  'DEBUG=true check "check" "echo echo; false" "remedy"' \
  "$ASCII_BULLET check${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${RED}echo${RESET}" \
  "${FAINT}DEBUG: ${RESET}Done with 'check', exited 1${RESET}" \
  "${RESET}" \
  "${YELLOW}Suggested remedy: ${RESET}${YELLOW}${BOLD}remedy${RESET}" \
  "${YELLOW}(Copied to clipboard)${RESET}"
}

@test "failing silent check" {
  run_color_scenario color=true \
  'check "check" "false" "remedy"' \
  "$ASCII_BULLET check${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}false${RESET}" \
  "${RESET}" \
  "${YELLOW}Suggested remedy: ${RESET}${YELLOW}${BOLD}remedy${RESET}" \
  "${YELLOW}(Copied to clipboard)${RESET}"
}
