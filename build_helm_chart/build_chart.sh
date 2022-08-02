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

appVersion=$(git describe --tags --abbrev=7)
sed -i "s/appVersion: 0.0.0/appVersion: \"${appVersion:1}\"/" Chart.yaml
sed -i "s/^version: 0.0.0/version: \"${appVersion:1}\"/" Chart.yaml

helm package .
echo "$REPO_TOKEN" | helm registry login "$REPO_ADDRESS" --username "$REPO_LOGIN" --password-stdin
echo "oci://$REPO_ADDRESS/helm/"
helm push "${APPLICATION:1}-$appVersion.tgz" "oci://$REPO_ADDRESS/helm/"
