#!/usr/bin/env bats

setup() {
	. "get_mdr_all_langs.bash"
}

teardown() {
  :
}

function invoking_exists_command_without_arguments { #@test
  echo "# run exists_command" >&3
	run exists_command 
  echo -e "#\ttesting return code equals 1" >&3
	[[ "$status" -eq 1 ]]
}

function invoking_exists_command_with_non_existing_command { #@test
  echo "# run exists_command wgetfff" >&3
	run exists_command wgetfff
  echo -e "#\ttesting return code equals 1" >&3
	[[ "$status" -eq 1 ]]
  echo -e "#\ttesting output is empty" >&3
  [[ -z "$output" ]]
}

function invoking_exists_command_with_existing_command { #@test
  echo "# run exists_command wget" >&3
	run exists_command wget
  echo -e "#\ttesting return code equals 0" >&3
	[[ "$status" -eq 0 ]]
  echo -e "#\ttesting output contains wget" >&3
	[[ "$output" =~ .*"wget".* ]]
  echo -e "#\ttesting if command exists and is executable" >&3
  [[ -x "$output" ]]
}

function invoking_cleanup { #@test
  echo "# run cleanup" >&3
	run cleanup 
  echo -e "#\ttesting return code equals 0" >&3
	[[ "$status" -eq 0 ]]
}
