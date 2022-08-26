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

if [[ $VERSION != "latest" ]]; then
  export POETRY_VERSION=$VERSION
fi

if [[ $INSTALL_PREVIEW == "true" ]]; then
  export POETRY_PREVIEW=1
fi

curl -sSL https://install.python-poetry.org | python3 -
export PATH=/github/home/.local/bin:$PATH
poetry config repositories.custom_repo "$REPO_URL"

POETRY_ADDITIONAL_OPTIONS=()
if [[ -n "$EXTRAS" ]]; then
  if [[ "$EXTRAS" == "all" ]]; then
    echo "Going to install all extras with the project"
    POETRY_ADDITIONAL_OPTIONS+=("--all-extras")
  else
    echo "Install with extras: $EXTRAS"
    POETRY_ADDITIONAL_OPTIONS+=("--extras" "$EXTRAS")
  fi;
fi;

if [[ "$(echo "$INSTALL_NO_ROOT" | tr '[:upper:]' '[:lower:]')" == 'true' ]]; then
  echo "Install only dependencies"
  POETRY_ADDITIONAL_OPTIONS+=("--no-root")
fi;

poetry install "${POETRY_ADDITIONAL_OPTIONS[@]}"

EXPORT_ADDITIONAL_OPTIONS=""
if [[ "$(echo "$EXPORT_CREDENTIALS" | tr '[:upper:]' '[:lower:]')" == "true" ]];
then
  EXPORT_ADDITIONAL_OPTIONS="$EXPORT_ADDITIONAL_OPTIONS --with-credentials"
fi;

if [[ "$(echo "$EXPORT_REQUIREMENTS" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
  REQUIREMENTS_ABSOLUTE_PATH="$PWD/$REQUIREMENTS_PATH"
  # shellcheck disable=SC2086
  poetry export -f requirements.txt --output "$REQUIREMENTS_ABSOLUTE_PATH" --without-hashes $EXPORT_ADDITIONAL_OPTIONS
  echo "requirements exported to $REQUIREMENTS_ABSOLUTE_PATH"
fi

