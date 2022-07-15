## 📇 Index

* [tests.value()](#testsvalue)
* [foo()](#foo)

## tests.value()

Same, as `tests.eval`, but writes stdout into given variable and
return stderr as expected.

* __🔧 Example__

  ```bash
  _x() {
      echo "y [$@]"
  }
  tests:value response _x a b c
  tests:assert-equals "$response" "y [a b c]"
  ```

* __🔌 Args__

  * __$1__ (string): Variable name.
  * __...__ (string): String to evaluate.

* __👓 See also__

  * [tests.eval](#testseval)
  * [foo()](#foo)

## foo()

foo should work
