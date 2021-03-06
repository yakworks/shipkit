#!/bin/bash
# shellcheck disable=SC1000-SC9999
############
#
# Motivation to rewrite a simple alternative to doctoc: How Much Do You Trust That Package? Understanding The Software Supply Chain https://www.youtube.com/watch?v=fnELtqE6mMM
#
# Attribution: this include includes prework [done by meleu](https://gist.github.com/meleu/57867f4a01ede1bd730f14b2f018ae89) and I developed the way doctoc interacts with markdown files
#
# Generates a Table of Contents getting a markdown file as first input.
# second input is optional and allows you to select minlevel
#
# Inspiration for this script:
# https://medium.com/@acrodriguez/one-liner-to-generate-a-markdown-toc-f5292112fd14

# The list of invalid chars is probably incomplete, but is good enough for my
# current needs.
# Got the list from:
# https://github.com/thlorenz/anchor-markdown-header/blob/56f77a232ab1915106ad1746b99333bf83ee32a2/anchor-markdown-header.js#L25
INVALID_CHARS="'[]/?!:\`.,()*\";{}+=<>~$|#@&–—"

# default minimum level for table of contents (TOC) headers
DEFMINLEVEL=2
DEFMAXLEVEL=3
# min header level to be a TOC entry; setting default value for a BASH variable -> src https://jaduks.livejournal.com/7934.html
MINLEVEL=${2:-$DEFMINLEVEL}
MAXLEVEL=${3:-$DEFMAXLEVEL}

LC_CTYPE=C && LANG=C

check_arg1_file() {

    # src https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
    if [ -z "$1" ]; then
        echo "Error. No argument found. Put as argument a file.md"
        exit 1
    fi

    [[ ! -f "$1" ]] && echo "Error. File not found" && exit

}

check_arg2_minlevel() {

    [[ $MINLEVEL -lt 1 ]] && echo Error in script && echo Description: minlevel variable should be equal or greater than 1 && exit

    local level=$MINLEVEL
    while [[ $(grep -E "^#{$level} " "$1" | wc -l) -le 1 ]]; do
        level=$(($level+1))
    done
    if [[ $MINLEVEL -ne $level ]]; then
        echo -e "\nnote: detected all headers (maybe except 1) in level $level, switching to that level of headers to fill table of contents"
    fi
    MINLEVEL=$level

}

toc() {

    local line
    local level
    local title
    local anchor
    local output

    while IFS='' read -r line || [[ -n "$line" ]]; do
        level="$(echo "$line" | sed -E 's/(#+).*/\1/; s/#/  /g; s/^  //')"
        title="$(echo "$line" | sed -E 's/^#+ //')"
        # tr does not do OK the lowercase for non ascii chars, add sed to pipeline -> src https://stackoverflow.com/questions/13381746/tr-upper-lower-with-cyrillic-text
        anchor="$(echo "$title" | tr '[:upper:] ' '[:lower:]-' | sed 's/[[:upper:]]*/\L&/' | tr -d "$INVALID_CHARS")"

        # check new line introduced is not duplicated, if is duplicated, introduce a number at the end
        #   copying doctoc behavior
        temp_output=$output"$level- [$title](#$anchor)\n"
        counter=1
        while true; do
            nlines="$(echo -e $temp_output | wc -l)"
            duplines="$(echo -e $temp_output | sort | uniq | wc -l)"
            if [ $nlines = $duplines ]; then
                break
            fi
            temp_output=$output"$level- [$title](#$anchor-$counter)\n"
            counter=$(($counter+1))
        done

        output="$temp_output"

    # grep: filter header candidates to be included in toc
    # sed: remove the ignored headers (case: minlevel greater than one) to avoid unnecessary spacing later in level variable assignment
    done <<< "$(grep -E "^#{${MINLEVEL},${MAXLEVEL}} " "$1" | tr -d '\r' | sed "s/^#\{$(($MINLEVEL-1))\}//g")"

    # when in toc we have two `--` quit one
    output="$(echo "$output" | sed 's/--*/-/g')"

    echo "$output"

}

insert() {

    local toc_text="$2"
    local appname='doctoc.sh'
    # inspired in doctoc lines
    local start_toc='<!-- TOC -->'
    local info_toc='<!-- DO NOT EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->'
    local end_toc='<!-- \/TOC -->'

    toc_block="$start_toc\n$info_toc\n**Table of Contents**\n\n$toc_text\n$end_toc"

    # temporary replace of '/' (confused with separator of substitutions) and '&' (confused with match regex symbol) to run the special sed command
    utext_ampersand="id8234923000230gzz"
    utext_slash="id9992384923423gzz"
    toc_block="$(echo "$toc_block" | sed "s,\&,$utext_ampersand,g")"
    toc_block="$(echo "$toc_block" | sed "s,\/,$utext_slash,g")"

    # search multiline toc block -> https://stackoverflow.com/questions/2686147/how-to-find-patterns-across-multiple-lines-using-grep/2686705
    # grep color for debugging -> https://superuser.com/questions/914856/grep-display-all-output-but-highlight-search-matches
    if grep --color=always -Pzl "(?s)$start_toc.*\n.*$end_toc" $1 ; then
        echo -e "\n  Updated content of $appname block in $1 succesfully\n"
        # src https://askubuntu.com/questions/533221/how-do-i-replace-multiple-lines-with-single-word-in-fileinplace-replace
        sed -i ":a;N;\$!ba;s/$start_toc.*$end_toc/$toc_block/g" $1
    else
        echo -e "\n  Created $appname block in $1 succesfully\n"
        sed -i 1i"$toc_block" "$1"
        echo $toc_block
    fi
    echo "sed on $1"

    # sed -i ":a;N;\$!ba;s/$start_toc.*$end_toc/$toc_block/g" "$1"
    # undo symbol replacements
    sed -i "s,$utext_ampersand,\&,g" "$1"
    sed -i "s,$utext_slash,\/,g" "$1"

}

main() {

    check_arg1_file "$1"
    # pass text removing the code blocks which can contain `#` symbols (comments, bash shebang, etc.) -> thanks https://stackoverflow.com/questions/6945621/using-sed-to-remove-a-block-of-text/6945788#6945788
    tmp_file="tmp_file_182341491498139889838948932898998899"
    sed '/```/,/```/d' $1 > "$tmp_file"
    check_arg2_minlevel "$tmp_file"
    toc_text=$(toc "$tmp_file")
    rm "$tmp_file"

    insert "$1" "$toc_text"

}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
