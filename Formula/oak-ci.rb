class OakCi < Formula
  include Language::Python::Virtualenv

  desc "Codebase intelligence toolkit for development workflows"
  homepage "https://github.com/goondocks-co/open-agent-kit"
  url "https://files.pythonhosted.org/packages/fb/8d/91facb95bfacd6dad95ba5c385a26504f24bac8116496a6606a227b88279/oak_ci-1.0.9.tar.gz"
  sha256 "63ed669d1fd2090a68dc753ed53d03eb35054d65d4999fb063eff5230aa5e631"
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
