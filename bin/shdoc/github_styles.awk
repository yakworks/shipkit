BEGIN {
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
    styles["github", "argN", "to"] = "__\\1__ (\\2):"
    # styles["github", "argN", "to"] = "**\\1** | (\\2) | "

    styles["github", "argN_notype", "from"] = "^(\\$[0-9])[ -:]*"
    # styles["argN_notype", "to"] = "**\\1** | (string) | "
    styles["github", "argN_notype", "to"] = "__\\1__ (string): "

    styles["github", "arg@", "from"] = "^\\$@ (\\S+)"
    styles["github", "arg@", "to"] = "__...__ (\\1):"

    styles["github", "set", "from"] = "^(\\S+) (\\S+)"
    styles["github", "set", "to"] = "__\\1__ (\\2):"

    styles["github", "li", "from"] = ".*"
    styles["github", "li", "to"] = "* &"

    styles["github", "i", "from"] = ".*"
    styles["github", "i", "to"] = "_&_"

    styles["github", "anchor", "from"] = ".*"
    styles["github", "anchor", "to"] = "[&](#&)"

    styles["github", "exitcode", "from"] = "([>!]?[0-9]{1,3}) (.*)"
    styles["github", "exitcode", "to"] = "**\\1**: \\2"
}
