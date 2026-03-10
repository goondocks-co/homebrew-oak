class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/bd/6a/0bca76c7b74a37c7ea3a964734807de60d6d40857f98aed94f21ddbb7999/oak_ci-1.5.5.tar.gz"
  sha256 "8f8cfe2d96a947e82c60abdedba56528ec7db3057871a3971d7c1d909975e3b9"
  license "MIT"

  depends_on "python@3.13"

  def install
    # Create a virtualenv with pip. We use python -m venv directly (not
    # virtualenv_create) because Homebrew's helper passes --without-pip.
    python3 = "python3.13"
    system python3, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"

    # Pre-build a wheel from the Homebrew-downloaded source and stash it
    # for post_install. This avoids re-fetching oak-ci from PyPI, which
    # consistently fails on the first pip invocation after venv creation
    # (likely due to pip HTTP cache/connection cold-start after self-upgrade).
    mkdir_p libexec/".wheels"
    system libexec/"bin/pip", "wheel", "--no-deps", "--wheel-dir=#{libexec}/.wheels", "."

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
    # Install from the pre-built wheel. The main package is local; only
    # dependencies are fetched from PyPI. This runs AFTER Homebrew's
    # linkage-fixup phase so native wheels (cryptography, grpcio,
    # onnxruntime) aren't subjected to Mach-O header rewriting.
    wheel = Dir["#{libexec}/.wheels/oak_ci-*.whl"].first
    odie "Pre-built wheel not found in #{libexec}/.wheels" unless wheel
    system libexec/"bin/pip", "install", wheel
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oak version")
    assert_match "Open Agent Kit", shell_output("#{bin}/oak --help")
  end
end
