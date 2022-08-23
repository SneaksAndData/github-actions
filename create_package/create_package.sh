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
version=$(git describe --tags --abbrev=0)a$PULL_REQUEST_NUMBER.dev$COMMENTS_COUNT
sed -i "s/version = \"0.0.0\"/version = \"$version\"/" pyproject.toml
echo "__version__ = '$version'" > "./$PACKAGE_NAME/_version.py"
echo "REPOSITORY TO PUBLISH IS $REPO_URL"
poetry config repositories.custom_repo "$REPO_URL"
poetry build && poetry publish -r custom_repo
echo "::set-output name=version::$version"
