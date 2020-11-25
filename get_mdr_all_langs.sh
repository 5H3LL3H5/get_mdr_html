#!/usr/bin/env bash
#
# Small script to get content of the european medical device regulation
# Copyright (C) 2020 (christianstenzel@linux.com)
# Permission to copy and modify is granted under the MIT license
# Last revised 2020-11-25
################################################################################


################################################################################
# Print error message to standard out.
# Arguments:
#   1) Optional error message.
# Outputs:
#   Writes timestamped error message to stderr.
################################################################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}


################################################################################
# Center the text with a surrounding border.
# Arguments:
#   1) text to center,
#   2) padding width,
#      if not supplied the current terminal width is used
#   3) left glyph which forms the left border
#   4) optional right glyph which forms the right border,
#      if not given the left glyph is used instead
#   5) optional spacing around the text, default two spaces between text and
#      last glyph of left border and first glyph of right border respectivally
# Outputs:
#   Writes centered message to stdout.
################################################################################
center_text()
{
  local text="${1}"                         # text to center
  local -i padding_width=${2:-$(tput cols)} # if left query the number of cols
                                            # via terminfo database
  local -r left_glyph="${3:-=}"             # glyph to compose the left border
  local -r right_glyph="${4:-$left_glyph}"  # optional glyph to compose the
                                            # right border
  local -i num_of_spaces="${5:-2}"          # spacing around the text

  local -i text_width=${#text}

  # if no text is obmitted use full border style
  local spacing
  if [[ -z "$text" ]];
  then
    text=""
    spacing=""
    num_of_spaces=0
    text_width=0
  else
    # space between the text and borders 
    printf -v spacing "%0.s " $(seq 1 "$num_of_spaces")
  fi

  local border_width=$(( (padding_width - (num_of_spaces * 2) - text_width) / 2 ))
  local left_border
  local right_border
  if (( border_width < 0 ));
  then
    # handle invalid computation of border width but write warning to stdout
    err "Warning: Invalid border width, set to 0."
    border_width=0
  fi
  printf -v left_border "%0.s$left_glyph" $(seq 1 "$border_width")
  printf -v right_border "%0.s$right_glyph" $(seq 1 "$border_width")

  # a side of the border may be longer (e.g. the right border)
  if (( ( padding_width - (num_of_spaces * 2) - text_width ) % 2 != 0 ));
  then
    # the right border has one more character than the left border
    # the text is aligned leftmost
    right_border="${right_border}${right_glyph}"
  fi

  # displays the text in the center of the screen, surrounded by borders.
  printf "${left_border}${spacing}${text}${spacing}${right_border}\n"
}

# readonly variables 
declare -r wget="/usr/bin/wget"
declare -r agent="Mozilla"
declare -r cmds="robots=off"
declare -r logfile="wget-logfile"

# readonly string arrays
declare -r -a langs=( "BG" "ES" "CS" "DA" "DE" "ET" "EL" "EN" "FR" "GA" "HR" "IT" "LV" "LT" "HU" "MT" "NL" "PL" "PT" "RO" "SK" "SL" "FI" "SV" )
declare -r -a uri=( "https://eur-lex.europa.eu/legal-content/" "/TXT/HTML/?uri=CELEX:32017R0745&from=IT#d1e32-108-1" )

for lang in ${langs[@]};
do

  declare url="${uri[0]}$lang${uri[1]}"
  declare -i strlen_url=${#url}
  {
    echo
    center_text ""                                        $((strlen_url + 20))
    center_text "Getting content for language $lang from" $((strlen_url + 20)) ">" "<"
    center_text "$url"                                    $((strlen_url + 20)) ">" "<"
    center_text ""                                        $((strlen_url + 20))
    echo
  } >> "$logfile"


  "$wget"\
    --debug\
    --mirror\
    --convert-links\
    --adjust-extension\
    --span-hosts\
    --backup-converted\
    --page-requisites\
    --no-parent\
    --execute "$cmds"\
    --user-agent="$agent"\
    --append-output="$logfile"\
    "${url}"

done
