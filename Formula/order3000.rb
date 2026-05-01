# typed: false
# frozen_string_literal: true
#
# This is a TEMPLATE. The five `__…__` tokens below are substituted by
# `apps/order3000-cli/scripts/release.sh` on every release:
#
#   0.1.11              ← `version` field of apps/order3000-cli/package.json
#   b82ac2271cff70cc020d5d62759f5cff35b617176c27429ab2ffad965723dd54     ← sha256 of order3000-darwin-arm64.tar.gz
#   9d63b731342883d32d44818374938bf3f248b398c30076ca390e591dc7b4b8b7       ← sha256 of order3000-darwin-x64.tar.gz
#   833d4d47eeb34de69467ebdac3d7a1a634cff801aa68f1e37956cf64ec6380ad      ← sha256 of order3000-linux-arm64.tar.gz
#   8f5c2d15078ce4edf14ae98c938f3c340f863ac279ea3dbc5732b584fd10fd3c        ← sha256 of order3000-linux-x64.tar.gz
#
# The substituted file is committed to `github.com/order3000/homebrew-tap`.
# Hand-edits to this template are overwritten on every release; the
# rendered formula in the tap repo carries the real values.
class Order3000 < Formula
  desc "Agent-friendly command-line interface for the order3000 platform"
  homepage "https://github.com/order3000/cli"
  version "0.1.11"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-arm64.tar.gz"
      sha256 "b82ac2271cff70cc020d5d62759f5cff35b617176c27429ab2ffad965723dd54"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-darwin-x64.tar.gz"
      sha256 "9d63b731342883d32d44818374938bf3f248b398c30076ca390e591dc7b4b8b7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-arm64.tar.gz"
      sha256 "833d4d47eeb34de69467ebdac3d7a1a634cff801aa68f1e37956cf64ec6380ad"
    end
    on_intel do
      url "https://github.com/order3000/cli/releases/download/v#{version}/order3000-linux-x64.tar.gz"
      sha256 "8f5c2d15078ce4edf14ae98c938f3c340f863ac279ea3dbc5732b584fd10fd3c"
    end
  end

  def install
    bin.install "order3000"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/order3000 --version")
  end
end
