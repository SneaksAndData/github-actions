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

token="$(aws codeartifact get-authorization-token --domain "$AWS_CA_DOMAIN" --domain-owner "$AWS_CA_DOMAIN_OWNER" --region "$AWS_REGION" --query authorizationToken --output text)"
echo "::add-mask::$token"
echo "token=$token" >> "${GITHUB_OUTPUT}"

if [[ "$MODE" == "read" ]]
then
  url="$(aws codeartifact get-repository-endpoint --domain "$AWS_CA_DOMAIN" --domain-owner "$AWS_CA_DOMAIN_OWNER" --repository esd-artifacts --region "$AWS_REGION" --format pypi --query repositoryEndpoint --output text)/simple/"
elif [[ "$MODE" == "publish" ]]
then
  url="$(aws codeartifact get-repository-endpoint --domain "$AWS_CA_DOMAIN" --domain-owner "$AWS_CA_DOMAIN_OWNER" --repository esd-artifacts --region "$AWS_REGION" --format pypi --query repositoryEndpoint --output text)"
else
  >&2 echo "Unknown mode: $MODE"
  exit 1
fi;

echo "::add-mask::$url"
echo "url=$url" >> "${GITHUB_OUTPUT}"

echo "user=aws" >> "${GITHUB_OUTPUT}"
