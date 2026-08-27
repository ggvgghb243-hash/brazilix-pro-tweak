# Brazilix Pro Tweak

iOS Theos Tweak project with automated GitHub Actions CI/CD.

## Features
- Automated `.deb` build via GitHub Actions (macOS runner with Theos & iOS SDKs)
- Native Theos Makefile structure

## Building with GitHub Actions
Every push to any branch or manual trigger (`workflow_dispatch`) will automatically compile the tweak into a Debian package (`.deb`) and upload it as a downloadable artifact in the GitHub Actions tab.
