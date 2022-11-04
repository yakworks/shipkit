Chapter 19. Using make to Build C Programs
------------------------------------------

As you saw in [Chapter 18](cinanut-CHP-18.html#cinanut-CHP-18), the commands involved in compiling and linking C programs can be numerous and complex. The _make_ utility automates and manages the process of compiling programs of any size and complexity, so that a single _make_ command replaces hundreds of compiler and linker commands. Moreover, _make_ compares the timestamps of related files to avoid having to repeat any previous work. And most importantly, _make_ manages the individual rules that define how to build various targets, and automatically analyzes the dependency relationships between all the files involved.

There are a number of different versions of _make_, and their features and usage differ to varying degrees. They feature different sets of built-in variables and targets with special meanings. In this brief chapter, rather than trying to cover different varieties, we concentrate on GNU _make_, which is widely available. (On systems that use a different default _make_, GNU _make_ is often available under the executable name _gmake_.) Furthermore, even as far as GNU _make_ is concerned, this chapter sticks more or less to the basics: in this book, we want to use _make_ only as a tool for building programs from C source code. If you want to go on to exploit the full capabilities of _make_, an inevitable step is to read the program's documentation itself. For a well-structured course in using _make_'s advanced capabilities, see also _Managing Projects with GNU make_ by Robert Mecklenburg (O'Reilly).

### 19.1. Targets, Prerequisites, and Commands

Before we describe the _make_ solution, we will briefly review the problem. To make an executable program, we need to link compiled object files. To generate object files, we need to compile C source files. The source files in turn need to be preprocessed to include their header files. And whenever we have edited a source or header file, then any file that was directly or indirectly generated from it needs to be rebuilt.

The _make_ utility organizes the work just described in the form of _rules_. For C programs, these rules generally take the following form: the executable file is a _target_ that must be rebuilt whenever certain object files have changedthe object files are its _prerequisites_. At the same time, the object files are _intermediate targets_, which must be recompiled if the source and header files have changed. (Thus the executable depends indirectly on the source files. _make_ manages such dependency chains elegantly, even when they become complex.) The rule for each target generally contains one or more commands, called the _command script_, that _make_ executes to build it. For example , the rule for building the executable file says to run the linker, while the rule for building object files says to run the preprocessor and compiler. In other words, a rule's prerequisites say when to build the target, and the command script says how to build it.

### 19.2. The Makefile

The _make_ program has a special syntax for its rules. Furthermore, the rules for all the operations that you want _make_ to manage in your project generally need to be collected in a file for _make_ to read. The command-line option \-f _filename_ tells _make_ which file contains the rules you want it to apply. Usually, though, this option is omitted and _make_ looks for a file with the default name _makefile_, or failing that, _Makefile_.

When you read makefiles , remember that they are not simply scripts to be executed in sequential order. Rather, _make_ first analyzes an entire makefile to build a dependency tree of possible targets and their prerequisites, then iterates through that dependency tree to build the desired targets.

In addition to rules, makefiles also contain comments, variable assignments, macro definitions, include directives, and conditional directives. These will be discussed in later sections of this chapter, after we have taken a closer look at the meat of the makefile: the rules.

### 19.3. Rules


##### Example 19-1. A basic makefile

~~~bash
# A basic makefile for "circle".
 
CC = gcc
CFLAGS = -Wall -g -std=c99
LDFLAGS = -lm
 
circle : circle.o circulararea.o
        $(CC) $(LDFLAGS) -o $@ $^
 
circle.o : circle.c
        $(CC) $(CFLAGS) -o $@ -c $<
 
circulararea.o: circulararea.c
        $(CC) $(CFLAGS) -o $@ -c $<

~~~

The line that begins with the character # is a comment, which _make_ ignores. This makefile begins by defining some variables, which are used in the statements that follow. The rest of the file consists of rules, whose general form is:

~~~bash
_target_ [_target_ [_..._]\] : [_prerequisite_[_prerequisite_[_..._]]]
        [_command_
        [_command_
        [_..._]]]
~~~
  

The first _target_ must be placed at the beginning of the line, with no whitespace to the left of it. Moreover, each _command_ line must start with a tab character. (It would be simpler if all whitespace characters were permissible here, but that's not the case.)

Each rule in the makefile says, in effect: if any _target_ is older than any _prerequisite_, then execute the _command_ script. More importantly, _make_ also checks whether the prerequisites have other prerequisites in turn before it starts executing commands.

Both the prerequisites and the command script are optional. A rule with no command script only tells _make_ about a dependency relationship; and a rule with no prerequisites tells only how to build the target, not when to build it. You can also put the prerequisites for a given target in one rule, and the command script in another. For any target requested, whether on the _make_ command line or as a prerequisite for another target, _make_ collects all the pertinent information from all rules for that target before it acts on them.

[Example 19-1](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-1) shows two different notations for variable references in the command script. Variable names that consist of more than one characterin this case, CC, CFLAGS, and LDFLAGSmust be prefixed with a dollar sign and enclosed in parentheses when referenced. Variables that consist of just one characterin our example, these happen to be the automatic variables ^, <, and @need just the dollar sign, not the parentheses. We discuss variables in detail in a separate section later in this chapter. The following program output shows how _make_ expands both kinds of variables to generate compiler commands:

~~~bash
$ make -n -f Makefile19-1 circle
gcc -Wall -g -std=c99 -o circle.o -c circle.c
gcc -Wall -g -std=c99 -o circulararea.o -c circulararea.c
gcc -lm -o circle circle.o circulararea.o
~~~
  

The command-line option \-n instructs _make_ to print the commands it would otherwise execute to build the specified targets. This option is indispensable when testing makefiles. (A complete reference list of _make_ options is included at the end of this chapter.) The final line of output corresponds to the first rule contained in [Example 19-1](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-1). It shows that _make_ expands the variable reference `$(CC)` to the text gcc and `$(LDFLAGS)` to `-lm`. The automatic variables `\$@` and `\$^` expand to the target circle and the prerequisite list circle.o circulararea.o. In the first two output lines, the automatic variable `$<` is expanded to just one prerequisite, which is the name of the C source file to be compiled.

#### 19.3.1. The Command Script

The command script for a rule can consist of several lines, each of which must begin with a tab. Comments and blank lines are ignored, so that the command script ends with the next target line or variable definition.

Furthermore, the first line of the command script may be placed after a semicolon at the end of the dependency line, thus:

~~~bash
target_list : [prerequisite_list] ; [command
        [command
        [...]]]
~~~

  

This variant is rarely used today, however.

The important thing to remember about the command part of a _make_ rule is that it is not a shell script. When _make_ invokes a rule to build its target, each line in the rule's command section is executed individually, in a separate shell instance. Thus you must make sure that no command depends on the side effects of a preceding line. For example, the following commands will not run _etags_ in the _src_ subdirectory:

~~~bash
TAGS:
        cd src/
        etags *.c
~~~
  

In trying to build TAGS, _make_ runs the shell command cd src/ in the current directory. When that command exits, _make_ runs etags \*.c in a new shell, again in the current directory.

There are ways to cause several commands to run in the same shell: putting them on one line, separated by a semicolon, or adding a backslash to place them virtually on one line:

~~~bash
TAGS:
        cd src/    ;\
        etags *.c
~~~
  

Another reason for running multiple commands in the same shell could be to speed up processing, especially in large projects.

#### 19.3.2. Pattern Rules

The last two rules in [Example 19-1](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-1) show a repetitive pattern. Each of the two object files, _circle.o_ and _circulararea.o_, depends on a source file with the same name and the suffix _.c_, and the commands to build them are the same. _make_ lets you describe such cases economically using _pattern rules_ . Here is a single rule that replaces the last two rules in [Example 19-1](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-1):

~~~bash
circulararea.o circle.o: %.o: %.c
        $(CC) $(CFLAGS) -o $@ -c $<
~~~
  

The first line of this rule has three colon-separated parts rather than two. The first part is a list of the targets that the rule applies to. The rest of the line, %.o: %.c, is a pattern explaining how to derive a prerequisite name from each of the targets, using the percent sign (%) as a wildcard. When _make_ matches each target in the list against the pattern %.o, the part of the target that corresponds to the wildcard % is called the _stem_. The stem is then substituted for the percent sign in %.c to yield the prerequisite.

The general syntax of such pattern rules is:

~~~bash
[target_list :] target_pattern : prerequisite_pattern
        [command-script]
~~~

  

You must make sure that each target in the list matches the target pattern. Otherwise, _make_ issues an error message.

If you include an explicit target list, the rule is a _static pattern rule_. If you omit the target list, the rule is called an _implicit rule_, and applies to any target whose name matches the target pattern. For example, if you expect to add more modules as the _circle_ program grows and evolves, you can make a rule for all present and future object files in the project like this:

~~~bash
%.o: %.c
        $(CC) $(CFLAGS) -o $@ -c $<
~~~

  

And if a certain object needs to be handled differently for some reason, you can put a static pattern rule for that object file in the makefile as well. _make_ then applies the static rule for targets explicitly named in it, and the implicit rule for all other _.o_ files. Also, _make_ refrains from announcing an error if any object file's implicit prerequisite does not exist.

The percent sign is usually used only once in each pattern. To represent a literal percent sign in a pattern, you must escape it with a backslash. For example, the filename `app%3amodule.o` matches the pattern `app\%3a%.o`, and the resulting stem is module. To use a literal backslash in a pattern without escaping a percent sign that happens to follow it, you need to escape the backslash itself. Thus the filename `app\module.o` would match the pattern `app\\%.o`, yielding the stem module.

#### 19.3.3. Suffix Rules

The kind of pattern rule in which the percent sign represents all but the filename's suffix is the modern way of expressing a _suffix rule_. In older makefiles, you might see such a rule expressed in the following notation:

~~~bash
.c.o:
        $(CC) $(CFLAGS) ...
~~~
  

The "target" in this rule consists simply of the target and source filename suffixesand in the opposite order; that is, with the source suffix first, followed by the target suffix. This example with the target .c.o: is equivalent to a pattern rule beginning with %o: %c. If a suffix rule target contains only one suffix, then that is the suffix for source filenames, and target filenames under that rule are assumed to have no suffix.

GNU _make_ also supports suffix rules , but that notation is considered obsolete. Pattern rules using the % wildcard character are more readable, and more versatile.

Every suffix used in the target of a suffix rule must be a "known suffix." _make_ stores its list of known suffixes in the built-in variable SUFFIXES. You can add your own suffixes by declaring them as prerequisites of the built-in target .SUFFIXES (see the section "[Special Targets Used as Runtime Options](cinanut-CHP-19-SECT-11.html#cinanut-CHP-19-SECT-11.4)," near the end of this chapter, for more about his technique).

#### 19.3.4. Built-in Rules

You don't have to tell _make_ how to do standard operations like compiling an object file from C source; the program has a built-in default rule for that operation, and for many others. [Example 19-2](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-2) shows a more elegant version of our sample makefile that takes advantage of built-in rules .

##### Example 19-2. A makefile using built-in rules

```bash
# A slightly more elegant makefile for "circle".
 
CC = gcc
CFLAGS = -Werror -std=c99
OBJS =  circle.o circulararea.o
 
circle: $(OBJS) -lm
```
  

This makefile does away with the rule for compiling source code into objects, depending instead on _make_'s built-in pattern rule. Furthermore, the rule that says the executable _circle_ depends on the two object files has no command script. This is because _make_ also has a built-in rule to link objects to build an executable. We will look at those built-in rules in a moment. First, suppose we enter this command:

~~~
$ touch *.c ; make circle
~~~
  

This produces roughly the same output as before:

~~~
gcc -Werror -std=c99   -c -o circle.o circle.c
gcc -Werror -std=c99   -c -o circulararea.o circulararea.c
gcc circle.o circulararea.o  /usr/lib/libm.so  -o circle
~~~
  

None of these commands is visible in the new makefile in [Example 19-2](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-2), even if individual arguments are recognizable in the variable assignments. To display _make_'s built-in rules (as well as the variables at work), you can run the program with the command-line switch \-p. The output is rather long. Here are the parts of it that are relevant to our example (including the comments that _make_ generates to identify where each variable or rule definition originates):

~~~
# default
OUTPUT_OPTION = -o $@
 
# default
LINK.o = $(CC) $(LDFLAGS) $(TARGET_ARCH)
 
# default
COMPILE.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
 
%: %.o
#  commands to execute (built-in):
        $(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@
 
%.o: %.c
#  commands to execute (built-in):
        $(COMPILE.c) $(OUTPUT_OPTION) $<
~~~

Note that the linking step was handled by a combination of two rules; _make_ automatically applied the command defined by the built-in rule using the information about the prerequisites provided by the dependency rule in the makefile.

Finally, the makefile in [Example 19-2](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-2), unlike [Example 19-1](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-1), does not define a variable for linker options. Instead, it correctly lists the C math library as a prerequisite of the executable _circle_, using the same \-lm notation as the compiler's command line. The output shown illustrates how _make_ expands this notation to the full library filename.

#### 19.3.5. Implicit Rule Chains

_make_ tries to use implicit rules, whether built-in ones or pattern rules from the makefile, for any target that doesn't have an explicit rule with a command script. There may be many implicit rules that match a given target. For example, _make_ has built-in rules to generate an object file (matching the pattern %.o) from source code in C (%.c) or C++ (%.cpp) or even assembler (%.s). Which rule does _make_ use, then? It selects the first one in the list for which the prerequisites either are available or can be made by applying appropriate rules. In this way, _make_ can automatically apply a _chain_ of implicit rules to generate a target. If _make_ generates any _intermediate_ files that are not mentioned in the makefile, it deletes them once they have served their purpose. For example, suppose that the current directory contains only the file _square.c_, and the makefile contains the following:

~~~
%: %.o
        cc -o $@ $^
 
%.o : %.c
        cc -c -o $@ $<
~~~
  

To disable all the built-in rules and use only the two implicit rules we can see in the makefile, we'll run _make_ with the \-r option:

~~~
$ **ls**
Makefile  square.c
$ **make -r square**
cc -c -o square.o square.c
cc -o square square.o
rm square.o
$ **ls**
Makefile square  square.c
~~~
  

From the target, the two implicit rules in the makefile, and the available source file, _make_ found the indirect way to build the target, and then automatically cleaned up the intermediate object file, because it isn't mentioned in the makefile or on the command line.

#### 19.3.6. Double-Colon Rules

Before we move away from rules, another kind of rule that you should know about is the _double-colon rule_, so named because it has not one, but two colons between the targets and the prerequisites:

~~~
_target_ :: _prerequisites
    command_s
~~~
  

Double-colon rules are the same as single-colon rules, unless your makefile contains multiple double-colon rules for the same target. In that case, _make_ treats the rules as alternative rather than cumulative: instead of collating all the rules' prerequisites into a single set of dependencies for the target, _make_ tests the target against each rule's prerequisites separately to decide whether to execute that rule's script. [Example 19-3](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-3) shows a makefile that uses double-colon rules.

##### Example 19-3. Double-colon rules

~~~
# A makefile for "circle" to demonstrate double-colon rules.
 
CC = gcc
RM = rm -f
CFLAGS = -Wall -std=c99
DBGFLAGS = -ggdb -pg
DEBUGFILE = ./debug
SRC = circle.c circulararea.c
 
circle :: $(SRC)
        $(CC) $(CFLAGS) -o $@ -lm $^
 
circle :: $(DEBUGFILE)
        $(CC) $(CFLAGS) $(DBGFLAGS) -o $@ -lm $(SRC)
 
.PHONY : clean
clean  :
        $(RM) circle

~~~

The makefile in [Example 19-3](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-EX-3) builds the target _circle_ in either of two ways, with or without debugging options in the compiler command line. In the first rule for _circle_, the target depends on the source files. _make_ runs the command for this rule if the source files are newer than the executable. In the second rule, _circle_ depends on a file named _debug_ in the current directory. The command for that rule doesn't use the prerequisite _debug_ at all. That file is empty; it just sits in the directory for the sake of its timestamp, which tells _make_ whether to build a debugging version of the _circle_ executable. The following sample session illustrates how _make_ can alternate between the two rules:

~~~

$ make clean
rm -f circle
$ make circle
gcc -Wall -std=c99 -o circle -lm circle.c circulararea.c
$ make circle
make: `circle' is up to date.
$ touch debug
$ make circle
gcc -Wall -std=c99 -ggdb -pg -o circle -lm circle.c circulararea.c
$ make circle
make: `circle' is up to date.
$ make clean
rm -f circle
$ make circle
gcc -Wall -std=c99 -o circle -lm circle.c circulararea.c
~~~
  

As the output shows, _make_ applies only one rule or the other, depending on which rule's prerequisites are newer than the target. (If both rules' prerequisites are newer than the target, _make_ applies the rule that appears first in the makefile.)

[![](images/pixel.jpg)](http://85.147.245.113/mirrorbooks/cinanutshell/0596006977/0596006977/31071535.html)


### 19.4. Comments

In a makefile, a hash mark (#) anywhere in a line begins a comment, unless the line is a command. make ignores comments, as if the text from the hash mark to the end of its line did not exist. Comments (like blank lines) between the lines of a rule do not interrupt its continuity. Leading whitespace before a hash mark is ignored.

If a line containing a hash mark is a commandthat is, if it begins with a tab characterthen it cannot contain a make comment. If the corresponding target needs to be built, make passes the entire command line, minus the leading tab character, to the shell for execution. (Some shells, such as the Bourne shell, also interpret the hash mark as introducing a comment, but that is beyond make's control.)

### 19.5. Variables

All variables in _make_ are of the same type: they contain sequences of characters, never numeric values. Whenever _make_ applies a rule, it evaluates all the variables contained in the targets, prerequisites, and commands. Variables in GNU _make_ come in two "flavors," called _recursively expanded_ and _simply expanded_ variables. Which flavor a given variable has is determined by the specific assignment operator used in its definition. In a recursively expanded variable, nested variable references are stored verbatim until the variable is evaluated. In a simply expanded variable, on the other hand, variable references in the value are expanded immediately on assignment, and their expanded values are stored, not their names.

Variable names can include any character except :, \=, and #. However, for robust makefiles and compatibility with shell constraints, you should use only letters, digits, and the underscore character.

#### 19.5.1. Assignment Operators

Which assignment operator you use in defining a variable determines whether it is a simply or a recursively expanded variable. The assignment operator \= in the following example creates a recursively expanded variable:

~~~
DEBUGFLAGS = $(CFLAGS) -ggdb -DDEBUG -O0
~~~
  

_make_ stores the character sequence to the right of the equals sign verbatim; the nested variable $(CFLAGS) is not expanded until $(DEBUGFLAGS) is used.

To create a simply expanded variable, use the assignment operator := as shown in the following example:

~~~
OBJ = circle.o circulararea.o
TESTOBJ := $(OBJ) profile.o
~~~
  

In this case _make_ stores the character sequence `circle.o circulararea.o profile.o` as the value of `$(TESTOBJ)`. If a subsequent assignment modifies the value of `$(OBJ), $(TESTOBJ)` is not affected.

You can define both recursively expanded and simply expanded variables not only in the makefile, but also on the _make_ command line, as in the following example:

~~~
$ make CFLAGS=-ffinite-math-only circulararea.o
~~~

Each such assignment must be contained in a single command-line argument. If the assignment contains spaces, you must escape them or enclose the entire assignment in quotation marks. Any variable defined on the command line, or in the shell environment, can be cancelled out by an assignment in the makefile that starts with the optional override keyword, as this one does:

~~~
override CPPLFAGS = -DDEBUG
~~~
  

Use override assignments with caution, unless you want to confuse and frustrate future users of your makefile.

_make_ also provides two more assignment operators. Here is the complete list:


* `=`  Defines a recursively expanded variable.

* `:=`  Defines a simply expanded variable.

* `+=`  Also called the _append operator_. Appends more characters to the existing value of a variable. If the left operand is not yet defined, 
  the assignment defines a recursively expanded variable. Or, to put it another way, the result of the append operator is a recursively expanded variable, unless its left operand already exists as a simply expanded variable.
  
  This operator provides the only way to append characters to the value of a recursively expanded variable. The following assignment is wrong, as recursive expansion would cause an infinite loop:

  ~~~
  OBJ = $(OBJ) profile.o
  ~~~
  
  Here is the right way to do it:

  ~~~
  OBJ += profile.o
  ~~~
  
  The += operator automatically inserts a space before appending the new text to the variable's previous value.

* `?=` The _conditional assignment_ operator. Assigns a value to a variable, but only if the variable has no value.

  The conditional assignment operator can only define recursively expanded variables. If its left operand already exists, it remains unaffected, 
  regardless of whether it is a simply expanded or a recursively expanded variable.

  In addition to these operations, there are two more ways to define _make_ variables. One is the define directive, 
  used to create variables of multiple lines; we will discuss this in the section "[Macros](cinanut-CHP-19-SECT-8.html#cinanut-CHP-19-SECT-8)," 
  later in this chapter. Another is by setting environment variables in the system shell before you invoke _make_. 
  We will discuss _make_'s use of environment variables later in the chapter as well.

#### 19.5.2. Variables and Whitespace

In a variable assignment, _make_ ignores any whitespace between the assignment operator and the first non-whitespace character of the value. However, trailing whitespace up to the end of the line containing the variable assignment, or up to a comment that follows on the same line, becomes part of the variable's value. Usually this behavior is unimportant, because most references to _make_ variables are options in shell command lines, where additional whitespace has no effect. However, if you use variable references to construct file or directory names, unintended whitespace at the end of an assignment line can be fatal.

On the other hand, if you develop complex makefiles, you could sometimes need a literal space that _make_ does not ignore or interpret as a list separator. The easiest way is to use a variable whose value is a single space character, but defining such a variable is tricky. Simply enclosing a space in quotation marks does not have the same effect as in C. Consider the following assignment:

~~~
ONESPACE := ' '
TEST = Does$(ONESPACE)this$(ONESPACE)work?
~~~
  

In this case, a reference to $(TEST) would expand to the following text:

~~~
Does' 'this' 'work?
~~~

Double quotation marks are no different: they also become part of the variable's value. To define a variable containing just the space and nothing else, you can use the following lines:

~~~
NOTHING :=
ONESPACE := $(NOTHING) # This comment terminates the variable's value.
~~~
  

The variable reference $(NOTHING) expands to zero characters, but it ends the leading whitespace that _make_ trims off after the assignment operator. If you do not insert a comment after the space character that follows $(NOTHING), you may find it hard to tell when editing the makefile whether the single trailing space is present as desired.

#### 19.5.3. Target-Specific Variable Assignments

You can make any of the assignment operations apply to only a specific target (or target pattern) by including a line in your makefile with the form:

~~~
target_list: [override] assignment
~~~

While _make_ is building the given targetor its prerequisitesthe target-specific or pattern-specific variable supersedes any other definition of the same variable name elsewhere in the makefile.

[Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4) shows a sample makefile illustrating different kinds of assignments.

##### Example 19-4. Variable assignments

~~~
# Tools and options:
CC = gcc
CFLAGS = -c -Wall -std=c99 $(ASMFLAGS)
DEBUGCFLAGS = -ggdb -O0
RM = rm -f
MKDIR = mkdir -p
 
# Filenames:
OBJ = circle.o circulararea.o
SYMTABS = $(OBJ .o=.sym)
EXEC = circle
 
# The primary targets:
production: clean circle
 
testing: clean debug
 
symbols: $(SYMTABS)
 
clean:
        $(RM) $(OBJ) *.sym circle dcircle
 
# Rules to build prerequisites:
circle debug: $(OBJ) -lm
        $(CC) $(LDFLAGS) -o $(EXEC) $^
 
$(OBJ): %.o: %.c
        $(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $<
 
$(SYMTABS): %.sym: %.c
        $(CC) $(CFLAGS) $(CPPFLAGS) -o $*.o $<
 
# Target-specific options:
debug: CPPFLAGS += -DDEBUG
debug: EXEC = circle-dbg
debug symbols: CFLAGS += $(DEBUGCFLAGS)
symbols: ASMFLAGS = -Wa,-as=$*.sym,-L
~~~

  

For the targets debug and symbols, this makefile uses the append operator to add the value of DEBUGCFLAGS to the value of CFLAGS, while conserving any compiler flags already defined.

The assignment to SYMTABS illustrates another feature of _make_ variables: you can perform substitutions when referencing them. As [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4) illustrates, a substitution reference has this form:

~~~
$(name: ending=new_ending)
~~~
  

When you reference a variable in this way, _make_ expands it, then checks the end of each word in the value (where a word is a sequence of non-whitespace characters followed by a whitespace character, or by the end of the value) for the string _ending_. If the word ends with _ending_, _make_ replaces that part with _new\_ending_. In [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4), the resulting value of $(SYMTABS) is circle.sym circulararea.sym.

The variable CFLAGS is defined near the top of the makefile, with an unconditional assignment. The expansion of the nested variable it contains, $(ASMFLAGS), is deferred until _make_ expands $(CFLAGS) in order to execute the compiler command. The value of $(ASMFLAGS) for example may be \-Wa,-as=circle.sym,-L, or it may be nothing. When _make_ builds the target symbols, the compiler command expands recursively to:

~~~
gcc -c -Wall -std=c99 -Wa,-as=circle.sym,-L -ggdb -O0   -o circle.o circle.c
gcc -c -Wall -std=c99 -Wa,-as=circulararea.sym,-L -ggdb -O0   -o circulararea.o 
circulararea.c
~~~
  

As you can see, if there is no variable defined with the name CPPFLAGS at the time of variable expansion, _make_ simply replaces $(CPPFLAGS) with nothing.

    Unlike C, _make_ doesn't balk at undefined variables. 
    The only difference between an undefined variable and a variable whose value contains no characters is that a defined variable has a determined flavor: 
    it is either simply expanded or recursively expanded, and cannot change its behavior, even if you assign it a new value.

Like many real-life makefiles, the one in [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4) uses variables to store the names of common utilities like _mkdir_ and _rm_ together with the standard options that we want to use with them. This approach not only saves repetition in the makefile's command scripts, but also makes maintenance and porting easier.

#### 19.5.4. The Automatic Variables

The command scripts in [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4) also contain a number of single-character variables: $@, $<, $^, and $\*. These are _automatic variables_, which _make_ defines and expands itself in carrying out each rule. Here is a complete list of the automatic variables and their meanings in a given rule:

  

`$@`

    The target filename.

  

`$*`

The stem of the target filenamethat is, the part represented by % in a pattern rule.

  

`$<`

The first prerequisite.

  

`$^`

The list of prerequisites, excluding duplicate elements.

  

`$?`

The list of prerequisites that are newer than the target.

  

`$+`

The full list of prerequisites, including duplicates.

  

`$%`

If the target is an archive member, the variable $% yields the member name without the archive filename, and $@ supplies the filename of the archive.

The last of these automatic variables brings up a special target case. Because most programs depend not only on source code, but also on library modules, _make_ also provides a special notation for targets that are members of an archive:

~~~
archive_name(member_name): [prerequisites]
        [command_script]
~~~


The name of the archive member is enclosed in parentheses immediately after the filename of the archive itself. Here is an example:

~~~
AR = ar -rv
 
libcircularmath.a(circulararea.o): circulararea.o
      $(AR) $@ $%
~~~
  

This rule executes the following command to add or replace the object file in the archive:

~~~
ar -rv libcircularmath.a circulararea.o
~~~
  

In other _make_ versions, these special variables also have long names that start with a dot, such as `$(.TARGET)` as a synonym for `$@`. Also, some _make_ programs use the symbol `$>` for all prerequisites rather than GNU _make_'s `$^`.

When an automatic variable expands to a list, such as a list of filenames, the elements are separated by spaces.

To separate filenames from directories, there are two more versions of each automatic variable in this list whose names are formed with the suffixes D and F. Because the resulting variable name is two characters, not one, parentheses are required. For example, `$(@D)` in any rule expands to the directory part of the target, without the actual filename, while `$(@F)` yields just the filename with no directory. (GNU _make_ supports these forms for compatibility's sake, but provides more flexible handling of filenames by means of functions: see the section "[Built-in Functions](cinanut-CHP-19-SECT-9.html#cinanut-CHP-19-SECT-9.1)," later in this chapter.)

#### 19.5.5. Other Built-in Variables

The variables that _make_ uses internally are described in the following list. You can also use them in makefiles. Remember that you can find out the sources of all variables in the output of make -p.

  

`MAKEFILES`

A list of standard makefiles that _make_ reads every time it starts.

  

`MAKEFILE_LIST`

A list of all the makefiles that the present invocation of _make_ is using.

  

`MAKE`

This variable holds the name of the _make_ executable. When you use $(MAKE) in a command, _make_ automatically expands it to the full path name of the program file, so that all recursive instances of _make_ are from the same executable.

  

`MAKELEVEL`

When _make_ invokes itself recursively, this variable holds the degree of recursion of the present instance. In exporting this variable to the environment, _make_ increments its value. Child instances of _make_ print this number in square brackets after the program name in their console output.

  

`MAKEFLAGS`

This variable contains the command-line options with which _make_ was invoked, with some exceptions. Each instance of _make_ reads this variable from the environment on starting, and exports it to the environment before spawning a recursive instance. You can modify this variable in the environment or in a makefile.

  

`MAKECMDGOALS`

_make_ stores any targets specified on the command line in this variable. You can modify this variable, but doing so doesn't change the targets _make_ builds.

  

`CURDIR`

This variable holds the name of the current working directory, after _make_ has processed its \-C or \--directory command-line options. You can modify this variable, but doing so doesn't change the working directory.

  

`VPATH`

The directory path that _make_ uses to search for any files not found in the current working directory.

  

`SHELL`

The name of the shell that _make_ invokes when it runs command scripts, usually /bin/sh. Unlike most variables, _make_ doesn't read the value of SHELL from the environment (except on Windows), as users' shell preferences would make _make_'s results less consistent. If you want _make_ to run commands using a specific shell, you must set this variable in your makefile.

  

`MAKESHELL`

On Windows, this variable holds the name of the command interpreter for _make_ to use in running command scripts. MAKESHELL overrides SHELL.

  

`SUFFIXES`

_make_'s default list of known suffixes (see "[Suffix Rules](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-SECT-3.3)," earlier in this chapter). This variable contains the default list, which is not necessarily the list currently in effect; the value of this variable does not change when you clear the list or add your own known suffixes using the built-in target .SUFFIXES.

  

`.LIBPATTERNS`

A list of filename patterns that determines how _make_ searches for libraries when a prerequisite starts with \-l. The default value is lib%.so lib%.a. A prerequisite called \-lm causes _make_ to search for _libm.so_ and _libm.a_, in that order.

#### 19.5.6. Environment Variables

If you want, you can set environment variables in the shell before starting _make_, and then reference them in the makefile using the same syntax as for other _make_ variables. Furthermore, you can use the export directive in the makefile to copy any or all of _make_'s variables to the shell environment before invoking shell commands, as in the following example:

~~~
INCLUDE=/usr/include:/usr/local/include:~/include
export INCLUDE
export LIB := $(LIBS):/usr/lib:/usr/local/lib
 
%.o: %.c
        $(CC) $(CFLAGS) -o $@ -c $<
~~~
  

When the C compiler is invoked by the pattern rule in this example, it can obtain information defined in the makefile by reading the environment variables INCLUDE and LIB. Similarly, _make_ automatically passes its command-line options to child instances by copying them to and then exporting the variable MAKEFLAGS. See the section "[Recursive make Commands](cinanut-CHP-19-SECT-11.html#cinanut-CHP-19-SECT-11.2)," later in this chapter, for other examples.

The shell environment is more restrictive than _make_ with regard to the characters that are permitted in variable names and values. It might be possible to trick your shell into propagating environment variables containing illegal characters, but the easiest thing by far is just to avoid special characters in any variables you want to export.

### 19.6. Phony Targets

The makefile in [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4) also illustrates several different ways of using targets. The targets debug, testing, production, clean, and symbols are not names of files to be generated. Nonetheless, the rules clearly define the behavior of a command like **make production** or **make clean symbols debug**. Targets that are not the names of files to be generated are called _phony targets_ .

In [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4), the phony target clean has a command script, but no prerequisites. Furthermore, its command script doesn't actually build anything: on the contrary, it deletes files generated by other rules. We can use this target to clear the board before rebuilding the program from scratch. In this way, the phony targets testing and production ensure that the executable is linked from object files made with the desired compiler options by including clean as one of their prerequisites.

You can also think of a phony target as one that is never supposed to be up to date: its command script should be executed whenever the target is called for. This is the case with cleanas long as no file with the name _clean_ happens to appear in the project directory.

Often, however, a phony target's name might really appear as a filename in the project directory. For example, if your project's products are built in subdirectories, such as _bin_ and _doc_, you might want to use subdirectory names as targets. But you must make sure that _make_ rebuilds the contents of a subdirectory when out of date, even if the subdirectory itself already exists.

For such cases, _make_ lets you declare a target as phony regardless of whether a matching filename exists. The way to do so is to is to add a line like this one to your makefile, making the target a prerequisite of the special built-in target .PHONY:

~~~
.PHONY: clean
~~~
  

Or, to use an example with a subdirectory name, suppose we added these lines to the makefile in [Example 19-4](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-EX-4):

~~~
.PHONY: bin
bin: circle
        $(MKDIR) $@
        $(CP) $< $@/
        $(CHMOD) 600 $@/$<
~~~
  

This rule for the target bin actually does create bin in the project directory. However, because bin is explicitly phony, it is never up to date. _make_ puts an up-to-date copy of _circle_ in the _bin_ subdirectory even if _bin_ is newer than its prerequisite, _circle_.

You should generally declare all phony targets explicitly, as doing so can also save time. For targets that are declared as phony, _make_ does not bother looking for appropriately named source files that it could use with implicit rules to build a file with the target's name. An old-fashioned, slightly less intuitive way of producing the same effect is to add another rule for the target with no prerequisites and no commands:

~~~
bin: circle
        $(MKDIR) $@
        $(CP) $< $@/
        $(CHMOD) 600 $@/$<
bin:
~~~
  

The .PHONY target is preferable if only because it is so explicit, but you may see the other technique in automatically generated dependency rules, for example.

[![](images/pixel.jpg)](http://85.147.245.113/mirrorbooks/cinanutshell/0596006977/0596006977/31071535.html)

### 19.7. Other Target Attributes

There are also other attributes that you can assign to certain targets in a makefile by making those targets prerequisites of other built-in targets like .PHONY. The most important of these built-in targets are listed here. Other special built-in targets that can be used in makefiles to alter _make_'s runtime behavior in general are listed at the end of this chapter.

  

`.PHONY`

Any targets that are prerequisites of .PHONY are always treated as out of date.

  

`.PRECIOUS`

Normally, if you interrupt _make_ while running a command scriptif _make_ receives any fatal signal, to be more precise_make_ deletes the target it was building before it exits. Any target you declare as a prerequisite of .PRECIOUS is not deleted in such cases, however.

Furthermore, when _make_ builds a target by concatenating implicit rules, it normally deletes any intermediate files that it creates by one such rule as prerequisites for the next. However, if any such file is a prerequisite of .PRECIOUS (or matches a pattern that is a prerequisite of .PRECIOUS), _make_ does not delete it.

  

`.INTERMEDIATE`

Ordinarily, when _make_ needs to build a target whose prerequisites do not exist, it searches for an appropriate rule to build them first. If the absent prerequisites are not named anywhere in the makefile, and _make_ has to resort to implicit rules to build them, then they are called _intermediate_ files. _make_ deletes any intermediate files after building its intended target (see the section "[Implicit Rule Chains](cinanut-CHP-19-SECT-3.html#cinanut-CHP-19-SECT-3.5)," earlier in this chapter). If you want certain files to be treated in this way even though they are mentioned in your makefile, declare them as prerequisites of .INTERMEDIATE.

  

`.SECONDARY`

Like .INTERMEDIATE, except that _make_ does not automatically delete files that are prerequisites of .SECONDARY.

You can also put .SECONDARY in a makefile with no prerequisites at all. In this case, _make_ treats all targets as prerequisites of .SECONDARY.

  

`.IGNORE`

For any target that is a prerequisite of .IGNORE, _make_ ignores any errors that occur in executing the commands to build that target. .IGNORE itself does not take a command script.

You can also put .IGNORE in a makefile with no prerequisites at all, although it is probably not a good idea. If you do, _make_ ignores all errors in running any command script.

  

`.LOW_RESOLUTION_TIME`

On some systems, the timestamps on files have resolution of less than a second, yet certain programs create timestamps that reflect only full seconds. If this behavior causes _make_ to misjudge the relative ages of files on your system, you can declare any file with low-resolution timestamps as a prerequisite of .LOW\_RESOLUTION\_TIME. Then _make_ considers the file up to date if its timestamp indicates the same whole second in which its prerequisite was stamped. Members of library archives are automatically treated as having low-resolution timestamps.

A few other built-in targets act like general runtime options, affecting _make_'s overall behavior just by appearing in a makefile. These are listed in the section "[Running make](cinanut-CHP-19-SECT-11.html#cinanut-CHP-19-SECT-11)," later in this chapter.

### 19.8. Macros

When we talk about macros in _make_, you should remember that there is really no difference between them and variables. Nonetheless, _make_ provides a directive that allows you to define variables with both newline characters and references to other variables embedded in them. Programmers often use this capability to encapsulate multiline command sequences in a variable, so that the term _macro_ is fairly appropriate. (The GNU _make_ manual calls them "canned command sequences.")

To define a variable containing multiple lines, you must use the define directive. Its syntax is:

~~~
define macro_name
macro_value
endef
~~~
  

The line breaks shown in the syntax are significant: define and endef both need to be placed at the beginning of a line, and nothing may follow define on its line except the name of the macro. Within the _macro\_value_, though, any number of newline characters may also occur. These are included literally, along with all other characters between the define and endef lines, in the value of the variable you are defining. Here is a simple example:

~~~
define installtarget
 @echo Installing $@ in $(USRBINDIR) ... ;\
 $(MKDIR) -m 7700 $(USRBINDIR)           ;\
 $(CP) $@ $(USRBINDIR)/                  ;\
 @echo ... done.
endef
~~~
  

The variable references contained in the macro installtarget are stored literally as shown here, and expanded only when _make_ expands $(installtarget) itself, in a rule like this for example:

~~~
circle: $(OBJ) $(LIB)
        $(CC) $(LDFLAGS) -o $@ $^
ifdef INSTALLTOO
        $(installtarget)
endif
~~~
  
[![](images/pixel.jpg)](http://85.147.245.113/mirrorbooks/cinanutshell/0596006977/0596006977/31071535.html)

### 19.9. Functions

GNU _make_ goes beyond simple macro expansion to provide functions both built-in and user-defined functions. By using parameters, conditions, and built-in functions, you can define quite powerful functions and use them anywhere in your makefiles.

The syntax of function invocations in makefiles, like that of macro references, uses the dollar sign and parentheses:

~~~
$(function_name argument[,argument[,...]])
~~~


    Whitespace in the argument list is significant. _make_ ignores any whitespace before the first argument, 
    but if you include any whitespace characters before or after a comma, _make_ treats them as part of the adjacent argument value.

  

The arguments themselves can contain any characters, except for embedded commas. Parentheses must occur in matched pairs; otherwise they will keep _make_ from parsing the function call correctly. If necessary, you can avoid these restrictions by defining a variable to hold a comma or parenthesis character, and using a variable reference as the function argument.

#### 19.9.1. Built-in Functions

GNU _make_ provides more than 20 useful text-processing and flow-control functions, which are listed briefly in the following sections.

##### 19.9.1.1. Text-processing functions

The text-processing functions listed here are useful in operating on the values of _make_ variables, which are always sequences of characters:

 `$(subst find_text, replacement_text, original_text)`

Expands to the value of original_text, except that each occurrence of find_text in it is changed to replacement_text.


`$(patsubst find_pattern, replacement_pattern, original_text)`

Expands to the value of original_text, except that each occurrence of find_pattern in it is changed to replacement_pattern. The find_pattern argument may contain a percent sign as a wildcard for any number of non-whitespace characters. If replacement_pattern also contains a percent sign, it is replaced with the characters represented by the wildcard in find_pattern. The patsubst function also collapses each unquoted whitespace sequence into a single space character.


`$(strip original_text)`

Removes leading and trailing whitespace, and collapses each unquoted internal whitespace sequence into a single space character.


`$(findstring find_text, original_text)`

Expands to the value of find_text, if it occurs in original_text; or to nothing if it does not.


`$(filter find_patterns, original_text)`

find_patterns is a whitespace-separated list of patterns like that in patsubst. The function call expands to a space-separated list of the words in original_text that match any of the words in find_patterns.


`$(filter-out find_patterns, original_text)`

Expands to a space-separated list of the words in original_text that do not match any of the words in find_patterns.


`$(sort original_text)`

Expands to a list of the words in original_text, in alphabetical order, without duplicates.


`$(word n, original_text)`

Expands to the nth word in original_text.


`$(firstword original_text)`

The same as $(word 1,original_text).


`$(wordlist n, m, original_text)`

Expands to a space-separated list of the nth through mth words in original_text.


`$(words original_text)`

Expands to the number of words in original_text.



##### 19.9.1.2. Filename-manipulation functions

These functions operate on a whitespace-separated list of file or directory names, and expand to a space-separated list containing a processed element for each name in the argument:

`$(dir filename_list)`

Expands to a list of the directory parts of each filename in the argument.


`$(notdir filename_list)`

Expands to a list of the filenames in the argument with their directory parts removed.


`$(suffix filename_list)`

Expands to a list of the filename suffixes in the argument. Each suffix is the filename ending, beginning with the last period (.) in it; or nothing, if the filename contains no period.


`$(basename filename_list)`

Expands to a list of the filenames in the argument with their suffixes removed. Directory parts are unchanged.


`$(addsuffix suffix,filename_list)`

Expands to a list of the filenames in the argument with suffix appended to each one. (suffix is not treated as a list, even if it contains whitespace.)


`$(addprefix prefix,filename_list)`

Expands to a list of the filenames in the argument with prefix prefixed to each one. (prefix is not treated as a list, even if it contains whitespace.)


`$(join prefix_list,suffix_list)`

Expands to a list of filenames composed by concatenating each word in prefix_list with the corresponding word in suffix_list. If the lists have different numbers of elements, the excess elements are included unchanged in the result.


`$(wildcard glob)`

Expands to a list of existing filenames that match the pattern glob, which typically contains shell wildcards.



##### 19.9.1.3. Conditions and flow control functions

The functions listed here allow you to perform operations conditionally, process lists iteratively, or execute the contents of a variable:

`$(foreach name, list, replacement)`

The argument name is a name for a temporary variable (without dollar sign and parentheses). The replacement text typically contains a reference to $(name). The result of the function is a list of expansions of replacement, using successive elements of list as the value of $(name).


`$(if condition, then_text[, else_text])`

Expands to the value of then_text if condition, stripped of leading and trailing spaces, expands to a nonempty text. Otherwise, the function expands to the value of else_text, if present.


`$(eval text)`

Treats the expansion of text as included makefile text.

##### 19.9.1.4. Operations on variables

The argument _variable\_name_ in the descriptions that follow is just the name of a variable (without dollar sign and parentheses), not a reference to it. (Of course, you may use a variable reference to obtain the name of another variable, if you want.)

`$(value variable_name)`

Expands to the "raw" value of the variable named, without further expansion of any variable references it may contain.


`$(origin variable_name)`

Expands to one of the following values to indicate how the variable named was defined:

- undefined
- default
- environment
- environment override
- file
- command line
- override
- automatic

`$(call variable_name, argument[, argument[,...]])`

Expands the variable named, replacing numbered parameters in its expansion ($1, $2, and so on) with the remaining arguments. In effect, this built-in function allows you to create user-defined function-like macros. See the section "User-Defined Functions," later in this chapter.



##### 19.9.1.5. System functions

The functions in the following list interact with _make_'s environment:

`$(shell text)`

Passes the expansion of text to the shell. The function expands to the standard output of the resulting shell command.


`$(error text)`

make prints the expansion of text as an error message and exits.


`$(warning text)`

Like the error command, except that make doesn't exit. The function expands to nothing.



#### 19.9.2. User-Defined Functions

You can define functions in the same way as simply expanded variables or macros, using the define directive or the := assignment operator. Functions in _make_ are simply variables that contain numbered parameter references$1, $2, $3, and so onto represent arguments that you provide when you use the built-in function call to expand the variable.

In order for these parameters to be replaced with the arguments when _make_ expands your user-defined function, you have to pass the function name and arguments to the built-in _make_ function call.

[Example 19-5](cinanut-CHP-19-SECT-9.html#cinanut-CHP-19-EX-5) defines the macro getmodulename to return a filename for a program module depending on whether the flag STATIC has been set, to indicate a statically linked executable, or left undefined, to indicate dynamic object linking.

##### Example 19-5. The user-defined function getmodulename

~~~bash
# A conditional assignment, just as a reminder that
# the user may define STATIC=1 or STATIC=yes on the command line.
STATIC ?=
 
# A function to generate the "library" module name:
# Syntax: $(call getmodulename, objectname, isstatic)
define getmodulename
  $(if $2,$1,$(addsuffix .so,$(basename $1)))
endef
 
all: circle
 
circle: circle.o $(call getmodulename,circulararea.o,$(STATIC))
        $(CC) -o $@ $^
 
ifndef STATIC
%.so: %.o
      $(CC) -shared -o $@ $<
endif
~~~
  

The $(call _..._) function expands the macro getmodulename either to the text circulararea.o, or, if the variable STATIC is not defined, to circulararea.so.

The rule to build the object file _circulararea.o_ in [Example 19-5](cinanut-CHP-19-SECT-9.html#cinanut-CHP-19-EX-5) brings us to our next topic, as it illustrates another way to query the STATIC flag in another way: by means of the _conditional directive_ ifndef.

### 19.10. Directives

We have already introduced the define directive, which produces a simply expanded variable or a function. Other _make_ directives allow you to influence the effective contents of your makefiles dynamically by making certain lines in a makefile dependent on variable conditions, or by inserting additional makefiles on the fly.

#### 19.10.1. Conditionals

You can also make part of your makefile conditional upon the existence of a variable by using the ifdef or ifndef directive. They work the same as the C preprocessor directives of the same names, except that in _make_, an undefined variable is the same as one whose value is empty. Here is an example:

~~~bash
OBJ = circle.o
LIB = -lm
 
ifdef SHAREDLIBS
  LIB += circulararea.so
else
  OBJ += circulararea.o
endif
 
circle: $(OBJ) $(LIB)
        $(CC) -o $@ $^
 
%.so : %.o
       $(CC) -shared -o $@ $<
~~~

As the example shows, the variable name follows ifdef or ifndef without a dollar sign or parentheses. The makefile excerpt shown here defines a rule to link object files into a shared library if the variable SHAREDLIBS has been defined. You might define such a general build option in an environment variable, or on the command line, for example.

You can also make certain lines of the makefile conditional upon whether two expressionsusually the value of a variable and a literal stringare equal. The ifeq and ifneq directives test this condition. The two operands whose equality is the condition to test are either enclosed together in parentheses and separated by a comma, or enclosed individually in quotation marks and separated by whitespace. Here is an example:

~~~bash
ifeq ($(MATHLIB), /usr/lib/libm.so)
  # ... Special provisions for this particular math library ...
endif
~~~

  

That conditional directive, with parentheses, is equivalent to this one with quotation marks:

~~~bash
ifeq "$(MATHLIB)" "/usr/lib/libm.so"
  # ... Special provisions for this particular math library ...
endif
~~~

  

The second version has one strong advantage: the quotation marks make it quite clear where each of the operands begins and ends. In the first version, you must remember that whitespace within the parentheses is significant, except immediately before and after the comma (see also the section "[Variables and Whitespace](cinanut-CHP-19-SECT-5.html#cinanut-CHP-19-SECT-5.2)," earlier in this chapter).


    _make_'s handling of whitespace in the ifeq and ifneq directives is not the same as in function calls!

  

#### 19.10.2. Includes

The include directive serves the same purpose as its C preprocessor counterpart, but works slightly differently. To start with an example, you might write a makefile named _defaults.mk_ with a set of standard variables for your environment, containing something like this:

~~~bash
BINDIR = /usr/bin
HOMEBINDIR = ~/bin
SRCDIR = project/src
BUILDDIR = project/obj
 
RM = rm -f
MKDIR = mkdir -p
# ... etc. ...
~~~
  
Then you could add these variables to any makefile by inserting this line:

~~~bash
include defaults.mk
~~~
  

The include keyword may be followed by more than one filename. You can also use shell wildcards like \* and ?, and reference _make_ variables to form filenames:

~~~bash
include $(HOMEBINDIR)/myutils.mk $(SRCDIR)/*.mk
~~~
  
For included files without an absolute path, _make_ searches in the current working directory first, then in any directories specified with the `-I` option on the command line, and then in standard directories determined when _make_ was compiled.

If _make_ fails to find a file named in an include directive, it continues reading the makefile, and then checks to see whether there is a rule that will build the missing file. If so, _make_ rereads the whole makefile after building the included file. If not, _make_ exits with an error. The `-include` directive (or its synonym `sinclude`) is more tolerant: it works the same as include, except that _make_ ignores the error and goes on working if it can't find or build an included file.

#### 19.10.3. Other Directives

Of the other four _make_ directives, three are used to control the interplay between _make_'s internal variables and the shell environment, while the fourth instructs _make_ where to look for specific kinds of files. These directives are:

  

* `override variable_assignment`

  Ordinarily, variables defined on the command line take precedence over definitions or assignments with the same name in a makefile. Prefixing the override keyword makes an assignment in a makefile take precedence over the command line. The variable_assignment may use the =, :=, or += operator, or the define directive.


* `export [ variable_name | variable_assignment]`

  You can prefix export to a variable assignment or to the name of a variable that has been defined to export that variable to the environment, so that programs invoked by command scripts (including recursive invocations of make) can read it.

  The export directive by itself on a line exports all make variables to the environment.

      make does not export variables whose names contain any characters other than letters, digits, and underscores. 
      The values of variables you export from makefiles may contain characters that are not allowed in shell environment variables. S
      uch values will probably not be accessible by ordinary shell commands. Nonetheless, child instances of make itself can inherit and use them.

  The make variables SHELL and MAKEFLAGS, and also MAKEFILES if you have assigned it a value, are exported by default. Any variables which the current instance of make acquired from the environment are also passed on to child processes.


* `unexport variable_name`

  Use the unexport directive to prevent a variable from being exported to the environment. The unexport directive always overrides export.


* `vpath pattern directory[: directory[: ...]]`

  The pattern in this directive is formed in the same way as in make pattern rules, using one percent sign (%) as a wildcard character. Whenever make needs a file that matches the pattern, it looks for it in the directories indicated, in the order of their appearance. An example:

  ~~~
  vpath  %.c  $(MYPROJECTDIR)/src
  vpath  %.h  $(MYPROJECTDIR)/include:/usr/include
  ~~~

  On Windows, the separator character in the directory list is a semicolon, not a colon.


### 19.11. Running make

This section explains how to add dependency information to the makefile automatically, and how to use _make_ recursively. These two ways of using _make_ are common and basic, but they do involve multiple features of the program. Finally, the remainder of this section is devoted to a reference list of GNU _make_'s command-line options and the special pseudotargets that also function as runtime options.

The command-line syntax of _make_ is as follows:

~~~bash
make [options] [variable_assignments] [target [target [...]]]
~~~

  

If you don't specify any target on the command line, _make_ behaves as though you had specified the default target; that is, whichever target is named first in the makefile. _make_ builds other targets named in the makefile only if you request them on the command line, or if they need to be built as prerequisites of any target requested.

#### 19.11.1. Generating Header Dependencies

Our program executable _circle_ depends on more files than those we have named in the sample makefile up to now. Just think of the standard headers included in our source code, to begin withnot to mention the implementation-specific header files they include in turn.

Most C source files include both standard and user-defined header files, and the compiled program should be considered out of date whenever any header file has been changed. Because you cannot reasonably be expected to know the full list of header files involved, the standard _make_ technique to account for these dependencies is to let the C preprocessor analyze the #include directives in your C source and write the appropriate _make_ rules. The makefile lines in [Example 19-6](cinanut-CHP-19-SECT-11.html#cinanut-CHP-19-EX-6) fulfill this purpose.

##### Example 19-6. Generating header dependencies

~~~bash
CC = gcc
OBJ = circle.o circulararea.o
LIB = -lm
 
circle: $(OBJ) $(LIB)
        $(CC) $(LDFLAGS) -o $@ $^
 
%.o: %.c
        $(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $<
 
dependencies: $(OBJ:.o=.c)
        $(CC) -M $^ > $@
 
include dependencies
~~~

  

The third rule uses a special kind of _make_ variable reference, called a _substitution reference_ , to declare that the target dependencies depends on files like those named in the value of $(OBJ), but with the ending _.c_ instead of _.o_. The command to build dependencies runs the compiler with the preprocessor option \-M, which instructs it to collate dependency information from source files. (The GCC compiler permits fine control of the dependency output by means of more preprocessor options that start with \-M: these are listed in the section "[GCC Options for Generating Makefile Rules](cinanut-CHP-19-SECT-11.html#cinanut-CHP-19-SECT-11.5)," at the end of this chapter.)

The first time you use this makefile, _make_ prints an error message about the include directive because no file named dependencies exists. When this happens, however, _make_ automatically treats the missing file named in the include directive as a target, and looks for a rule to build it. The include directive itself is placed below the target rules to prevent the included file's contents from defining a new default target.

#### 19.11.2. Recursive make Commands

Your makefile rules can include any command that is executable on your system. This includes the _make_ command itself, and indeed recursive invocation of _make_ is a frequently used technique, especially to process source code in subdirectories. _make_ is designed to be aware of such recursive invocation, and incorporates certain features that help it work smoothly when you use it in this way. This section summarizes the special features of "recursive _make_."

The most typical recursive use of _make_ is in building projects that are organized in subdirectories, with a makefile in each subdirectory. The following snippet illustrates how a top-level makefile can invoke recursive instances of _make_ in three subdirectories named _utils_, _drivers_, and _doc_:

~~~bash
.PHONY: utils drivers doc
 
utils drivers doc:
    $(MAKE) -C $@
~~~

  

The variable MAKE is not defined in the makefile; it is defined internally to yield the full pathname of the currently running program file. Your makefiles should always invoke _make_ in this way to ensure consistent program behavior.

The command-line option \-C, or its long form \--directory, causes _make_ to change to the specified working directory on startup, before it even looks for a makefile. This is how _make_ "passes control" to the makefile in a subdirectory when used recursively. In this example, the command does not name a target, so the child _make_ will build the first target named in the default makefile in the given subdirectory.

The subdirectories themselves are declared as prerequisites of the special target .PHONY so that _make_ never considers them up to date (see "[Phony Targets](cinanut-CHP-19-SECT-6.html#cinanut-CHP-19-SECT-6)," earlier in this chapter, for more details). However, if files in one subdirectory depend on files in a parallel subdirectory, you must account for these dependencies in the makefile of a higher-level directory that contains both subdirectories.

There are a few things to remember about command-line options and special variables when you use _make_ recursively. A more complete list of _make_ options and environment variables appears in the next section, "Command-Line Options." The following list merely summarizes those with a special relevance to the recursive use of _make_:

*   Some of _make_'s command-line options instruct it not to execute commands, but to only print them (\-n), or to touch the files (\-t), or to indicate whether the targets are up to date (\-q). If in these cases the subordinate _make_ command were not executed, then these options would be incompatible with the recursive use of _make_. To ensure recursion, when you run _make_ with one of the \-t, \-n, or \-q options, commands containing the variable reference $(MAKE) are executed, even though other commands are not. You can also extend this special treatment to other commands individually by prefixing a plus sign (+) to the command line as a command modifier.
    
*   The variable MAKELEVEL automatically contains a numeral indicating the recursion depth of the current _make_ instance, starting with 0 for a _make_ invoked from the console.
    
*   The parent instance of _make_ passes its command-line options to child instances by copying them to the environment variable MAKEFLAGS. However, the options \-C, \-f, \-o, and \-W are exceptions: these options, which take a file or directory name as their argument, do not appear in MAKEFLAGS.
    
*   The \-j option, whose argument tells _make_ how many commands it can spawn for parallel processing, is passed on to child instances of _make_, but with the parallel job limit decreased by one.
    
*   By default, a child instance of _make_ inherits those of its parent's variables that were defined on the command line or in the environment. You can use the export directive to pass on variables defined in a makefile.
    

Like any other shell command in a makefile rule, a recursive instance of _make_ can exit with an error status. If this happens, the parent _make_ also exits with an error (unless it was started with the \-k or \--keep-going option), so that the error cascades up the chain of recursive _make_ instances.

When using _make_ recursively with multiple makefiles in subdirectories, you should use the include directive to avoid duplicating common definitions, implicit rules, and so on. See the section "[Includes](cinanut-CHP-19-SECT-10.html#cinanut-CHP-19-SECT-10.2)," earlier in this chapter, for more information.

#### 19.11.3. Command-Line Options

The following is a brief summary of the command-line options supported by GNU _make_. Some of these options can also be enabled by including special targets in the makefile. Such targets are described in the following section.

`-B, --always-make`

Build unconditionally. In other words, make considers all targets out of date.


`-C dir, --directory= dir`

make changes the current working directory to dir before it does anything else. If the command line includes multiple -C options (which is often the case when make invokes itself recursively), each directory specified builds on the previous one. Example:

    `$ make -C src -C common -C libs`

    These options would have the same effect as -C src/common/libs.


`-d`

Print debugging information.


`-e`


`--environment-overrides`

In case of multiple definitions of a given variable name, variables defined on the make command line or in makefiles normally have precedence over environment variables. This command-line option makes environment variables take precedence over variable assignments in makefiles (except for variables specified in override directives).


`-f filename, --file= filename, --makefile= filename`

Use the makefile filename.

`-h, --help`

Print make's command-line options.


`-i, --ignore-errors`

Ignore any errors that occur when executing command scripts.


`-I dir, --include-dir= dir`

If a makefile contains include directives that specify files without absolute paths, search for such files in the directory dir (in addition to the current directory). If the command line includes several -I options, the directories are searched in the order of their occurrence.


`-j [ number] , --jobs[= number]`

Run multiple commands in parallel. The optional integer argument number specifies the maximum number of simultaneous jobs. The -j argument by itself causes make to run as many simultaneous commands as possible. (Naturally make is smart enough not to start building any target before its prerequisites have been completed.) If the command line includes several -j options, the last one overrides all others.

    Parallel jobs spawned by make do not share the standard streams elegantly. 
    Console output from different jobs can appear in random order, and only one job can inherit the stdin stream from make. 
    If you use the -j option, make sure none of the commands in your makefiles read from stdin.




`-k, --keep-going`

This option tells make not to exit after a command has returned a nonzero exit status. Instead, make abandons the failed target and any other targets that depend on it, but continues working on any other goals in progress.


`-l [ number], --load-average[= number], --max-load[= number]`

In conjunction with the -j option, -l (that's a lowercase L) prevents make from executing more simultaneous commands whenever the system load is greater than or equal to the floating-point value number. The -l option with no argument cancels any load limit imposed by previous -l options.


`-n, --just-print, --dry-run, --recon`

make prints the commands it would otherwise run, but doesn't actually execute them.


`-o filename, --old-file= filename, --assume-old= filename`

make treats the specified file as if it were up to date, and yet older than any file that depends on it.


`-p, --print-data-base`

Before executing any commands, make prints its version information and all its rules and variables, including both built-ins and those acquired from makefiles.


`-q, --question`

make builds nothing and prints nothing, but returns an exit status as follows:

- 0 All specified targets are up to date.
- 1 At least one target is out of date.
- 2 An error occurred.

`-r, --no-builtin-rules`

This option disables make's built-in implicit rules, as well as the default list of suffixes for old-style suffix rules. Pattern rules, user-defined suffixes, and suffix rules that you have defined in makefiles still apply, as do built-in variables.


`-R, --no-builtin-variables`

Like -r, but also disables make's built-in rule-specific variables. Variables you define in makefiles are unaffected.


`-s, --silent, --quiet`

Ordinarily make echoes each command on standard output before executing it. This option suppresses such output.


`-S, --no-keep-going, --stop`

This option causes a recursive instance of make to ignore a -k or --keep-going option inherited from its parent make.


`-t, --touch`

make simply touches target filesthat is, it updates their timestampsinstead of rebuilding them.


`-v, --version`

make prints its version and copyright information.


`-w, --print-directory`

make prints a line indicating the working directory both before and after processing the makefile. This output can be useful in debugging recursive make applications. This option is enabled by default for recursive instances of make, and whenever you use the -C option.


`--no-print-directory`

Disable the working directory output in cases where -w is automatically activated.


`-W filename, --what-if= filename, --new-file= filename, --assume-new= filename`

make treats the file filename as if it were brand-new.


`--warn-undefined-variables`

Normally, make takes references to undefined variables in its stride, treating them like references to variables with empty values. This option provides warnings about undefined variables to help you debug your makefiles.

#### 19.11.4. Special Targets Used as Runtime Options

The built-in targets listed in this section are ordinarily used in makefiles to alter _make_'s runtime behavior in general. Other built-in targets are used primarily to assign attributes to certain targets in a makefile, and are listed in the section "[Other Target Attributes](cinanut-CHP-19-SECT-7.html#cinanut-CHP-19-SECT-7)," earlier in this chapter.

`.DEFAULT`

You can use the built-in target .DEFAULT to introduce a command script that you want make to execute for any target that is not covered by any other explicit or implicit rule. make also executes the .DEFAULT command script for every prerequisite that is not a target in some rule.


`.DELETE_ON_ERROR`

You can include the built-in target .DELETE_ON_ERROR anywhere in a makefile to instruct make to delete any target that has been changed by its command script if the script returns a nonzero value on exiting.


`.SILENT`

Normally make prints each command to standard output before executing it. However, if a given target is a prerequisite of .SILENT, then make does not print the rules when building that target.

If you include .SILENT with no prerequisites in a makefile, it applies to all targets, like the command-line options -s or --silent.


`.EXPORT_ALL_VARIABLES`

This target acts as an option telling make to export all the currently defined variables before spawning child processes (see the section "Recursive make Commands," earlier in this chapter).


`.NOTPARALLEL`

This built-in target is a general option; any prerequisites are ignored. The target .NOTPARALLEL in a makefile overrides the command-line option -j for the current instance of make, so that targets are built in sequence. If make invokes itself, however, such recursions still run parallel to the present instance, unless their makefiles also contain .NOTPARALLEL.


`.SUFFIXES`

This built-in target defines the list of suffixes that make recognizes for use in old-style suffix rules (see "Suffix Rules," earlier in this chapter). You can add suffixes to the built-in list by naming them as prerequisites of .SUFFIXES, or clear the list by declaring the target .SUFFIXES with no prerequisites.


#### 19.11.5. GCC Options for Generating Makefile Rules

