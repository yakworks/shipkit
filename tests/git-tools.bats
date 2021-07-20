#!/usr/bin/env bats
load test_helper

setup() {
  fixtures git-tools
  export GITHUB_TOKEN=s3cr3t
  export BOT_EMAIL=9cibot@9ci.com
}

teardown() {
  PATH=$OLD_PATH
}

@test 'git-clone-pages' {
  run make -f $FIXTURES_ROOT/Makefile git-clone-pages
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
}

@test 'git-push-pages' {
  run make -f $FIXTURES_ROOT/Makefile git-push-pages
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "mock-git -C build/gh-pages add -A ." ]
  [ "${lines[1]}" == "mock-git -C build/gh-pages commit -a -m CI Docs published [skip ci]" ]
  [ "${lines[2]}" == "mock-git -C build/gh-pages push -q https://dummy:s3cr3t@github.com/yakworks/shipkit.git gh-pages" ]
}

@test 'config-bot-git-user' {
  run make -f $FIXTURES_ROOT/Makefile config-bot-git-user
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  [ "${lines[2]}" == "mock-git config --global user.name 9cibot" ]
}

