#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

# Added beside the compiler the base image put in /etc/rescript, rather than
# into a prefix of their own, because a start-point symlinks that one directory
# in as its node_modules: that is how node finds jest, and how the ReScript
# compiler finds the package a kata's rescript.json names.
#
# rescript is deliberately absent: it comes from the base image. Naming it here
# would let this image drift to a different compiler from its siblings, which
# is the thing having a base image is for.
npm install --prefix /etc/rescript \
  @glennsl/rescript-jest \
  jest

# The compiler writes its build output beside the sources it compiles, and a
# kata runs as sandbox. The base image set this for what it installed; these
# packages are new.
chown -R sandbox /etc/rescript

# Read from the installed package, so the record is the jest a kata runs.
add_test_framework Jest "$(node -p "require('/etc/rescript/node_modules/jest/package.json').version")"
cat /versions.json
