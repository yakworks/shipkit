Uses bats https://github.com/bats-core/bats-core

`make test` will run the tests

## Test Examples

```bash
@test 'examples will fail' {
  [ 1 -lt 0 ]
  FOO=bar
  # add the || false to test with [[ ]]
  [[ $FOO && $FOO != "buzz" ]] || false
  # for negating use same syntax
  ! BUZZ || false
  #or with doubles with expected failure
  ! [[ $FOO && $FOO != "bar" ]] || false

}
```

## asserts

from https://github.com/bats-core/bats-assert

The expressions must be a simple command, no `[[`, see docs for using bash -c as option.

### `assert`

Fail if the given expression evaluates to false.

```bash
@test 'assert()' {
  assert [ 1 -lt 0 ]
}
```

On failure, the failed expression is displayed.

```
-- assertion failed --
expression : [ 1 -lt 0 ]
--
```


### `refute`

Fail if the given expression evaluates to true.

```bash
@test 'refute()' {
  refute [ 1 -gt 0 ]
}
```

On failure, the successful expression is displayed.

```
-- assertion succeeded, but it was expected to fail --
expression : [ 1 -gt 0 ]
--
```


### `assert_equal`

Fail if the two parameters, actual and expected value respectively, do not equal.

```bash
@test 'assert_equal()' {
  assert_equal 'have' 'want'
}
```

On failure, the expected and actual values are displayed.

```
-- values do not equal --
expected : want
actual   : have
--
```

If either value is longer than one line both are displayed in *multi-line* format.


### `assert_not_equal`

Fail if the two parameters, actual and unexpected value respectively, are equal.

```bash
@test 'assert_not_equal()' {
  assert_not_equal 'foobar' 'foobar'
}
```

On failure, the expected and actual values are displayed.

```
-- values should not be equal --
unexpected : foobar
actual     : foobar
--
```

If either value is longer than one line both are displayed in *multi-line* format.
