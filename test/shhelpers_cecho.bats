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

ESC="^["
RESET="${ESC}[0m"

@test "styles" {
  run_scenario color=true \
  'cecho "test " -b "bold " -f "faint " -i "italic " -u "underline"' \
  "test ${RESET}^[[1mbold ${RESET}^[[2mfaint ${RESET}^[[3mitalic ${RESET}^[[4munderline${RESET}"
}

@test "colors" {
  run_scenario color=true \
  'cecho "test " --black "black " --red "red " --green "green " --yellow "yellow " --blue "blue " --magenta "magenta " --cyan "cyan " --white "white"' \
  "test ${RESET}^[[30mblack ${RESET}^[[31mred ${RESET}^[[32mgreen ${RESET}^[[33myellow ${RESET}^[[34mblue ${RESET}^[[35mmagenta ${RESET}^[[36mcyan ${RESET}^[[37mwhite${RESET}"
}

@test "bright colors" {
  run_scenario color=true \
  'cecho "test " -B --black "black " -B --red "red " -B --green "green " -B --yellow "yellow " -B --blue "blue " -B --magenta "magenta " -B --cyan "cyan " -B --white "white"' \
  "test ${RESET}^[[90mblack ${RESET}^[[91mred ${RESET}^[[92mgreen ${RESET}^[[93myellow ${RESET}^[[94mblue ${RESET}^[[95mmagenta ${RESET}^[[96mcyan ${RESET}^[[97mwhite${RESET}"
}

@test "bundled args" {
  run_scenario color=true \
  'cecho "test " -bi "bundled " -Bu "args"' \
  "test ${RESET}^[[1m^[[3mbundled ${RESET}^[[4margs${RESET}"
}

@test "multiple styles and colors" {
  run_scenario color=true \
  'cecho "test " --green "green " -u "underlined" " and " -b "bold"' \
  "test ${RESET}^[[32mgreen ${RESET}^[[4munderlined${RESET} and ${RESET}^[[1mbold${RESET}"
}

@test "multiple styles and colors without explicit segment separators" {
  run_scenario color=true \
  'cecho "test " --blue "blue, " --yellow "yellow, " "and " --green "green text"' \
  "test ${RESET}^[[34mblue, ${RESET}^[[33myellow, ${RESET}and ${RESET}^[[32mgreen text${RESET}"
}

@test "no newline at the end" {
  run_scenario color=true \
  'cecho -n "test " --cyan "no new"; echo "line"' \
  "test ${RESET}^[[36mno new${RESET}line"
}

@test "works with empty string regardless of styles, colors, other segments, etc." {
  run_scenario color=true \
  'cecho ""' \
  "${RESET}"

  run_scenario color=true \
  'cecho --white ""' \
  "${RESET}"

  run_scenario color=true \
  'cecho -b "#" "" -b "#"' \
  "^[[1m#${RESET}${RESET}^[[1m#${RESET}"

  run_scenario color=true \
  'cecho -b "#" --cyan "" -b "#"' \
  "^[[1m#${RESET}^[[36m${RESET}^[[1m#${RESET}"
}

@test "help message" {
  run_scenario color=false \
  'cecho --help' \
  "cecho: echo text with color and style" \
  "Usage: cecho [options] <text>" \
  "Example: cecho --red -b \"Hello World\""
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
