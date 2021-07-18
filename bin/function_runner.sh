# ---
# helper to run functions, meant to be source imported at end of script.
# example: add `source build/bin/function_runner.sh` at end of bash script,
# wrap it in  if [[ "${#BASH_SOURCE[@]}" -eq 1 ]]; then
# if you want it to be ignored when your script it sourced into another
# then if you have a set of functions in that script you can run one like so
# ./tools.sh some_function arg1 arg1
# ---

# --- boiler plate function runner, keep at end of file ------
# if declare works then its a function
if declare -f "$1" > /dev/null; then
  "$@" #call function with arguments verbatim
else
  echo "'$1' is not a known function name" >&2; exit 1
fi
