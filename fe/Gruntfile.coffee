module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.initConfig
    jade:
      index:
        options:
          pretty: true
        expand: true
        flatten: true
        src: ['src/main/jade/**/*.jade']
        dest: '../public/html'
        ext: '.html'
    stylus:
      design:
        expand: true
        flatten: true
        src: ['src/main/styl/**/*.styl']
        dest: '../public/css'
        ext: '.css'
    coffee:
      main:
        expand: true
        flatten: true
        src: ['src/main/coffee/**/*.coffee']
        dest: '../public/js'
        ext: '.js'
    watch:
      styl:
        files: ['src/main/styl/**/*.styl']
        tasks: ['stylus']
      jade:
        files: ['src/main/jade/**/*.jade']
        tasks: ['jade']
      coffee:
        files: ['src/main/coffee/**/*.coffee']
        tasks: ['coffee']
    connect:
      main:
        options:
          base: '../public'
  grunt.registerTask 'default', ['jade', 'stylus', 'coffee', 'watch']
