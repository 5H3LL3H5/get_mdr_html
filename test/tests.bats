#!/usr/bin/env bats
# shellcheck disable=SC1089,SC1083,SC2154


setup() {
  echo "# setup testsuite" >&3
  echo -e "#\tSourcing script get_mdr_all_langs.bash" >&3
	. "get_mdr_all_langs.bash"
  echo -e "#\tPrinting builtin variables" >&3
  echo -e #\tBATS_TEST_FILENAM=$BATS_TEST_FILENAME >&3
  echo -e "#\tBATS_TEST_DIRNAME=$BATS_TEST_DIRNAME" >&3
  echo -e "#\tBATS_TEST_NAMES=$BATS_TEST_NAMES" >&3
  echo -e "#\tBATS_TEST_NAME=$BATS_TEST_NAME" >&3
  echo -e "#\tBATS_TEST_DESCRIPTION=$BATS_TEST_DESCRIPTION" >&3
  echo -e "#\tBATS_TEST_NUMBER=$BATS_TEST_NUMBER" >&3
  echo -e "#\tBATS_SUITE_TEST_NUMBER=$BATS_SUITE_TEST_NUMBER" >&3
  echo -e "#\tBATS_TMPDIR=$BATS_TMPDIR" >&3
  echo -e "#\tBATS_FILE_EXTENSION=$BATS_FILE_EXTENSION" >&3
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
