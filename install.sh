#!/usr/bin/env bash
set -e
set -x

pushd servers/workflow
  ./gradlew build
popd

thrift -gen js:node -o servers/web/ servers/workflow/src/main/thrift/askcraig.thrift
thrift -gen js:node -o servers/web/ servers/workflow/src/main/thrift/shared.thrift

pushd servers/web
  npm install
  npm run build
popd


# TODO pass port
# cd servers/workflow
# ./gradlew run

# cd servers/web
# npm start -- --workflow-server=localhost:9090
