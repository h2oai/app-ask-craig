#!/usr/bin/env bash

touch \
  web/out.log \
  web/error.log \
  workflow/out.log \
  workflow/error.log

tail --retry \
  -f web/out.log \
  -f web/error.log \
  -f workflow/out.log \
  -f workflow/error.log

