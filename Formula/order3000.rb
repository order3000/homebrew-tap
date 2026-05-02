# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.1.12              ← `version` field of apps/order3000-cli/package.json
#   237443401aec519f01c3365652f47412e32bac87ac807d6d442d5588ce635809     ← sha256 of order3000-darwin-arm64.tar.gz
#   dd63c339bb7b2c526a7e2811c5a372aca393bef98bab0fd4f84952a98374a06c       ← sha256 of order3000-darwin-x64.tar.gz
#   8102aa1be6c6e5e0cac3ecd986232c4d74c5e99dc6266e29c0693b640547b479      ← sha256 of order3000-linux-arm64.tar.gz
#   0a58d26ee0b946e5539662e902a4be275719dc3461e9fc3eacc9cf5148158a20        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.1.12"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "237443401aec519f01c3365652f47412e32bac87ac807d6d442d5588ce635809"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "dd63c339bb7b2c526a7e2811c5a372aca393bef98bab0fd4f84952a98374a06c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "8102aa1be6c6e5e0cac3ecd986232c4d74c5e99dc6266e29c0693b640547b479"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "0a58d26ee0b946e5539662e902a4be275719dc3461e9fc3eacc9cf5148158a20"
    end
  end

  def install
    bin.install "order3000"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/order3000 --version")
  end
end
