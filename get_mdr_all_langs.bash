#!/usr/bin/env bash
#
# Small script to get content of the european medical device regulation
# Copyright (C) 2020 (christianstenzel@linux.com)
# Permission to copy and modify is granted under the MIT license
# Last revised 2020-11-25
###############################################################################

###############################################################################
# Print error message to stderr.
# Arguments:
#   1) Optional error message.
# Outputs:
#   Writes timestamped error message to stderr.
###############################################################################
err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

###############################################################################
# Checks if command exists.
# Arguments:
#   1) command to check.
# Returns:
#   0 ... command exists on system
#   1 ... command unavailable
# Outputs:
#   If command exists whole path is written to stdout.
###############################################################################
exists_command() {
	command -v "$1"
}

###############################################################################
# Center the text with a surrounding border.
# Arguments:
#   1) text to center,
#   2) padding width,
#      if not supplied the current terminal width is used
#   3) left glyph which forms the left border
#   4) optional right glyph which forms the right border,
#      if not given the left glyph is used instead
#   5) optional spacing around the text, default two spaces between text and
#      last glyph of left border and first glyph of right border respectively
# Outputs:
#   Writes centered message to stdout.
###############################################################################
center_text() {
	local text="${1}"                         # text to center
	local -i padding_width=${2:-$(tput cols)} # if left query the number of cols
	# via terminfo database
	local -r left_glyph="${3:-=}"            # glyph to compose the left border
	local -r right_glyph="${4:-$left_glyph}" # optional glyph to compose the
	# right border
	local -i num_of_spaces="${5:-2}" # spacing around the text

	local -i text_width=0   # text width
	local -i border_width=0 # border width value
	local spacing=""        # string with spaces around text
	local left_border=""    # string filled up with left glyphs
	local right_border=""   # string filled up with right glyphs

	# if no text is omitted use full border style
	if [[ -z "$text" ]]; then
		text=""
		num_of_spaces=0
	else
		text_width=${#text}
		# spaces between the text and borders
		printf -v spacing "%0.s " $(seq 1 "$num_of_spaces")
	fi

	border_width=$(((padding_width - (num_of_spaces * 2) - text_width) / 2))

	# fill up borders with glyphs
	printf -v left_border "%0.s$left_glyph" $(seq 1 "$border_width")
	printf -v right_border "%0.s$right_glyph" $(seq 1 "$border_width")

	# a side of the border may be longer (e.g. the right border)
	if (((padding_width - (num_of_spaces * 2) - text_width) % 2 != 0)); then
		# the right border has one more character than the left border
		# the text is aligned leftmost
		right_border="${right_border}${right_glyph}"
	fi

	# displays the text in the center of the screen, surrounded by borders.
	printf "%s%s%s%s%s\n" \
		"$left_border" "$spacing" "$text" "$spacing" "$right_border"
}

###############################################################################
# Main control function;
# Arguments:
#   None
# Outputs:
#   Writes centered message to stdout.
###############################################################################
main() {
	# check if required commands are installed
	if ! exists_command wget &>/dev/null; then
		err "Command wget not available."
		return 1
	fi

	# readonly variables
	local -r wget=$(exists_command wget)
	local -r agent="Mozilla"
	local -r cmds="robots=off"
	local -r logfile="wget-logfile"

	# readonly string arrays

	# available languages
	# ( "BG" "ES" "CS" "DA" "DE" "ET" "EL" "EN" "FR" "GA" "HR" "IT" "LV" "LT" "HU" "MT" "NL" "PL" "PT" "RO" "SK" "SL" "FI" "SV" )
	local -r -a langs=("DE" "EN")
	local -r -a formats=("HTML" "PDF")
	local -r -a uri=(
		"https://eur-lex.europa.eu/legal-content/"
		"/TXT/"
		"/?uri=CELEX:32017R0745"
		"/?uri=OJ:L:2017:117:FULL")

	# inner loop variables
	local url=""
	local -i strlen_url=0

	# get content
	for ((idx_uri = 2; idx_uri < ${#uri[@]}; ++idx_uri)); do
		for lang in "${langs[@]}"; do
			for format in "${formats[@]}"; do
				url="${uri[0]}$lang${uri[1]}${format[0]}${uri[idx_uri]}"
				strlen_url=${#url}
				{
					echo
					center_text "" $((strlen_url + 20))
					center_text "Getting content for language $lang from" $((strlen_url + 20)) ">" "<"
					center_text "$url" $((strlen_url + 20)) ">" "<"
					center_text "" $((strlen_url + 20))
					echo
				} >>"$logfile"

				"$wget" \
					--debug --mirror --convert-links --adjust-extension --span-hosts --page-requisites --no-parent --execute "$cmds" \
					--user-agent="$agent" \
					--append-output="$logfile" \
					"${url}"

			done # end of iterating through formats
		done  # end of iterating through languages
	done   # end of iterating through uris
}

#                                                                SIGNAL HANDLER
###############################################################################

###############################################################################
# cleanup on exit, signal handler
###############################################################################
cleanup() {
	:
}

#                                                                          BODY
###############################################################################

###############################################################################
# code in here only gets executed if script is run directly on the cmdline
###############################################################################
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then

	# install signal handler
	trap cleanup EXIT

	# pass whole parameter list to main
	if ! main "$@"; then
		err "Execution of script $0 failed."
		exit 1
	fi
fi
