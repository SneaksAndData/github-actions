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

curl -sSL https://install.python-poetry.org | python3 - --preview
export PATH=/github/home/.local/bin:$PATH
poetry config repositories.azops "$REPO_URL"
poetry install
REQUIREMENTS_ABSOLUTE_PATH="$PWD/$REQUIREMENTS_PATH"
if [[ "$(echo "$EXPORT_REQUIREMENTS" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
  poetry export -f requirements.txt --output "$REQUIREMENTS_ABSOLUTE_PATH" --without-hashes --with-credentials
  echo "requirements exported to $REQUIREMENTS_ABSOLUTE_PATH"
fi

