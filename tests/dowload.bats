#!/usr/bin/env bats
load test_helper
setup_file() { echo_test_name; }

MAKEFILE='
include ./Shipkit.make

test1:
	$(call download,http://localhost,cat -)

test2:
	$(call download_to,http://localhost,/tmp/nowhere)
'

setup() {
  PATH=fixtures/bin:$PATH
}

teardown() {
  PATH=$OLD_PATH
}

@test 'download callable attempts a download' {
  run make -f <(echo "$MAKEFILE") test1 DOWNLOADER=tests/fixtures/bin/curl
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  # [ "${lines[0]}" == "tests/fixtures/bin/curl  \"http://localhost\" | cat -" ]
  [ "${lines[0]}" == "mock-curl http://localhost" ]
}

@test 'download_to callable attempts a download' {
  run make -f <(echo "$MAKEFILE") test2 DOWNLOADER=tests/fixtures/bin/curl
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  # [ "${lines[0]}" == "tests/fixtures/bin/curl --write-out \"%{http_code}\" -o /tmp/nowhere \"http://localhost\"" ]
  [ "${lines[0]}" == "mock-curl --write-out %{http_code} -o /tmp/nowhere http://localhost" ]
}
