# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.13.1              ← `version` field of apps/order3000-cli/package.json
#   2080b1806c36154f38bfc1a1b2ba938f6f7cd6973767ba54a4bc470e9e12fd19     ← sha256 of order3000-darwin-arm64.tar.gz
#   2545a59a2fb1c3ee9d973e23716014341ec5090ae6f402eea566fdcbbf30f77f       ← sha256 of order3000-darwin-x64.tar.gz
#   e7e287fbb6c7744d3b29f118a08cae51bbfe997bc75c49ca24d705d40cb308aa      ← sha256 of order3000-linux-arm64.tar.gz
#   f5a8c25637551df18f347ec9f96a962816b525a52b6daa4fc6c0e30fd218f095        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.13.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "2080b1806c36154f38bfc1a1b2ba938f6f7cd6973767ba54a4bc470e9e12fd19"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "2545a59a2fb1c3ee9d973e23716014341ec5090ae6f402eea566fdcbbf30f77f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "e7e287fbb6c7744d3b29f118a08cae51bbfe997bc75c49ca24d705d40cb308aa"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "f5a8c25637551df18f347ec9f96a962816b525a52b6daa4fc6c0e30fd218f095"
    end
  end

  def install
    # The Bun-compiled standalone embeds the Bun runtime, which prints
    # `warn: CPU lacks AVX support, strange crashes may occur. Reinstall
    # Bun or use *-baseline build:` to stderr on every invocation when
    # the host CPU lacks AVX. The advice in that warning ("use *-baseline
    # build") is a dead end: the official `bun-darwin-x64-baseline` /
    # `bun-linux-x64-baseline` runtimes ALSO emit the same warning, and
    # `bun build --compile --target=*-baseline` produces a binary that
    # warns identically. Treat the warning as non-actionable Bun noise
    # and filter the two lines (warning + URL) at the wrapper level so
    # `order3000 …` looks like any other CLI.
    #
    # The wrapper preserves stdout, exit code, signal handling, and
    # argv quoting; it only mutates stderr by dropping the two known
    # AVX lines.
    libexec.install "order3000" => "order3000-bin"
    (bin/"order3000").write <<~SH
      #!/bin/bash
      exec "#{libexec}/order3000-bin" "$@" \\
        2> >(grep -v -E '^warn: CPU lacks AVX support|^  https://github\\.com/oven-sh/bun/releases/download/.*-baseline\\.zip' >&2)
    SH
    chmod 0755, bin/"order3000"
  end

  test do
    # The version check also exercises the wrapper — if the wrapper is
    # broken, this test fails before we ship the formula.
    assert_match version.to_s, shell_output("#{bin}/order3000 --version")
  end
end
