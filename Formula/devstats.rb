# Homebrew formula for devstats. This file is the source of truth; the copy users
# install from lives in the tap repository luongnv89/homebrew-tap at
# Formula/devstats.rb, so `brew install luongnv89/tap/devstats` works on macOS and Linux.
#
# Publishing a release (keep `version` in Cargo.toml and the tag in sync):
#   1. In the release commit, point `url` below at the new tag (tests/metadata.rs
#      checks it matches Cargo.toml).
#   2. Tag and push the release: git tag vX.Y.Z && git push origin vX.Y.Z
#   3. Get the checksum of the source tarball:
#        curl -fsSL https://github.com/luongnv89/devstats-cli/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
#   4. Set `sha256` below, then copy this file to Formula/devstats.rb in
#      luongnv89/homebrew-tap and push it.
#   5. Check it: brew audit --strict --online luongnv89/tap/devstats
#                brew install --build-from-source luongnv89/tap/devstats && brew test devstats
class Devstats < Formula
  desc "Contribution stats for every contributor across GitHub organizations"
  homepage "https://github.com/luongnv89/devstats-cli"
  url "https://github.com/luongnv89/devstats-cli/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "13ea61af45e4fad676efd256a735d8f3786efbbd6b0b11f3ea1c6283e4c533fe"
  license "Apache-2.0"
  head "https://github.com/luongnv89/devstats-cli.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    # Runs `devstats --completions bash|zsh|fish`.
    generate_completions_from_executable(bin/"devstats", "--completions")
  end

  def caveats
    <<~EOS
      devstats reads a GitHub token from GITHUB_TOKEN, GH_TOKEN or `gh auth token`.
      Without one, GitHub allows only 60 requests per hour.
    EOS
  end

  test do
    assert_match "devstats #{version}", shell_output("#{bin}/devstats --version")
    assert_match "#compdef devstats", shell_output("#{bin}/devstats --completions zsh")
    # Bad input fails offline with the documented exit code 3.
    output = shell_output("#{bin}/devstats 'not an org' 2>&1", 3)
    assert_match "not a GitHub organization", output
  end
end
