#!/usr/bin/env coffee
gulp = require 'gulp'
jade = require 'gulp-jade'
copy = require 'gulp-copy'
styl = require 'gulp-stylus'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
runSequence = require 'run-sequence'
del = require 'del'

jadeopts = pretty: true
coffeeopts = {}
stylopts = {}

coffeesrc =
  'bustracker.js': [
    'fe/src/main/coffee/channels.coffee'
    'fe/src/main/coffee/bustracker.coffee'
  ]
  'backdoor.js': [
    'fe/src/main/coffee/channels.coffee'
    'fe/src/main/coffee/backdoor.coffee'
  ]

gulp.task 'clean-js', (cb) ->
  del ['public/**/*.js'], force: true, cb

gulp.task 'clean-css', (cb) ->
  del ['public/**/*.css'], force: true, cb

gulp.task 'clean-html', (cb) ->
  del ['public/**/*.html'], force: true, cb

gulp.task 'jade', ->
  gulp.src 'fe/src/main/jade/**/*.jade'
    .pipe jade jadeopts
    .pipe gulp.dest 'public/html'

buildCoffee = ->
  for k, v of coffeesrc
    gulp.src v
      .pipe coffee coffeeopts
      .pipe concat k
      .pipe gulp.dest 'public/js'


gulp.task 'styl', ->
  gulp.src 'fe/src/main/styl/**/*.styl'
    .pipe styl stylopts
    .pipe gulp.dest 'public/css'

gulp.task 'copy', ->
  gulp.src __dirname + '/fe/src/main/resources/**'
    .pipe gulp.dest 'public/png'

gulp.task 'watch', ->
  gulp.watch 'fe/src/main/coffee/**/*.coffee', ['coffee']
  gulp.watch 'fe/src/main/jade/**/*.jade', ['jade']
  gulp.watch 'fe/src/main/styl/**/*.styl', ['styl']
  gulp.watch 'fe/src/main/resources/**/*.png', ['copy']
  
gulp.task 'coffee', buildCoffee

gulp.task 'build', ['jade', 'styl', 'coffee', 'copy']
gulp.task 'clean', ['clean-html', 'clean-css', 'clean-js']
gulp.task 'cleanbuild', -> runSequence 'clean', 'build'
gulp.task 'default', ['cleanbuild', 'watch']
