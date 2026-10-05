# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.16.5              ← `version` field of apps/order3000-cli/package.json
#   ac4e0676610a49b112b0ee1acfea4738537a3660160e3d2c872f53e289ffe881     ← sha256 of order3000-darwin-arm64.tar.gz
#   dd683e313af4c90095b82f09a5bfc2b5a9486cb65ea0c45b9eea201f3bdbea3d       ← sha256 of order3000-darwin-x64.tar.gz
#   9d0c779c68fc9538e6d6bbb9c9e3de71a65db43a8dba0289aef9c9f2edee249e      ← sha256 of order3000-linux-arm64.tar.gz
#   eaed1087ccdc1a4feb85505de6ccd6fde4231940a4d60e4b1314fbb28f077009        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.16.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "ac4e0676610a49b112b0ee1acfea4738537a3660160e3d2c872f53e289ffe881"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "dd683e313af4c90095b82f09a5bfc2b5a9486cb65ea0c45b9eea201f3bdbea3d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "9d0c779c68fc9538e6d6bbb9c9e3de71a65db43a8dba0289aef9c9f2edee249e"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "eaed1087ccdc1a4feb85505de6ccd6fde4231940a4d60e4b1314fbb28f077009"
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
