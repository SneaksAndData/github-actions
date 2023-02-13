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

is_completed=''

while [ "$is_completed" == '' ]
do

  echo "Waiting for the deployment package to be generated"
  sleep 5
  is_completed=$(gh workflow view "$GENERATE_PACKAGE_WORKFLOW_NAME" --repo "$TARGET_REPO_NAME" | grep "Updating $PROJECT_NAME to $PROJECT_VERSION" | grep main | grep completed || true)

done

new_release=$(gh release list --repo "$TARGET_REPO_NAME" --limit 1 | tail -n 1 | cut -d$'\t' -f1)

echo "Submitting a deployment for a new configuration release $new_release"

gh workflow run "$DEPLOY_WORKFLOW_NAME" --repo "$TARGET_REPO_NAME" --field environment="$DEPLOY_ENVIRONMENT" --ref "refs/tags/$new_release"

