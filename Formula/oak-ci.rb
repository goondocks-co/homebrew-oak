class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/ef/5b/bd4b087a161200f2138c5f7e6b57bff017b574e7bb11c39fc40f89f932c9/oak_ci-1.1.4.tar.gz"
  sha256 "076ea736770425b0e57ff3b56d6ed0f806190e2d2da3d0f99f3fb92e8fb0632e"
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
