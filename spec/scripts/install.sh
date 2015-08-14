#!/bin/bash

set -e
set -x

bundle install --without development
if test "$RS_SET" != ""; then
  curl -sLo - http://j.mp/install-travis-docker | sh -xe
fi