#!/usr/bin/env gawk -f
# SPDX-License-Identifier: MIT

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
    if(TOC=="") TOC = "1"

    debug_enable = ENVIRON["SHDOC_DEBUG"] == "1"
    debug_fd = ENVIRON["SHDOC_DEBUG_FD"]
    debug_file = ENVIRON["SHDOC_DEBUG_FILE"]
    if (!debug_fd) debug_fd = "stderr"
    if (!debug_file) debug_file = "/dev/fd/" debug_fd

    split("", commentLines)

    debug("================= BEGIN ======================")
}

fname != FILENAME {
  fname = FILENAME;
  fidx++
  debug("file index:" fidx " fname: " fname )
}

function debug(msg) {
    if (debug_enable) {
        printf("%-4s %-10s %s\n", FNR, basename(FILENAME), msg);
        # print (FNR) " : " basename(FILENAME) " : " msg # > debug_file
    }
}

function basename(file) {
  sub(".*/", "", file)
  return file
}

function render(type, text) {
    styleFrom = styles[style, type, "from"]
    styleTo = styles[style, type, "to"]
    return gensub( styleFrom, styleTo, "g", text )
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
      gsub(/[^[:alnum:] _-]/, "", url)
      gsub(/ /, "-", url)
    }

    return "[" title "](#" url ")"
}

# fixed indenting for example code blocks
function unindent(text) {
    split(text, text_lines, "\n")

    # find a maximum level indent as a starting point
    # find a first non empty line
    start = 0
    max_indent = 0
    for (i = 0; i < length(text_lines); i++) {
        if (text_lines[i] != "" && start == 0) {
            start = i
        }

        match(text_lines[i], /^[ ]*/)
        if (RLENGTH > max_indent) {
            max_indent = RLENGTH
        }
    }

    # find a minimum level of indentation
    indent = max_indent
    for (i = start; i < length(text_lines); i++) {
        match(text_lines[i], /^[ ]*/)
        if (RLENGTH < indent) {
            indent = RLENGTH
        }
    }

    # remove the minimum level of indentation and join text_lines
    for (i = start; i < length(text_lines); i++) {
        text_lines[i] = substr(text_lines[i], indent + 1)
        if (i == start) {
            result = "  " text_lines[i]
        } else {
            result = result "\n" "  " text_lines[i]
        }
    }

    return result
}

function reset() {
    debug("→ reset()")

    delete docblock
    description = ""
}

function init() {
    debug("→ is_initialized set()")
    is_initialized = 1
}

# sets file_description = description if empty
function handle_file_description() {
    debug("→ handle_file_description")
    if (description && file_description == "") {
        debug("→ → file_description: set to description")
        file_description = description
        return;
    }
}

# concats text to source with a `\n`
# if source is empty then just sets it to text
# `concat("foo", "bar", '\n) == "foo\nbar"` or `concat("", "bar") == "bar"`
function concat(source, text, sep) {
    if (source == "") {
        source = text
    } else {
        source = source sep text
    }
    return source
}

function push(arr, value) {
    arr[length(arr)+1] = value
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

function docblock_set(key, value) {
    docblock[key] = value
}

function docblock_concat(key, value) {
    if (key in docblock) {
        docblock[key] = concat(docblock[key], value, "\n")
    } else {
        docblock[key] = value
    }
}

function docblock_push(key, value) {
    docblock[key][length(docblock[key])+1] = value
}

function render_docblock(func_name, description, docblock) {
    debug("→ render_docblock")
    debug("→ → func_name: [" func_name "]")
    debug("→ → description: [" description "]")
    # debug("→ → docblock: [" join(docblock, " ")  "]")
    debug("→ → commentLines: [" join(commentLines, "\n") "]")

    lines[0] = renderFunctionHeading(func_name)

    if (description != "") {
        push(lines, description)
    }
    spaces2= "  "
    if ("example" in docblock) {
        push(lines, renderFunctionSubHeading(EXAMPLE_TITLE))
        push(lines, "\n" spaces2 render("code", "bash"))
        push(lines, unindent(docblock["example"]))
        push(lines, spaces2 render("/code"))
        push(lines, "")
    }

    if ("arg" in docblock) {
        push(lines, renderFunctionSubHeading(ARG_TITLE) "\n")
        for (i in docblock["arg"]) {
            item = docblock["arg"][i]
            if(match(item, /\(\w+\)/)) {
                # debug("******************** → → arg matched type for item: [" item "]")
                item = render("argN", item)
            } else if(match(item, /[1-9] (string|int|number|array|float)/)) {
                # debug("***** → → arg matched type for know types: [" item "]")
                item = render("argN", item)
            } else {
                # evrything wants to be a string in bash
                item = render("argN_notype", item)
                # item = render("argN", item)
            }
            # item = render("argN", item)
            item = render("arg@", item)
            item = spaces2 render("li", item)
            if (i == length(docblock["arg"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("noargs" in docblock) {
        push(lines, render("i", "Function has no arguments.") "\n")
    }

    if ("set" in docblock) {
        push(lines, renderFunctionSubHeading(VARS_TITLE) "\n")
        for (i in docblock["set"]) {
            item = docblock["set"][i]
            item = render("set", item)
            item = spaces2 render("li", item)
            if (i == length(docblock["set"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("exitcode" in docblock) {
        push(lines, renderFunctionSubHeading(EXIT_TITLE) "\n")
        for (i in docblock["exitcode"]) {
            item = spaces2 render("li", render("exitcode", docblock["exitcode"][i]))
            if (i == length(docblock["exitcode"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("stdin" in docblock) {
        push(lines, renderFunctionSubHeading(INPUT_TITLE) "\n")
        for (i in docblock["stdin"]) {
            item = spaces2 render("li", docblock["stdin"][i])
            if (i == length(docblock["stdin"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("stdout" in docblock) {
        push(lines, renderFunctionSubHeading(OUTPUT_TITLE) "\n")
        for (i in docblock["stdout"]) {
            item = spaces2 render("li", docblock["stdout"][i])
            if (i == length(docblock["stdout"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("see" in docblock) {
        push(lines, renderFunctionSubHeading(SEE_TITLE) "\n")
        for (i in docblock["see"]) {
            item = spaces2 render("li", render_toc_link(docblock["see"][i]))
            if (i == length(docblock["see"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }


    result = join(lines, "\n")
    delete lines
    return result
}

function doDescriptionSub(descripLine) {
  # debug("→ → doDescriptionSub")
  # tag
  sub(/^[[:space:]]*# @description[[:space:]]*/, "", descripLine)
  # remove the hash
  sub(/^[[:space:]]*#\s*/, "", descripLine)
  # empty comment line
  sub(/^#\s*$/, "", descripLine)
  # #--- seperator
  sub(/^[[:space:]]*#-{3,}\s*/, "", descripLine)
  # multiple hashes
  sub(/^[[:space:]]*#\s?#+/, "", descripLine)
  return descripLine
}

function trackCommentLine(commentLine){
  if(is_initialized) {
    # if(!commentLines) {
      # commentLines[0] = $0
    # } else {
      # push(commentLines, $0)
    # }
    push(commentLines, commentLine)
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

{
    debug("line: [" $0 "]")
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
    debug("→ **** hit on MAN DOC file_title " )
    sub(/^[[:space:]]*#\s?/, "")
    file_title = $0
    # next line can be
    title_line_num = (NR-1 + 1)
    next
}

# MAN DOC file_title seperator
/^#\s?=*$/ && in_file_header_docs && file_title && !in_description {
    # old if && !is_title_seperator_done && title_line_num == NR-1
    debug("→ **** hit on MAN DOC === separator and Description start ")
    is_title_seperator_done = 1
    in_description = 1
    next
}

# blank line or not a comment resets
/^[^#]*$/ && in_file_header_docs {
    debug("→ **** hit on file_header break line [" $0 "]")
    handle_file_description()
    reset()
    in_file_header_docs = 0
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
/^\s*#\s?##*$/ && is_initialized {
    debug("→ **** hit on ### block description detected")
    in_description = 1
    in_example = 0
    reset()
}

in_description {
    debug("→ in_description")
    # any one of these will stop the decription flow.
    # not a `# `, any `# @` thats not a @desc, any `# example` and blank line
    # if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# @example/ || /^\s*# [\`]{3}/ || /^\s*[^#]/ ) {
    if (/^[^[[:space:]]*#]|^[[:space:]]*# @[^d]|^[[:space:]]*[^#]|^[[:space:]]*$/) {
        debug("→ → in_description: leave")

        if (!match(description, /\n$/)) {
            description = description "\n"
        }

        in_description = 0

        # handle_file_description()
    } else {
        debug("→ calling doDescriptionSub")
        descripLine = doDescriptionSub($0)
        description = concat(description, descripLine, "\n")
        next
    }
}

/^[[:space:]]*# @example/ {
    debug("→ @example")

    in_example = 1


    next
}

# Example code block
/^\s*# [\`]{3}/ {
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
        if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# [\`]{3}/ || /^\s*[^#]/) {
            debug("→ → in_example: leave")
            in_example = 0
        } else {
            debug("→ → in_example: concat")
            sub(/^[[:space:]]*#/, "")
            sub(/^\s*#\s/, "")

            docblock_concat("example", $0)
            next
        }
    }

}

/^[[:space:]]*# @arg/ {
    debug("→ @arg")
    sub(/^[[:space:]]*# @arg /, "")

    docblock_push("arg", $0)

    next
}

/^[[:space:]]*# @noargs/ {
    debug("→ @noargs")
    docblock["noargs"] = 1

    next
}

/^[[:space:]]*# @set/ {
    debug("→ @set")
    sub(/^[[:space:]]*# @set /, "")

    docblock_push("set", $0)

    next
}

/^[[:space:]]*# @exitcode/ {
    debug("→ @exitcode")
    sub(/^[[:space:]]*# @exitcode /, "")

    docblock_push("exitcode", $0)

    next
}

/^[[:space:]]*# @see/ {
    debug("→ @see")
    sub(/[[:space:]]*# @see /, "")

    docblock_push("see", $0)

    next
}

/^[[:space:]]*# @stdin/ {
    debug("→ **** hit on @stdin")

    sub(/^[[:space:]]*# @stdin /, "")

    docblock_push("stdin", $0)

    next
}

/^[[:space:]]*# @stdout/ {
    debug("→ **** hit on @stdout")

    sub(/^[[:space:]]*# @stdout /, "")

    docblock_push("stdout", $0)

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
/^[ \t]*(function([ \t])+)?([a-zA-Z0-9_\-:-\\.]+)([ \t]*)(\(([ \t]*)\))?[ \t]*\{/ && !in_example{
    # && (length(docblock) != 0 || description != "") && !in_example
    debug("→ function line [" $0 "]")
    delete functionLines
    if (is_internal) {
        debug("→ → function: it is internal, skipping")
        # is_internal = 0
    } else {
        is_internal = 0
        func_name = gensub(\
            /^[ \t]*(function([ \t])+)?([a-zA-Z0-9_\-:-\\.]+)[ \t]*\(.*/, \
            "\\3()", \
            "g" \
        )
        doc = concat(doc, render_docblock(func_name, description, docblock), "\n")
        liItem = render("li", render_toc_link(func_name))
        tocContent = concat(tocContent, liItem, "\n")
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
    commentLine = doDescriptionSub($0)
    trackCommentLine(commentLine)
}

# blank line resets
/^[[:space:]]*?$/ && !in_function_block {
    debug("→ **** hit on blank line RESET [" $0 "]")
    delete commentLines
}

# NOT starting with # comment line
/^[^#]*$/ {
    debug("→ **** hit on break line [" $0 "]")
    handle_file_description();
    in_file_header_docs = 0
    reset()
    next
}

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

    if (file_title != "") {
        print renderHeading(1, file_title)

        if (file_brief != "") {
            print "\n" file_brief
        }

        if (file_description != "") {
            print "\n" renderHeading(2, DESC_TITLE)
            print "\n" file_description
        }
    }

    if (TOC && tocContent) {
        print renderHeading(2, TOC_TITLE)
        print "\n" tocContent
    }

    print "\n" doc

    ## TODO: add examples section
}