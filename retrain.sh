#!/usr/bin/env bash
set -e
set -x

export ML_SERVER_IP_PORT=localhost:9090

pushd workflow
  mongoexport \
    --verbose \
    --db=app-ask-craig \
    --collection=jobs \
    --type=csv \
    --fields=category,jobtitle \
    --out=./data/craigslistJobTitles.csv
popd

pushd web
  ./node_modules/.bin/coffee retrain.coffee
popd
