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
13. [setup_gh_app](#setup_gh_app)
14. [update_airflow_variables](#update_airflow_variables)
15. [contribute_changes](#contribute_changes)
16. [activate_workflow](#activate_workflow)
16. [setup_aws_ca](#setup_aws_ca)

## semver_release

### Description
Creates a new GitHub release based on git tags and [semantic versioning](https://semver.org/)

**NOTE**: This action uses [`github.ref`](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context)
variable for target branch name (see: https://cli.github.com/manual/gh_release_create).

### Inputs
| Name        | Description                              | Optional |
|-------------|:-----------------------------------------|----------|
| major_v     | major version of current release         | False    |
| minor_v     | minor version of current release         | False    |
| assets_path | assets to upload for the current release | True     |

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
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Create Release
        uses: SneaksAndData/github-actions/semver_release@v0.1.11
        with:
          major_v: 0
          minor_v: 0
          assets_path: ./dist
```

## install_poetry

### Description
Installs poetry to build environment and restores dependencies using custom and private pypi indices.
Optionally can export dependency tree to requirements.txt file.



### Inputs
| Name                      | Description                                                                                                                    | Optional  | Default value               |
|---------------------------|:-------------------------------------------------------------------------------------------------------------------------------|-----------|-----------------------------|
| pypi_repo_url             | URL of python package index (for custom packages)                                                                              | True      | ""                          |
| pypi_token_username       | Package index authentication username.                                                                                         | True      | ""                          |
| pypi_token                | Package index authentication token or password.                                                                                | True      | ""                          |
| export_requirements       | Set to `true` if need to generate requirements.txt. **Optional** defaults to **false**.                                        | True      | false                       |
| export_credentials        | If export_requirements is set to true, it exports requirements.txt with --with-credentials flag. Otherwise, does nothing.      | True      | true                        |
| requirements_path         | Path to requirements.txt to be generated (relative to sources root).                                                           | True      | .container/requirements.txt | 
| install_preview           | Install preview version of Poetry.                                                                                             | True      | false                       |
| version                   | Version to install. If value is 'latest', script will install the latest available version of Poetry.                          | True      | latest                      |
| install_extras            | List of optional dependencies to install, separated by space. If value is 'all', all extras will be installed                  | True      |                             |
| install_only_dependencies | If set to true, installs only dependencies for project, adds the parameter `--no-root` to `poetry install` command.            | True      | false                       |
| skip_dependencies         | If set to true, installs only poetry without installing dependencies.                                                          | True      | false                       |
| export_dev_requirements   | If export_requirements is set to true, it exports dev requirements.txt with --without-dev flag. Otherwise, does nothing.       | True      | true                        |
| no_binary_dependencies    | Dependencies that must be built from source - equivalent to installer.no-binary setting in Poetry. Example: "bottleneck,numpy" | True      | ""                          |

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
        uses: SneaksAndData/github-actions/install_poetry@v0.0.17
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
| Name                       | Description                                                                        | Optional | Default value |
|----------------------------|:-----------------------------------------------------------------------------------|----------|---------------|
| container_registry_address | Container registry address                                                         | False    |               |
| application:               | Application name                                                                   | False    |               |
| container_registry_user    | Container registry username                                                        | False    |               |
| container_registry_token   | Container registry access token                                                    | False    |               |
| helm_version               | Version of helm to install                                                         | True     | 3.9.2         |
| helm_directory             | Location of helm chart related to project root                                     | True     | .helm         |
| app_version                | Application version to use for the chart. If omitted, the latest tag will be used. | True     |               |
| chart_version              | Chart version to use for the chart. If omitted, the latest tag will be used.       | True     |               |

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
        uses: SneaksAndData/github-actions/build_helm_chart@v0.0.17
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
4) ⚠️ If the input `repo_url` is not provided, this action will push the package to a **public repository** (https://pypi.org).
In this case, the input `public_package_index_token` should be provided.

### Inputs
| Name                       | Description                                                                          | Optional | Default value |
|----------------------------|:-------------------------------------------------------------------------------------|----------|:--------------|
| repo_url                   | Package index URL                                                                    | True     | Empty         |
| repo_token_username        | Package index authentication username                                                | True     | Empty         |
| repo_token                 | Package index authentication token or password.                                      | True     | Empty         |
| package_name               | Name of package to create. This should match name of root project directory          | False    |               |               
| version                    | Version of package. If not provided, a new **development** version will be generated |          | Empty         |               
| public_package_index_token | Access token for publishing to a public repository (https://pypi.org)                | True     | Empty         |

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
        uses: SneaksAndData/github-actions/install_poetry@v0.0.17
        with:
          pypi_repo_url: ${{ secrets.AZOPS_PYPI_REPO_URL }}
          pypi_token_username: ${{ secrets.AZOPS_PAT_USER }}
          pypi_token: ${{ secrets.AZOPS_PAT }}
          skip_dependencies: true
      - name: Create package
        uses: SneaksAndData/github-actions/create_package@v0.0.17
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
        uses: SneaksAndData/github-actions/generate_version@v0.0.17
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
        uses: SneaksAndData/github-actions/install_azcopy@v0.0.17
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
        uses: SneaksAndData/github-actions/login_to_aks@v0.0.17
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
        uses: SneaksAndData/github-actions/generate_version@v0.0.17
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@v0.0.17
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare site-packages for deployment
        uses: SneaksAndData/github-actions/deploy_poetry_project_to_azfs@v0.0.17
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
        uses: SneaksAndData/github-actions/generate_version@v0.0.17
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@v0.0.17
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare dbt for deployment
        uses: SneaksAndData/github-actions/deploy_dbt_project_to_azfs@v0.0.17
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
        uses: SneaksAndData/github-actions/generate_version@v0.0.17
        id: version
      - name: Generate SAS for upload
        uses: SneaksAndData/github-actions/get_azure_share_sas@v0.0.17
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Prepare dbt for deployment
        uses: SneaksAndData/github-actions/deploy_data_schemas_to_azfs@v0.0.17
        with:
          deployment_root: /dbt
          project_version: ${{ steps.version.outputs.version }}
          destination: ${{ steps.sas.outputs.authorized_destination }}
          project_name: dbt_project
```

# run_azcopy
Invoke [azcopy copy](https://learn.microsoft.com/en-us/azure/storage/common/storage-ref-azcopy-copy?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json)
command in pipeline.

### Inputs
| Name               | Description                                    | Optional | Default value |
|--------------------|:-----------------------------------------------|----------|---------------|
| source             | Source directory or SAS url to copy            | False    |               |
| target             | Target directory or SAS url                    | False    |               |
| mode               | azcopy action mode (copy or sync)              | True     | copy          |
| put_md5            | If `true` sets `--put-md5` parameter to azcopy | True     | True          |
| delete_destination | azcopy --delete-destination flag               | True     | False         |

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
        uses: SneaksAndData/github-actions/get_azure_share_sas@v0.0.17
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Copy data
        uses: SneaksAndData/github-actions/run_azcopy@v0.0.17
        with:
          source: source/directory/on/build/agent
          target: ${{ steps.sas.outputs.authorized_destination }}
```
## get_azure_share_sas

### Description
Generates new temporary
[Shared Access Signature](https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview)
for a file share, attached to a storage account.

### Inputs
| Name            | Description                                                      | Optional | Default Value |
|-----------------|:-----------------------------------------------------------------|----------|---------------|
| directory_name  | Path within file share                                           | False    |               |
| account_key     | Name of the storage account of the share                         | False    |               |
| account_name    | Key of the storage account of the share                          | False    |               |
| expiration_date | Expiration date in format that can be used by the `date` command | True     | +10 minutes   |
| directory_type  | Type of directory (blob or fileshare)                            | True     | fileshare     |


**NOTES**:
1) For the expiration date format see [man 1 date](https://man7.org/linux/man-pages/man1/date.1.html)

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
        uses: SneaksAndData/github-actions/get_azure_share_sas@v0.0.17
        with:
          directory_name: share-name/path/within/share
          account_key: ${{ secrets.ACCOUNT_KEY }}
          account_name: ${{ secrets.ACCOUNT_NAME }}
        id: sas
      - name: Copy data
        uses: SneaksAndData/github-actions/run_azcopy@v0.0.17
        with:
          source_directory: source/directory/on/build/agent
          target: ${{ steps.sas.outputs.authorized_destination }}
```

## setup_gh_app

### Description

Configure git client in the workflow job to authenticate to GitHub using a GitHub App instead of builtin repo-scoped GITHUB_TOKEN.
next workflow steps.

### Inputs
| Name                | Description                 | Optional | Default Value |
|---------------------|:----------------------------|----------|---------------|
| app_private_key     | Private key of application  | False    |               |
| app_installation_id | Application installation Id | False    |               |
| git_user_email      | User email for git client   | False    |               |
| git_user_name       | User name for git client    | False    |               |

### Outputs
| Name         | Description                          |
|--------------|--------------------------------------|
| access_token | Access token generated by GitHub API |

### Usage
```yaml
name: Checkout repo using github app

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Reconfigure Git to use App
        id: setup_gh_app
        uses: SneaksAndData/github-actions/setup_gh_app@v0.0.17
        with:
          app_private_key: ${{ secrets.APP_PRIVATE_KEY }}
          app_installation_id: 1234567
          app_id: 89123
          git_user_name: "Github App"
          git_user_email: "user@example.com"

      - name: Checkout Airflow Variables
        uses: actions/checkout@v3
        with:
          repository: SneaksAndData/airflow-variables
          token: ${{ steps.setup_gh_app.outputs.access_token }}
          path: airflow-variables
          fetch-depth: 0
```

## update_airflow_variables

Update airflow configuration of a specified dbt project to the current version (git tag) and provided execution graph

### Inputs
| Name              | Description                         | Optional | Default Value |
|-------------------|:------------------------------------|----------|---------------|
| project_name      | Name of the project                 | False    |               |
| project_version   | Version of the project              | False    |               |
| project_graph     | Graph generated by metadata-manager | False    |               |
| working_directory | User name for git client            | False    |               |
| airflow_variable  | JSON-encoded airflow variable       | False    |               |

### Outputs
| Name             | Description                    | Optional | Default Value |
|------------------|:-------------------------------|----------|---------------|
| airflow_variable | JSON-encoded airflow variable  | False    |               |

### Usage
```yaml
name: Update airflow-variables

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Update Project Version
        uses: SneaksAndData/github-actions/update_airflow_variables@v0.0.17
        id: update_variables
        with:
          project_name: dbt-project
          working_directory: github-repository
          project_version: 0.0.1
          project_graph: "{}"
```

## contribute_changes

Create pull request in repository

### Inputs
| Name              | Description                                                                                 | Optional | Default Value |
|-------------------|:--------------------------------------------------------------------------------------------|----------|---------------|
| project_name      | Name of the project                                                                         | False    |               |
| project_version   | Version of the project                                                                      | False    |               |
| working_directory | Directory with airflow-variables GitHub repo                                                | False    |               |
| access_token      | An access token with push and create pull request permissions                               | False    |               |
| merge             | True if action should merge changes. Otherwise just create a branch and open a Pull Request | False    |               |

### Outputs
No outputs defined

### Usage
```yaml
name: Create pull request

on:
  workflow_dispatch:

jobs:
  contribute_changes:
    runs-on: ubuntu-latest
    steps:
      - name: Contribute Variable Changes
        uses: SneaksAndData/github-actions/contribute_changes@v0.0.17
        with:
          project_name: dbt-project
          working_directory: github-repository
          project_version: 0.0.1
          access_token: ${{ secrets.ACCESS_TOKEN }}
          merge: false
```

## activate_workflow

Triggers a specified GitHub Workflow file with parameters.

### Inputs
| Name               | Description                                                   | Optional | Default Value |
|--------------------|:--------------------------------------------------------------|----------|---------------|
| access_token       | An access token with push and create pull request permissions | False    |               |
| repo_name          | Repository to deploy                                          | False    |               |
| workflow_name      | Name of the workflow to activate                              | False    |               |
| deploy_environment | Environment name to deploy                                    | True     | production    |

### Outputs
No outputs defined

### Usage
```yaml
name: Deploy latest tag

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy variables
        uses: SneaksAndData/github-actions/activate_workflow@v0.0.17
        with:
          access_token: ${{ secrets.ACCESS_TOKEN }}
          repo_name: github-repo
          workflow_name: Deploy Variables to airflow
```

## wait_for_workflow

Create pull request in repository

### Inputs
| Name          | Description                                                   | Optional | Default Value |
|---------------|:--------------------------------------------------------------|----------|---------------|
| access_token  | An access token with push and create pull request permissions | False    |               |
| run_title     | Repository to deploy                                          | False    |               |
| repo_name     | Repository name                                               | False    |               |
| workflow_name | Name of the workflow                                          | False    |               |
| branch_name   | Name of the branch                                            | True     | main          |

### Outputs
No outputs defined

### Usage
```yaml
name: Deploy latest tag

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy variables
        uses: SneaksAndData/github-actions/activate_workflow@v0.0.17
        with:
          access_token: ${{ secrets.ACCESS_TOKEN }}
          run_title: "Updating Project github-repo to version 1.1.1"
          repo_name: github-repo
          workflow_name: Prepare Helm chart
```

## read_airflow_variable

Read airflow variable, escape newlines for using content in other steps.

### Inputs
| Name               | Description                                       | Optional | Default Value |
|--------------------|:--------------------------------------------------|----------|---------------|
| project_name       | Project name                                      | False    |               |
| root_directory     | Root directory with variables repository          | False    |               |
| variables_sub_path | Subdirectory with JSON-encoded file with variable | False    |               |

### Outputs
| Name             | Description                   |
|------------------|:------------------------------|
| airflow_variable | JSON-encoded airflow variable |

### Usage
```yaml
name: Deploy latest tag

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Read airflow variable
        uses: SneaksAndData/github-actions/read_airflow_variable@v0.0.17
        with:
          project_name: ${{ env.PROJECT_NAME }}
        id: read
```

## setup_aws_ca 

Setup AWS CodeArtifact credentials

### Inputs
| Name                | Description                                      | Optional | Default Value |
|---------------------|:-------------------------------------------------|----------|---------------|
| aws_access_key      | AWS access key                                   | False    |               |
| aws_access_key_id   | AWS access key ID                                | False    |               |
| mode                | Setup for read or publish                        | False    |               |
| aws_ca_domain       | AWS CodeArtifact domain                          | False    |               |
| aws_ca_domain_owner | AWS CodeArtifact domain owner name               | False    |               |
| aws_ca_repository   | AWS CodeArtifact repository name                 | False    |               |
| aws_region          | AWS region where the artifact storage is located | True     | eu-central-1  |

### Outputs
| Name  | Description                                           |
|-------|:------------------------------------------------------|
| url   | Python artifact storage URL (pip or twine-compatible) |
| user  | User Name                                             |
| token | Access token                                          |

### Usage
```yaml
name: Deploy latest tag

on:
  workflow_dispatch:

jobs:
  create_release:
    runs-on: ubuntu-latest
    steps:
      - name: Setup AWS CA
        uses: SneaksAndData/github-actions/setup_aws_ca@v0.1.1
        with:
          aws_access_key: ${{ env.AWS_ACCESS_KEY }}
          aws_access_key_id: ${{ env.AWS_ACCESS_KEY_ID }}
          mode: read
          aws_ca_domain: some-domain
          aws_ca_domain_owner: some-domain-owner
          aws_ca_repository: some-repository
        id: aws_ca
      - name: Install Poetry and dependencies
        uses: SneaksAndData/github-actions/install_poetry@v0.1.0
        with:
          pypi_repo_url: ${{ steps.aws_ca.outputs.url }}
          pypi_token_username: ${{ steps.aws_ca.outputs.user }}
          pypi_token: ${{ steps.aws_ca.outputs.token }}
```
