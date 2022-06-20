# github-actions

Repository for common actions used in Sneaks And Data CI/CD processes

Available actions are:
1. [semver_release](#semver_release)
2. [install_poetry](#install_poetry)

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
        uses: SneaksAndData/github-actions/semver_release@v0.0.2
        with:
          major_v: 0
          minor_v: 0
```

## install_poetry

### Description
Installs poetry to build environment and restores dependencies using custom and private pypi indices.
Optionally can export dependency tree to requirements.txt file.

### Inputs
  inputs:
  - pypi_repo_url -- URL of python package index (for custom packages)
  - pypi_token_username -- Username for authentication at python package index (for custom packages)
  - pypi_token -- Token for authentication at python package index (for custom packages)
  - export_requirements -- Set to `true` if need to generate requirements.txt. **Optional** defaults to **false**.
  - export_credentials -- If export_requirements is set to true, it exports requirements.txt with
    --with-credentials flag. Otherwise, does nothing. **Optional**. Default value is '**true**'"
  - requirements_path -- Path to requirements.txt to be generated (relative to sources root).
    **Optional**. Default value is '**.container/requirements.txt**'.
  - install_preview -- Install preview version of Poetry. **Optional**. Default value is '**true**'
  - version -- Version to install. If value is 'latest', script will install the latest available version of Poetry.
    **Optional**. Default value is '**latest**'
  - install_extras -- List of optional dependencies to install, separated by space. **Optional**. Default is empty.

### Outputs
No outputs defined

### Usage
```yaml
name: Install poetry and package dependencies

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
       - name: Install Poetry and dependencies
         uses: SneaksAndData/github-actions/install_poetry@v0.0.3
         with:
           pypi_repo_url: ${{ secrets.AZOPS_PYPI_REPO_URL }}
           pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
           pypi_token: ${{ secrets.AZOPS_PAT }}
           export_requirements: True # if you want to generate requirements.txt
           requirements_path: ".container/requirements.txt" 
           install_extras: "azure datadog"
```
