# Homebrew Tap

Homebrew Casks and Formulae maintained by ChoSeongmin1128. Install packages with their fully qualified names so Homebrew trusts only the selected package.

## ClaudeUsage

```bash
brew install --cask choseongmin1128/tap/claude-usage
```

The Cask installs the notarized universal app from the immutable production GitHub Release. ClaudeUsage's signed Sparkle updater remains enabled, so either the app or Homebrew can install a later production release.

For an existing manual installation, quit ClaudeUsage and move only `/Applications/ClaudeUsage.app` to the Trash before installing the Cask. Preferences, Application Support data, Keychain items, and credentials owned by external CLIs are outside the app bundle and are not removed. Do not use `--adopt`; Homebrew skips its artifact comparison for self-updating Casks.

Staging builds are not distributed through this tap.

## Repository layout

- `Casks/*.rb`: prebuilt macOS applications
- `Formula/*.rb`: source or binary command-line packages
- `Scripts/validate-tap.sh`: automatic discovery, syntax, style, audit, livecheck, and fetch validation for every package

Each package keeps its release automation in its upstream repository. An updater may change only its own Cask or Formula file; it must preserve every unrelated package and tap policy file. Package tokens must be unique across `Casks` and `Formula`.

The CI runner temporarily trusts the whole tap only to run Homebrew's repository-wide syntax checks. User installation stays package-scoped through the fully qualified name above.
