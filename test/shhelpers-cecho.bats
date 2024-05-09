load run-scenario-helper.bash

@test "styles" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " -b "bold " -f "faint " -i "italic " -u "underline"' \
  "test ${RESET}^[[1mbold ${RESET}^[[2mfaint ${RESET}^[[3mitalic ${RESET}^[[4munderline${RESET}"
}

@test "colors" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " --black "black " --red "red " --green "green " --yellow "yellow " --blue "blue " --magenta "magenta " --cyan "cyan " --white "white"' \
  "test ${RESET}^[[30mblack ${RESET}^[[31mred ${RESET}^[[32mgreen ${RESET}^[[33myellow ${RESET}^[[34mblue ${RESET}^[[35mmagenta ${RESET}^[[36mcyan ${RESET}^[[37mwhite${RESET}"
}

@test "bright colors" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " -B --black "black " -B --red "red " -B --green "green " -B --yellow "yellow " -B --blue "blue " -B --magenta "magenta " -B --cyan "cyan " -B --white "white"' \
  "test ${RESET}^[[90mblack ${RESET}^[[91mred ${RESET}^[[92mgreen ${RESET}^[[93myellow ${RESET}^[[94mblue ${RESET}^[[95mmagenta ${RESET}^[[96mcyan ${RESET}^[[97mwhite${RESET}"
}

@test "bundled args" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " -bi "bundled " -Bu "args"' \
  "test ${RESET}^[[1m^[[3mbundled ${RESET}^[[4margs${RESET}"
}

@test "multiple styles and colors" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " --green "green " -u "underlined" " and " -b "bold"' \
  "test ${RESET}^[[32mgreen ${RESET}^[[4munderlined${RESET} and ${RESET}^[[1mbold${RESET}"
}

@test "multiple styles and colors without explicit segment separators" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho "test " --blue "blue, " --yellow "yellow, " "and " --green "green text"' \
  "test ${RESET}^[[34mblue, ${RESET}^[[33myellow, ${RESET}and ${RESET}^[[32mgreen text${RESET}"
}

@test "no newline at the end" {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho -n "test " --cyan "no new"; echo "line"' \
  "test ${RESET}^[[36mno new${RESET}line"
}

@test "works with empty string regardless of styles, colors, other segments, etc." {
  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho ""' \
  "${RESET}"

  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho --white ""' \
  "${RESET}"

  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho -b "#" "" -b "#"' \
  "^[[1m#${RESET}${RESET}^[[1m#${RESET}"

  run_color_scenario color=true 'source bin/.shhelpers' \
  'cecho -b "#" --cyan "" -b "#"' \
  "^[[1m#${RESET}^[[36m${RESET}^[[1m#${RESET}"
}

@test "help message" {
  run_color_scenario color=false 'source bin/.shhelpers' \
  'cecho --help' \
  "cecho: echo text with color and style" \
  "Usage: cecho [options] <text>" \
  "Example: cecho --red -b \"Hello World\""
}
