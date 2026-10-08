cask "claude-usage" do
  version "2.9.1"
  sha256 "1e0e1fd1034efe5d577ce3a33040ce77d26ac2a07e9a751513fa01b1f885a132"

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
