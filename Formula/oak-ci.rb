class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/c0/27/03f31e886161f4d575ccb80629b668e11a4621cc68681779d067b5d5a4a2/oak_ci-1.0.4.tar.gz"
  sha256 "dd2147a0673413f9ddabdecaeb6dcf6e43977ccfcd8906db0309b15aaa26343f"
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
    assert_match "Usage", shell_output("#{bin}/oak --help")
  end
end
