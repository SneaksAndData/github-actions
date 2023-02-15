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

  echo "Waiting for the workflow $WORKFLOW_NAME with run title $RUN_TITLE in the repository $REPO_NAME to be completed"
  sleep 5
  is_completed=$(gh workflow view "$WORKFLOW_NAME" --repo "$REPO_NAME" | grep "$RUN_TITLE" | grep "$BRANCH_NAME" | grep completed || true)

done