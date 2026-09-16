#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/homebrew-tap-tests.XXXXXX")"
BIN="$TEST_ROOT/bin"
FIXTURE="$TEST_ROOT/tap"
TRACE="$TEST_ROOT/brew.log"

cleanup() {
    local exit_code=$?
    rm -rf "$TEST_ROOT"
    exit "$exit_code"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

mkdir -p "$BIN" "$FIXTURE/Casks" "$FIXTURE/Formula"
: > "$FIXTURE/Casks/first-app.rb"
: > "$FIXTURE/Casks/second-app.rb"
: > "$FIXTURE/Formula/example-cli.rb"

cat > "$BIN/brew" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
printf '<%s>\n' "$*" >> "${TAP_TEST_TRACE:?}"
if [[ "${1:-}" == "--repository" ]]; then
    printf '%s\n' "${TAP_TEST_ROOT:?}"
elif [[ "${1:-}" == "livecheck" ]]; then
    package="${!#}"
    token="${package##*/}"
    kind="formula"
    [[ " $* " == *" --cask "* ]] && kind="cask"
    printf '[{"%s":"%s","version":{"current":"1.0.0","latest":"1.0.0","outdated":false,"newer_than_upstream":false}}]\n' \
        "$kind" "$token"
fi
SCRIPT
chmod +x "$BIN/brew"

: > "$TRACE"
env \
    "PATH=$BIN:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    "TAP_TEST_TRACE=$TRACE" \
    "TAP_TEST_ROOT=$FIXTURE" \
    "$ROOT_DIR/Scripts/validate-tap.sh" >/dev/null

for package in first-app second-app example-cli; do
    rg -F "choseongmin1128/tap/$package" "$TRACE" >/dev/null
done

: > "$FIXTURE/Formula/first-app.rb"
if env \
    "PATH=$BIN:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    "TAP_TEST_TRACE=$TRACE" \
    "TAP_TEST_ROOT=$FIXTURE" \
    "$ROOT_DIR/Scripts/validate-tap.sh" >/dev/null 2>&1; then
    echo "duplicate package tokens must fail" >&2
    exit 1
fi

echo "tap validator tests passed"
