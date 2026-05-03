# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.5.0              ← `version` field of apps/order3000-cli/package.json
#   a36ab9d185f3072134e243a986784e60b23c8df7fb9a9f72e9211960afc69e67     ← sha256 of order3000-darwin-arm64.tar.gz
#   777f36951adb16bb50770da3af2417e9ce1652f223e7c916fd32d6b4a8e10c9e       ← sha256 of order3000-darwin-x64.tar.gz
#   b3f571c9b6913e5d0e74bdc4a90209bde5da3ee9d233e097c9db28d19a237891      ← sha256 of order3000-linux-arm64.tar.gz
#   c3103684d15de383e41a6e248c3488a5e8344f9e409a75dfc78c7cc3d6c8f380        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "a36ab9d185f3072134e243a986784e60b23c8df7fb9a9f72e9211960afc69e67"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "777f36951adb16bb50770da3af2417e9ce1652f223e7c916fd32d6b4a8e10c9e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "b3f571c9b6913e5d0e74bdc4a90209bde5da3ee9d233e097c9db28d19a237891"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "c3103684d15de383e41a6e248c3488a5e8344f9e409a75dfc78c7cc3d6c8f380"
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
