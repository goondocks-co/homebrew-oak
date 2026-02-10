class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/1b/63/cad40ceddcb4e60f7a869fcacf44d3ec79bd6e3a3a0919b1616ac142b045/oak_ci-1.0.6.tar.gz"
  sha256 "bec8e69a64c184194805a6b50a9c89accc642ea2caeb98c3cdf32c061cd65f5e"
  license "MIT"

  depends_on "python@3.13"

  def install
    # Create a full virtualenv (with pip) and install oak-ci with all deps.
    # We use python -m venv directly (not virtualenv_create) because Homebrew's
    # helper passes --without-pip. We need pip to install oak-ci with pre-built
    # wheels, since native deps like onnxruntime and flatbuffers lack sdists.
    python3 = "python3.13"
    system python3, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", "oak-ci==#{version}"
    bin.install_symlink libexec/"bin/oak"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oak version")
    assert_match "Open Agent Kit", shell_output("#{bin}/oak --help")
  end
end
