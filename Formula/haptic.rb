class Haptic < Formula
  desc "macOS Force Touch trackpad haptic feedback CLI"
  homepage "https://github.com/rusintez/haptic"
  url "https://github.com/rusintez/haptic.git", tag: "v1.0.0"
  license "MIT"
  head "https://github.com/rusintez/haptic.git", branch: "main"

  depends_on :macos
  depends_on xcode: ["12.0", :build]

  def install
    system "swiftc", "-O", "-o", "haptic", "main.swift",
           "-F", "/System/Library/PrivateFrameworks",
           "-framework", "MultitouchSupport"
    bin.install "haptic"
  end

  def caveats
    <<~EOS
      haptic requires a Force Touch trackpad to work.
      You must have your finger on the trackpad to feel the feedback.

      Usage:
        haptic [pattern]

      Patterns: light, medium, strong, done, alert, heartbeat, pulse, knock, sos
    EOS
  end

  test do
    assert_match "haptic", shell_output("#{bin}/haptic --help")
  end
end
