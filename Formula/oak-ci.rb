class OakCi < Formula
  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/c0/27/03f31e886161f4d575ccb80629b668e11a4621cc68681779d067b5d5a4a2/oak_ci-1.0.4.tar.gz"
  sha256 "dd2147a0673413f9ddabdecaeb6dcf6e43977ccfcd8906db0309b15aaa26343f"
  license "MIT"

  depends_on "python@3.13"

  def install
    # Create a virtualenv and install oak-ci with pip (uses pre-built wheels).
    # This avoids sdist-only build failures for native deps like onnxruntime
    # and flatbuffers, which don't publish source distributions.
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install "oak-ci==#{version}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oak version")
    assert_match "Usage", shell_output("#{bin}/oak --help")
  end
end
