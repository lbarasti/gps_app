#!/usr/bin/env coffee
gulp = require 'gulp'
jade = require 'gulp-jade'
copy = require 'gulp-copy'
styl = require 'gulp-stylus'
watch = require 'gulp-watch'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
runSequence = require 'run-sequence'
del = require 'del'

jadeopts = {}
coffeeopts = {}
stylopts = {}

coffeesrc =
  'bustracker.js': [
    'src/main/coffee/channels.coffee'
    'src/main/coffee/bustracker.coffee'
  ]
  'backdoor.js': [
    'src/main/coffee/channels.coffee'
    'src/main/coffee/backdoor.coffee'
  ]

cleanJs = (cb) ->
  del ['../public/**/*.js'], force: true, cb

gulp.task 'clean-css', (cb) ->
  del ['../public/**/*.css'], force: true, cb

gulp.task 'clean-html', (cb) ->
  del ['../public/**/*.html'], force: true, cb

buildJade = ->
  gulp.src 'src/main/jade/**/*.jade'
    .pipe jade jadeopts
    .pipe gulp.dest '../public/html'

buildCoffee = ->
  for k, v of coffeesrc
    gulp.src v
      .pipe coffee coffeeopts
      .pipe concat k
      .pipe gulp.dest '../public/js'


buildStyl = ->
  gulp.src 'src/main/styl/**/*.styl'
    .pipe styl stylopts
    .pipe gulp.dest '../public/css'

gulp.task 'copy', ->
  gulp.src 'src/main/resources/**/*.png'
    .pipe copy '../public/png'

gulp.task 'coffee', buildCoffee
gulp.task 'jade', buildJade
gulp.task 'styl', buildStyl
gulp.task 'clean-js', cleanJs

gulp.task 'watch', ->
  watch 'src/main/styl/**/*.styl', buildStyl

  watch 'src/main/jade/**/*.jade', buildJade
  watch 'src/main/coffee/**/*.coffee', cleanJs buildCoffee

gulp.task 'build', ['jade', 'styl', 'coffee', 'copy']
gulp.task 'clean', ['clean-html', 'clean-css', 'clean-js']
gulp.task 'cleanbuild', runSequence 'clean', 'build'
gulp.task 'default', ['cleanbuild', 'watch']
