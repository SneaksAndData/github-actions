# github-actions

Repository for common actions used in Sneaks And Data CI/CD processes

Available actions are:

## semver_release

### Description
Creates a new github release based on git tags and [semantic versioning](https://semver.org/)

### Inputs
- major_v -- major version of current release
- minor_v -- minor version of current release

### Outputs
- version -- generated new version of the release

### Usage
```yaml
name: Release a new version

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Create Release
        uses: ./semver_release/
        with:
          major_v: 0
          minor_v: 0
```