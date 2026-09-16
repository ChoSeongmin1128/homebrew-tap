#!/usr/bin/env bash

set -euo pipefail

TAP="${HOMEBREW_TAP:-choseongmin1128/tap}"

die() {
    echo "error: $*" >&2
    exit 1
}

for binary in brew jq find sort uniq basename; do
    command -v "$binary" >/dev/null 2>&1 || die "required command not found: $binary"
done

TAP_ROOT="$(brew --repository "$TAP")" || die "tap is not installed: $TAP"
[[ "$TAP_ROOT" == /* && -d "$TAP_ROOT" && ! -L "$TAP_ROOT" ]] \
    || die "invalid tap repository path"

PACKAGE_FILES="$({
    for directory in Casks Formula; do
        if [[ -d "$TAP_ROOT/$directory" && ! -L "$TAP_ROOT/$directory" ]]; then
            find "$TAP_ROOT/$directory" -type f -name '*.rb' -maxdepth 1 -print
        fi
    done
} | LC_ALL=C sort)"
[[ -n "$PACKAGE_FILES" ]] || die "tap must contain at least one Cask or Formula"

TOKENS="$(
    while IFS= read -r package_file; do
        [[ ! -L "$package_file" ]] || die "package file must not be a symlink: $package_file"
        token="$(basename "$package_file" .rb)"
        [[ "$token" =~ ^[a-z0-9][a-z0-9@+._-]*$ ]] \
            || die "invalid package token: $token"
        printf '%s\n' "$token"
    done <<< "$PACKAGE_FILES"
)"
DUPLICATES="$(printf '%s\n' "$TOKENS" | LC_ALL=C sort | uniq -d)"
[[ -z "$DUPLICATES" ]] || die "duplicate package token across Casks and Formula: $DUPLICATES"

brew readall --aliases --syntax "$TAP"
brew style "$TAP"

while IFS= read -r package_file; do
    token="$(basename "$package_file" .rb)"
    case "$package_file" in
        "$TAP_ROOT"/Casks/*)
            kind="cask"
            ;;
        "$TAP_ROOT"/Formula/*)
            kind="formula"
            ;;
        *)
            die "package is outside the supported directories: $package_file"
            ;;
    esac
    package="$TAP/$token"

    brew audit "--$kind" --strict --online "$package"
    LIVECHECK_JSON="$(brew livecheck "--$kind" --json "$package")"
    printf '%s\n' "$LIVECHECK_JSON" \
        | jq -e --arg token "$token" '
            length == 1
            and ((.[0].cask // .[0].formula) == $token)
            and .[0].version.current == .[0].version.latest
            and .[0].version.outdated == false
            and .[0].version.newer_than_upstream == false
        ' >/dev/null \
        || die "livecheck does not match the declared version: $package"
    brew fetch "--$kind" "$package" >/dev/null
done <<< "$PACKAGE_FILES"

echo "tap validation complete: $(printf '%s\n' "$PACKAGE_FILES" | wc -l | tr -d ' ') package(s)"
