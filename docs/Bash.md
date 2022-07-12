# Bash Tips

## Bash Conditional Expressions

### If Then brackets

double [[ allow you to use `&&` and `||` instead of `-a` and `-o`

THERE MUST BE AT LEAST ONE SPACE BETWEEN BRACKETS. `[$VAR]` IS INVALID. SHOULD ALWAYS BE `[ $VAR ]`

### Check if File Exists

When checking if a file exists, the most commonly used FILE operators are -e and -f. The first one will check whether a file exists regardless of the type, while the second one will return true only if the FILE is a regular file (not a directory or a device).

The most readable option when checking whether a file exists or not is to use the test command in combination with the if statement . Any of the snippets below will check whether the /etc/resolv.conf file exists:

```bash
FILE=/etc/resolv.conf
if test -f "$FILE"; then
    echo "$FILE exists."
fi

if [ -f "$FILE" ]; then
    echo "$FILE exists."
fi

if [[ -f "$FILE" ]]; then
    echo "$FILE exists."
fi

test -f "$FILE" && echo "$FILE exists."

[ -f "$FILE" ] && echo "$FILE exists."

[[ -f "$FILE" ]] && echo "$FILE exists."

if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
fi

```

If you want to run a series of command after the && operator simply enclose the commands in curly brackets separated by ; or &&:

```bash
FILE=/etc/resolv.conf
[ -f "$FILE" ] && { echo "$FILE exist."; cp "$FILE" /tmp/; }
[ -f "$FILE" ] && echo "$FILE exist." || echo "$FILE does not exist."
```

### Check if File does Not Exist

```bash
FILE=/etc/resolv.conf
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
fi

[ ! -f "$FILE" ] && echo "$FILE does not exist."
```

### Check if Multiple Files Exist

```bash
if [ -f /etc/resolv.conf -a -f /etc/hosts ]; then
    echo "Both files exist."
fi


# double brackets when using &&
if [[ -f /etc/resolv.conf && -f /etc/hosts ]]; then
    echo "Both files exist."
fi

[ -f /etc/resolv.conf -a -f /etc/hosts ] && echo "Both files exist."

# double brackets when using &&
[[ -f /etc/resolv.conf && -f /etc/hosts ]] && echo "Both files exist."
```

### /dev/null 

you may sometimes see this and its just a dummy file that you can dump anything to and helps with execution.

often you may see `2>/dev/null` in context something like `grep -i 'abc' content 2>/dev/null`. [A Good explanation is here](https://askubuntu.com/questions/350208/what-does-2-dev-null-mean). basically it means send any errors to a blackhole and we are only concerned with successful output.


### Operators

The test command includes the following FILE operators that allow you to test for particular types of files:

#### File

- `-d FILE` - True if the FILE exists and is a directory.
- `-e FILE` - True if the FILE exists and is a file, regardless of type (node, directory, socket, etc.).
- `-f FILE` - True if the FILE exists and is a regular file (not a directory or device).
- `-h FILE` - True if the FILE exists and is a symbolic link.
- `-L FILE` - True if the FILE exists and is a symbolic link.
- `-O FILE` - True if the FILE exists and is owned by the user running the command.
- `-s FILE` - True if the FILE exists and has nonzero size.
- `-w FILE`- True if the FILE exists and is writable.
- `-x FILE` - True if the FILE exists and is executable.

#### Single brackets `[ ]` 

- `"$VAR"` - same as -n
- `-n "$VAR"` - True if the length of VAR is greater than zero. this is default is not really needed
- `! "$VAR"` - same as `! -n` which is essentially the same as `-z`.
- `-z "$VAR"` - True if the VAR is empty or unset.
- `${VAR+set}` - True only if the VAR is unset (never setup or `unset VAR` was called) but false if VAR is set and is empty string
- `"$VAR1" = "BAR` - True if VAR1 = "BAR" .
- `"$VAR1" = "$VAR2"` - True if VAR1 and VAR2 are equal.
- `"$VAR1" != "$VAR2"` - True if VAR1 and VAR2 are not equal.
- `INTEGER1 -eq INTEGER2` - True if INTEGER1 and INTEGER2 are equal.
- `INTEGER1 -gt INTEGER2` - True if INTEGER1 is greater than INTEGER2.
- `INTEGER1 -lt INTEGER2` - True if INTEGER1 is less than INTEGER2.
- `INTEGER1 -ge INTEGER2` - True if INTEGER1 is equal or greater than INTEGER2.
- `INTEGER1 -le INTEGER2` - True if INTEGER1 is equal or less than INTEGER2.

#### Double brackets `[[ ]]` 

Double brackets aer a bash thing. In many cases you dont need to wrap vars in "" for when there are spaces
It allows for using `==` `&&` `||`

[see ](https://stackoverflow.com/questions/13542832/difference-between-single-and-double-square-brackets-in-bash)
and [this is decent](http://dev.gosteven.com/2013/03/brackets-parentheses-curly-braces-in.html)
and [this is very good](https://www.assertnotmagic.com/2018/06/20/bash-brackets-quick-reference/)

## Bash For Loop

```bash
for item in [LIST]; do
  [COMMANDS]
done

for element in Hydrogen Helium Lithium Beryllium;do
  echo "Element: $element"
done
```

### Range

```bash
for i in {0..3}
do
  echo "Number: $i"
done

# {START..END..INCREMENT}
for i in {0..20..5}
do
  echo "Number: $i"
done
```

### Loop over array elements

```bash
BOOKS=('Atlas Shrugged' 'Don Quixote' 'Ulysses' 'The Great Gatsby')

for book in "${BOOKS[@]}"; do
  echo "Book: $book"
done
```

### C-style Bash for loop

```bash
for ((i = 0 ; i <= 1000 ; i++)); do
  echo "Counter: $i"
done
```

### break and continue Statements

```bash
for element in Hydrogen Helium Lithium Beryllium; do
  if [[ "$element" == 'Lithium' ]]; then
    break # this could be on single line with &&
  fi
  echo "Element: $element"
done

for i in {1..5}; do
  # ifs can be on single line as outined in inf then section
  [[ "$i" == '2' ]] && continue
  echo "Number: $i"
done

```

### Real World

#### Renaming files with spaces in the filename

```bash

for file in *\ *; do
  mv "$file" "${file// /_}"
done
```

- The first line creates a for loop and iterates through a list of all files with a space in its name. The expression `*\ *` creates the list.
- The second line applies to each item of the list and moves the file to a new one replacing the space with an underscore `_`. The part `${file// /_}` is using the shell parameter expansion to replace a pattern within a parameter with a string.
- done indicates the end of the loop segment.

## Parameter Expansion

| Exp                  | Set and Not Null     | Empty    | Unset           |
|------------------------|----------------------|-----------------|-----------------|
| **${parameter:-word}** | substitute parameter | substitute word | substitute word |
| **${parameter-word}**  | substitute parameter | substitute null | substitute word |
| **${parameter:=word}** | substitute parameter | assign word     | assign word     |
| **${parameter=word}**  | substitute parameter | substitute null | assign word     |
| **${parameter:?word}** | substitute parameter | error, exit     | error, exit     |
| **${parameter?word}**  | substitute parameter | substitute null | error, exit     |
| **${parameter:+word}** | substitute word      | substitute null | substitute null |
| **${parameter+word}**  | substitute word      | substitute word | substitute null |


| Exp           | FOO="world" | FOO=""      | Unset FOO |
|---------------|-------------|-------------|--------------|
| ${FOO:-hello} | world       | hello       | hello        |
| ${FOO-hello}  | world       | ""          | hello        |
| ${FOO:=hello} | world       | FOO=hello   | FOO=hello    |
| ${FOO=hello}  | world       | ""          | FOO=hello    |
| ${FOO:?hello} | world       | error, exit | error, exit  |
| ${FOO?hello}  | world       | ""          | error, exit  |
| ${FOO:+hello} | hello       | ""          | ""           |
| ${FOO+hello}  | hello       | hello       | ""           |

To check if variable is unset or set to blank string

[See this SO for good break down](https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash)

and when using double `[[` quotes are not needed for word splitting but might be with `[` as [outlined here](https://wiki.bash-hackers.org/syntax/ccmd/conditional_expression#word_splitting)

The nutshell summary of below is you really only need to think of it 4 ways

- `[ "$FOO" ]` - will be true if FOO is anything, unset and empty string will be false
- `[ ! "$FOO" ]` - will be true if FOO is unset or and empty string, false if FOO is anything else
- `[ ${FOO+set} ]` - will be true if FOO is set to anything, including an empty string
- `[ ! ${FOO+set} ]` - will be true if FOO is unset, variable is never setup, if FOO empty this  returns false as thats considered set.


```bash
# will echo if its falsy
function isFalsy {
  [[ ! $1 ]] && echo "unsetOrEmpty"; [[ "$1" = false ]] && echo "isFalse"; [[ "$1" = 0 ]] && echo "is0"
}

# will echo if its truthy
function isTruthy {
  [ ! $(isFalsy "$1") ] && echo "isTruthy"
}

VarName=FOO

echo "-- When FOO is unset --"
[ -z "$FOO" ] && echo "FOO unset and empty 1"
[ ! $FOO ] && echo "FOO unset and empty 2" # The defaults is -n, so this is ! -n
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
[[ $FOO || $FOO == "" ]] && echo "FOO is set long way 4"

# will NOT be true
[ ${!VarName} ] && echo "** should not show"
[ "${!VarName}" ] && echo "** should not show"
# Will be true now as its empty string
[ ${!VarName+set} ] && echo "var in VarName is set \${!VarName+set} 5"

# truthy falsy
[ $(isFalsy "$FOO") ] && echo "FOO is falsy 6"
[ $(isTruthy "$FOO") ] && echo "** should not show"

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

echo

echo "-- When FOO=bar ls bazz --"
FOO="bar ls bazz"
# When string has spaces the single [] will expand and try to run as command
# So we have 2 options when var can have spaces, put quotes around the Param or use [[ ]]
# the ones from above have been commented out, uncomment to see the errors
# the ${FOO+x} expand fine even with spaces

[ -z "$FOO" ] && echo "** should not show"
# [ ! $FOO ] && echo "** should not show" # !! this blows up now
[ ! "$FOO" ] && echo "** should not show" # !works if quoting it
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
[[ $FOO || $FOO == "" ]] && echo 'good [[ $FOO || $FOO == "" ]] 4'
# [ ${!VarName} ] && echo "good \${!VarName}" # !! this blows up now
[[ ${!VarName} ]] && echo "good [[ \${!VarName} ]] 5" # executes fine with double [[]]
[ "${!VarName}" ] && echo 'good "${!VarName}" 6'
[ ${!VarName+x} ] && echo "good \${!VarName+x} 7"
# truthy falsy
[ $(isFalsy "$FOO") ] && echo "** should not show"
[ $(isTruthy "$FOO") ] && echo "FOO is truthy 8"
echo
```

if [ -z ${var+x} ]; then echo "var is unset"; else echo "var is set to '$var'"; fi

## booleans

bash has no Boolean data type, and so no keywords representing true and false. The if statement merely checks if the command you give it succeeds or fails. The test command takes an expression and succeeds if the expression is true; a non-empty string is an expression that evaluates as true, just as in most other programming languages. false is a command which always fails. (By analogy, true is a command that always succeeds.) 

## SED
https://edoras.sdsu.edu/doc/sed-oneliners.html


Links
https://unix.stackexchange.com/questions/224548/how-to-use-call-by-reference-on-an-argument-in-a-bash-function
http://rus.har.mn/blog/2010-07-05/subshells/
https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
https://github.com/dylanaraps/pure-bash-bible

functions
http://rus.har.mn/blog/2010-07-05/subshells/
https://unix.stackexchange.com/questions/224548/how-to-use-call-by-reference-on-an-argument-in-a-bash-function
https://github.com/tests-always-included/wick
https://mezzantrop.wordpress.com/2018/06/27/a-nice-way-to-return-string-values-from-functions-in-bash/
https://www.linuxjournal.com/content/return-values-bash-functions

bash modules and loader
https://github.com/vlisivka/bash-modules
https://github.com/basherpm/basher

Other CMD line tools from here
https://www.reddit.com/r/commandline/comments/vrmbfa/what_are_some_useful_cli_tools_that_arent_popular/
https://github.com/ranger/ranger is pretty awesone
https://rclone.org/
https://osxfuse.github.io/
https://github.com/costis94/bookcut
https://github.com/bulletmark/edir/blob/master/edir.py
https://wtfutil.com/
https://github.com/Nukesor/pueue
https://github.com/sharkdp/fd


nginx bash scripts
https://www.gushiciku.cn/pl/pQ4H/zh-hk
https://stackoverflow.com/questions/60757496/how-to-run-bash-script-from-nginx
https://serverfault.com/questions/679180/nginx-how-to-run-shell-script-on-page-load-via-lua-module-os-execute-and-then-se

bash and python
https://medium.com/capital-one-tech/bashing-the-bash-replacing-shell-scripts-with-python-d8d201bc0989
https://unix.stackexchange.com/questions/184726/how-to-include-python-script-inside-a-bash-script
https://www.educba.com/bash-shell-programming-with-python/
https://towardsdatascience.com/different-ways-to-run-bash-scripts-in-your-python-file-8aeb721bc3d1
https://www.freecodecamp.org/news/python-for-system-administration-tutorial/
