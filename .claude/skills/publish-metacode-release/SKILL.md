---
name: publish-metacode-release
description: Publish a new release of the metacode CLI tool and update its Homebrew tap. Uploads the release tar.gz as a GitHub Release asset on staycaffeinated/metacode-g4, then updates the url/sha256/version in the Homebrew formula at staycaffeinated/homebrew-tap (Formula/metacode.rb) and pushes. Use when the user asks to "publish a metacode release", "cut a new metacode release", "release metacode X.Y.Z", "update the homebrew formula", or similar for this specific project.
---

# Publish a metacode release

This automates the release flow for the `metacode` CLI tool and its Homebrew
tap. It replaces the old process of committing the `.tar.gz` directly into
`homebrew-tap` (which bloated that repo's git history and caused `http.postBuffer`
push failures — see that repo's old `TROUBLE_SHOOTING.txt`). Instead, the
tarball is published as a GitHub Release asset on the `metacode-g4` repo itself,
and the tap repo only ever holds the small formula file.

Requires: `gh` CLI installed and authenticated (`gh auth status`), and `git`
push access to both repos. Run this from a real terminal with network access
(e.g. Claude Code on the user's machine) — it will not work through a sandboxed
environment with no network access.

Repos and paths (fixed for this project):
- Source repo (where the release is published): `staycaffeinated/metacode-g4`
- Tap repo: `staycaffeinated/homebrew-tap`
  - Local clone: `~/Workspace/JavaProjects/homebrew-tap`
  - Formula file: `Formula/metacode.rb`
  - Default branch: `main`

## Inputs needed from the user (ask if not provided)

1. The version being released, e.g. `14.2.0`.
2. The path to the already-built release tarball, e.g.
   `~/Workspace/JavaProjects/metacode-g4/build/distributions/metacode-14.2.0.tar.gz`.
   The filename should follow the existing convention: `metacode-<version>.tar.gz`.

Do not attempt to build the tarball yourself — assume the user has already run
their own build (e.g. Gradle Shadow jar packaging) and has it ready locally.

## Steps

1. **Sanity check the tap repo is clean before touching it.**
   ```
   cd ~/Workspace/JavaProjects/homebrew-tap
   git status --short --branch
   ```
   If there are uncommitted changes, stop and ask the user how to proceed
   rather than overwriting them. Otherwise `git pull` to make sure it's current.

2. **Compute the sha256 of the new tarball.**
   ```
   shasum -a 256 <path-to-tarball>
   ```
   (On Linux, use `sha256sum` instead.) Keep the resulting hash for step 4.

3. **Create the GitHub Release with the tarball as an asset**, on the
   `metacode-g4` source repo (not the tap repo):
   ```
   gh release create v<version> <path-to-tarball> \
     --repo staycaffeinated/metacode-g4 \
     --title "v<version>" \
     --generate-notes
   ```
   If a release for that tag already exists, ask the user before overwriting
   (`gh release upload` to add an asset, or `gh release delete` first).

   The resulting asset download URL will be:
   ```
   https://github.com/staycaffeinated/metacode-g4/releases/download/v<version>/metacode-<version>.tar.gz
   ```

4. **Update the formula file** at
   `~/Workspace/JavaProjects/homebrew-tap/Formula/metacode.rb`:
   - Replace the `url "..."` line with the release download URL from step 3.
   - Replace the `sha256 "..."` line with the hash from step 2.
   - In the `test do` block, update the `assert_match "<old-version>", output`
     line to the new version string.

   Example diff shape (values will differ):
   ```ruby
   url "https://github.com/staycaffeinated/metacode-g4/releases/download/v14.2.0/metacode-14.2.0.tar.gz"
   sha256 "abcd1234...
   ...
   assert_match "14.2.0", output
   ```

5. **Commit and push the tap repo.**
   ```
   cd ~/Workspace/JavaProjects/homebrew-tap
   git add Formula/metacode.rb
   git commit -m "Bump metacode to <version>"
   git push
   ```
   Do NOT add the `.tar.gz` file to this commit or to the repo — release
   assets now live on GitHub Releases, not in this repo's git history.

6. **Verify.** Show the user the diff that was committed (`git show HEAD`) and
   confirm the release is visible: `gh release view v<version> --repo staycaffeinated/metacode-g4`.
   Suggest they can test locally with `brew upgrade metacode` or
   `brew test metacode` once the tap picks up the change.

## Notes for the user

- Historical tarballs already committed into `homebrew-tap`'s git history
  (versions 5.0.0–14.1.0) are not touched by this skill — cleaning those out
  would require a git history rewrite (e.g. `git filter-repo`), which is a
  separate, deliberate one-time operation and should only be done if asked.
- The `.archives/` folder and `update-metacode-tap.sh` in the tap repo are
  gitignored local helpers (not tracked by git) — this skill doesn't need to
  touch them, though `update-metacode-tap.sh` can still be used afterward to
  copy the updated formula into a local `brew` tap for testing before pushing,
  if the user wants to test first.
