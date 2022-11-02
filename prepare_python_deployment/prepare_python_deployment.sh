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
env_path=$(poetry env info | grep Path | head -n 1 | cut -d':' -f2 | xargs)

mkdir -p "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$PROJECT_VERSION/$PROJECT_NAME"
mv -v "$env_path"/lib/python3.9/site-packages/* "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$PROJECT_VERSION/"
mv -v ./"$PROJECT_NAME"/* "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$PROJECT_VERSION/$PROJECT_NAME/"
