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

echo "Preparing to deploy $PROJECT_NAME $PROJECT_VERSION"
set -Eeuo pipefail

if [ -z "$PROJECT_DIRECTORY" ]; then
      PROJECT_DIRECTORY="${PROJECT_NAME/-/_}"
fi;

env_path=$(poetry env info --directory "$PWD/$PROJECT_NAME" | grep Path | head -n 1 | cut -d':' -f2 | xargs)

SOURCE_DIRECTORY="./$DEPLOYMENT_ROOT/$PROJECT_NAME/$PROJECT_VERSION/"

mkdir -p "$SOURCE_DIRECTORY/$PROJECT_DIRECTORY"
mv -v "$env_path"/lib/python"$PYTHON_VERSION"/site-packages/* "$SOURCE_DIRECTORY"
mv -v ./"$PROJECT_DIRECTORY"/* "$SOURCE_DIRECTORY/$PROJECT_DIRECTORY"

./azcopy copy "./$SOURCE_DIRECTORY/*" "$DESTINATION" --recursive --overwrite true
