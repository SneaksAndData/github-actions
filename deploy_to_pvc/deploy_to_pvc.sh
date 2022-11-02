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

set -e

export PATH="/github/home/.local/bin:$PATH"

current_version=$(git describe --tags --abbrev=7)
echo "Preparing upload for $PROJECT_NAME $current_version"

env_path=$(poetry env info | grep Path | head -n 1 | awk '{print $2}')
         
mkdir -p "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$current_version/$PROJECT_NAME"

mv -v "$env_path"/lib/python3.9/site-packages/* "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$current_version/"
mv -v ./"$PROJECT_NAME"/* "./$DEPLOYMENT_ROOT/$PROJECT_NAME/$current_version/$PROJECT_NAME/"

echo 'Getting cluster credentials'
az login --service-principal \
  --username "$CLUSTER_SP_CLIENT_ID" \
  --password "$CLUSTER_SP_CLIENT_PASSWORD" \
  --tenant "$TENANT_ID"

az account set --subscription "$SUBSCRIPTION_ID"
az aks get-credentials --name "$AKS_NAME" --resource-group "$AKS_NAME"

distribution_pvc=$(kubectl get pv --namespace "$NAMESPACE" | grep "$CLAIM_NAME" | cut -d' ' -f1)
volume_handle=$(kubectl get pv --namespace "$NAMESPACE" "$distribution_pvc" -o json | jq .spec.csi.volumeHandle | cut -d# -f2)
account_secret=azure-storage-account-$volume_handle-secret
account_name=$(kubectl get secret --namespace "$NAMESPACE" "$account_secret" -o json | jq .data.azurestorageaccountname | cut -d'"' -f2 | base64 -d)
account_key=$(kubectl get secret --namespace "$NAMESPACE" "$account_secret" -o json | jq .data.azurestorageaccountkey | cut -d'"' -f2 | base64 -d)


echo Generating SAS for upload
end=$(date -d '+5 minutes' '+%Y-%m-%dT%H:%MZ')
sas=$(az storage account generate-sas --account-key "$account_key" --account-name "$account_name" --expiry "$end" --https-only --permissions acdlpruw --resource-types sco --services f | cut -d'"' -f2)

destination="https://$account_name.file.core.windows.net/$distribution_pvc/$PROJECT_NAME/$current_version"
authorized_destination="$destination?$sas"

echo Getting AzCopy
curl -s -L https://aka.ms/downloadazcopy-v10-linux --output azcopy.tar.gz \
  && tar -xf azcopy.tar.gz -C . --strip-components=1

echo "Deploying $PROJECT_NAME $current_version to $destination"
./azcopy copy ./"$DEPLOYMENT_ROOT/$PROJECT_NAME/$current_version/*" "$authorized_destination" \
  --recursive \
  --overwrite true \
  --put-md5