#!/usr/bin/env bash

# runs from root dir
rm test.md
touch test.md
./bin/bashdoc/main.sh -f test.md
# ./bin/bashdoc/doctoc.sh test.md
