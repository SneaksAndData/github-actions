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

distribution_pvc=$(kubectl get pv --namespace "$NAMESPACE" | grep "$CLAIM_NAME" | cut -d' ' -f1)
volume_handle=$(kubectl get pv --namespace "$NAMESPACE" "$distribution_pvc" -o json | jq .spec.csi.volumeHandle | cut -d# -f2)
account_secret=azure-storage-account-$volume_handle-secret
account_name=$(kubectl get secret --namespace "$NAMESPACE" "$account_secret" -o json | jq .data.azurestorageaccountname | cut -d'"' -f2 | base64 -d)
account_key=$(kubectl get secret --namespace "$NAMESPACE" "$account_secret" -o json | jq .data.azurestorageaccountkey | cut -d'"' -f2 | base64 -d)


destination="https://$account_name.file.core.windows.net/$distribution_pvc/$DIRECTORY_NAME"
echo "Generating SAS for upload to $destination"
end=$(date -d '+5 minutes' '+%Y-%m-%dT%H:%MZ')
sas=$(
  az storage account generate-sas \
      --account-key "$account_key" \
      --account-name "$account_name" \
      --expiry "$end" \
      --https-only \
      --permissions acdlpruw \
      --resource-types sco \
      --services f | cut -d'"' -f2
)

authorized_destination="$destination?$sas"
echo "::add-mask::$sas"
echo "::add-mask::$authorized_destination"
echo "authorized_destination=$authorized_destination" >> "$GITHUB_OUTPUT"
