#!/bin/bash -Eeu
readonly MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat ${MY_DIR}/docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

# Confirms the version of one tool inside the image. docker/package.json asks
# npm for "*", so a rebuild picking up a new release stops here and names it,
# rather than changing what the image offers without saying so.
check_version()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r version_command="${3}"
  local -r actual=$(docker run --rm -i ${IMAGE_NAME} sh -c "${version_command}")

  if echo "${actual}" | grep -q "${expected}"; then
    echo "${name} VERSION CONFIRMED as ${expected}"
  else
    echo "${name} VERSION EXPECTED: ${expected}"
    echo "${name} VERSION   ACTUAL: ${actual}"
    exit 42
  fi
}

# The compiler is checked as well as the test framework. It is the compiler that
# has to offer a binary for the host architecture, which is what keeps this
# image running natively rather than emulated.
check_version jest     30.4 'npx jest --version'
check_version rescript 12.3 'npx rescript --version'
