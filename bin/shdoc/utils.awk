# --- Common Utils ---

# gets file name from full path
function basename(path) {
  sub(".*/", "", path)
  return path
}

# gets the realtive path and file from a base_dir
function rel_filename(fname, base_dir) {
  sub(base_dir, "", fname)
  debug("relative_fname: " fname)
  return fname
}

# returns the path without filename
function basedir(f) {
  sub(/\/[^\/]+$/, "", f)
  return f "/"
}

# concats text to source with a `\n`
# if source is empty then just sets it to text
# `concat("foo", "bar", '\n) == "foo\nbar"` or `concat("", "bar") == "bar"`
function concat(source, text, sep) {
    if (source == "") {
        source = text
    } else {
        source = source sep text
    }
    return source
}

function push(arr, value) {
    arr[length(arr)+1] = value
}

# (the extra space before result is a coding convention to indicate that i is a local variable, not an argument):
function join(arr, sep,     result) {
    for (i = 0; i < length(arr); i++) {
        if (i == 0) {
            result = arr[i]
        } else {
            result = result sep arr[i]
        }
    }
    return result
}

#---END UTILS---
