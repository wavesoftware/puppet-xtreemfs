#!/bin/bash

set -e
set -x

bundle install --without development --path ${BUNDLE_PATH:-vendor/bundle} --jobs=3 --retry=3
if test "$RS_SET" != ""; then
  curl -sLo - http://j.mp/install-travis-docker | sh -xe
fi