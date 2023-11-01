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


if [[ "$(echo "$DIRECTORY_TYPE" | tr '[:upper:]' '[:lower:]')" == 'fileshare' ]]; then
  destination="https://$ACCOUNT_NAME.file.core.windows.net/$DIRECTORY_NAME"
  services="f"
elif [[ "$(echo "$DIRECTORY_TYPE" | tr '[:upper:]' '[:lower:]')" == 'blob' ]]; then
  destination="https://$ACCOUNT_NAME.blob.core.windows.net/$DIRECTORY_NAME"
  services="b"
else
  echo "Directory type \"$DIRECTORY_TYPE\" not supported"
  exit 1;
fi;


echo "Expiration date \"$EXPIRATION_DATE\""
if [[ "$OSTYPE" =~ ^darwin ]]; then
  end=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$EXPIRATION_DATE" "+%Y-%m-%d %H:%M:%S")
else
  end=$(date -d "$EXPIRATION_DATE" '+%Y-%m-%dT%H:%MZ')
fi;
echo "Generating SAS for $destination with expiration date $end"
sas=$(
  az storage account generate-sas \
      --account-key "$ACCOUNT_KEY" \
      --account-name "$ACCOUNT_NAME" \
      --expiry "$end" \
      --https-only \
      --permissions acdlpruw \
      --resource-types sco \
      --services "$services" | cut -d'"' -f2
)

authorized_destination="$destination?$sas"
echo "::add-mask::$sas"
echo "::add-mask::$authorized_destination"
echo "authorized_destination=$authorized_destination" >> "$GITHUB_OUTPUT"
