module.exports = (grunt)->

  files =
    bin: <[
      bin/autoreload
    ]>

    src:<[
      index
      lib/client
      lib/autoreload
      lib/default-options
      lib/utils
    ]>

    test: <[
      test/buster
      test/lib/test-utils
      test/helper/autoreload
      test/tests/autoreload.test
      test/tests/websocket.test
    ]>

    test-data:<[
      test/data
    ]>

    gruntjs:<[
      Gruntfile
    ]>

  este-files =
    gruntjs:
      files: <[ src/Gruntfile.ls ]>
      tasks: <[ config ]>
    ls:
      files: <[ src/index.ls src/lib/*.ls src/bin/*.ls ]>
      tasks: <[ src-debug test ]>
    test:
      files: <[ src/test/**/*.ls ]>
      tasks: <[ test ]>

  banner = '''
    /*
     * <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>
     * <<%= pkg.homepage %>>
     *
     * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>
     *
     * Licensed under the <%= pkg.licenses[0].type %> License.
     * <<%= pkg.licenses[0].url %>>
     */

  '''

  shebang = '''
    #!/usr/bin/env node

  '''

  require! path

  {each,flatten} = require \prelude-ls

  # (files, out, src, conf) -> conf-obj
  path-conv = (files,deco-key,deco-val,conf)->
    for k, v of files
      cur = ((conf[k] ?= {}).files = {})
      v |> each (-> cur[ deco-key it ] = deco-val it)
    conf

  este-listener = (file)->
    matcher = ->
      grunt.file.match it.files, file .length > 0

    for ,obj of este-files => obj
    |> (.filter matcher)
    |> (.map (.tasks))
    |> flatten

  {rel-js,tmp-js,src-ls} = do
    conv = ([pre,post])->( (it)->("#{pre}#{it}#{post}") )
    {
      rel-js: conv  [ "", \.js ]
      tmp-js: conv <[ tmp/js/ .js ]>
      src-ls: conv <[ src/    .ls ]>
    }

  grunt.init-config do

    pkg: grunt.file.readJSON \package.json

    clean:
      tmp:  <[ tmp/**/*  tmp ]>
      src:  <[ lib/**/*  lib  bin/**/* bin index.js ]>
      test: <[ test/**/* test ]>

    buster:
      test: {}

    livescript: path-conv do
      files{ bin, src, test, gruntjs }, tmp-js, src-ls,
      {
        options: { +bare }
      }

    uglify: path-conv do
      files{ src, bin }, rel-js, tmp-js,
      {
        options:
          mangle: except: <[ module.exports ]>
        src: options: banner:  banner
        bin: options: banner: (shebang + banner)
      }

    copy: path-conv do
      files{src,bin,test,gruntjs}, rel-js, tmp-js,
      {
        test-tmp: {
          +expand
          cwd:'src/test/data'
          src:'**'
          dest:'tmp/test/data/'
        }
      }

    este-watch:
      options:
        dirs: <[ src/**/ test/**/ tmp/**/ ]>
        livereload: {-enabled}
        ignored-files:
          index-of: ->
            (it isnt /\.(ls|js)$/ig and 1) or -1

      "*": este-listener

  <[
    grunt-buster
    grunt-livescript
    grunt-este-watch
    grunt-contrib-uglify
    grunt-contrib-copy
    grunt-contrib-clean
  ]>
  |> each (grunt.loadNpmTasks _)

  # following code is needed to reload the Gruntfile.js
  grunt.task.register-task do
    \reload, 'Reload the Gruntfile and restart Gruntjs', ->
      gruntfile = path.resolve 'Gruntfile.js'
      delete require.cache[gruntfile]

      grunt.task
        ..clear-queue!
        # ..init [ \esteWatch ]
        ..run  [ \esteWatch ]

  # grunt.loadTasks('./tasks');

  * * \config    <[ livescript:gruntjs copy:gruntjs reload ]>
    * \clean-all <[ clean:test clean:src clean:tmp ]>
    * \src-debug <[ livescript:src copy:src ]>
    * \release   <[ livescript:src livescript:bin
                    uglify:src uglify:bin test clean:test clean:tmp ]>
    * \test      <[ livescript:test copy:test copy:testTmp buster ]>
    * \default   <[ esteWatch ]>
  |> each (grunt.registerTask.apply grunt, _)

