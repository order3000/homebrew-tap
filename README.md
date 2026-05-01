# order3000 — Homebrew tap

Homebrew tap for the [order3000 CLI](https://github.com/order3000/cli).

```sh
brew tap order3000/tap
brew install order3000
order3000 --version
```

To upgrade later: `brew upgrade order3000`.

---

## What lives here

This repository hosts only the Homebrew formula. It is published from
the kadal monorepo (`apps/order3000-cli/homebrew/order3000.rb` template)
on every CLI release. The actual binaries are attached to GitHub
Releases on [`order3000/cli`](https://github.com/order3000/cli/releases).

Hand edits to `Formula/order3000.rb` are overwritten on the next
release; treat this repository as a publishing target, not a working
tree.

## Issues / PRs

Issues for the CLI itself: <https://github.com/order3000/cli/issues>.
