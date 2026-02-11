class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/24/f5/b32d216517366aaca207738efb1260cb9b3647464ebe550472cf5dc833e4/oak_ci-1.0.7.tar.gz"
  sha256 "5ce4e132a783ba7d06c524c11fe7fb59a89fe8856408f04b199b50dcd62cb703"
  license "MIT"

  depends_on "python@3.13"

  def install
    # Create a virtualenv with pip. We use python -m venv directly (not
    # virtualenv_create) because Homebrew's helper passes --without-pip.
    python3 = "python3.13"
    system python3, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"

    # Write a wrapper script that delegates to the real oak binary.
    # We can't use bin.install_symlink because the target doesn't exist yet
    # (pip install runs in post_install) and Homebrew's link phase runs
    # between install and post_install — dangling symlinks get dropped.
    (bin/"oak").write <<~SH
      #!/bin/bash
      exec "#{libexec}/bin/oak" "$@"
    SH
    (bin/"oak").chmod 0755
  end

  def post_install
    # Install oak-ci AFTER Homebrew's linkage-fixup phase so that native
    # wheels (cryptography, grpcio, onnxruntime) with pre-built .so files
    # are never subjected to Mach-O header rewriting.
    system libexec/"bin/pip", "install", "oak-ci==#{version}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oak version")
    assert_match "Open Agent Kit", shell_output("#{bin}/oak --help")
  end
end
