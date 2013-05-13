module.exports = (grunt)->

  pkg = grunt.file.readJSON('package.json')

  grunt.initConfig
    pkg: pkg

    coffee:
      compile:
        files:
          "<%= pkg.name %>.js": ["d3.svg.rubberband.coffee"]

    stylus:
      compile:
        files:
          "<%= pkg.name %>.css": "d3.svg.rubberband.styl"

    uglify:
      options:
        banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('yyyy-mm-dd')%> */\n"""
        mangle: false  ## if true, jumly.min.js is corrupted
      build:
        src: '<%= pkg.name %>.js'
        dest: '<%= pkg.name %>.min.js'

    cssmin:
      compress:
        options:
          banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('yyyy-mm-dd')%> */"""
        files:
          'build/<%= pkg.name %>.min.css': [ "<%= pkg.name %>.css" ]

    "jasmine-node":
      run:
        spec: 'spec',
      options:
        coffee: true,
      env:
        NODE_PATH: "lib/js"

    regarde:
      css:
        files: '*.styl'
        tasks: ['stylus', 'cssmin']
      js:
        files: '*.coffee'
        tasks: ['coffee', 'uglify']
      coffee:
        files: ['spec/*.coffee']
        tasks: ['compile', 'jasmine-node']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-jasmine-node'
  grunt.loadNpmTasks 'grunt-regarde'

  grunt.registerTask 'default', ['build']
  grunt.registerTask 'minify', ['uglify', 'cssmin']
  grunt.registerTask 'compile', ['coffee', 'stylus']
  grunt.registerTask 'build', ['compile', 'minify']
  grunt.registerTask 'spec', ['jasmine-node']
  grunt.registerTask 'dev', ['livereload-start', 'regarde']
  grunt.registerTask 'release', "", ->
    grunt.task.requires ["build"]
    fs = require "fs"
    dir = "views/static/release"
    fs.mkdirSync dir unless fs.existsSync dir

    done = @async()
    require("child_process").exec "cp build/jumly.*  #{dir}; git add #{dir}", (err,stdout,stderr)->
      process.stdout.write stdout if stdout
      process.stderr.write stderr if stderr
      process.stderr.write err if err
      done(true)
