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

DBT_TARGET_SCHEMA=$(echo "$BRANCH" | sed "s/-/_/g" | sed "s/\//_/g")
export DBT_TARGET_SCHEMA

if [[ "$DEPLOY_ENVIRONMENT" == 'test' ]];
  then
    profile_target='dev';
  else
    profile_target='prod';
fi;

mkdir -p ~/.ssh
ssh-keyscan -p "$SPARK_PORT" "$SPARK_HOST" >> ~/.ssh/known_hosts
echo "$SSH_KEY" > ~/.ssh/spark
chmod 0600 ~/.ssh/spark

ssh -fNT -i ~/.ssh/spark "${SPARK_USER}@${SPARK_HOST}" -p "$SPARK_PORT" -L 10001:localhost:10000

poetry run dbt compile --profiles-dir .dbt --target $profile_target
poetry run dbt seed --profiles-dir .dbt --target $profile_target
