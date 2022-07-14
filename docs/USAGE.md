
## Array

: Functions for array operations and manipulations.


---

### array.contains()

Check if item exists in the given array.

#### 🔌 Arguments

- **$1** | (string) |  Item to search (needle).
- **$2** | (array) |  Array to be searched (haystack).

#### 💡 Return codes

- **0** 🎯 - If successful.
- **1** 💥 - If no match found in the array.
- **2** 💥 - Function missing arguments.

#### Example

```bash
 array=("a" "b" "c")
 array.contains "c" ${array[@]}
 #Output
 0
```

---

### array.dedupe()

Remove duplicate items from the array.

#### 🔌 Arguments

- **$1** | (array) |  Array to be deduped.

#### 💡 Return codes

- **0** 🎯 - If successful.
- **2** 💥 - Function missing arguments.

#### 🖨 Stdout output

-  Deduplicated array.

#### Example

```bash
 array=("a" "b" "a" "c")
 printf "%s" "$(array.dedupe ${array[@]})"
 #Output
 a
 b
 c
```

---

### array.is_empty()

Check if a given array is empty.

#### 🔌 Arguments

- **$1** | (array) |  Array to be checked.

#### 💡 Return codes

- **0** 🎯 - If the given array is empty.
- **2** 💥 - If the given array is not empty.

#### Example

```bash
  array=("a" "b" "c" "d")
  array.is_empty "${array[@]}"
```

---

### array.join()

Join array elements with a string.
the output is a string containing a string representation of all the array elements in the same order,
with the $2 glue string between each element.

#### 🔌 Arguments

- **$1** | (string) | String to join the array elements (glue).
- **$2** | (array) |  The array to be joined with glue string.

#### 💡 Return codes

- **0** 🎯 If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  string representation of all the array elements

#### Example

```bash
  array=("a" "b" "c" "d")
  printf "%s" "$(array.join "," "${array[@]}")"
  #Output
  a,b,c,d
  printf "%s" "$(array.join "" "${array[@]}")"
  #Output
  abcd
```

---

### array.reverse()

Return an array with elements in reverse order.

#### 🔌 Arguments

- **$1** | (array) |  The input array.

#### 💡 Return codes

- **0** 🎯  If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  The reversed array.

#### Example

```bash
  array=(1 2 3 4 5)
  printf "%s" "$(array.reverse "${array[@]}")"
  #Output
  5 4 3 2 1
```

---

### array.random_element()

Returns a random item from the array.

#### 🔌 Arguments

- **$1** | (array) |  The input array.

#### 💡 Return codes

- **0** 🎯 If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  Random item out of the array.

#### Example

```bash
  array=("a" "b" "c" "d")
  printf "%s\n" "$(array.random_element "${array[@]}")"
  #Output
  c
```

---

### array.sort()

Sort an array from lowest to highest.

#### 🔌 Arguments

- **$1** | (string) | array The input array.

#### 💡 Return codes

- **0** 🎯  If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  sorted array.

#### Example

```bash
  sarr=("a c" "a" "d" 2 1 "4 5")
  array.array_sort "${sarr[@]}"
  #Output
  1
  2
  4 5
  a
  a c
  d
```

---

### array.rsort()

Sort an array in reverse order (highest to lowest).

#### 🔌 Arguments

- **$1** | (string) | array The input array.

#### 💡 Return codes

- **0** 🎯  If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  reverse sorted array.

#### Example

```bash
  sarr=("a c" "a" "d" 2 1 "4 5")
  array.array_sort "${sarr[@]}"
  #Output
  d
  a c
  a
  4 5
  2
  1
```

---

### array.bsort()

Bubble sort an integer array from lowest to highest.
This sort does not work on string array.

#### 🔌 Arguments

- **$1** | (array) |  The input array.

#### 💡 Return codes

- **0** 🎯  If successful.
- **2** 💥 Function missing arguments.

#### 🖨 Stdout output

-  bubble sorted array.

#### Example

```bash
  iarr=(4 5 1 3)
  array.bsort "${iarr[@]}"
  #Output
  1
  3
  4
  5
```

---

### array.merge()

Merge two arrays.
Pass the variable name of the array instead of value of the variable.

#### 🔌 Arguments

- **$1** | (string) | string variable name of first array.
- **$2** | (string) | string variable name of second array.

#### 💡 Return codes

- **0** 🎯 - If successful.
- **2** 💥 - Function missing arguments.

#### 🖨 Stdout output

-  Merged array.

#### Example

```bash
  a=("a" "c")
  b=("d" "c")
  array.merge "a[@]" "b[@]"
  #Output
  a
  c
  d
  c
```


## String

Functions for string operations and manipulations.


---

### string.trim()

Strip whitespace from the beginning and end of a string.

#### 🔌 Arguments

- **$1** | (string) | string The string to be trimmed.

#### 🖨 Stdout output

-  The trimmed string.

#### Example

```bash
echo "$(string::trim "   Hello World!   ")"
#Output
Hello World!
```

---

### string::split()

Split a string to array by a delimiter.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The delimiter string.

#### 🖨 Stdout output

-  Returns an array of strings created by splitting the string parameter by the delimiter.

#### Example

```bash
array=( $(string::split "a,b,c" ",") )
printf "%s" "$(string::split "Hello!World" "!")"
#Output
Hello
World
```

---

### string::lstrip()

Strip characters from the beginning of a string.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The characters you want to strip.

#### 🖨 Stdout output

-  Returns the modified string.

#### Example

```bash
echo "$(string::lstrip "Hello World!" "He")"
#Output
llo World!
```

---

### string::rstrip()

Strip characters from the end of a string.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The characters you want to strip.

#### 🖨 Stdout output

-  Returns the modified string.

#### Example

```bash
echo "$(string::rstrip "Hello World!" "d!")"
#Output
Hello Worl
```

---

### string::to_lower()

Make a string lowercase.

#### 🔌 Arguments

- **$1** | (string) | string The input string.

#### 🖨 Stdout output

-  Returns the lowercased string.

#### Example

```bash
echo "$(string::to_lower "HellO")"
#Output
hello
```

---

### string::to_upper()

Make a string all uppercase.

#### 🔌 Arguments

- **$1** | (string) | string The input string.

#### 🖨 Stdout output

-  Returns the uppercased string.

#### Example

```bash
echo "$(string::to_upper "HellO")"
#Output
HELLO
```

---

### string::contains()

Check whether the search string exists within the input string.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The search key.

#### Example

```bash
string::contains "Hello World!" "lo"
```

---

### string::starts_with()

Check whether the input string starts with key string.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The search key.

#### Example

```bash
string::starts_with "Hello World!" "He"
```

---

### string::ends_with()

Check whether the input string ends with key string.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The search key.

#### Example

```bash
string::ends_with "Hello World!" "d!"
```

---

### string::regex()

Check whether the input string matches the given regex.

#### 🔌 Arguments

- **$1** | (string) | string The input string.
- **$2** | (string) | string The search key.

#### Example

```bash
string::regex "HELLO" "^[A-Z]*$"
```


## makechecker

Checks makefiles for common issues. The main one being 4 spaces instead of tab to start shell commands


---

### function makechecker.lint {

Lints a one or more dirs
The main issue to check for is lines starting with 4 spaces

#### 🔌 Arguments

- $@ - {array} one or more dirs

#### Example

```bash
  makechecker lint makefiles
```

---

### function makechecker.lint_files {

Lint one or more files

#### 🔌 Arguments

- $@ - {array} list of files

#### 💡 Return codes

- **0** 🎯 - success
- **1** 💥 - bad makefile

---

### function makechecker.find_targets {

gets all files that either start with Makefile or have .make extension

#### 🔌 Arguments

- $@ - {array} one or more dirs



## circle

utils for working with CI circle and publishing,


---

### circle.trigger()


uses curl to trigger a pipeline
$1 - the owner/repo
$2 - the circle token


## is.sh

@description Various validations and asserts that can be chained
and be explicit in a DSL-like way.
@example
    source lib/is.sh
    is.begin "Checking for file validity"
    is.not-blank "$1" && is.non-empty


---

### __is.validation.error()

Private Helper Function
Invoke a validation on the value, and process
                  the invalid case using a customizable error handler.

#### 🔌 Arguments

- 1 func        Validation function name to invoke
- 2 var         Value under the test
- 4 error_func  Error function to call when validation fails

---

### is-validations()

Returns the list of validation functions available

---

### __is.validation.ignore-error()

Private function that ignores errors

---

### __is.validation.report-error()

Private function that ignores errors

---

### validations.begin()

Public API
Part 1. supporting functions

---

### 

---

### 

---

### 

---

### is.not-blank()

Public API
Part 2. "is" validations — no output, just return code
is.not-blank <arg>

#### 💡 Return codes

- true if the first argument is not blank

---

### is.blank()

is.blank <arg>

#### 💡 Return codes

- true if the first argument is blank

---

### is.empty()

is.empty <arg>

#### 💡 Return codes

- true if the first argument is blank or empty

---

### is.not-a-blank-var()

is.not-a-blank-var <var-name>

#### 💡 Return codes

- true if varaible passed by name is not blank

---

### is.a-non-empty-file()

is.a-non-empty-file <file>

#### 💡 Return codes

- true if the file passed is non epmpty

---

### is.an-empty-file()

is.an-empty-file <file>

#### 💡 Return codes

- true if the file passed is epmpty

---

### is.a-directory()

is.a-directory <dir>

#### 💡 Return codes

- true if the argument is a propery

---

### is.an-existing-file()

is.an-existing-file <file>

#### 💡 Return codes

- true if the file exits

---

### is.a-function.invoke()

if the argument passed is a value function, invoke it

#### 💡 Return codes

- exit status of the function

---

### is.a-function()

verifies that the argument is a valid shell function

---

### is.a-variable()

verifies that the argument is a valid and defined variable

---

### 

---

### is.a-non-empty-array()

verifies that the argument is a non-empty array

---

### is.sourced-in()

verifies that the argument is a valid and defined variable

---

### is.a-script()

returns success if the current script is executing in a subshell

---

### is.integer()

returns success if the argument is an integer

#### See also

- [https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash](#httpsstackoverflowcomquestions806906how-do-i-test-if-a-variable-is-a-number-in-bash)

---

### is.an-integer()

returns success if the argument is an integer

---

### is.numeric()

returns success if the argument is numeric, eg. float

---

### is.command()

returns success if the argument is a valid command found in the $PATH

---

### is.a-command()

returns success if the argument is a valid command found in the $PATH

---

### is.missing()

returns success if the command passed as an argument is not in $PATH

---

### is.alias()

returns success if the argument is a current alias

---

### is.zero()

returns success if the argument is a numerical zero

---

### is.non.zero()

returns success if the argument is not a zero

---

### whenever()

Public API
Part 3. error versions of each validation, which print an error messages
a convenient DSL for validating things

#### Example

```bash
   whenever /var/log/postgresql.log is.an-empty-file && {
      touch /var/log/postgresql.log
   }
```

---

### unless()

a convenient DSL for validating things

#### Example

```bash
   unless /var/log/postgresql.log is.an-non-empty-file && {
      touch /var/log/postgresql.log
   }
```

