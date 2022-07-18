# Usage Docs
### 📇 Index

* [pod.sh](#podsh)
  * [pod.go()](#podgo)
  * [pod.go:faster()](#podgofaster)
* [subdir_test/misc.sh](#subdir_testmiscsh)
  * [misc.a()](#misca)
  * [misc.b()](#miscb)

## pod.sh

simple example of how a _script_ can be documented - for testing

### Description

pod = Plain Old Documentation. Its a term from the perl days and it smiliar to man
Will be able to generate man pages from it ot setup right

### pod.go()

documenting function without tags. keep it easy to read. Sticks to a markdownish like context
can provide a quick example inline like `pod.sh go "$bar"`

* __🔌 Args__

  * __$1__ (any): make it easy to comment on vars, can also use indents instead of markdown lists
  * __$2__ (any): type in the docs will default to string

### pod.go:faster()

more complex example

* __🔧 Example__

  ~~~bash
  echo "code fenced examples have the benefit if setup right of being formated in editor such as vscode"
  ~~~

* __🔌 Args__

  * __$1__ (number): args can be indented if you prefere a cleaner style
  * __$2__ (any): (can_be_whatever) the specified types can be anything
  * __$@__ (any): remaining args
  * __$3__ (any): can still use the arg tag

* __🔢 Exit Codes__

  * __>0__ : can use error codes or use @exitcode

## simple.sh

### Description

pod = Plain Old Documentation. Its a term from the perl days and it smiliar to man
Will be able to generate man pages from it ot setup right

### misc.a()

simple a

### misc.b()

desc b


