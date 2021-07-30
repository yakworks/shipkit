#!/usr/bin/env bats
source "$SHIPKIT_BIN/semver"
load test_helper

setup_file() { echo_test_name; }

setup() {
  export FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures/versions"
  export VERSION_FILENAME=build/semver_tests/version.env
  export VERSION_SET_SNAPSHOT=true
}

@test 'bump_patch' {
  version=$(bump_patch "1.2.3 ")
  [ "$version" = "1.2.4" ]

  version=$(bump_patch "1.2.3-RC.1")
  [ "$version" = "1.2.3-RC.2" ]
}

@test 'update version file' {
  mkdir -p build/semver_tests
  semverFile=build/semver_tests/version.properties
  echo "version=1.0.1" > $semverFile
  echo "publishedVersion=1.0.0" >> $semverFile
  echo "snapshot=false" >> $semverFile

  bump_version_file "1.2.3" $semverFile false
  grep "version=1.2.4" $semverFile
  grep "publishedVersion=1.2.3" $semverFile
  grep "snapshot=false" $semverFile

  bump_version_file "1.2.5" $semverFile true
  grep "version=1.2.6" $semverFile
  grep "publishedVersion=1.2.5" $semverFile
  grep "snapshot=true" $semverFile

}

@test 'make sure gsecrets.show-version works' {

  semverFile=$VERSION_FILENAME
  echo "version=1.0.1" > $semverFile
  echo "publishedVersion=1.0.0" >> $semverFile
  echo "snapshot=false" >> $semverFile

  grep "version=1.0.1" $semverFile
  grep "publishedVersion=1.0.0" $semverFile
  grep "snapshot=false" $semverFile

  run make -f $FIXTURE_DIR/Makefile bump-version-file VERSION=1.0.1
  __debug "${status}" "${output}" "${lines[@]}"

  [ "$status" -eq 0 ]
  grep "version=1.0.2" $semverFile
  grep "publishedVersion=1.0.1" $semverFile
  grep "snapshot=true" $semverFile
  # [ "${lines[0]}" == "tests/fixtures/bin/curl  \"http://localhost\" | cat -" ]
}
