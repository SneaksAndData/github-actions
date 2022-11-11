# github-actions

Repository for common actions used in Sneaks And Data CI/CD processes

Available actions are:
1. [semver_release](#semver_release)
2. [install_poetry](#install_poetry)
3. [build_helm_chart](#build_helm_chart)
4. [create_package](#create_package)
5. [generate_version](#generate_version)
6. [install_azcopy](#install_azcopy)
7. [login_to_aks](#login_to_aks)
8. [deploy_poetry_project_to_azfs](#deploy_poetry_project_to_azfs)
9. [deploy_dbt_project_to_azfs](#deploy_dbt_project_to_azfs)
10. [deploy_data_schemas_to_azfs](#deploy_data_schemas_to_azfs)
11. [run_azcopy](#run_azcopy)
12. [get_azure_share_sas](#get_azure_share_sas)

## semver_release

### Description
Creates a new GitHub release based on git tags and [semantic versioning](https://semver.org/)

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
        uses: SneaksAndData/github-actions/semver_release@v0.0.10
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
| Name             | Description                                                  |
|------------------|:-------------------------------------------------------------|
| custom_repo_name | Name of configured custom repository for poetry push command |

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
        uses: SneaksAndData/github-actions/install_poetry@v0.0.10
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
        uses: SneaksAndData/github-actions/build_helm_chart@v0.0.10
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
        uses: SneaksAndData/github-actions/install_poetry@v0.0.10
        with:
          pypi_repo_url: ${{ secrets.AZOPS_PYPI_REPO_URL }}
          pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
          pypi_token: ${{ secrets.AZOPS_PAT }}
          skip_dependencies: true
      - name: Create package
        uses: SneaksAndData/github-actions/create_package@v0.0.10
        with:
          pypi_repo_url: ${{ secrets.AZOPS_PYPI_UPLOAD }}
          pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
          pypi_token: ${{ secrets.AZOPS_PAT }}
          package_name: python_project
```

## generate_version

Generates project version based on current git commit and git tags.

**NOTES**:
1) To use this action, your repository should contain
[version tags](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases).
This action relies on git tags to be present in order to generate a version.
2) Generated version is will not be compatible with [PEP-440](https://peps.python.org/pep-0440/), so this versions 
should not be used with python packages. Although, this action can be used with
[source code deployments](#deploy_poetry_project_to_azfs) of python applications.


### Inputs
No inputs defined
### Outputs
| Name                | Description                                                                 |
|---------------------|:----------------------------------------------------------------------------|
| version             | generated version string                                                    |

### Usage
```yaml
name: Print version

on:
  workflow_dispatch
jobs:
  print_version:
    name: print version
    runs-on: ubuntu-latest
    if: ${{ github.ref != 'refs/heads/main' }}
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Get project version
        uses: SneaksAndData/github-actions/generate_version@0.0.10
        id: version
      - run: echo "$version"
        env:
          version: ${{steps.version.outputs.version}}
```

## install_azcopy

Installs azcopy v10 in current build directory.

### Inputs
No inputs defined

### Outputs
No outputs defined

### Usage
```yaml
name: Install azcopy

on:
  workflow_dispatch:
    
jobs:
  install_azcopy:
    name: install azcopy
    runs-on: ubuntu-latest
    steps:
      - name: Install azcopy v10
        uses: SneaksAndData/github-actions/install_azcopy@0.0.10
```

## login_to_aks
Get AKS login credentials for kubectl. Service principal used must have a permission to list cluster credentials.

### Inputs
| Name                       | Description                              | Optional | Default value |
|----------------------------|:-----------------------------------------|----------|---------------|
| cluster_sp_client_id       | Cluster service principal application id | False    |               |
| cluster_sp_client_password | Cluster service principal password       | False    |               |
| tenant_id                  | Azure tenant ID                          | False    |               |
| subscription_id            | Azure subscription ID                    | False    |               |               
| cluster_name               | Name of the cluster                      | False    |               |

### Outputs
No outputs defined

### Usage
```yaml
name: Login to AKS

on:
jobs:
  login_to_aks:
    name: Login to AKS
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Get cluster credentials
        uses: SneaksAndData/github-actions/login_to_aks@0.0.10
        with:
          cluster_sp_client_id: $AZURE_CLIENT_ID
          cluster_sp_client_password: $AZURE_CLIENT_SECRET
          tenant_id: $AZURE_TENANT_ID
          subscription_id: $AZURE_SUBSCRIPTION_ID
          cluster_name: $AZURE_AKS_NAME
```

# deploy_poetry_project_to_azfs
Copy python site-packages of current virtual environment and installs application into it. 

### Inputs
| Name              | Description                                                      | Optional | Default value |
|-------------------|:-----------------------------------------------------------------|----------|---------------|
| output_directory  | Local directory on build agent to store files                    | False    |               |
| project_version   | Version of the project                                           | False    |               |
| project_name      | Name of the project                                              | False    |               |
| project_directory | Directory name inside the project (if differs from project name) | True     | ""            |
| destination       | Directory or SAS for upload                                      | False    |               |
| python_version    | Project python version                                           | True     | 3.9           |
| deployment_root   | Root directory in the file share                                 | False    |               |

**NOTES**:
1) To use this action, your project should use poetry for virtual environment management. Ensure that you installed
the latest version of poetry and project dependencies (for instance, by [install_poetry](#install_poetry) action).

### Outputs
No outputs defined

### Usage
```yaml
name: Prepare python deployment

on:
  workflow_dispatch:
    
jobs:
  prepare_deployment:
    name: Prepare python code for deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Get project version
        uses: SneaksAndData/github-actions/generate_version@0.0.10
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@0.0.10
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare site-packages for deployment
        uses: SneaksAndData/github-actions/deploy_poetry_project_to_azfs@0.0.10
        with:
          deployment_root: /python
          project_version: ${{ steps.version.outputs.version }}
          destination: ${{ steps.sas.outputs.authorized_destination }}
          project_name: python_project
```

# deploy_dbt_project_to_azfs
Prepare DBT models for deployment to an Azure file share.

### Inputs
| Name             | Description                                   | Optional | Default value |
|------------------|:----------------------------------------------|----------|---------------|
| output_directory | Local directory on build agent to store files | False    |               |
| project_version  | Version of the project                        | False    |               |
| project_name     | Name of the project                           | False    |               |
| destination      | Directory or SAS for upload                   | False    |               |
| deployment_root  | Root directory in the file share              | False    |               |

### Outputs
No outputs defined

### Usage
```yaml
name: Prepare deployment

on:
  workflow_dispatch:
    
jobs:
  prepare_deployment:
    name: Prepare dbt output for deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Get project version
        uses: SneaksAndData/github-actions/generate_version@0.0.10
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@0.0.10
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare dbt for deployment
        uses: SneaksAndData/github-actions/deploy_dbt_project_to_azfs@0.0.10
        with:
          deployment_root: /dbt
          project_version: ${{ steps.version.outputs.version }}
          destination: ${{ steps.sas.outputs.authorized_destination }}
          project_name: dbt_project
```

# deploy_data_schemas_to_azfs
Prepare DBT schemas for deployment to an Azure file share.

### Inputs
| Name             | Description                                   | Optional | Default value |
|------------------|:----------------------------------------------|----------|---------------|
| output_directory | Local directory on build agent to store files | False    |               |
| project_version  | Version of the project                        | False    |               |
| project_name     | Name of the project                           | False    |               |
| destination      | Directory or SAS for upload                   | False    |               |
| deployment_root  | Root directory in the file share              | False    |               |

### Outputs
No outputs defined

### Usage
```yaml
name: Prepare deployment

on:
  workflow_dispatch:
jobs:
  validate_commit:
    name: Prepare schemas output for deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Get project version
        uses: SneaksAndData/github-actions/generate_version@0.0.10
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@0.0.10
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare dbt for deployment
        uses: SneaksAndData/github-actions/deploy_data_schemas_to_azfs@0.0.10
        with:
          deployment_root: /dbt
          project_version: ${{ steps.version.outputs.version }}
          destination: ${{ steps.sas.outputs.authorized_destination }}
          project_name: dbt_project
```

# run_azcopy
Copy data from local directory on build agent to Azure blob container or file share

### Inputs
| Name             | Description             | Optional | Default value |
|------------------|:------------------------|----------|---------------|
| source_directory | Local directory to copy | False    |               |
| target           | Target Azure file share | False    |               |

### Outputs
No outputs defined

### Usage
```yaml
name: Copy files

on:
  workflow_dispatch:
    
jobs:
  copy_files:
    name: Copy files
    steps:
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@0.0.10
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Copy data
        uses: SneaksAndData/github-actions/run_azcopy@0.0.10
        with:
          source_directory: source/directory/on/build/agent
          target: ${{ steps.sas.outputs.authorized_destination }}
```
## get_azure_share_sas

### Description
Generates new temporary
[Shared Access Signature](https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview)
for a file share, attached to a storage account.

**NOTES**:
1) The generated SAS is valid for 5 minutes.

### Inputs
| Name           | Description                              | Optional |
|----------------|:-----------------------------------------|----------|
| directory_name | Path within file share                   | False    |
| account_key    | Name of the storage account of the share | False    |
| account_name   | Key of the storage account of the share  | False    |

### Outputs
| Name                   | Description                                                 |
|------------------------|-------------------------------------------------------------|
| authorized_destination | URL of the file share with attached shared access signature |

### Usage
```yaml
name: Release a new version

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@0.0.10
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Copy data
        uses: SneaksAndData/github-actions/run_azcopy@0.0.10
        with:
          source_directory: source/directory/on/build/agent
          target: ${{ steps.sas.outputs.authorized_destination }}
```
