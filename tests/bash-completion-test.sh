#!/bin/bash -e
set -o pipefail

SCRIPT="$1"

. "$SCRIPT"

declare -A ZYPPER_OUTPUT
COMP_WORDBREAKS=$'\t\n"><=;|&(:'"'"

zypper_test_stub() {
	local IFS=' '
	echo -n "${ZYPPER_OUTPUT["$*"]}"
}
__ZYPPER_TEST_STUB=zypper_test_stub

TESTFAIL() {
	echo -e "FAILED: ${FUNCNAME[1]}\n\t$1"
	return 1
}

stub_for_output() {
	local output="$1"
	shift

	local IFS=' '
	local args="$*"

	output=$(sed '
		s/^[[:blank:]]*|//
		s/|[[:blank:]]*$//
		s/\\n/\n/g
		s/\\r/\r/g
		s/\\t/\t/g
	' <<<"$output")

	ZYPPER_OUTPUT["$args"]="$output"
}

global_options() {
	local output='
		|\t--before-section
		|
		|  Global Options:
		|\t--long-short, -w\t\tLong and short.
		|\t--long\t\tLong.
		|\t--apostrophe-in-desc\t\tDescription'\''s apostrophe should cause no issue.
		|
		|     Heading:
		|\t--wrapping-description\tDescription wraps around
		|\t\t\t\tto next line.
		|\t--long-short-placeholder, -A <PH>\tAbc xyz.
		|\t--long-placeholder <ph>\tAbc xyz.
		|\t\t\t\tUppercase on a line by itself.
		|\t--colon-description\t\tColon in description (here: it is)
		|    \t   \t  --spaces-and-tabs
		|
		|  Commands:
		'

	local expected=(
		--long-short
		--long
		--apostrophe-in-desc
		--wrapping-description
		--long-short-placeholder
		--long-placeholder
		--colon-description
		--spaces-and-tabs
	)

	stub_for_output "$output" -q -h
	stub_for_output "$output" -q help

	COMP_CWORD=1
	COMP_WORDS=(zypper '')

	_zypper || true

	if [ ${#COMPREPLY[@]} -ne ${#expected[@]} ]; then
		TESTFAIL "Expected: ${expected[*]}\n\t  Actual: ${COMPREPLY[*]}"
	fi

	for ((i=0; i<${#COMPREPLY[@]}; i++)); do
		if [ ! "${COMPREPLY[$i]}" = "${expected[$i]}" ]; then
			TESTFAIL "Expected: ${expected[*]}\n\t  Actual: ${COMPREPLY[*]}"
		fi
	done
}

global_options
