#!/bin/bash
npm install
coffee -c gulpfile.coffee
gulp &
bundle exec ruby server.rb
# cp -r fe2/ public/
# rm public/png/20181025-busmap.png
