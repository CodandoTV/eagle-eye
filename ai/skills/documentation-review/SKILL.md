---
name: documentation-review
description: Validate EagleEye documentation matches actual implementation
trigger: when the user asks to review documentation, check for outdated docs, or verify docs match code
---

# Documentation Review for EagleEye

When invoked:

1. Scan all documentation:
   ```text
   doc/**/*.md
   README.md
   ```

2. Validate links:

   ### Internal
   - For each markdown link to a file (e.g., `[text](some/path.md)`), verify the referenced file exists.
   - For anchor links (e.g., `[text](#section)`), verify the target section heading exists in the file.

   ### External
   - For URLs (e.g., `https://...`), verify they are reachable (HTTP 200).

3. Verify configuration examples match actual project configuration:

   ### Dart Package
   - Cross-check `pubspec.yaml` snippets in docs against actual `pubspec.yaml`.
   - Verify `analysis_options.yaml` examples match the real file.
   - Verify installation instructions (`dev_dependencies:` snippets) match the current package name and version convention.
   - Verify CLI run command (`dart run eagle_eye:main`) is accurate.
   - Verify JSON configuration examples (`eagle_eye_config.json`) match the actual rule engine.

4. Verify documented APIs exist:
   - Check that all referenced public Dart APIs, classes, and functions exist in `lib/`.

5. Verify setup instructions are accurate:
   - Cross-check `README.md` setup steps against actual build files (`pubspec.yaml`, `analysis_options.yaml`).

6. Verify release instructions are still valid:
   - Check `CHANGELOG.md` and `pubspec.yaml` version consistency.

7. Report findings:

   ### Errors
   - Broken internal links
   - Broken external URLs
   - Configuration examples that don't match real files
   - Non-existent APIs referenced in docs

   ### Warnings
   - Outdated version references
   - Missing sections or incomplete documentation
   - Deprecated feature references

   ### Suggestions
   - Recommended improvements to clarity or completeness
