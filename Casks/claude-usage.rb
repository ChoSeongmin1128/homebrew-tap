cask "claude-usage" do
  version "2.10.6"
  sha256 "5317f394ea7bcd366a086a44aad980673ff2d77e864a211c6953b6239eacd7d2"

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
