#!/usr/bin/env bash

source ../setVar
source ../utils

VarName=FOO

echo "-- When FOO is unset --"
[ -z "$FOO" ] && echo "FOO unset and empty 1"
[ ! "$FOO" ] && echo "FOO unset and empty 2a" # works too
[ ! $FOO ] && echo "FOO unset and empty 2b" # The defaults is -n, so this is ! -n
[ -z ${FOO+set} ] && echo "FOO is unset 3" # -z and ! are same thing
[ ! ${FOO+set} ] && echo "FOO is unset, using ! 4"
# checking VarName that has the name of the variable
[ ! ${!VarName+set} ] && echo "var in VarName unset with ! \${!VarName+set} 5"

# these will NOT be true
[ $FOO ] && echo "** should not show" #default is -n
[ -n "$FOO" ] && echo "** should not show" #default is -n so does not need to be here
[ ${FOO+set} ] && echo "** should not show"
[[ $FOO && $FOO != "" ]] && echo "** should not show"

[ "${!VarName}" ] && echo "** should not show"
[ ${!VarName+set} ] && echo "** should not show"
# truthy falsy
[ $(isFalsy "$FOO") ] && echo "FOO is falsy 6"
[ $(isTruthy "$FOO") ] && echo "** should not show"

[[ "${FOO:-}" = "BOO" ]] && echo "** should not show"
[[ "$FOO" = "" ]] && echo "** should not show"

echo

echo "-- When FOO is empty string --"
FOO=""
[ -z "$FOO" ] && echo "FOO unset and empty 1"
[ ! $FOO ] && echo "FOO unset and empty 2" # The defaults is -n, so this is ! -n
# These will NOT be true now as they only pick up unset but Foo is empty string now
[ -z ${FOO+set} ] && echo "** should not show"
[ ! ${FOO+set} ] && echo "** should not show"
# checking VarName that has the name of the variable
[ ! ${!VarName+set} ] && echo "** should not show"

# Will NOT be true as empty string is not truthy
[ $FOO ] && echo "** should not show"
[ "$FOO" ] && echo "** should not show"
# Will be true now as its empty string
[ ${FOO+set} ] && echo "FOO is set \${FOO+set} 3"
[[ $FOO || $FOO = "" ]] && echo "FOO is set long way 4"

# will NOT be true
[ ${!VarName} ] && echo "** should not show"
[ "${!VarName}" ] && echo "** should not show"
# Will be true now as its empty string
[ ${!VarName+set} ] && echo "var in VarName is set \${!VarName+set} 5"

# truthy falsy
[ $(isFalsy "$FOO") ] && echo "FOO is falsy 6"
[ $(isTruthy "$FOO") ] && echo "** should not show"

[[ "$FOO" = "" ]] && echo "** should not show"
[[ "${FOO:-}" = "" ]] && echo "** should not show"

echo

echo "-- When FOO=bar --"
FOO="bar"
# will NOT be true now
[ -z "$FOO" ] && echo "** should not show"
[ ! $FOO ] && echo "** should not show" # The defaults is -n, so this is ! -n
[ -z ${FOO+set} ] && echo "** should not show"
[ ! ${FOO+set} ] && echo "** should not show"
[[ ! $FOO  && $FOO != "" ]] && echo "** should not show"
# checking VarName that has the name of the variable
[ ! ${!VarName+set} ] && echo "** should not show"

# Will be true now
[ $FOO ] && echo "good $FOO 1"
[ "$FOO" ] && echo 'good "$FOO" 2' # -n is the default and does not need to be specified
[ ${FOO+set} ] && echo "good \${FOO+set} 3"
[[ $FOO || $FOO == "" ]] && echo 'good [[ $FOO || $FOO == "" ]] 4'
[ ${!VarName} ] && echo "good \${!VarName} 5"
[ "${!VarName}" ] && echo 'good "${!VarName}" 6'
[ ${!VarName+set} ] && echo "good \${!VarName+set} 7"

# truthy falsy
[ $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "FOO is truthy 8"

[[ "$FOO" = "bar" ]] && echo "good eq check"
[[ "${FOO:-}" = "bar" ]] && echo "good eq check"


echo

echo "-- When FOO=bar ls bazz --"
FOO="bar ls bazz"
# When string has spaces the single [] will expand and try to run as command
# So we have 2 options when var can have spaces, put quotes around the Param or use [[ ]]
# the ones from above have been commented out, uncomment to see the errors
# the ${FOO+x} expand fine even with spaces

[ -z "$FOO" ] && echo "** should not show"
# [ ! $FOO ] && echo "** should not show" # !! this blows up now
[ ! "$FOO" ] && echo "** should not show" # works too
[[ ! $FOO ]] && echo "** should not show" # executes fine with double [[]]
[ -z ${FOO+x} ] && echo "** should not show"
[ ! ${FOO+x} ] && echo "** should not show"
[[ ! $FOO  && $FOO != "" ]] && echo "** should not show"
[ ! ${!VarName+x} ] && echo "** should not show"
# Will be true now
# [ $FOO ] && echo "good $FOO" # !! this blows up now
[[ $FOO ]] && echo "good [[ \$FOO ]] 1" # executes fine with double [[]]
[ "$FOO" ] && echo 'good [ "$FOO" ] 2'
[ ${FOO+x} ] && echo "good \${FOO+x} 3"
[[ $FOO || $FOO = "" ]] && echo 'good [[ $FOO || $FOO == "" ]] 4'
# [ ${!VarName} ] && echo "good \${!VarName}" # !! this blows up now
[[ ${!VarName} ]] && echo "good [[ \${!VarName} ]] 5" # executes fine with double [[]]
[ "${!VarName}" ] && echo 'good "${!VarName}" 6'
[ ${!VarName+x} ] && echo "good \${!VarName+x} 7"
# truthy falsy
[ $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "FOO is truthy 8"
echo

# ------ playground ------

# things get tricky now with "falsy" and truthy in bash
# to be falsy a value could be false, "false", 0, "0", unset, empty string or commands with non-zero
# so we came up with isFalsy function
# https://github.com/Jeff-Russ/bash-boolean-helpers/blob/master/bool-helpers.sh
# https://velenux.wordpress.com/2012/06/18/how-to-use-a-bash-function-in-an-if-statement/

echo -e "\nFalsy FOO=any value"; FOO="any value"

[ $(isFalsy "$FOO") ] && echo "** should not show"
[ ! $(isFalsy "$FOO") ] && echo "Foo not isFalsy"
[ $(isTruthy "$FOO") ] && echo "Foo isTruthy"

echo -e "\nFalsy FOO is unset"; unset FOO

[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo -e "\nFalsy FOO="; FOO=
[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo -e "\nFalsy FOO=false"; FOO=false
[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo -e "\nFalsy FOO=\"false\""; FOO="false"
[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo -e "\nFalsy FOO=0"; FOO=0
[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo -e "\nFalsy FOO=\"0\""; FOO="0"
[ $(isFalsy "$FOO") ] && echo "FOO is Falsy"
[ ! $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "** should not show"

echo; echo

echo -e "\nCombo Falsy FOO=false and BAR=42"; FOO="0"; BAR=42
# double brackets allow use to have && ||
[[ $(isFalsy "$FOO") && $(isTruthy "$BAR") ]] && echo "FOO is Falsy && BAR is truthy 1"
[[ $(isFalsy "$FOO") && $BAR = 42 ]] && echo "FOO is Falsy && BAR is 42 2"
[[ $(isFalsy "$FOO") && (($BAR > 40)) ]] && echo "FOO is Falsy && ((BAR > 40)) 3"
[[ ! $(isFalsy "$FOO") && $BAR = 42 ]] && echo "** should not show"
[[ $(isTruthy "$FOO") && $BAR = 42 ]] && echo "** should not show"

echo; echo
