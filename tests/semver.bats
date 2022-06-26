#!/usr/bin/env bats
source "$SHIPKIT_BIN/semver"
load test_helper

setup() {
  export FIXTURE_DIR="$BATS_TEST_DIRNAME/fixtures/versions"
}

@test 'bump_patch' {
  version=$(bump_patch "1.2.3 ")
  [ "$version" = "1.2.4" ]

  version=$(bump_patch "1.2.3-RC.1")
  [ "$version" = "1.2.3-RC.2" ]
}

@test 'update version snapshot file' {
  mkdir -p build/semver_tests
  semverFile=build/semver_tests/version1.properties
  echo "version=1.0.1" > $semverFile
  echo "publishedVersion=1.0.0" >> $semverFile
  echo "snapshot=false" >> $semverFile

  export VERSION_SET_SNAPSHOT=false
  bump_version_file "1.2.3" $semverFile false
  grep "version=1.2.4" $semverFile
  grep "publishedVersion=1.2.3" $semverFile
  grep "snapshot=false" $semverFile

  export VERSION_SET_SNAPSHOT=true
  bump_version_file "1.2.5" $semverFile true
  grep "version=1.2.6" $semverFile
  grep "publishedVersion=1.2.5" $semverFile
  grep "snapshot=true" $semverFile

}
