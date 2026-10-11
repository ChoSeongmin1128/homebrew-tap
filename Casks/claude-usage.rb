cask "claude-usage" do
  version "2.9.5"
  sha256 "135f9830be165311b3eea7f3350a5a9d5cc4a35268ed14a21615ea33dafef039"

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
