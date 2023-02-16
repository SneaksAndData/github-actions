#!/usr/bin/env bash

#  Copyright (c) 2022 Ecco Sneaks & Data
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

set -Eeuo pipefail

new_release=$(gh release list --repo "$REPO_NAME" --limit 1 | tail -n 1 | cut -d$'\t' -f1)

echo "Activating a workflow with arguments: ..."

gh workflow run "$WORKFLOW_NAME" --repo "$REPO_NAME" --field environment="$DEPLOY_ENVIRONMENT" --ref "refs/tags/$new_release"
