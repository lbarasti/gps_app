#!/bin/bash
npm install
coffee -c gulpfile.coffee
gulp &
../server.rb
