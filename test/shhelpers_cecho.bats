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

@test "styles" {
  run_scenario color=true \
  'cecho "test " -b "bold " -f "faint " -i "italic " -u "underline"' \
  'test ^[[0m^[[1mbold ^[[0m^[[2mfaint ^[[0m^[[3mitalic ^[[0m^[[4munderline^[[0m'
}

@test "colors" {
  run_scenario color=true \
  'cecho "test " --black "black " --red "red " --green "green " --yellow "yellow " --blue "blue " --magenta "magenta " --cyan "cyan " --white "white"' \
  'test ^[[0m^[[30mblack ^[[0m^[[31mred ^[[0m^[[32mgreen ^[[0m^[[33myellow ^[[0m^[[34mblue ^[[0m^[[35mmagenta ^[[0m^[[36mcyan ^[[0m^[[37mwhite^[[0m'
}

@test "bright colors" {
  run_scenario color=true \
  'cecho "test " -B --black "black " -B --red "red " -B --green "green " -B --yellow "yellow " -B --blue "blue " -B --magenta "magenta " -B --cyan "cyan " -B --white "white"' \
  'test ^[[0m^[[90mblack ^[[0m^[[91mred ^[[0m^[[92mgreen ^[[0m^[[93myellow ^[[0m^[[94mblue ^[[0m^[[95mmagenta ^[[0m^[[96mcyan ^[[0m^[[97mwhite^[[0m'
}

@test "bundled args" {
  run_scenario color=true \
  'cecho "test " -bi "bundled " -Bu "args"' \
  'test ^[[0m^[[1m^[[3mbundled ^[[0m^[[4margs^[[0m'
}

@test "multiple styles and colors" {
  run_scenario color=true \
  'cecho "test " --green "green " -u "underlined" " and " -b "bold"' \
  'test ^[[0m^[[32mgreen ^[[0m^[[4munderlined^[[0m and ^[[0m^[[1mbold^[[0m'
}

@test "multiple styles and colors without explicit segment separators" {
  run_scenario color=true \
  'cecho "test " --blue "blue, " --yellow "yellow, " "and " --green "green text"' \
  'test ^[[0m^[[34mblue, ^[[0m^[[33myellow, ^[[0mand ^[[0m^[[32mgreen text^[[0m'
}

@test "no newline at the end" {
  run_scenario color=true \
  'cecho -n "test " --cyan "no new"; echo "line"' \
  'test ^[[0m^[[36mno new^[[0mline'
}

@test "works with empty string regardless of styles, colors, other segments, etc." {
  run_scenario color=true \
  'cecho ""' \
  '^[[0m'

  run_scenario color=true \
  'cecho --white ""' \
  '^[[0m'

  run_scenario color=true \
  'cecho -b "#" "" -b "#"' \
  '^[[1m#^[[0m^[[0m^[[1m#^[[0m'

  run_scenario color=true \
  'cecho -b "#" --cyan "" -b "#"' \
  '^[[1m#^[[0m^[[36m^[[0m^[[1m#^[[0m'
}

@test "help message" {
  run_scenario color=false \
  'cecho --help' \
  'cecho: echo text with color and style' \
  'Usage: cecho [options] <text>' \
  'Example: cecho --red -b "Hello World"'
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
