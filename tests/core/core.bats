#!/usr/bin/env bats
source "$SHIPKIT_BIN/core/main"
load ../test_helper

@test 'core.rel_path' {

    [ $(core.rel_path "/A/B/C" "/A/B/C") = "." ]

    [ $(core.rel_path "/A/B/C" "/A") = "../.." ]

    [ $(core.rel_path "/A/B/C" "/A/B") = ".." ]

    [ $(core.rel_path "/A/B/C" "/A/B/C/D") = "D" ]

    [ $(core.rel_path "/A/B/C" "/A/B/C/D/E") = "D/E" ]

    [ $(core.rel_path "/A/B/C" "/A/B/D") = "../D" ]
}

