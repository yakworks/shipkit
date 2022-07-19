#!/usr/bin/env gawk -f
# SPDX-License-Identifier: MIT

function debug(msg) {
    if (debug_enable) {
        relative FILENAME
        printf("%3s %-10s (%s): %s\n", FNR, basename(FILENAME), fidx, msg) > debug_file
        # print (FNR) " : " basename(FILENAME) " : " msg # > debug_file
    }
}

function init_file(){
    FILE_DOC = ""
    fname = FILENAME
    # default filename_title will the relative name and is used when processing multiple files
    filename_title = rel_filename(fname, base_dir)
    fidx++
    debug("FILENAME: " FILENAME " base_dir: " base_dir " fidx:" fidx " fname: " fname " file_title: " file_title)
    add_toc_file_entry(filename_title)
}

function reset_docblock_arrays(){
    split("", comment_lines)
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
    return "* __" text "__"
}

function add_toc_file_entry(name){
    if(MULTI_FILE){
        add_toc_item_entry(name, "")
    }
}
function add_toc_item(name){
    _level = 1
    if(MULTI_FILE) _level = 2
    _ident_spaces = nchars(" ", (_level-1)*2)
    add_toc_item_entry(name, _ident_spaces)
}

function add_toc_item_entry(name, ident){
    if(!ident) ident=""
    _liItem = sprintf(format_li, render_toc_link(name))
    tocContent = concat(tocContent, ident _liItem, "\n")
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
        file_description = "\n" join(description_lines, "\n")
    }
}

# docblock is for functions. renders it out
function render_docblock(func_name) {
    debug("→ render_docblock")
    debug("→ → func_name: [" func_name "]")

    _lines[1] = renderFunctionHeading(func_name)
    _lines[2] = ""
    lcnt=3
    _dlnum = length(description_lines)
    if (_dlnum) {
        for(i=1; i <= _dlnum; i++) {
            _dlval = description_lines[i]
            debug("→ → desc _line val : [" i  _dlval  "]")
            if( _lines[lcnt-1] ~ pattern_empty_line && _dlval ~ pattern_empty_line){
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
        exBlock = sprintf(format_code, indentor(docblock_example_lines, 2))
        push(_lines, exBlock)
    }

    render_args(docblock_args, _lines, format_arg, ARG_TITLE)

    if (docblock_noargs) {
        push(_lines, "_Function has no arguments._\n")
    }

    render_args(docblock_sets, _lines, format_arg, VARS_TITLE)
    render_args(docblock_exitcodes, _lines, format_exitcode, EXIT_TITLE)

    render_li_items(docblock_stdins, _lines, "%s", INPUT_TITLE)
    render_li_items(docblock_stdouts, _lines, "%s", OUTPUT_TITLE)
    render_li_items(docblock_sees, _lines, "", SEE_TITLE)

    _func_docs = join(_lines, "\n")
    # concat to the main doc
    DOC = DOC "\n"
    if(FUNCTION_DIVIDER) DOC = DOC FUNCTION_DIVIDER "\n"
    DOC = concat(DOC, _func_docs)

    # add function to the TOC
    add_toc_item(func_name)
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

            item = sprintf(format_li_ident, rendered)
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
    _len = length(args_array)
    if (_len) {
        push(lines, renderFunctionSubHeading(title) "\n")
        for(i=1; i<=_len; i++) {
            varItem = args_array[i]
            split(varItem, splitArr, " ")
            varName = splitArr[1]
            # debug("varItem [" varItem "] splitArr [" splitArr[2] "] ")
            idx = index(varItem, " ")
            # rest of varItem with out the "$1 " argnum
            varDesc = varType = substr(varItem, idx+1)
            # debug("varDesc [" varDesc "] ")
            if(match(varType, pattern_known_types)){
                # debug("========== pattern_known_types hit [" varType "] ")
                sub(pattern_known_types, "", varDesc)
                split(varType, splitArr, " ")
                varType = splitArr[1]
            }
            else if(match(varType, pattern_args_types)) {
                # debug("-------------- pattern_args_types hit [" varType "] ")
                sub(pattern_args_types, "", varDesc)
                split(varType, splitArr, ")")
                varType = splitArr[1]
                sub(/^[ \t]*-[ \t]*/, "", varType)
                sub(/\(/, "", varType)
            }
            else {
                debug("************ no type  [" varType "] ")
                sub(/^[ \t]*-[ \t]*/, "", varDesc)
                varType = "any"
            }
            # debug("varName [" varName "] varType [" varType "] varDesc [" varDesc "]")

            # hack if its the exit code format then use the other one as there is no type
            if(title == EXIT_TITLE)
                result = sprintf(format_exitcode, varName, varDesc)
            else
                result = sprintf(printFormat, varName, varType, varDesc)

            result = sprintf(format_li_ident, result)
            if (i == length(args_array)) result = result "\n"
            push(lines, result)
        }
    }
}

function doDescriptionSub(line) {
    # debug("→ → doDescriptionSub")
    # tag
    sub(/^[ \t]*# @description[ \t]*/, "", line)
    # remove hashes on empty comment line
    sub(/^[ \t]*##*[ \t]*/, "", line)
    # remove the #--- seperator
    sub(/^#-{3,}[ \t]*/, "", line)
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

function render_multi_header(){
    print "# " MAIN_TITLE
    if (TOC) {
        print renderHeading(2, TOC_TITLE) "\n\n" tocContent "\n"
    }
}

function render_file_doc(){
    debug("→ render_file_doc {")
    debug("→ → file_title:       [" file_title "]")
    debug("→ → file_brief:       [" file_brief "]")
    debug("→ → file_description: [" file_description "]")
    debug("→ render_file_doc }")
    debug("→ VARS ")
    debug("→ TOC " TOC)

    FILE_DOC = ""
    if(!file_title) file_title = filename_title
    if (file_title != "") {
        FILE_DOC = renderHeading(1, file_title "\n")
        if (file_brief != "") {
            FILE_DOC = FILE_DOC "\n" file_brief "\n"
        }
        if (file_description != "") {
            FILE_DOC = FILE_DOC "\n" renderHeading(2, DESC_TITLE) "\n" file_description "\n"
        }
    }

    if (!is_multi_file && TOC && tocContent) {
        FILE_DOC = FILE_DOC "\n" renderHeading(2, TOC_TITLE) "\n\n" tocContent "\n"
    }

    MAIN_DOC = MAIN_DOC FILE_DOC DOC "\n"
    # reset
    file_title = ""
    file_brief = ""
    file_description = ""
    DOC = ""
    FILE_DOC = ""
    # print MAIN_DOC
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

# function concatLF(src, text) {
#     return concat(src, text, "/n")
# }

function push(arr, value) {
    arr[length(arr)+1] = value
}

# joins an array, assumes index starts with 1
function join(arr, sep,     _result) {
    _result = arr[1]
    for (i = 2; i <= length(arr); i++) {
        _result = _result sep arr[i]
    }
    return _result
}

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

# ltrim but removes the # comment prefix. chr defaults to # but can pass somethign like * too
function comment_trim(s, commentChar)  {
    if(!commentChar) commentChar = "#"
    sub(/^[ \t]+/, "", s) #remove spaces and tabs first
    sub("^" commentChar "+[ \\t]*", "", s);
    return s
}

# gets a char repeated n times.
# `nchars("x", 2) == "xx"`
function nchars(c, n,       _res){
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
