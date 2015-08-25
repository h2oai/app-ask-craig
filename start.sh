#!/usr/bin/env bash
set -e
set -x

# TODO pass port

pushd workflow
  ./gradlew run > out.log 2> error.log &
  PID=$!
  if ps -p $PID > /dev/null ; then
    echo $PID > server.pid
  else
    echo "Could not start workflow server"
    exit 1
  fi
popd

pushd web
  ./node_modules/.bin/coffee server.coffee --workflow-server=localhost:9090 > out.log 2> error.log &
  PID=$!
  if ps -p $PID > /dev/null ; then
    echo $PID > server.pid
  else
    echo "Could not start web server"
    exit 1
  fi
popd

exit 0
