# Claude Code Guidelines

This file contains guidelines for Claude Code when working on this project.

## Commit Messages

### Format
- Keep commit messages **short and precise**
- Use imperative mood (e.g., "Fix bug" not "Fixed bug")
- For bugfixes, add **FIX** prefix

### Examples

**Bug fixes:**
```
FIX Platform error on web by using kIsWeb check
```

**Features:**
```
Add enrollment video download for web
```

**Multiple related changes:**
```
FIX web compatibility issues for Chrome

- Fix Platform._operatingSystem error in enrollment screen
- Fix TextField layout errors on web
- Change video format to .webm for web downloads
```

### Commit Workflow
1. After completing work, propose commit message(s)
2. Offer only 1 draft
3. Do not commit yourself. The user will do it manually.

## Project-Specific Notes

- Videos recorded on web are in WebM format (.webm)
- Audio recording is disabled via `enableAudio: false` in CameraController
- Web platform detection uses `kIsWeb` from `package:flutter/foundation.dart`
- Platform-specific code uses conditional imports for web utilities