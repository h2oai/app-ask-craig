#!/usr/bin/env bash
set -e
set -x

pushd workflow
  ./gradlew build
popd

pushd web
  npm install
  npm run build
popd


# TODO pass port
# cd workflow
# ./gradlew run

# cd web
# npm start -- --workflow-server=localhost:9090
