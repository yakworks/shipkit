This dir contains optional make files to include and help kickstart common targets depending on project language and structure

great resource
http://wanderinghorse.net/computing/make/book/ManagingProjectsWithGNUMake-3.1.3.pdf
https://zhjwpku.com/assets/pdf/books/Managing.Projects.With.Gnu.Make.3Rd.Edition.pdf

# Quick Cheat Sheet and Tips for Makefiles

## Formatting

- indent with tabs, NOT spaces
- to ref a variable either `${var}` or `$(var)` will work but we always use the paren format `$(...)`
  so its clear that its make and not being passed to shell
- double `##` after makefile name will display it in the help

## Targets

- the part after the `:` are the target(s) it depends on. 
- if the target is the name of file or dir then make will cache it and not run it if it exists
- so to flag a target as run and not have it run again use `touch some/path/file` for example
- `@:` when you see this it just means `@`=don't echo command and `:` which is bash for do nothing 
  but have it look like a successful nothing [see this SO](https://stackoverflow.com/questions/8610799/what-does-at-symbol-colon-mean-in-a-makefile)
- `|` in a target’s prerequisite means that those to right of `|` wont force the target to be updated if one of its rules is executed. Example `foobar: foo | bar` means "that bar must be built before foobar, but that foobar won't be considered out of date because bar is newer than foobar" See [SO answer](https://stackoverflow.com/questions/52821513/symbol-in-dependency) and [make docs](https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types)
- `$@` and `$<` - `$@` is the name of the target being generated, 
  [see this SO answer and accepted one above it](https://stackoverflow.com/questions/3220277/what-do-the-makefile-symbols-and-mean/37701195#37701195) \
  7 “core” automatic variables:

    1. `$@` - The name/filename representing the target.
    2. `$%` - The filename element of an archive member specification.
    3. `$<` - The name/filename of the first prerequisite.
    4. `$?` - The names of all prerequisites that are newer than the target, separated by spaces.
    5. `$^` - The filenames of all the prerequisites, separated by spaces. 
        This list has duplicate filenames removed since for most uses, such as compiling, copying, etc., duplicates are not wanted.
    6. `$+` - Similar to `$^`, this is the names of all the prerequisites separated by spaces, except that `$+` includes duplicates. This variable was created for specific situations such as arguments to linkers where duplicate values have meaning.
    7. `$*` -

- `:=` is called _expansion assignment_. its evaluates at the time of assignment where `=` evaluates after the whole makefile is read. [see here for good explanation](https://andylinuxblog.blogspot.com/2015/06/what-is-colon-equals-sign-in-makefiles.html)   

### Target-specific Variable

A target with a variable right after it like `foo : BAR = true`

[Gnu Docs](https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html)

## Calling shell commands

- default shell is `bin/sh` but we change it to bash with `SHELL := /bin/bash`

- prepend the command with `@` and it won't echo it to the console and reduces noise

- passing through `$` variable references will require a double `$$` to escape it, without it make will think
  its and internal reference

- each line in a target runs in a new shell. To run them together its recomended to create a
  function in the build.sh and call that as its can get a little ugly in `make`. 
  if you need to do it in make then each exec should end 
  with `;` and a `\` if its multiline. for example (note if you copy this example make sure to convert indent spaces to tabs):
  ```
  foo: ## shows foos
      @FOOS="buzz bar bazz"; \
      for f in $$FOOS; do \
        echo "$$f"; \
      done;
  ```

- `make` can call it self using the `$(MAKE)` built in. so to call a build target `$(MAKE) build` can be used
