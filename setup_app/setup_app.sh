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

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

jwt_script=$(cat << EOF
require 'openssl'
require 'jwt'  # https://rubygems.org/gems/jwt

# Private key contents
private_key = OpenSSL::PKey::RSA.new(ENV["DELAMAIN_PRIVATE_KEY"])

# Generate the JWT
payload = {
  # issued at time, 60 seconds in the past to allow for clock drift
  iat: Time.now.to_i - 60,
  # JWT expiration time (10 minute maximum)
  exp: Time.now.to_i + (10 * 60),
  # GitHub App's identifier
  iss: "${{ env.DELAMAIN_APP_ID }}"
}

jwt = JWT.encode(payload, private_key, "RS256")
puts jwt
EOF
)

echo "$jwt_script" > /tmp/jwt_script
sudo gem install jwt
ruby /tmp/jwt_script > /tmp/jwt

github_token_ednpoint="https://api.github.com/app/installations/$DELAMAIN_APP_INSTALLATION_ID/access_tokens"
curl -X POST -H "Authorization: Bearer $(cat /tmp/jwt)" \
  -H "Accept: application/vnd.github+json" "$github_token_ednpoint" | jq '.token' | cut -d'"' -f2 > /tmp/access_token

echo "access_token=$(cat /tmp/access_token)" >> "$GITHUB_OUTPUT"