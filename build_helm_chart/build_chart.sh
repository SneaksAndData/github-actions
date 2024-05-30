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


if [[ -n "$APP_VERSION" ]]; then
  appVersion=$(git describe --tags --abbrev=7)
else
  appVersion="$APP_VERSION"
fi;

if [[ -n "$CHART_VERSION" ]]; then
  chartVersion=$(git describe --tags --abbrev=7)
else
  chartVersion="$CHART_VERSION"
fi;


sed -i "s/appVersion: 0.0.0/appVersion: \"${appVersion:1}\"/" Chart.yaml
sed -i "s/^version: .*/version: \"$chartVersion\"/" Chart.yaml

cat Chart.yaml

helm package .
echo "$REPO_TOKEN" | helm registry login "$REPO_ADDRESS" --username "$REPO_LOGIN" --password-stdin
echo "oci://$REPO_ADDRESS/helm/"
helm push "$APPLICATION-$appVersion.tgz" "oci://$REPO_ADDRESS/helm/"
