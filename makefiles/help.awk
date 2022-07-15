#!/usr/bin/env gawk -f
# SPDX-License-Identifier: MIT

# Awk program for automatically generating help text from those ludicrous makefiles.
# imported into

BEGIN {

    debug_enable = ENVIRON["HELP_DEBUG"] == "1"
    debug_fd = ENVIRON["HELP_DEBUG_FD"]
    debug_file = ENVIRON["HELP_DEBUG_FILE"]
    if (!debug_fd) debug_fd = "stderr"
    if (!debug_file) debug_file = "/dev/fd/" debug_fd

    # whether to generate toc, default to true
    # if(target_regex=="") target_regex = "1"
}

# sort from here https://unix.stackexchange.com/a/609885
function sortIdx (origArray, idxs, j, i, Local, tx, e, cmd) {
    for (j in origArray) str = str j "\n"
    # The \047s in the code represent 's which shell does not allow to be included in '-delimited
    cmd = "printf \047%s\047 \047" str "\047 |sort " args
    i = 0
    while ( (cmd | getline idx) > 0 ) {
      idxs[++i] = idx
    }
    close (cmd);
    return i;
}

function len(a, i, k) {
  for (i in a) k++
  return k
}

function join(a,sep) {
  result = ""
  if (sep == "")
    sep = SUBSEP
  for (item in a)
    result = result sep a[item]
  return result
}

function unjoin(a, text, sep) {
  if (sep == "")
    sep = SUBSEP
  split(substr(text, 2), a, sep)
}

function append(a, item) {
  a[len(a) + 1] = item
}

function extend(a, b) {
  for (item in b)
    append(a, b[item])
}

function debug(msg) {
  if (debug_enable) {
    print (NR-1 + 1) " : " FILENAME ":" msg
    # > debug_file
  }
}

/^## / {
  comments[++comments_counter] = substr($0, 4)
  debug("→ added comment line [" comments[comments_counter] "]")
}

# matches the makefile target
/^[^: \t]*:[^;]*;?/ {
  split($0, recipe_firstline, ":")
  target = recipe_firstline[1]
  includeThis = 1
  # target_regex = "^test\\."
  if (target_regex){
    includeThis = false # not include by default
    if (match(target, target_regex)) includeThis = 1
  }

  if ( includeThis && substr(lastline, 1, 2) == "##" ) {
    debug("→ found target [" target "]")
    width = length(target)
    # track the max  width for formatting
    max_width = (max_width > width) ? max_width : width + 1
    target_docs[target] = join(comments, "~")
    # delete comments
  }
  delete comments
}

# not a comment line, append and resets
!/^##/ {
  if (len(comments) > 0) {
    extend(global_docs, comments)
    append(global_docs, "")
    delete comments
  }
}
{ lastline = $0 }

END {

  for (doc in global_docs)
    print global_docs[doc]

  printf "\nUsage: \033[32mmake \033[36m<target> <VARIABLE>=<value>\n\n"
  printf "\033[0mTargets:\n\n"
  n = sortIdx(target_docs, idxs)
  for (j=1; j<=n; j++) {
    target = idxs[j]
    unjoin(help, target_docs[target], "~")
    printf "\033[36m%-" max_width "s\033[0m│  %s\n", target, help[1]
    for (i = 2; i <= len(help); i++)
      printf "%-" max_width "s│  %s\n", "", help[i]
  }
  printf "\n"
}
