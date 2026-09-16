# ClaudeUsage Homebrew Tap

Homebrew Cask distribution for [ClaudeUsage](https://github.com/ChoSeongmin1128/claude-usage).

```bash
brew install --cask choseongmin1128/tap/claude-usage
```

The Cask installs the notarized universal app from the immutable production GitHub Release. ClaudeUsage's signed Sparkle updater remains enabled, so either the app or Homebrew can install a later production release.

For an existing manual installation, quit ClaudeUsage and move only `/Applications/ClaudeUsage.app` to the Trash before installing the Cask. Preferences, Application Support data, Keychain items, and credentials owned by external CLIs are outside the app bundle and are not removed. Do not use `--adopt`; Homebrew skips its artifact comparison for self-updating Casks.

Staging builds are not distributed through this tap.
