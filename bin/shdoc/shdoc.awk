#!/usr/bin/awk -f

BEGIN {
    if (! style) {
        style = "github"
    }
    if (! toc) {
        toc = 1
    }
    if (! hlevel) {
        hlevel = ""
    }


    styles["github", "h1", "from"] = ".*"
    styles["github", "h1", "to"] = "# &"

    styles["github", "h2", "from"] = ".*"
    styles["github", "h2", "to"] = "## &"

    styles["github", "h3", "from"] = ".*"
    styles["github", "h3", "to"] = "### &"

    styles["github", "h4", "from"] = ".*"
    styles["github", "h4", "to"] = "#### &"

    styles["github", "code", "from"] = ".*"
    styles["github", "code", "to"] = "```&"

    styles["github", "/code", "to"] = "```"

    # styles["github", "argN", "from"] = "^(\\$[0-9]) (\\S+)"
    # styles["github", "argN", "to"] = "**\\1** (\\2):"

    styles["github", "argN", "from"] = "^(\\$[0-9])[ -:]*\\(?+(\\w+)\\)?+"
    styles["github", "argN", "to"] = "**\\1** (\\2):"
    # styles["github", "argN", "to"] = "**\\1** | (\\2) | "

    styles["github", "argN_notype", "from"] = "^(\\$[0-9])[ -:]*"
    # styles["argN_notype", "to"] = "**\\1** | (string) | "
    styles["github", "argN_notype", "to"] = "**\\1** (string): "

    styles["github", "arg@", "from"] = "^\\$@ (\\S+)"
    styles["github", "arg@", "to"] = "**...** (\\1):"

    styles["github", "set", "from"] = "^(\\S+) (\\S+)"
    styles["github", "set", "to"] = "**\\1** (\\2):"

    styles["github", "li", "from"] = ".*"
    styles["github", "li", "to"] = "* &"

    styles["github", "i", "from"] = ".*"
    styles["github", "i", "to"] = "_&_"

    styles["github", "anchor", "from"] = ".*"
    styles["github", "anchor", "to"] = "[&](#&)"

    styles["github", "exitcode", "from"] = "([>!]?[0-9]{1,3}) (.*)"
    styles["github", "exitcode", "to"] = "**\\1**: \\2"

    debug_enable = ENVIRON["SHDOC_DEBUG"] == "1"
    debug_fd = ENVIRON["SHDOC_DEBUG_FD"]
    if (!debug_fd) {
        debug_fd = 2
    }
    debug_file = "/dev/fd/" debug_fd
}

function render(type, text) {
    styleFrom = styles[style, type, "from"]
    styleTo = styles[style, type, "to"]
    return gensub( styleFrom, styleTo, "g", text )
}

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

function render_toc_item(title) {
    return "* " render_toc_link(title)
}

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
            result = text_lines[i]
        } else {
            result = result "\n" text_lines[i]
        }
    }

    return result
}

function reset() {
    debug("→ reset()")

    delete docblock
    description = ""
}

function handle_description() {
    debug("→ handle_description")
    if (description == "") {
        debug("→ → description: empty")
        return;
    }

    if (file_description == "") {
        debug("→ → description: added")
        file_description = description
        return;
    }
}

function concat(x, text) {
    if (x == "") {
        x = text
    } else {
        x = x "\n" text
    }

    return x
}

function push(arr, value) {
    arr[length(arr)+1] = value
}

function join(arr) {
    for (i = 0; i < length(lines); i++) {
        if (i == 0) {
            result = lines[i]
        } else {
            result = result "\n" lines[i]
        }
    }

    return result
}

function docblock_set(key, value) {
    docblock[key] = value
}

function docblock_concat(key, value) {
    if (key in docblock) {
        docblock[key] = concat(docblock[key], value)
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

    lines[0] = render("h3", func_name)
    if (description != "") {
        push(lines, description)
    }

    if ("example" in docblock) {
        push(lines, render("h4", "Example"))
        push(lines, "\n" render("code", "bash"))
        push(lines, unindent(docblock["example"]))
        push(lines, render("/code"))
        push(lines, "")
    }

    if ("arg" in docblock) {
        push(lines, render("h4", "Arguments") "\n")
        for (i in docblock["arg"]) {
            item = docblock["arg"][i]
            if(match(item, /\(\w+\)/)) {
                debug("******************** → → arg matched type for item: [" item "]")
                item = render("argN", item)
            } else if(match(item, /[1-9] (string|int|number|array|float)/)) {
                debug("***** → → arg matched type for know types: [" item "]")
                item = render("argN", item)
            } else {
                # evrything wants to be a string in bash
                item = render("argN_notype", item)
                # item = render("argN", item)
            }
            # item = render("argN", item)
            item = render("arg@", item)
            item = render("li", item)
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
        push(lines, render("h4", "Variables set") "\n")
        for (i in docblock["set"]) {
            item = docblock["set"][i]
            item = render("set", item)
            item = render("li", item)
            if (i == length(docblock["set"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("exitcode" in docblock) {
        push(lines, render("h4", "Exit codes") "\n")
        for (i in docblock["exitcode"]) {
            item = render("li", render("exitcode", docblock["exitcode"][i]))
            if (i == length(docblock["exitcode"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("stdin" in docblock) {
        push(lines, render("h4", "Input on stdin") "\n")
        for (i in docblock["stdin"]) {
            item = render("li", docblock["stdin"][i])
            if (i == length(docblock["stdin"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("stdout" in docblock) {
        push(lines, render("h4", "Output on stdout") "\n")
        for (i in docblock["stdout"]) {
            item = render("li", docblock["stdout"][i])
            if (i == length(docblock["stdout"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }

    if ("see" in docblock) {
        push(lines, render("h4", "See also") "\n")
        for (i in docblock["see"]) {
            item = render("li", render_toc_link(docblock["see"][i]))
            if (i == length(docblock["see"])) {
                item = item "\n"
            }
            push(lines, item)
        }
    }


    result = join(lines)
    delete lines
    return join(lines)
}

function debug(msg) {
    if (debug_enable) {
        print "DEBUG: " msg > debug_file
    }
}

{
    debug("line: [" $0 "]")
}

/^[[:space:]]*# @internal/ {
    debug("→ @internal")
    is_internal = 1

    next
}

/^[[:space:]]*# @(name|file)/ {
    debug("→ @name|@file")
    sub(/^[[:space:]]*# @(name|file) /, "")
    file_title = $0

    next
}

/^[[:space:]]*# @brief/ {
    debug("→ @brief")
    sub(/^[[:space:]]*# @brief /, "")
    file_brief = $0

    next
}

/^[[:space:]]*# @description/ {
    debug("→ @description")
    in_description = 1
    in_example = 0

    handle_description()

    reset()
}

# function docs start with ###
/^\s*#\s?##/ {
    debug("→ @description")
    in_description = 1
    in_example = 0

    handle_description()

    reset()
}

in_description {
    # any one of these will stop the decription flow.
    # not a `# `, any `# @` thats not a @desc, any `# example` and any line thats not a `# ` comment
    if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# @example/ || /^\s*# [\`]{3}/ || /^\s*[^#]/) {
        debug("→ → in_description: leave")

        if (!match(description, /\n$/)) {
            description = description "\n"
        }

        in_description = 0

        handle_description()
    } else {
        debug("→ → in_description: concat")
        sub(/^[[:space:]]*# @description[[:space:]]*/, "")
        sub(/^[[:space:]]*#[[:space:]]*/, "")
        sub(/^[[:space:]]*#$/, "")
        sub(/^[[:space:]]*#\s*-{3,}\s*/, "")
        sub(/^[[:space:]]*# /, "")
        sub(/^[[:space:]]*#\s?#/, "")

        description = concat(description, $0)
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
    debug("→ @stdin")

    sub(/^[[:space:]]*# @stdin /, "")

    docblock_push("stdin", $0)

    next
}

/^[[:space:]]*# @stdout/ {
    debug("→ @stdout")

    sub(/^[[:space:]]*# @stdout /, "")

    docblock_push("stdout", $0)

    next
}

/^[ \t]*(function([ \t])+)?([a-zA-Z0-9_\-:-\\.]+)([ \t]*)(\(([ \t]*)\))?[ \t]*\{/ && !in_example{
    # && (length(docblock) != 0 || description != "") && !in_example
    debug("→ function")
    if (is_internal) {
        debug("→ → function: it is internal, skip")
        is_internal = 0
    } else {
        debug("→ → function: register")

        is_internal = 0
        func_name = gensub(\
            /^[ \t]*(function([ \t])+)?([a-zA-Z0-9_\-:-\\.]+)[ \t]*\(.*/, \
            "\\3()", \
            "g" \
        )
        debug("******************** → →func_name: [" func_name "]")
        doc = concat(doc, render_docblock(func_name, description, docblock))
        tocContent = concat(tocContent, render_toc_item(func_name))
    }

    reset()
    next
}

# nothing matched and not starting with # comment line
/^[^#]*$/ {
    debug("→ break line [" $0 "]")
    handle_description();
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

    if (file_title != "") {
        print render("h1", file_title)

        if (file_brief != "") {
            print "\n" file_brief
        }

        if (file_description != "") {
            print "\n" render("h2", "Overview")
            print "\n" file_description
        }
    }

    if (toc == 1 && tocContent) {
        print render("h2", "Index") "\n"
        print tocContent
    }

    print "\n" doc

    ## TODO: add examples section
}
