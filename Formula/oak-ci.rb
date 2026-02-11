class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/fb/29/331408609f6a2cb36dffccee2a1300d6a4dd432c29af058862683536c19b/oak_ci-1.0.12.tar.gz"
  sha256 "b17fbd31e206c12ea3fe1327854fc5764da95e814406de7d7a631125c387a3d4"
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
    # Retry with backoff — PyPI CDN can take 1-2 minutes to propagate
    # a newly published version to all edge nodes.
    system "bash", "-c", <<~SH
      for i in 1 2 3 4 5; do
        "#{libexec}/bin/pip" install "oak-ci==#{version}" && exit 0
        echo "PyPI not ready yet (attempt $i/5), retrying in 30s..."
        sleep 30
      done
      echo "ERROR: oak-ci #{version} not available on PyPI after 5 attempts"
      exit 1
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oak version")
    assert_match "Open Agent Kit", shell_output("#{bin}/oak --help")
  end
end
