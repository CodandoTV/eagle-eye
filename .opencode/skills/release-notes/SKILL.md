---
name: release-notes
description: Generate release notes and prepare the next release
---

When invoked:

1. Detect current version from `pubspec.yaml`:
   - Read the `version:` field (e.g., `2.0.2`).

2. Get the latest Git tag:
   ```bash
   git tag --sort=-v:refname | head -1
   ```

3. Analyze unreleased changes:
   ```bash
   git log <latest-tag>..HEAD --oneline
   ```

4. Categorize commits by conventional commit type:

   | Category | Keywords |
   |----------|----------|
   | Major | `breaking`, `BREAKING CHANGE` |
   | Minor | `feat`, `feature` |
   | Patch | `fix`, `docs`, `chore`, `refactor`, `test`, `changelog` |

5. Determine next semantic version based on the highest category found.

6. Update version in `pubspec.yaml`:
   - Replace the `version:` field with the new version.

7. Create or update `CHANGELOG.md`:
   - Add a new section at the top:

   ```md
   ## X.Y.Z

   ### Features

   - Added ...

   ### Fixes

   - Fixed ...

   ### Documentation

   - Updated ...
   ```

8. Generate a release summary with:
   - New version number
   - Number of commits by category
   - Key changes

9. Prompt the user to:
   ```bash
   git commit -m "Bump version to X.Y.Z"
   git tag vX.Y.Z
   git push && git push --tags
   ```

10. Verify publishing metadata:
    - Confirm `pubspec.yaml` has `homepage`, `description`, and valid `version`.
    - No sensitive or private packages (check for `publish_to: none`).
