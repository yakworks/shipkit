# ---
# Namespaced helper to run functions, meant to be source imported at end of script.
# example: add following to end of script
#
# # BASH_SOURCE check will be true if this is run, false if imported into another script with `source`
# if [[ "${#BASH_SOURCE[@]}" == 1 ]]; then
#   export fn_namespace='kube' && source "${BASHKIT_CORE}/function_runner_ns.sh"
# fi
#

# if declare works then its a valid function
if declare -f "${fn_namespace}.${1:-}" > /dev/null; then
  # if this is run from makefile or command line then will prepend the fn_namespace that was exported from script
  "${fn_namespace}.$@" #call function with arguments verbatim
else
  [ "${1:-}" ] && echo "'${fn_namespace:-}.$1' has empty function or is not a known function name" >&2 && exit 1
fi
