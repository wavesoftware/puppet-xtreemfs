#!/bin/bash

set -e
set -x

if test "$RS_SET" != ""; then
  ./run 'bundle exec rake acceptance'
else
  bundle exec rake test
fi