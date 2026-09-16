#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/homebrew-tap-tests.XXXXXX")"
BIN="${TEST_ROOT}/bin"
FIXTURE="${TEST_ROOT}/tap"
TRACE="${TEST_ROOT}/brew.log"

cleanup() {
  local exit_code=$?
  rm -rf "${TEST_ROOT}"
  exit "${exit_code}"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

mkdir -p "${BIN}" "${FIXTURE}/Casks" "${FIXTURE}/Formula"
: >"${FIXTURE}/Casks/first-app.rb"
: >"${FIXTURE}/Casks/second-app.rb"
: >"${FIXTURE}/Formula/example-cli.rb"

cp "${ROOT_DIR}/Scripts/tests/fixtures/brew" "${BIN}/brew"
chmod +x "${BIN}/brew"

run_validator() {
  env \
    "PATH=${BIN}:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    "TAP_TEST_TRACE=${TRACE}" \
    "TAP_TEST_ROOT=${FIXTURE}" \
    "${ROOT_DIR}/Scripts/validate-tap.sh"
}

: >"${TRACE}"
run_validator >/dev/null

for package in first-app second-app example-cli
do
  grep -F "choseongmin1128/tap/${package}" "${TRACE}" >/dev/null
done

: >"${FIXTURE}/Formula/first-app.rb"
if env \
   "PATH=${BIN}:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
   "TAP_TEST_TRACE=${TRACE}" \
   "TAP_TEST_ROOT=${FIXTURE}" \
   "${ROOT_DIR}/Scripts/validate-tap.sh" >/dev/null 2>&1
then
  echo "duplicate package tokens must fail" >&2
  exit 1
fi
rm "${FIXTURE}/Formula/first-app.rb"

ln -s "${FIXTURE}/Casks/first-app.rb" "${FIXTURE}/Casks/linked-app.rb"
if env \
   "PATH=${BIN}:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
   "TAP_TEST_TRACE=${TRACE}" \
   "TAP_TEST_ROOT=${FIXTURE}" \
   "${ROOT_DIR}/Scripts/validate-tap.sh" >/dev/null 2>&1
then
  echo "symlink package files must fail" >&2
  exit 1
fi
rm "${FIXTURE}/Casks/linked-app.rb"

mv "${FIXTURE}/Formula" "${FIXTURE}/Formula.real"
ln -s "${FIXTURE}/Formula.real" "${FIXTURE}/Formula"
if env \
   "PATH=${BIN}:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
   "TAP_TEST_TRACE=${TRACE}" \
   "TAP_TEST_ROOT=${FIXTURE}" \
   "${ROOT_DIR}/Scripts/validate-tap.sh" >/dev/null 2>&1
then
  echo "symlink package directories must fail" >&2
  exit 1
fi

echo "tap validator tests passed"
