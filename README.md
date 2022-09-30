# github-actions

Repository for common actions used in Sneaks And Data CI/CD processes

Available actions are:
1. [semver_release](#semver_release)
2. [install_poetry](#install_poetry)
3. [build_helm_chart](#build_helm_chart)
4. [create_package](#create_package)

## semver_release

### Description
Creates a new github release based on git tags and [semantic versioning](https://semver.org/)

### Inputs
| Name    | Description                      | Optional |
|---------|:---------------------------------|----------|
| major_v | major version of current release | False    |
| minor_v | minor version of current release | False    |

### Outputs
| Name    | Description                          |
|---------|--------------------------------------|
| version | generated new version of the release |

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
        uses: SneaksAndData/github-actions/semver_release@v0.0.9
        with:
          major_v: 0
          minor_v: 0
```

## install_poetry

### Description
Installs poetry to build environment and restores dependencies using custom and private pypi indices.
Optionally can export dependency tree to requirements.txt file.



### Inputs
| Name                      | Description                                                                                                                | Optional | Default value               |
|---------------------------|:---------------------------------------------------------------------------------------------------------------------------|----------|-----------------------------|
| pypi_repo_url             | URL of python package index (for custom packages)                                                                          | False    |                             |
| pypi_token_username       | Package index authentication username.                                                                                     | False    |                             |
| pypi_token                | Package index authentication token or password.                                                                            | False    |                             |
| export_requirements       | Set to `true` if need to generate requirements.txt. **Optional** defaults to **false**.                                    | False    |                             |
| export_credentials        | If export_requirements is set to true, it exports requirements.txt with --with-credentials flag. Otherwise, does nothing.  | True     | true                        |
| requirements_path         | Path to requirements.txt to be generated (relative to sources root).                                                       | True     | .container/requirements.txt | 
| install_preview           | Install preview version of Poetry. This should be set to **true** in build process until Poetry version 1.2.0 is released. | True     | false                       |
| version                   | Version to install. If value is 'latest', script will install the latest available version of Poetry.                      | True     | latest                      |
| install_extras            | List of optional dependencies to install, separated by space. If value is 'all', all extras will be installed              | True     |                             |
| install_only_dependencies | If set to true, installs only dependencies for project, adds the parameter `--no-root` to `poetry install` command.        | True     | false                       |
| skip_dependencies         | If set to true, installs only poetry without installing dependencies.                                                      | True     | false                       |

### Outputs
| Name             | Description                                                 |
|------------------|:------------------------------------------------------------|
| custom_repo_name | Name of configured custom repository to poetry push command |

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
        uses: SneaksAndData/github-actions/install_poetry@v0.0.9
        with:
           pypi_repo_url: ${{ secrets.AZOPS_PYPI_REPO_URL }}
           pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
           pypi_token: ${{ secrets.AZOPS_PAT }}
           export_requirements: True # if you want to generate requirements.txt
           requirements_path: ".container/requirements.txt" 
           install_extras: "azure datadog"
```

## build_helm_chart

### Description

Allows to build helm chart and push it to remote container repository.

**NOTE**: to be able to use this action, your repository should contain [version tags](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).
This action relies on git tags to be present in order to generate an artifact tag.

### Inputs
| Name                       | Description                                    | Optional | Default value |
|----------------------------|:-----------------------------------------------|----------|---------------|
| container_registry_address | Container registry address                     | False    |               |
| application:               | Application name                               | False    |               |
| container_registry_user    | Container registry username                    | False    |               |
| container_registry_token   | Container registry access token                | False    |               |
| helm_version               | Version of helm to install                     | True     | 3.9.2         |
| helm_directory             | Location of helm chart related to project root | True     | .helm         |

### Outputs
No outputs defined

### Usage
```yaml
name: Build and publish Helm chart

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Build and Push Chart (DEV)
        uses: SneaksAndData/github-actions/build_helm_chart@v0.0.9
        with:
          application: beast
          container_registry_user: ${{secrets.AZCR_DEV_USER}}
          container_registry_token:  ${{secrets.AZCR_DEV_TOKEN}}
          container_registry_address: ${{secrets.AZCR_DEV_USER}}
```
        
## create_package

### Description

Creates a development version of a python package according to [PEP-440](https://peps.python.org/pep-0440/) from
an open pull request and uploads it to a provided python index.

Version format is `{Major}.{Minor}.{Patch}a{PR_NUMBER}dev{COMMENT_NUMBER}` where PR_NUMBER is number of pull request and 
COMMENT_NUMBER is number of comment which triggered a build.

**NOTES**:
1) To use this action, your repository should contain
[version tags](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).
This action relies on git tags to be present in order to generate an artifact tag.
2) This action should be placed in separate job with issue_comment pull request trigger. (see Usage below)
3) This action requires to [poetry](https://python-poetry.org/docs/master/) ~1.2 being installed in build environment (for example, by [install_poetry action](#install_poetry))

### Inputs
| Name                | Description                                                                 | Optional | Default value |
|---------------------|:----------------------------------------------------------------------------|----------|---------------|
| pypi_repo_url       | Package index URL                                                           | False    |               |
| pypi_token_username | Package index authentication username                                       | False    |               |
| pypi_token          | Package index authentication token or password.                             | False    |               |
| package_name        | Name of package to create. This should match name of root project directory | False    |               |               

### Outputs
No outputs defined

### Usage

Add to `.github/workflows` a workflow file defined as follwoing and replace value in property `package_name` with name
of root folder of your package:

```yaml
on: issue_comment

jobs:
  pr_commented:
    name: Build package on PR comment
    runs-on: ubuntu-latest
    if: ${{ github.event.issue.pull_request && github.event.comment.body == 'create_package' && github.event.issue.state == 'open' }}
    steps:
      - uses: actions/checkout@v2
        with:
          ref: refs/pull/${{github.event.issue.number}}/merge
          fetch-depth: 0
      - name: Install Poetry and dependencies
        uses: SneaksAndData/github-actions/install_poetry@v0.0.9
        with:
          pypi_repo_url: ${{ secrets.AZOPS_PYPI_REPO_URL }}
          pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
          pypi_token: ${{ secrets.AZOPS_PAT }}
      - name: Create package
        uses: SneaksAndData/github-actions/create_package@v0.0.9
        with:
          pypi_repo_url: ${{ secrets.AZOPS_PYPI_UPLOAD }}
          pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
          pypi_token: ${{ secrets.AZOPS_PAT }}
          package_name: python_project
```
