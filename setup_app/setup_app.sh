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

git checkout -b update-ecco-cdp-silver-"$PROJECT_VERSION"
cat <<EOF > /tmp/command.jq
. + {
      "models_path": "/ecco/dist/$PROJECT_NAME/$PROJECT_VERSION/${PROJECT_NAME/-/_/}/models/**",
      "schemas_path":"/ecco/dist/${PROJECT_NAME}-schemas/$PROJECT_VERSION",
      "graph": "$PROJECT_GRAPH"
    }
EOF
echo "jq command begin ============================>"
cat /tmp/command.jq
echo "jq command end   ============================>"
jq --monochrome-output --from-file /tmp/command.jq .helm/variables/ecco_cdp_silver.json > /tmp/updated.json
mv /tmp/updated.json .helm/variables/ecco_cdp_silver.json