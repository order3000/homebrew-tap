# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.4.0              ← `version` field of apps/order3000-cli/package.json
#   1e66b8f5170a0b1bc75ba01696c28e503d5def53aed8fba1f7485c40bd3d3a8c     ← sha256 of order3000-darwin-arm64.tar.gz
#   63325b56a977d37bf7288a20a25ccc9eebf3a203be60bf0702612e7dc7be4207       ← sha256 of order3000-darwin-x64.tar.gz
#   bf5eb897f685f6ac94ab134ff05ea712001733d0c4b888484c9b25b2780cc278      ← sha256 of order3000-linux-arm64.tar.gz
#   d974a1a5ba48ec7b49ac0f51b95005e347eed04bf81cb93a5133a70a281c2d00        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "1e66b8f5170a0b1bc75ba01696c28e503d5def53aed8fba1f7485c40bd3d3a8c"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "63325b56a977d37bf7288a20a25ccc9eebf3a203be60bf0702612e7dc7be4207"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "bf5eb897f685f6ac94ab134ff05ea712001733d0c4b888484c9b25b2780cc278"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "d974a1a5ba48ec7b49ac0f51b95005e347eed04bf81cb93a5133a70a281c2d00"
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
