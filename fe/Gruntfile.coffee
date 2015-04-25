module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.initConfig
    copy:
      pngs:
        cwd: '.'
        expand: true
        flatten: true
        src: ['src/main/resources/**/*.png']
        dest: '../public/png'
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
        files:
          '../public/js/bustracker.js': [
            'src/main/coffee/channels.coffee'
            'src/main/coffee/bustracker.coffee'
          ]
          '../public/js/backdoor.js': [
            'src/main/coffee/channels.coffee'
            'src/main/coffee/backdoor.coffee'
          ]
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
  grunt.registerTask 'default', ['jade', 'stylus', 'coffee', 'copy', 'watch']
