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

echo "Copy from $SOURCE to $TARGET"
AZCOPY_OPTIONS=("--recursive")
if [[ "$(echo "$MODE" | tr '[:upper:]' '[:lower:]')" == 'copy' ]]; then
  AZCOPY_OPTIONS+=("--overwrite" "true")
fi;
if [[ "$(echo "$PUT_MD5" | tr '[:upper:]' '[:lower:]')" == 'true' ]]; then
  AZCOPY_OPTIONS+=("--put-md5")
fi;
if [[ "$(echo "$DELETE_DESTINATION" | tr '[:upper:]' '[:lower:]')" == 'true' ]]; then
  AZCOPY_OPTIONS+=("--delete-destination" "true")
fi;
./azcopy "$MODE" "$SOURCE" "$TARGET" "${AZCOPY_OPTIONS[@]}"
