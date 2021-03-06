#!/bin/bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ev

# Variables
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
GULP_CLI="$ROOT/node_modules/.bin/gulp"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=`mktemp -d`

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# deletes the temp directory
function cleanup {      
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
# trap cleanup EXIT

# Enter work dir
pushd "$WORK_DIR"

if [ ! -d "$ROOT/dist/package" ]; then
  pushd $ROOT
  $GULP_CLI build
  popd
fi

# Simulate env
cp -r $DIR/* .
npm install

echo "$ROOT/dist/package"
npm install "$ROOT/dist/package"

if hash xvfb-run 2>/dev/null; then
  xvfb-run npm run test
else
  npm run test
fi
