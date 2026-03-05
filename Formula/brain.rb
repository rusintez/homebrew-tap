class Brain < Formula
  desc "Local AI assistant that runs entirely on your Mac"
  homepage "https://github.com/rusintez/brain"
  url "https://github.com/rusintez/brain/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "24fc19dc8cf3911535f33b6f182bd2799bfd124997e3940784f4e41840a16082"
  license "MIT"

  depends_on :macos
  depends_on :xcode => ["15.0", :build]
  depends_on :arch => :arm64

  def install
    # Build with xcodebuild (required for Metal shaders)
    system "xcodebuild", "build",
           "-scheme", "brain",
           "-configuration", "Release",
           "-destination", "platform=macOS",
           "-derivedDataPath", ".derived"

    # Install binary
    libexec.install ".derived/Build/Products/Release/brain"
    
    # Install Metal bundle
    libexec.install ".derived/Build/Products/Release/mlx-swift_Cmlx.bundle"

    # Create wrapper script that sets correct working directory for bundle
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
