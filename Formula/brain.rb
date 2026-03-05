class Brain < Formula
  desc "Local AI assistant that runs entirely on your Mac"
  homepage "https://github.com/rusintez/brain"
  version "0.1.1"
  license "MIT"

  on_arm do
    url "https://github.com/rusintez/brain/releases/download/v0.1.1/brain-darwin-arm64.tar.gz"
    sha256 "e1063a03ce3485595cf9839229ac06e2ea34c253d2f36bd2baeb06bfdbc5d642"
  end

  depends_on :macos
  depends_on :arch => :arm64

  def install
    # Install binary and Metal bundle
    libexec.install "brain"
    libexec.install "mlx-swift_Cmlx.bundle"

    # Create wrapper script
    (bin/"brain").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/brain" "$@"
    EOS

    # Install example skills
    (pkgshare/"skills").install Dir["skills/*"] if Dir.exist?("skills")
  end

  def post_install
    # Create user skills directory
    skills_dir = Pathname.new(Dir.home)/".config/brain/skills"
    skills_dir.mkpath unless skills_dir.exist?
    
    # Copy example skills if not present
    if (pkgshare/"skills").exist?
      Dir[pkgshare/"skills/*"].each do |skill|
        target = skills_dir/File.basename(skill)
        cp skill, target unless target.exist?
      end
    end
  end

  def caveats
    <<~EOS
      brain is installed!

      Skills are stored in ~/.config/brain/skills/
      
      Models will download on first use (~500MB-2GB each).
      
      Some skills need optional tools:
        brew install ripgrep   # for grep/search skills
      
      Quick start:
        brain "What files are here?"
        brain -v "Show me thinking"
        brain --help
    EOS
  end

  test do
    assert_match "Local LLM agent", shell_output("#{bin}/brain --help")
  end
end
