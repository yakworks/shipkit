# example.sh

Brief here, can be usage

## Description

more here
* with lists
* of things

```bash
example.sh something -f text.txt
```

## Index

* [do.something()](#dosomething)
* [noargs()](#noargs)
* [c()](#c)
* [trip()](#trip)

## do.something()

Multiline description goes here
and here

### Example

```bash
some:other:func a b c
echo 123
```

### Arguments

* **$1** (string): Some arg.
* **...** (any): Rest of arguments.

### Variables set

* **RETVAL** (string): Variable was set

### Exit codes

* **0**:  If successfull.
* **>0**: Failure
* **5**:  some specific error.

### Input on stdin

* Path to something.

### Output on stdout

* Path to something.

### See also

* [some.other.func()](#someotherfunc)

## noargs()

can use description tag too

### Example

```bash
echo "using example tag"
echo 2
```

_Function has no arguments._

## c()

func c

### Example

```bash
echo 1
echo 2
```

## trip()

triple desc
