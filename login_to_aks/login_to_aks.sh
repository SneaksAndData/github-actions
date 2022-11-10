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

echo 'Getting cluster credentials'
az login --service-principal \
  --username "$CLUSTER_SP_CLIENT_ID" \
  --password "$CLUSTER_SP_CLIENT_PASSWORD" \
  --tenant "$TENANT_ID"

az account set --subscription "$SUBSCRIPTION_ID"
az aks get-credentials --name "$AKS_NAME" --resource-group "$AKS_NAME"
