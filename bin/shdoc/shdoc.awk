#!/usr/bin/env gawk -f
# SPDX-License-Identifier: MIT
# @include "github_styles.awk"
# @include "utils.awk"

BEGIN {
    if (!style) style = "github"

    if (! hlevel) {
      hlevel = ""
    }
    # starting header level
    if (!START_LEVEL) START_LEVEL = "1"

    # labels for the headings
    DESC_TITLE = "Description"
    TOC_TITLE = "📇 Index"
    EXAMPLE_TITLE = "🔧 Example"
    ARG_TITLE = "🔌 Args"
    VARS_TITLE = "🎯 Variables set"

    SEE_TITLE = "👓 See also"
    OUTPUT_TITLE = "📺 Stdout"
    INPUT_TITLE = "🎮 Stdin"
    EXIT_TITLE = "🔢 Exit Codes"

    FUNCTION_DIVIDER = "---"
    # whether to generate toc, default to true
    if(TOC=="") TOC = "1"
    # TOC = false
    if(ENVIRON["SHDOC_TOC"] == "0") TOC = false

    # greedy is bit like regex "greedy" in that it will doc all functions
    # and will add in any standard comments on the functions
    if(GREEDY=="") GREEDY = "1"

    debug_enable = ENVIRON["SHDOC_DEBUG"] == "1"
    debug_fd = ENVIRON["SHDOC_DEBUG_FD"]
    debug_file = ENVIRON["SHDOC_DEBUG_FILE"]
    if (!debug_fd) debug_fd = 2 # "stderr"
    if (!debug_file) debug_file = "/dev/fd/" debug_fd

    # init the arrays, does a dummy split to create empty arrays
    split("", comment_lines)

    reset_docblock_arrays()
    # some standard indents
    spaces2= "  "
    spaces4= "    "
    code_format = "  ~~~bash\n%s  ~~~\n"
    li_format =   "* %s"
    li_format_ident =   "  " li_format
    arg_format =  "__%s__ (%s): %s"
    exitcode_format =  "__%s__ : %s"

    # --- regex patterns ---
    # only gawk supports the @ patterns
    # knownTypePattern = @/^[ -]*(string|int|integer|number|float|array|list) /
    # typePattern = @/^[ -]*\(\w+\) /
    # know type in format "$1 string some desc", not prefered kept for compatibility
    knownTypePattern = "^[ -]*(string|int|integer|number|float|array|list) "
    # type pattern in format "$1 (string) some desc" or "$1 - (string) some desc"
    typePattern = "^[ -]*\\(\\w+\\) "
    emptyLinePattern = "^[\\s]*$"
    # the master DOC variable
    DOC=""
    debug("================= BEGIN ======================")
    # _="foo"
    # v1=substr(_,match(_,"oo"),RLENGTH)
}

# ONLY RUNS on first file to set base_dir, FILENAME will = "-" if its being piped and this will not run
FILENAME != "-" && !has_base_dir {
  base_dir = basedir(FILENAME)
  has_filename = 1
  has_base_dir = 1
}

# triggered on each file change
fname != FILENAME && has_filename {
  fname = FILENAME
  # default filename_title will the relative name and is used when processing multiple files
  filename_title = rel_filename(fname, base_dir)
  fidx++
  debug("FILENAME: " FILENAME " base_dir: " base_dir " file index:" fidx " fname: " fname " file_title: " file_title)
}

function debug(msg) {
    if (debug_enable) {
        relative FILENAME
        printf("%3s %-10s (%s): %s\n", FNR, basename(FILENAME), fidx, msg) > debug_file
        # print (FNR) " : " basename(FILENAME) " : " msg # > debug_file
    }
}

function reset_docblock_arrays(){
    split("", docblock_args)
    split("", docblock_sets)
    #   split("", docblock_examples)
    # split("", docblock_noargs)
    split("", docblock_stdins)
    split("", docblock_stdouts)
    split("", docblock_exitcodes)
    split("", docblock_sees)

    split("", description_lines)
    split("", docblock_example_lines)
    # docblock_examples = ""
    docblock_noargs = false
}

# function render(type, text) {
#     if(type == "see") {
#         return render_toc_link(text)
#     }
#     styleFrom = styles[style, type, "from"]
#     styleTo = styles[style, type, "to"]
#     return gensub( styleFrom, styleTo, "g", text )
# }

# uses the heading_level and the passed in leve to build the prefix for the headers
# ` headingPrefix(2) -> "##" `
function headingPrefix(level){
    headerPrefix = ""
    useLevel = START_LEVEL + level - 1
    for (i=1;i<=useLevel;i++) headerPrefix = headerPrefix "#"
    return headerPrefix
}

# builds the heading
# ` renderHeading(2, "Foo") -> "## Foo" `
function renderHeading(level, text){
  return headingPrefix(level) " " text
}

function renderFunctionHeading(text) {
    useLevel = 2
    return headingPrefix(useLevel) " " text
}

function renderFunctionSubHeading(text) {
    # useLevel = 3
    # return headingPrefix(useLevel) "* " text
    return "* __" text "__"
}

# renders the toc link
# ` render_toc_link("foo.bar()") == "[foo.bar()](#foobar)" `
function render_toc_link(title) {
    url = title
    if (style == "github") {
        # https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb#L44-L45
        url = tolower(url)
        # remove punctuation (alnum is alphanumeric), keep _ or -
        gsub(/[^[:alnum:] _-]/, "", url)
        # replace space with dash, should never really happen
        gsub(/ /, "-", url)
    }

    return "[" title "](#" url ")"
}

function reset() {
    debug("→ reset()")
    reset_docblock_arrays()
    description = ""
}

function init() {
    debug("→ is_initialized set()")
    is_initialized = 1
}

# sets file_description = description if empty
function handle_file_description() {
    debug("→ handle_file_description")
    if (length(description_lines) && file_description == "") {
        file_description = join(description_lines, "\n")
    }
}

# docblock is for functions. renders it out
function render_docblock(func_name) {
    debug("→ render_docblock")
    debug("→ → func_name: [" func_name "]")
    # debug("→ → description: [" description "]")
    # debug("→ → docblock: [" join(docblock, " ")  "]")
    # debug("→ → comment_lines: [" join(comment_lines, "\n") "]")

    _lines[1] = renderFunctionHeading(func_name)
    _lines[2] = ""
    lcnt=3
    _dlnum = length(description_lines)
    if (_dlnum) {
        for(i=1; i <= _dlnum; i++) {
            _dlval = description_lines[i]
            debug("→ → desc _line val : [" i  _dlval  "]")
            if( _lines[lcnt-1] ~ emptyLinePattern && _dlval ~ emptyLinePattern){
                 debug("2 blank lines, not adding")
            } else{
                _lines[lcnt++] = _dlval
                debug("→ → desc _line added : [" z  description_lines[i] "]")
            }
        }
    }

    if(_lines[lcnt-1] != "") push(_lines,"")

    if (length(docblock_example_lines)) {
        push(_lines, renderFunctionSubHeading(EXAMPLE_TITLE) "\n")
        exBlock = sprintf(code_format, indentor(docblock_example_lines, 2))
        push(_lines, exBlock)
    }

    render_args(docblock_args, _lines, arg_format, ARG_TITLE)

    if (docblock_noargs) {
        push(_lines, "_Function has no arguments._\n")
    }

    render_args(docblock_sets, _lines, arg_format, VARS_TITLE)
    render_args(docblock_exitcodes, _lines, exitcode_format, EXIT_TITLE)

    render_li_items(docblock_stdins, _lines, "%s", INPUT_TITLE)
    render_li_items(docblock_stdouts, _lines, "%s", OUTPUT_TITLE)
    render_li_items(docblock_sees, _lines, "", SEE_TITLE)
    # render_dockblock_section(docblock_stdins, lines, "stdin", INPUT_TITLE)
    # render_dockblock_section(docblock_stdouts, lines, "stdout", OUTPUT_TITLE)

    # render_dockblock_section(docblock_sees, lines, "see", SEE_TITLE)

    _func_docs = join(_lines, "\n")
    # debug("→ → _func_docs: [" _func_docs "]")
    # concat to the main doc
    DOC = concat(DOC, _func_docs)
    # add function to the TOC
    _liItem = sprintf(li_format, render_toc_link(func_name))
    tocContent = concat(tocContent, _liItem, "\n")
    # debug("→ → DOC: [" DOC "]")
    # clean out the line cache
    delete _lines
}

# render the function section (set, exits, stdout, etc..)
function render_li_items(array, lines, printFormat, title){
    if (length(array)) {
        push(lines, renderFunctionSubHeading(title) "\n")
        for(i=1; i<=length(array); i++) {
            ar = array[i]
            if(title == SEE_TITLE)
                rendered = render_toc_link(array[i])
            else
                rendered = sprintf(printFormat, array[i])

            item = sprintf(li_format_ident, rendered)
            # if its last item in array then append the LF
            if (i == length(array)) item = item "\n"
            push(lines, item)
        }
    }
}

# helper to return the matched string
function matcher(text, reggy){
    return substr(text,match(text,reggy),RLENGTH)
}

# renders functions args section
function render_args(args_array, lines, printFormat, title,         idx, varItem, splitArr, varName, varDesc, varType, result){
    if (length(args_array)) {
        push(lines, renderFunctionSubHeading(title) "\n")
        for (i in args_array) {
            varItem = args_array[i]
            split(varItem, splitArr, " ")
            varName = splitArr[1]

            # debug("varItem [" varItem "] splitArr [" splitArr[2] "] ")
            idx = index(varItem, " ")
            # rest of varItem with out the "$1 " argnum
            varDesc = varType = substr(varItem, idx+1)
            # debug("varDesc [" varDesc "] ")
            if(match(varType, knownTypePattern)){
                # debug("========== knownTypePattern hit [" varType "] ")
                sub(knownTypePattern, "", varDesc)
                split(varType, splitArr, " ")
                varType = splitArr[1]
            }
            else if(match(varType, typePattern)) {
                # debug("-------------- typePattern hit [" varType "] ")
                sub(typePattern, "", varDesc)
                split(varType, splitArr, ")")
                varType = splitArr[1]
                sub(/^\s?-\s*/, "", varType)
                sub(/\(/, "", varType)
            }
            else {
                debug("************ no type  [" varType "] ")
                sub(/^\s*-\s*/, "", varDesc)
                varType = "any"
            }
            # debug("varName [" varName "] varType [" varType "] varDesc [" varDesc "]")

            # hack if its the exit code format then use the other one as there is no type
            if(title == EXIT_TITLE)
                result = sprintf(exitcode_format, varName, varDesc)
            else
                result = sprintf(printFormat, varName, varType, varDesc)

            result = sprintf(li_format_ident, result)
            if (i == length(args_array)) result = result "\n"
            push(lines, result)
        }
    }
}

function doDescriptionSub(line) {
    # debug("→ → doDescriptionSub")
    # tag
    sub(/^[[:space:]]*# @description[[:space:]]*/, "", line)
    # remove hashes on empty comment line
    sub(/^\s*##*\s*/, "", line)
    # #--- seperator
    sub(/^#-{3,}\s*/, "", line)

    return line
}

function trackCommentLine(comment){
  if(is_initialized) {
    # if(!commentLines) {
      # commentLines[0] = $0
    # } else {
      # push(commentLines, $0)
    # }
    push(comment_lines, comment)
    # debug("→ ******************** trackCommentLine " $0)
    # debug("→ trackCommentLine " join(commentLines))
  }
}

function start_man_doc() {
    init()
    in_file_header_docs = 1
    is_man_doc = 1
    # commentLines[0] = ""
}

function finish_file_header(){
  handle_file_description()
  reset()
  in_file_header_docs = 0
}

{
    debug("======[" $0 "]======")
}

/^[[:space:]]*# @(internal|ignore)/ {
    debug("→ **** hit on @internal")
    is_internal = 1

    next
}

#=== Man(ish) Based File Headers ===

# there are a few way to indicate we have started the file docs.
# using the @name|file is the original default way
# another is to use ## like hashd.awk uses and we use for the func docs to keep it cleaner.
# license header could come first so we dont want to trigger on that. recomened to keep licence headers simple with https://spdx.dev/ids/
# example:
# ###
# # script_name.sh - some description
/^###*$/ && !is_initialized {
    debug("→ **** hit on first ## for file header docs " )
    start_man_doc()
    next
}

# First line with word is the file_title
# MAN DOC file_title
/^#\s\w+/ && in_file_header_docs && !file_title {
    debug("→ **** hit on MAN DOC file_title [" $0 "]" )
    # if it matches `name - brief`
    if(/^.*\s-\s.*$/){
      didx = index($0, " - ")
      file_title = substr($0, 0, didx-1)
      file_brief = substr($0, didx + 3)
      sub(/^#\s?/, "", file_title)
      debug("→ file_title [" file_title "] file_brief [" file_brief "]")
    } else {
      debug("→ normal file_title")
      sub(/^[[:space:]]*#\s?/, "")
      file_title = $0
    }
    # next line can be
    title_line_num = (NR-1 + 1)
    next
}

# MAN DOC file_title seperator
/^#\s?[=-]{2,}$/ && in_file_header_docs && file_title && !in_description {
    # old if && !is_title_seperator_done && title_line_num == NR-1
    debug("→ **** hit on MAN DOC === separator and Description start ")
    is_title_seperator_done = 1
    in_description = 1
    next
}

# blank line or not a comment resets
/^[^#]*$/ && in_file_header_docs {
    debug("→ **** hit on file_header break line [" $0 "]")
    finish_file_header()
    next
}

# /^#/ && in_file_header_docs {
#     debug("→ file header next # " FILENAME)
# }

#=== TAG Based File Headers ===

# @name|@file TAGS
/^[[:space:]]*# @(name|file|module|filename)/ {
    debug("→ @name|@file")
    sub(/^[[:space:]]*# @(name|file|module|filename) /, "")
    file_title = $0
    init()
    in_file_header_docs = 1
    # start_file_doc()
    next
}
# @brief TAGS
/^[[:space:]]*# @brief/ {
    debug("→ @brief")
    sub(/^[[:space:]]*# @brief /, "")
    file_brief = $0
    next
}

/^[[:space:]]*# @description/ {
    debug("→ **** hit on @description detected")
    in_description = 1
    in_example = 0
    init()
    reset()
}

# function docs start with ##
/^#\s?##*\s?$/ || /^###*\s*\w+.*$/ && is_initialized {
    debug("→ **** hit on ### block description detected")
    in_description = 1
    in_example = 0
    reset()
}

# Example code block
/^[[:space:]]*# @example/ || /^#\s[\`]{3}/ || /^#\s[~]{3}/ && !in_file_header_docs{
    debug("→ @example")
    in_example = 1
    next
}

in_example {
    if (! /^[[:space:]]*#[ ]{1,}/) {
        debug("→ → in_example: leave")
        in_example = 0
    } else {
        # not a `# `, any `# @` thats not a @desc, and any line thats not a `# ` comment
        if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# [\`]{3}/ || /^\s*# [~]{3}/ || /^\s*[^#]/) {
            debug("→ → in_example: leave")
            in_example = 0
        } else {
            debug("→ → in_example: concat" $0)
            sub(/^[[:space:]]*#/, "")
            sub(/^\s*#\s/, "")
            push(docblock_example_lines, $0)
            # docblock_examples = concat(docblock_examples, $0, "\n")
            next
        }
    }
}


in_description {
    debug("→ in_description")
    # any one of these will stop the decription flow.
    # not a `# `, any `# @` thats not a @desc, any `# example` and blank line
    # if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# @example/ || /^\s*# [\`]{3}/ || /^\s*[^#]/ ) {
    if (/^[^[[:space:]]*#]|^[[:space:]]*# @[^d]|^[[:space:]]*[^#]|^[[:space:]]*$/ ) {
        debug("→ → in_description: leave")
        in_description = 0
    }
    else {
        debug("→ calling doDescriptionSub " $0)
        descripLine = doDescriptionSub($0)
        debug("→ pushing descripLine " descripLine)
        push(description_lines, descripLine)
        next
    }
}

/^[[:space:]]*# @arg/ {
    debug("→ @arg")
    sub(/^[[:space:]]*# @arg /, "")

  # debug("→ argsArray" length(docblock_args))
    push(docblock_args, $0)

    next
}

/^[[:space:]]*# @noargs/ {
    debug("→ @noargs")
    docblock_noargs = 1

    next
}

/^[[:space:]]*# @set/ {
    debug("→ @set")
    sub(/^[[:space:]]*# @set /, "")

    push(docblock_sets, $0)

    next
}

/^[[:space:]]*# @(exitcode|errorcode)/ {
    debug("→ @exitcode")
    sub(/^[[:space:]]*# @(exitcode|errorcode) /, "")
    push(docblock_exitcodes, $0)
    next
}

/^[[:space:]]*# @see/ {
    debug("→ @see")
    sub(/[[:space:]]*# @see /, "")
    push(docblock_sees, $0)
    next
}

/^[[:blank:]]*# @stdin/ {
    debug("→ **** hit on @stdin")
    sub(/^[[:space:]]*# @stdin /, "")
    push(docblock_stdins, $0)
    next
}

/^[[:blank:]]*# @(stdout|return)/ {
    debug("→ **** hit on @stdout")
    sub(/^[[:space:]]*# @(stdout|return) /, "")
    push(docblock_stdouts, $0)
    next
}

# grabbing function assumes that your function is formatted some what sane according to best practices.
# use shfmt or one the plugins here and should owrk 99% of time. https://github.com/mvdan/sh#related-projects
# - if its a single line function like `foo(){ echo;}` then it should be one line.
#   in other words a function line shoudld either end with { or }
# - functions should end with a } and empty line.
# - nested functions not supported (not really good practice in bash anyway)
# - herdoc: if the heredoc contains an `}` or line that looks like a fn (because you generate source code or something )
#   then put it in its own function and mark it with @internal or @ignore. or wrap the heredoc in # @ignore-start and # @ignore-end
/^[ \t]*(function([ \t])+)?([a-zA-Z0-9_:\-\.]+)([ \t]*)(\(([ \t]*)\))?[ \t]*\{/ && !in_example{
# /^[ \t]*[[:alnum:]_\:\.]+[ \t]*(\(([ \t]*)\))?[[:blank:]]*\{/ ||
#  /^function / &&
#  !in_example {

# /^[[:blank:]]*(function([[:blank:]])+)?([a-zA-Z0-9_\-:-\\.]+)([[:blank:]]*)(\(([ \t]*)\))?[[:blank:]]*\{/ && !in_example {
    # && (length(docblock) != 0 || description != "") && !in_example
    debug("→ function line [" $0 "]")
    delete functionLines
    if (is_internal) {
        debug("→ → function: it is internal, skipping")
        # is_internal = 0
    } else {
        is_internal = 0
        sub(/^[ \t]*(function[ \t]+)?/, "")
        sub(/\s?\(\s?\).*$/, "")
        func_name = $0
        # TODO make this confiugruable
        func_name = func_name "()"
        render_docblock(func_name)
    }
    in_function_block = 1
    reset()
    next
}

# look for function end
/^\}/ && in_function_block {
    debug("→ **** hit on function end [" $0 "]")
    # looks like function end so mark it
    is_function_end = 1
}

# tracks the function lines
in_function_block {
    debug("→ **** in_function_block ")
    # looks like function end so mark it
    push(functionLines, $0)
    if(is_function_end){
      in_function_block = 0
      was_internal = is_internal
      is_function_end = 0
      is_internal = 0
    }
}


# starts with comment line, if gets here then nothing alse picked it up
# capture it and use it if eager is set to use the docs
/^#\s?/ {
    debug("→ **** hit on comment line [" $0 "]")
    comment = doDescriptionSub($0)
    trackCommentLine(comment)
}

# blank line resets
/^[[:space:]]*?$/ && !in_function_block {
    debug("→ **** hit on blank line RESET [" $0 "]")
    delete commentLines
}

# NOT starting with # comment line
# /^[^#]*$/ {
#     debug("→ **** hit on break line [" $0 "]")
#     handle_file_description();
#     in_file_header_docs = 0
#     reset()
#     next
# }

{
    debug("→ NOT HANDLED [" $0 "]")
}

END {
    debug("→ END {")
    debug("→ → file_title:       [" file_title "]")
    debug("→ → file_brief:       [" file_brief "]")
    debug("→ → file_description: [" file_description "]")
    debug("→ END }")
    debug("→ VARS ")
    debug("→ TOC " TOC)

  if(!file_title) file_title = filename_title
    if (file_title != "") {
        print renderHeading(1, file_title "\n")

        if (file_brief != "") {
            print file_brief "\n"
        }

        if (file_description != "") {
            print renderHeading(2, DESC_TITLE)
            print file_description "\n"

            # debug("============================file_description [" file_description "]")
        }

    }

    if (TOC && tocContent) {
        print renderHeading(2, TOC_TITLE) "\n"
        print tocContent
    }

    print DOC

    ## TODO: add examples section
}


# --- utils.awk ---

# gets file name from full path
function basename(path) {
  sub(".*/", "", path)
  return path
}

# gets the realtive path and file from a base_dir
function rel_filename(fname, base_dir) {
  sub(base_dir, "", fname)
  debug("relative_fname: " fname)
  return fname
}

# returns the path without filename
function basedir(f) {
  sub(/\/[^\/]+$/, "", f)
  return f "/"
}

# concats text to source with a `\n`
# if source is empty then just sets it to text
# `concat("foo", "bar", '\n) == "foo\nbar"` or `concat("", "bar") == "bar"`
function concat(src, text, sep) {
    if (src == "") {
        src = text
    } else {
        src = src sep text
    }
    return src
}

function push(arr, value) {
    arr[length(arr)+1] = value
}

function last(arr){
    return arr[length(arr)]
}

# (the extra space before result is a coding convention to indicate that i is a local variable, not an argument):
function join(arr, sep,     result) {
    for (i = 0; i < length(arr); i++) {
        if (i == 0) {
            result = arr[i]
        } else {
            result = result sep arr[i]
        }
    }
    return result
}

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

# gets a char repeated n times.
# `nchars("x", 2) == "xx"`
function nchars(c, n){
    for(i=0; i<n; i++) _res = _res " ";
    return _res
}


# first it unindents the bring it to  a base line of the the line that has the least
# then will re-indent the number of space specified.
# @arg ext_lines - the array with the lines to indent
# @arg [reindent] - optional.
function indentor(text_lines, reindent) {
    # find a maximum level indent as a starting point
    # find a first non empty line
    start = 0
    max_indent = 0
    for (i = 1; i <= length(text_lines); i++) {
        if (text_lines[i] != "" && start == 0) {
            start = i
        }
        # counts first line spaces
        match(text_lines[i], /^[ ]*/)
        # if matched then RLENGTH is set with the number of chars in the match, IOW the number of indent spaces
        if (RLENGTH > max_indent) max_indent = RLENGTH
    }

    # find a minimum level of indentation
    indent = max_indent
    for (i = start; i <= length(text_lines); i++) {
        match(text_lines[i], /^[ ]*/)
        if (RLENGTH < indent) indent = RLENGTH
    }
    spIdent = ""
    if(reindent)
        for(i=0;i<reindent;i++) spIdent = spIdent " ";

    # remove the minimum level of indentation and re-add the new indentation join text_lines
    for (i = start; i <= length(text_lines); i++) {
        text_lines[i] = substr(text_lines[i], indent + 1)
        if (i == start) {
            _res = spIdent text_lines[i]
        } else {
            _res = _res "\n" spIdent text_lines[i]
        }
    }
    #make sure it ends with lF
    if(!match(_res, /\n$/)) _res = _res "\n"
    return _res
}

#---END UTILS---
