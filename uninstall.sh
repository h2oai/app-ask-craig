#!/usr/bin/env bash
set -e
set -x

# Drop database
mongo app-ask-craig --eval "db.dropDatabase()"
