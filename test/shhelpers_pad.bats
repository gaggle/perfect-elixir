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

s='echo -n ">"'  # start
e='echo -n "<"'  # end

@test "pads text" {
  run_scenario color=true \
  "$s; _pad 'ham' 10; $e" \
  ">ham       <"

  run_scenario color=true \
  "$s; _pad 'bacon' 10; $e" \
  ">bacon     <"
}

@test "leftpads text" {
  run_scenario color=true \
  "$s; _leftpad 'ham' 10; $e" \
  ">       ham<"

  run_scenario color=true \
  "$s; _leftpad 'bacon' 10; $e" \
  ">     bacon<"
}

@test "clamps around text if text is shorter than padding" {
  run_scenario color=true \
  "$s; _pad 'ham' 1; $e" \
  ">ham<"

  run_scenario color=true \
  "$s; _leftpad 'ham' 1; $e" \
  ">ham<"
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
