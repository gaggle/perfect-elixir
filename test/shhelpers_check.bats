setup() {
  case "${TEST_SHELL}" in
    "zsh")
      shell="zsh -f"
      ;;
    *)
      shell="bash --noprofile --norc"
      ;;
  esac
}

ASCII_BULLET='M-bM-^@M-"'
ASCII_CHECKMARK='M-bM-^\M-^S'
ESC="^["
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
FAINT="${ESC}[2m"
GREEN="${ESC}[32m"
GREEN_BRIGHT="${ESC}[92m"
RED="${ESC}[31m"
YELLOW="${ESC}[33m"
RED_BRIGHT="${ESC}[91m"

@test "simple check" {
  run_scenario color=true \
  'check "check" "echo echo; true" "n/a"' \
  "${ASCII_BULLET} check${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "simple check w. debug" {
  run_scenario color=true \
  'DEBUG=true check "check" "echo echo; true" "n/a"' \
  "$ASCII_BULLET check${RESET}${GREEN_BRIGHT}${BOLD} $ASCII_CHECKMARK${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}" \
  "${FAINT}DEBUG: ${RESET}echo${RESET}"
}

@test "simple silent check w. debug" {
  run_scenario color=true \
  'DEBUG=true check "check" "true" "n/a"' \
  "$ASCII_BULLET check${RESET}${GREEN_BRIGHT}${BOLD} $ASCII_CHECKMARK${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: true${RESET}" \
  "${FAINT}DEBUG: ${RESET}"
}

@test "failing check" {
  run_scenario color=true \
  'check "check" "echo echo; false" "remedy"' \
  "${ASCII_BULLET} check${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${RED}echo${RESET}" \
  "${RESET}" \
  "${YELLOW}Suggested remedy: ${RESET}${YELLOW}${BOLD}remedy${RESET}" \
  "${YELLOW}(Copied to clipboard)${RESET}"
}

@test "failing check w. debug" {
  run_scenario color=true \
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
  run_scenario color=true \
  'check "check" "false" "remedy"' \
  "$ASCII_BULLET check${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}false${RESET}" \
  "${RESET}" \
  "${YELLOW}Suggested remedy: ${RESET}${YELLOW}${BOLD}remedy${RESET}" \
  "${YELLOW}(Copied to clipboard)${RESET}"
}

run_scenario() {
  local color_flag=${1#*=}
  local escaped_input=$(sed 's/"/\\"/g' <<< "$2")
  local expectations=("${@:2}")  # Use array to capture all arguments
  unset expectations[0]  # Remove the first element which is input

  local scenario="send \"$escaped_input\n\"
exp_prompt
send \"FORCE_COLOR=$color_flag; ($escaped_input) | cat -v\n\""

  for expect in "${expectations[@]}"; do
    local escaped_expect=$(sed 's/\\/\\\\/g; s/\[/\\[/g; s/\]/\\]/g; s/"/\\"/g' <<< "$expect")
    scenario+="
exp -exact \"$escaped_expect\""
  done

  scenario+="
exp_prompt"

  run test/run-expect-scenario "$scenario" "$shell" "source bin/.shhelpers"
  if [ "$DEBUG" == "true" ]; then
    echo "$output" >&3
  fi
  [ "$status" -eq 0 ]
}
