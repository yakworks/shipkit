#!/usr/bin/awk -f

# Varibles
# style = readme or doc
# toc = true or false
BEGIN {
    IGNORECASE = 1
    if (! style) {
        style = "doc"
    }

    if (! toc) {
        toc = 0
    }

    styles["empty", "from"] = ".*"
    styles["empty", "to"] = ""

    styles["h1", "from"] = ".*"
    styles["h1", "to"] = "# &"

    styles["h2", "from"] = ".*"
    styles["h2", "to"] = "## &"

    styles["h3", "from"] = ".*"
    styles["h3", "to"] = "### &"

    styles["h4", "from"] = ".*"
    styles["h4", "to"] = "#### &"

    styles["h5", "from"] = ".*"
    styles["h5", "to"] = "##### &"

    styles["code", "from"] = ".*"
    styles["code", "to"] = "```&"

    styles["/code", "to"] = "```"

    styles["argN", "from"] = "^(\\$[0-9])[ -]*\\{?+(\\w+)\\}?+"
    styles["argN", "to"] = "**\\1** | (\\2) | "
    # styles["argN", "to"] = "**\\1** | (\\2) | "

    styles["argN_notype", "from"] = "^(\\$[0-9])[ -]*"
    styles["argN_notype", "to"] = "**\\1** | (string) | "

    styles["arg@", "from"] = "^\\$@ (\\S+)"
    styles["arg@", "to"] = "**...** (\\1):"

    styles["li", "from"] = ".*"
    styles["li", "to"] = "- &"
    # styles["li", "to"] = "&"

    styles["i", "from"] = ".*"
    styles["i", "to"] = "*&*"

    styles["anchor", "from"] = ".*"
    styles["anchor", "to"] = "[&](#&)"

    styles["returncode", "from"] = "([>!]?[1-9]{1,3}) (.*)"
    styles["returncode", "to"] = "**\\1** 💥 \\2"

    styles["returncode0", "from"] = "([>!]?[0]{1}) (.*)"
    styles["returncode0", "to"] = "**0** 🎯 \\2"

    styles["h_rule", "to"] = "---"

    styles["comment", "from"] = ".*"
    styles["comment", "to"] = "<!-- & -->"

    styles["alias", "from"] = "alias (.*)=.*$"
    styles["alias", "to"] = "\\1"


    output_format["readme", "h1"] = "h2"
    output_format["readme", "h2"] = "h3"
    output_format["readme", "h3"] = "h4"
    output_format["readme", "h4"] = "h5"

    output_format["bashdoc", "h1"] = "h1"
    output_format["bashdoc", "h2"] = "h2"
    output_format["bashdoc", "h3"] = "h3"
    output_format["bashdoc", "h4"] = "h4"

    output_format["webdoc", "h1"] = "empty"
    output_format["webdoc", "h2"] = "h3"
    output_format["webdoc", "h3"] = "h4"
    output_format["webdoc", "h4"] = "h5"

}

function render(type, text) {
    if((style,type) in output_format){
        type = output_format[style,type]
    }
    return gensub( \
        styles[type, "from"],
        styles[type, "to"],
        "g",
        text \
    )
}

function render_list(item, anchor) {
    return "- [" item "](#" anchor ")"
}

function generate_anchor(text) {
    # https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb#L44-L45
    text = tolower(text)
    gsub(/[^[:alnum:]_ -]/, "", text)
    gsub(/ /, "-", text)
    return text
}

function reset() {
    has_example = 0
    has_args_heading = 0
    has_return_code = 0
    has_stdout = 0

    content_function_name = ""
    content_desc = ""
    content_example  = ""
    content_args = ""
    content_returncode = ""
    content_seealso = ""
    content_stdout = ""
}

function description_start() {
    in_description = 1
    in_example = 0
    in_file_module = 0
}

# {
#     print  "at start:" $0 >> "awk_start"
#     prev_line=$0
# }

/^\s*# (@internal|@ignore)/ {
    is_internal = 1
}

in_file_module {

    # stops as soon as it sees an empty line
    if (/^\s*$/) {
        if (!match(filedoc, /\n$/)) {
            filedoc = filedoc "\n"
        }
        in_file_module = 0
    } else {
        sub(/^\s*# (@brief|@summary)\s*/, "")
        sub(/^\s*#\s*-{3,}\s*/, "")
        sub(/^\s*# /, "")
        sub(/^\s*#\s?#/, "")
        sub(/^\s*#$/, "")

        if($0) {
            filedoc = filedoc "\n" $0
        }

    }
}

/^\s*# (@file|@module)/ {
    sub(/^\s*# (@file|@module):?\s*/, "")

    # filedoc = "\n" render("h1", $0) "\n"
    # if(style == "webdoc"){
    #     filedoc = filedoc render("comment", "file=" $0) "\n"
    # }

    in_file_module = 1
    filedoc = filedoc "\n" render("h1", $0) "\n"

}

/^\s*# (@brief|@summary)/ {
    sub(/^\s*# (@brief|@summary):?\s*/, "")
    if(style == "webdoc"){
        filedoc = filedoc render("comment", "brief=" $0) "\n"
    }
    filedoc = filedoc "\n" $0
}

# Description
/^\s*# @description/ {
    description_start()

}

# Description start with #---
/^\s*#\s*-{3}/ {
    description_start()
}

# function docs start with ##
/^\s*#\s?#/ {
    description_start()
}

in_description {
    # any one of these will stop the decription flow.
    # not a `# `, any `# @` thats not a @desc, any `# example` and any line thats not a `# ` comment
    if (/^[^\s*#]/ || /^\s*# @[^d]/ || /^\s*# example/ || /^\s*# [\`]{3}/ || /^\s*[^#]/) {
        if (!match(content_desc, /\n$/)) {
            content_desc = content_desc "\n"
        }
        in_description = 0
    }
    else {
        sub(/^\s*# @description\s*/, "")
        sub(/^\s*#\s*-{3,}\s*/, "")
        sub(/^\s*# /, "")
        sub(/^\s*#\s?#/, "")
        sub(/^\s*#$/, "")

        if($0) {
            content_desc = content_desc "\n" $0
        }
    }
}

in_example {

    if (! /^\s*#[ ]{3}/) {

        in_example = 0

        content_example = content_example "\n" render("/code") "\n"

    } else {
        sub(/^\s*#[ ]{3}/, "")

        content_example = content_example "\n" $0
    }
}

in_example_code_block {

    if (/^\s*#\s*[\`]{3}/) {
        # whack it so it doesn't get picked up again
        sub(/^\s*#\s*[\`]{3}/, "")

        in_example_code_block = 0

        content_example = content_example "\n" render("/code") "\n"

    } else {
        sub(/^\s*#\s/, "")

        content_example = content_example "\n" $0
    }
}

# Example @example
/^\s*# @?example/ {
    in_example = 1
    content_example = content_example "\n" render("h3", "Example")
    content_example = content_example "\n\n" render("code", "bash")
}

# Example code block
/^\s*# [\`]{3}/ {
    in_example_code_block = 1
    content_example = content_example "\n" render("h3", "Example")
    content_example = content_example "\n\n" render("code", "bash")
}

/^\s*# (@arg|@param)/ {
    do_args = 1
    sub(/^\s*#\s*(@arg|@param)\s*/, "")
}

# args in form # $1 - without param or arg
/^\s*# \$[1-9]/ {
    do_args = 1
}

do_args {
    if (!has_args_heading) {
        has_args_heading = 1
        content_args = content_args "\n" render("h3", "🔌 Arguments") "\n\n"
    }

    sub(/^\s*#\s*/, "") # remove the line start

    if(match($0, /\{\w+\}/)) {
        $0 = render("argN", $0)
    } else {
        # evrything wants to be a string in bash
        $0 = render("argN_notype", $0)
    }
    # $0 = render("argN", $0)
    # $0 = render("arg@", $0)
    content_args = content_args render("li", $0) "\n"
    do_args = 0
}


/^\s*# @noargs/ {
    content_args = content_args "\n" render("i", "Function has no arguments.") "\n"
}

in_return_codes {

    # for any line thats a pound and a number `# 0-9`
    if (/^\s*#\s*[0-9]/) {
        sub(/^\s*#\s*/, "")
        $0 = render("returncode0", $0)
        $0 = render("returncode", $0)
        content_returncode = content_returncode render("li", $0) "\n"
    } else {
        # break out on anything else
        in_return_codes = 0
    }
}

# @return with lines below it
/^\s*# @return[s]?\s*$/ {
    if (!has_return_code) {
        has_return_code = 1
        content_returncode = content_returncode "\n" render("h3", "💡 Return codes") "\n\n"
    }
    in_return_codes = 1
}

# @return(s) with description inline
/^\s*# @return[s]?\s+\w+/ {
    if (!has_return_code) {
        has_return_code = 1

        content_returncode = content_returncode "\n" render("h3", "💡 Return codes") "\n\n"
    }

    sub(/^\s*# @return[s]?\s+/, "")

    $0 = render("returncode0", $0)
    $0 = render("returncode", $0)

    content_returncode = content_returncode render("li", $0) "\n"
}

/^\s*# @see/ {
    sub(/\s*# @see /, "")
    anchor = generate_anchor($0)
    $0 = render_list($0, anchor)

    content_seealso = content_seealso "\n" render("h3", "See also") "\n\n" $0 "\n"
}

/^\s*# (@stdout|stdout:)/ {
    has_stdout = 1

    sub(/^\s*# (@stdout|stdout:)/, "")
    # sub(/^\s*# stdout:/, "")

    content_stdout = content_stdout "\n" render("h3", "🖨 Stdout output")
    content_stdout = content_stdout "\n\n" render("li", $0) "\n"
}

{
    docblock = content_desc content_args content_returncode content_stdout content_example content_seealso
    if(style == "webdoc"){
        docblock = docblock "\n" render("h_rule") "\n"
    }
    # print  "docblock part : " docblock >> "awk_docblock_section"
}

# function start
/^[ \t]*(function([ \t])+)?([a-zA-Z0-9\._:-]+)([ \t]*)(\(([ \t]*)\))?[ \t]*\{/ && docblock != "" && !in_example {

    content_function_name = gensub(\
        /^[ \t]*(function([ \t])+)?([a-zA-Z0-9\._:-]+)[ \t]*\(.*/, \
        "\\3()", \
        "g" \
    )

    doing_function_chunk = 1

}

# look for function end
/^\s?\}/ && doing_function_chunk {
    # looks like function end so mark it as we need to try and pick up alias
    # in_function_end is checked at start of desc
    found_function_end = 1
    finalize_function_docs = 1
}

# this is here as we want to finish only after blank line or alias
finalize_function_docs {

    if (is_internal ) {
        is_internal = 0
    } else {
        doc = doc "\n" render("h_rule") "\n"
        doc = doc "\n" render("h2", content_function_name) "\n" docblock
    }

    finalize_function_docs = 0
    content_function_name = ""
    reset()
    docblock = ""

}

END {

    if (filedoc != "") {
        print filedoc
    }

    if (toc) {
        print ""
        print render("h2", "Table of Contents")
        print content_idx
        print ""
        print render("h_rule")
    }

    print doc
}
