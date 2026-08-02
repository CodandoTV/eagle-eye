---
name: trigger-release
description: Automate the EagleEye release process — update changelog, bump version, tag, and push
trigger: when the user asks to trigger a release, cut a release, or release a new version
---

# Trigger Release

When invoked:

1. Verify the current branch is `main`:
   ```bash
   git branch --show-current
   ```
   If not on `main`, stop and tell the user to switch branches first.

2. Detect current version from `pubspec.yaml`:
   - Read the `version:` field (e.g., `2.0.2`).

3. Get the latest Git tag:
   ```bash
   git tag --sort=-v:refname | head -1
   ```

4. Show unreleased commits as context:
   ```bash
   git log <latest-tag>..HEAD --oneline
   ```

5. Compute the next patch version (always bump patch):
   - `2.0.2` → `2.0.3`

6. Ask the user for release notes. Ask questions one at a time:
   - "Here are the unreleased commits since `<latest-tag>`. What release notes should I write for v`<next-version>`?"
   - Wait for the user's response.

7. Insert the release notes into `CHANGELOG.md` at the top, after any existing content above the first `##` section:
   ```md
   ## <next-version>

   - <user-provided release notes>
   ```

8. Update the version in `pubspec.yaml`:
   - Replace the `version:` field with the next patch version.

9. Output the final commands for the user to run:
   ```bash
   git commit -am "Bump version to <next-version>"
   git tag v<next-version>
   git push && git push --tags
   ```

   Remind the user that pushing the tag will automatically trigger the pub.dev publish pipeline.
