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

providedMajor=$MAJOR_V
providedMinor=$MINOR_V
currentVersion=$(git describe --tags --abbrev=7)
currentMinor=$(echo "$currentVersion" | cut --delimiter=. --fields=2)
currentMajor=$(echo "$currentVersion" | cut --delimiter=. --fields=1 | cut --delimiter=v --fields=2)

if [[ $currentMajor -eq $providedMajor ]] && [[ $providedMinor -eq $currentMinor ]];
then
  currentRevision=$(echo "$currentVersion" | rev | cut --delimiter=. --fields=1 | rev | cut --delimiter=- --fields=1)
  nextRevision=$(( currentRevision + 1 ))
else
  nextRevision='0'
fi
nextVersion="v$providedMajor.$providedMinor.$nextRevision"
gh release create "$nextVersion" --generate-notes --target "$TARGET_BRANCH_NAME"
echo "version=$nextVersion" >> "$GITHUB_OUTPUT"
