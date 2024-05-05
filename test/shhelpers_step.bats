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
ASCII_DOWN_RIGHT_ARROW='M-bM-^FM-3'
ESC="^["
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
FAINT="${ESC}[2m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED_BRIGHT="${ESC}[91m"
GREEN_BRIGHT="${ESC}[92m"

@test "simple step" {
  run_scenario color=true \
  'step "step" "echo echo; true"' \
  "${ASCII_BULLET} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "simple step w. debug" {
  run_scenario color=true \
  'DEBUG=true step "step" "echo echo; true"' \
  "${ASCII_BULLET} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}" \
  "${FAINT}DEBUG: ${RESET}echo${RESET}"
}

@test "failing step" {
  run_scenario color=true \
  'step "step" "echo echo; false"' \
  "${ASCII_BULLET} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}"
}

@test "failing step w. debug" {
  run_scenario color=true \
  'DEBUG=true step "step" "echo echo; false"' \
  "${ASCII_BULLET} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${RED}echo${RESET}" \
  "${FAINT}DEBUG: ${RESET}Done with 'step', exited 1${RESET}"
}

@test "step w. output" {
  run_scenario color=true \
  'step --with-output "step" "echo echo; true"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}"
}

@test "step w. output & debug" {
  run_scenario color=true \
  'DEBUG=true step --with-output "step" "echo echo; true"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${GREEN_BRIGHT}${BOLD} ${ASCII_CHECKMARK}${RESET}" \
  "${FAINT}DEBUG: ${RESET}> Executed: echo echo; true${RESET}"
}

@test "failing step w. output" {
  run_scenario color=true \
  'step --with-output "step" "echo echo; false"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}"
}

@test "failing step w. output & debug" {
  run_scenario color=true \
  'DEBUG=true step --with-output "step" "echo echo; false"' \
  "${ASCII_BULLET} step:${RESET}" \
  "echo" \
  "${FAINT}${ASCII_DOWN_RIGHT_ARROW} step${RESET}${RED_BRIGHT}${BOLD} x${RESET}" \
  "${RED}> Executed: ${RESET}${RED}${BOLD}echo echo; false${RESET}" \
  "${FAINT}DEBUG: ${RESET}Done with 'step', exited 1${RESET}"
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