#!/usr/bin/env bash
set -e
set -x

pushd servers/workflow
  ./gradlew build
popd

pushd servers/web
  npm install
  npm run build
popd


# TODO pass port
# cd servers/workflow
# ./gradlew run

# cd servers/web
# npm start -- --workflow-server=localhost:9090
