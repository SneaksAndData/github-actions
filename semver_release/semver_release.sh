#!/usr/bin/env bash

set -Eeuo pipefail
providedMajor=$MAJOR_V
providedMinor=$MINOR_V
currentVersion=$(git describe --tags --abbrev=7)
currentMinor=$(echo "$currentVersion" | cut --delimiter=. --fields=2)
currentMajor=$(echo "$currentVersion" | cut --delimiter=. --fields=1 | cut --delimiter=v --fields=2)
if [[ $currentMajor -eq $providedMajor ]] && [[ $providedMinor -eq $currentMinor ]];
then
  currentRevision=$(echo "$currentVersion" | rev | cut --delimiter=. --fields=1 | rev | cut --delimiter=- --fields=1)
  nextRevision=$(( currentRevision + 1 ))
else
  nextRevision='0'
fi
nextVersion="v$providedMajor.$providedMinor.$nextRevision"
echo $nextVersion
gh release create "$nextVersion" --generate-notes

echo "::set-output name=version::$nextVersion"
