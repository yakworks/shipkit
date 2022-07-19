#!/usr/bin/env awk -f
BEGIN {
    # split("",a)
    push(a, "here")
    push(a, "is")
    push(a, "a")
    push(a, "loop")
    # a[2] = "is"
    # a[3] = "a"
    # a[4] = "loop"
    for (i in a) {
        print i " - " a[i]
    }
}

function push(arr, value) {
    arr[length(arr)+1] = value
}
