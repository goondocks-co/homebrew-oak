class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/24/f5/b32d216517366aaca207738efb1260cb9b3647464ebe550472cf5dc833e4/oak_ci-1.0.7.tar.gz"
  sha256 "5ce4e132a783ba7d06c524c11fe7fb59a89fe8856408f04b199b50dcd62cb703"
  license "MIT"

  depends_on "python@3.13"

  # Prevent Homebrew from rewriting Mach-O headers inside the virtualenv.
  # Native wheels (cryptography, grpcio, onnxruntime) have pre-built .so
  # files whose headers can't accommodate Homebrew's longer install paths.
  skip_clean "libexec"

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
