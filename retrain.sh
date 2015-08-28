#!/usr/bin/env bash
set -e
set -x

pushd workflow
  mongoexport \
    --verbose \
    --db=app-ask-craig \
    --collection=jobs \
    --type=csv \
    --fields=category,jobtitle \
    --out=./data/craigslistJobTitles.csv
popd
