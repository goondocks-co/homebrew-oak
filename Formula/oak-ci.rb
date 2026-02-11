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

    # The symlink target (libexec/bin/oak) won't exist until post_install,
    # but dangling symlinks are fine — Homebrew doesn't validate targets.
    bin.install_symlink libexec/"bin/oak"
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
