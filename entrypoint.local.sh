#!/bin/sh
set -e

bundle config --global --delete without
bundle config --global --delete frozen
bundle install
yarn install --check-files

bin/rails log:clear
bin/rails db:seed
bin/rails assets:clobber

# https://github.com/evanw/esbuild/issues/1511
yarn build --watch < /dev/zero &
yarn build:css --watch &
bundle exec pumactl start
