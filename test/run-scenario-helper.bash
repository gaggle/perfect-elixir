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

run_color_scenario() {
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

run_mocked_scenario() {
  local mock=$(cat <<< "$1" | test/mcall configure)
  local scenario=$(cat <<< "$2")

  run test/run-expect-scenario "$scenario" "$shell" "export MOCK=$mock && source test/mcall"
  if [ "$DEBUG" == "true" ]; then
    echo "$output" >&3
  fi
  [ "$status" -eq 0 ]
  MOCK=$mock test/mcall assert
  rm $mock
}

run_scenario() {
  local scenario=$(cat <<< "$1")

  run test/run-expect-scenario "$scenario" "$shell"
  if [ "$DEBUG" == "true" ]; then
    echo "$output" >&3
  fi
  [ "$status" -eq 0 ]
}
