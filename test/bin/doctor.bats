@test "displays help message when --help is used" {
  run bin/doctor --help
  [ "$status" -eq 0 ]
  echo "$output" | grep -Fq "Usage: bin/doctor [options]"
}
