#!/bin/bash
npm install
coffee -c gulpfile.coffee
gulp &
bundle exec ruby server.rb
