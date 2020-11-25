#!/usr/bin/env bats

setup() {
	. "get_mdr_all_langs.bash"
}

teardown() {
	:
}

@test "exists_command(): Call without arguments" {
	run exists_command 
	[ "$status" -eq 1 ]
}

@test "exists_command(): Call with non-existing command string" {
	run exists_command wgetfff
	[ "$status" -eq 1 ]
}

@test "exists_command(): Call with existing command string" {
	run exists_command wget
	[ "$status" -eq 0 ]
}

@test "cleanup(): Call returns always true" {
	run cleanup 
	[ "$status" -eq 0 ]
}
