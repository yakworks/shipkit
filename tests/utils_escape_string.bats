#!/usr/bin/env bats
load test_helper
setup_file() { echo_test_name; }

source "$SHIPKIT_BIN/core/utils"

@test 'escapes the main chars for json' {
  string="tab:	"
  [ `escape_json_string "$string"` = "tab:\t" ]

  string='quote:"'
  [ `escape_json_string "$string"` = 'quote:\"' ]

  string=`echo -e 'newline:\nbuzz'`
  echo `escape_json_string "$string"`
  [ `escape_json_string "$string"` = 'newline:\nbuzz' ]

  string='backslash:\'
  echo `escape_json_string "$string"`
  [ `escape_json_string "$string"` = 'backslash:\\' ]

}

