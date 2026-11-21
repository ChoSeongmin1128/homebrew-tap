cask "claude-usage" do
  version "2.10.11"
  sha256 "c9d07f61a3aacd907bf87dadd8c56ec28af483a9f099e4b497773fa86c673b78"

  url "https://github.com/ChoSeongmin1128/claude-usage/releases/download/v#{version}/ClaudeUsage.dmg"
  name "ClaudeUsage"
  desc "Menu bar usage monitor for Claude, Codex, and Antigravity"
  homepage "https://github.com/ChoSeongmin1128/claude-usage"

  livecheck do
    url "https://choseongmin1128.github.io/claude-usage/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: :sonoma

  app "ClaudeUsage.app"
end
