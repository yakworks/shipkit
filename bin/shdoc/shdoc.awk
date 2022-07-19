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
    # starting header level
    if (!MULTI_FILE) MULTI_FILE = false

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

    # when its multiple files this will be the h1 title.
    MAIN_TITLE = "Usage Docs"

    # FILE_DIVIDER = "---"
    # FUNCTION_DIVIDER = "---"

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

    # --- printf formats ---
    format_code =       "  ~~~bash\n%s  ~~~\n"
    format_li =         "* %s"
    format_li_ident =   "  " format_li
    format_arg =        "__%s__ (%s): %s"
    format_exitcode =   "__%s__ : %s"

    # --- regex patterns ---
    # only gawk supports the @ patterns
    # know type in format "$1 string some desc", not prefered kept for compatibility
    pattern_known_types = "^[ -]*(string|int|integer|number|float|array|list) "
    # type pattern in format "$1 (string) some desc" or "$1 - (string) some desc"
    pattern_args_types = "^[ -]*\\([[:alnum:]]+\\) "
    pattern_empty_line = "^[ \t]*$"

    # the FILE_DOC variable
    MAIN_DOC=""
    FILE_DOC=""
    DOC=""

    if(MULTI_FILE){
        START_LEVEL = 2
    }

    reset_docblock_arrays()

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

# init, only called once at start
!fname && has_filename {
    debug("======================= FILE INIT =======================")
    init_file()
}

# End of last file
# if we are here then its a multiple files
fname != FILENAME && has_filename {
    debug("================== FILENAME SWITCH [" fname "] ==============================")
    is_multi_file = 1
    is_initialized = false
    # will render out last files info
    render_file_doc()
    init_file()
}

{
    debug("======[" $0 "]======")
    debug("in_file_header_docs && file_title ["in_file_header_docs " " file_title "]======")
}

/^[[:space:]]*# @(internal|ignore)/ {
    debug("→ **** hit on @internal")
    is_internal = 1
    next
}

#=== pod or Man(ish) Based File Headers ===

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
/^#[ \t]+[[:alnum:]]+.*$/ && in_file_header_docs && !file_title {
    debug("→ **** hit on MAN DOC file_title [" $0 "]" )
    # if it matches `name - brief`
    if(/^.*[ \t]+-[ \t]+.*$/){
        didx = index($0, "-")
        file_title = substr($0, 0, didx-1)
        file_brief = trim(substr($0, didx + 2))
        file_title = comment_trim(rtrim(file_title))
        debug("→ file_title [" file_title "] file_brief [" file_brief "]")
    } else {
        file_title = comment_trim($0)
        debug("→ normal file_title - " file_title)
    }
    # next line can be
    title_line_num = (NR-1 + 1)
    next
}

# MAN DOC file_title seperator
/^#[ \t]*[=-]{2,}$/ && in_file_header_docs && file_title && !in_description {
    # old if && !is_title_seperator_done && title_line_num == NR-1
    debug("→ **** hit on MAN DOC === separator ")
    is_title_seperator_done = 1
    in_description = 1
    next
}

# blank line or not a comment finishes file header
/^[^#]*$/ && in_file_header_docs {
    debug("→ **** hit on file_header break line [" $0 "]")
    finish_file_header()
    next
}

#=== TAG Based File Headers ===

# @name|@file TAGS
/^[ \t]*# @(name|file|module|filename)/ {
    debug("→ @name|@file")
    file_title = comment_trim($0)
    sub(/^@(name|file|module|filename) /, "", file_title)
    init()
    in_file_header_docs = 1
    next
}
# @brief TAGS
/^[ \t]*# @brief/ {
    debug("→ @brief")
    file_brief = comment_trim($0)
    sub(/^@brief /, "", file_brief)
    next
}

/^[ \t]*# @description/ {
    debug("→ **** hit on @description detected")
    in_description = 1
    in_example = 0
    init()
    reset()
}

# function docs start with ##
/^[ \t]*#[ \t]*##*[ \t]*/ && is_initialized {
    debug("→ **** hit on ### block description detected")
    in_description = 1
    in_example = 0
    reset()
}

# Example code tag
/^[ \t]*# (@example|Example|EXAMPLE)/ && !in_file_header_docs{
    debug("→ @example")
    in_example = 1
    next
}
# Example code fence
/^# [\`]{3}/ || /^# [~]{3}/ && !in_file_header_docs{
    debug("→ EXAMPLE code fence")
    in_example = 1
    next
}

in_example {
    # not a `# `, any `# @` thats not a @desc, and any line thats not a `# ` comment
    if (! /^[ \t]*#[ ]/ || /^[ \t]*# @[^d]/ || /^[ \t]*# [\`]{3}/ || /^[ \t]*# [~]{3}/ || /^[ \t]*[^#]/) {
        debug("→ → in_example: leave")
        in_example = 0
    } else {
        debug("→ → in_example: concat" $0)
        sub(/^[ \t]*#/, "")
        push(docblock_example_lines, $0)
        next
    }
}

# simple args tag
/^[ \t]*# @arg/ {
    debug("→ @arg")
    sub(/^[[:space:]]*# @arg /, "")
    # debug("→ argsArray" length(docblock_args))
    push(docblock_args, $0)
    next
}

# simple args tag
/^#[ ]+-[ ]+\$[[:alnum:]]+/ {
    debug("→ - $ args")
    sub(/^#[ ]+-[ ]*/, "")
    # debug("→ argsArray" length(docblock_args))
    push(docblock_args, $0)
    next
}

# ARGS block. Starts wtih Arg or Args
/^# (Args|ARGS|Arguments)[:]?[ \t]*$/ {
    debug("→ ARGS")
    in_args = 1
    next
}

in_args {
    # not a `# `, any `# @` thats not a @desc, and normal line (not a comment)
    if (! /^[ \t]*#[ ]/ || /^[ \t]*# @[^d]/ || /^[ \t]*[^#]/) {
        debug("→ → in_args: false")
        in_args = 0
    } else {
        # debug("→ → in_args: concat" $0)
        # remove spaces and list prefix "-" or "*"
        sub(/^[ \t]*#[ \t]*[-*]?[ \t]*/, "")
        debug("→ → in_args: push" $0)
        push(docblock_args, $0)
        next
    }
}

# needs to come after the other blocks so its not picked up
in_description {
    debug("→ in_description")
    # any one of these will stop the decription flow.
    # not a `# `, any `# @` thats not a @desc, any `# example` and blank line
    if (/^[^ \t*#]|^[ \t]*# @[^d]|^[ \t]*[^#]|^[ \t]*$/ ) {
        debug("→ → in_description: leave")
        in_description = 0
    }
    else {
        descripLine = doDescriptionSub($0)
        push(description_lines, descripLine)
        debug("→ → in_description: pushed descripLine [" descripLine "] length [" length(description_lines) "]")
        next
    }
}

/^[ \t]*# @noargs/ {
    debug("→ @noargs")
    docblock_noargs = 1
    next
}

/^[ \t]*# @set/ {
    debug("→ @set")
    sub(/^[ \t]*# @set /, "")

    push(docblock_sets, $0)

    next
}

/^[ \t]*# @(exitcode|errorcode)/ {
    debug("→ @exitcode")
    sub(/^[ \t]*# @(exitcode|errorcode) /, "")
    push(docblock_exitcodes, $0)
    next
}

/^[ \t]*# @see/ {
    debug("→ @see")
    sub(/[ \t]*# @see /, "")
    push(docblock_sees, $0)
    next
}

/^[ \t]*# @stdin/ {
    debug("→ **** hit on @stdin")
    sub(/^[ \t]*# @stdin /, "")
    push(docblock_stdins, $0)
    next
}

/^[ \t]*# @(stdout|return)/ {
    debug("→ **** hit on @stdout")
    sub(/^[ \t]*# @(stdout|return) /, "")
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
    debug("→ function line [" $0 "]")
    delete functionLines
    if (is_internal) {
        debug("→ → function: it is internal, skipping")
        # is_internal = 0
    } else {
        is_internal = 0
        func_name = trim($0)
        sub(/^function[ \t]*/, "", func_name) # remove function if there
        sub(/[ \t]*\([ \t]*\).*$/, "", func_name) # remove parens if there and everythign after them
        sub(/[ \t]*{$/, "", func_name) # any dangling '{'
        # TODO make this confiugruable
        # add parens suffix
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
/^#[ \t]*/ {
    debug("→ **** hit on comment line [" $0 "]")
    comment = doDescriptionSub($0)
    trackCommentLine(comment)
}

# blank line resets
/^[ \t]*$/ && !in_function_block {
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
    debug("========================= END ========================")
    render_file_doc()
    # if is_multi_file then render out H1 and the TOC then reder the file docs
    if(is_multi_file){
        render_multi_header()
    }
    print MAIN_DOC
}
