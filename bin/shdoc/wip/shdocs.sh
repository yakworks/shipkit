#!/usr/bin/env bash
# shellcheck disable=SC1000-SC9999
set -euo pipefail # strict mode https://bit.ly/36MvF0T
source "$(dirname "${BASH_SOURCE[0]}")"/../core/main

function shdocs.generate() {
  # find bin -type f -exec awk '
  # /^#!.*bash/{print FILENAME}
  # {nextfile}' {} +

  local usage_md="docs/USAGE.md"
  rm -f $usage_md
  # touch $usage_md
  # shellcheck disable=2207
  # local -a lib_files=($(find lib -name '*.sh' -type f ))
  # gets all files that start with letter, excludes dot files
  local -a bin_files=($(find bin -type f -name '[a-z]*'))
  local -a files
  local module

  # run "rm -f ${usage_md} ${usage_adoc} && touch ${usage_md}"

  # files=("${lib_files[@]}" "${bin_files[@]}")
  files=("${lib_files[@]}" "${bin_files[@]}")
  # h3 "Processing ${#files[@]} files for shdoc comments..."

  for file in "${files[@]}"; do
    # checks for bash shebang and @file indicator
    grep -E -q '^#!.*bash' "${file}" &&
    grep -E -q '@(file|module|description|brief|example)' "${file}" || {
      continue
    }
    echo "file $file"
    doc.file "${file}" "${usage_md}"
  done
  echo
}

shdocs.file() {
    declare realfile
    realfile="$(realpath "${1}")"
    echo "realfile $realfile"
    if [[ -s "${realfile}" ]]; then
        # awk -v style="readme" -v toc=0 -f "${BIN_PATH}"/bashdoc/shdoc.awk < "${realfile}" > "$2"
        # "${BIN_PATH}"/bashdoc/shdoc2 < "${realfile}" > "$2"
        "${BIN_PATH}"/bashdoc/shdoc.awk < "${realfile}"
    fi
}

# --- boiler plate function runner, keep at end of file ------
# BASH_SOURCE check will be true if this is run, false if imported into another script with `source`
if [[ "${#BASH_SOURCE[@]}" == 1 ]]; then
  export fn_namespace='shdocs' && source "${BASHKIT_CORE}/function_runner_ns.sh"
fi
