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

OUTPUT=$(cat "$VARIABLES_SUB_PATH/${PROJECT_NAME//-/_}.json")

# Multiline string handling, per Github Community recommendation:
# https://github.community/t/set-output-truncates-multiline-strings/16852/3
# We remove here line endings instead of replacing because we do not need
# pretty JSON in action outputs
OUTPUT="${OUTPUT//$'\n'/''}"
OUTPUT="${OUTPUT//$'\r'/''}"

echo "airflow_variable=$OUTPUT" >> "$GITHUB_OUTPUT"
