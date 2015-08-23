#!/usr/bin/env bash
set -e
set -x

pushd workflow
  ./gradlew build
popd

pushd web
  npm install
  npm run build
  fluidc app.coffee --script=lib/thrift/lib/js/src/thrift.js --script=gen-js/Web.js --script=gen-js/web_types.js
popd


# TODO pass port
# cd workflow
# ./gradlew run

# cd web
# npm start -- --workflow-server=localhost:9090
