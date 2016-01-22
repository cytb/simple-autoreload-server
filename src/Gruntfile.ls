module.exports = (grunt)->

  files =
    bin: <[
      bin/autoreload
    ]>

    src:<[
      index
      lib/client
      lib/autoreload
      lib/options
      lib/utils
      lib/watch
    ]>

    test: <[
      test/buster
      test/lib/test-utils
      test/helper/autoreload
      test/tests/watch.test
      test/tests/autoreload.test
      test/tests/command.test
      test/tests/websocket.test
      test/tests/example.test
    ]>

    test-data:<[
      test/data
    ]>

    gruntjs:<[
      Gruntfile
    ]>

  este-files =
    readme:
      files: <[ src/doc/README.tmpl ]>
      tasks: <[ template:readme ]>

    gruntjs:
      files: <[ src/Gruntfile.ls ]>
      tasks: <[ config ]>

    ls:
      files: <[ src/index.ls src/lib/*.ls src/bin/*.ls ]>
      tasks: <[ src-debug test ]>

    test:
      files: <[ src/test/**/*.ls ]>
      tasks: <[ test ]>

  data =
    banner: grunt.file.read \src/doc/banner.tmpl
    pkg:    grunt.file.readJSON \package.json
    shebang: '''
      #!/usr/bin/env node

    '''

  # utils
  require! path
  {each,map,flatten} = require \prelude-ls

  # (files, out, src, conf) -> conf-obj
  path-conv = (files,deco-key,deco-val,conf)-->
    for k, v of files
      cur = ((conf[k] ?= {}).files = {})
      v |> each (-> cur[ deco-key it ] = deco-val it)
    conf

  # watcher
  este-listener = (file)->
    matcher = ->
      grunt.file.match it.files, file .length > 0

    for ,obj of este-files => obj
    |> (.filter matcher)
    |> (.map (.tasks))
    |> flatten

  # following code is needed to reload the Gruntfile.js
  grunt.task.register-task do
    \reload, 'Reload the Gruntfile and restart Gruntjs', ->
      gruntfile = path.resolve 'Gruntfile.js'
      delete require.cache[gruntfile]

      grunt.task
        ..clear-queue!
        # ..init [ \esteWatch ]
        ..run  [ \esteWatch ]


  grunt.task.register-task do
    \chmod, 'Change permissions.', ->
      require! fs
      files.bin
      |> each (fs.chmod-sync _, '775')

  # name map function
  {rel-js,tmp-js,src-ls} = do
    conv = ([pre,post])->( (it)->("#{pre}#{it}#{post}") )
    {
      rel-js: conv  [ "", \.js ]
      tmp-js: conv <[ tmp/js/ .js ]>
      src-ls: conv <[ src/    .ls ]>
    }

  conv-tmp-to-rel = (obj)->
    path-conv files{ src, test, gruntjs }, rel-js, tmp-js, do
      path-conv files{ bin }, (->it), tmp-js, obj

  #
  # Grunt config
  #
  grunt.init-config do
    pkg: data.pkg

    clean:
      tmp:  <[ tmp/**/*  tmp ]>
      src:  <[ lib/**/*  lib  bin/**/* bin index.js ]>
      test: <[ test/**/* test ]>

    buster:
      test: {}

    template: readme:
      files: 'README.md': 'src/doc/README.tmpl'
      options: data: ->
        pkg:data.pkg
        options: require \./lib/options

    livescript: path-conv do
      files{ bin, src, test, gruntjs }, tmp-js, src-ls,
      {
        options: { +bare }
      }

    uglify: conv-tmp-to-rel do
      options:
        mangle: except: <[ module.exports ]>
      src: options: banner: data.banner
      bin: options: banner: (data.shebang + data.banner)

    copy: conv-tmp-to-rel do
      bin: options: process: (data.shebang +)
      test-tmp: {
        +expand
        cwd:'src/test/data'
        src:'**'
        dest:'tmp/test/data/'
      }

    este-watch:
      options:
        dirs: <[ src/**/ test/**/ tmp/**/ ]>
        livereload: {-enabled}
        ignored-files:
          index-of: ->
            (it isnt /\.(ls|js|tmpl)$/ig and 1) or -1

      "*": este-listener

  <[
    buster
    livescript
    este-watch
    contrib-uglify
    contrib-copy
    contrib-clean
    template
  ]>
  |> map ('grunt-' +)
  |> each (grunt.loadNpmTasks _)

  # grunt.loadTasks('./tasks');

  * * \config    <[ livescript:gruntjs copy:gruntjs reload ]>
    * \clean-all <[ clean:test clean:src clean:tmp ]>
    * \src-debug <[ livescript:src livescript:bin copy:src copy:bin chmod ]>
    * \test      <[ livescript:test copy:test copy:testTmp buster ]>
    * \default   <[ esteWatch ]>
    * \release   <[ clean-all
                    livescript:src livescript:bin
                    uglify:src uglify:bin template:readme
                    chmod test clean:test clean:tmp ]>
    * \release-git <[ release clean-all ]>

  |> each (grunt.registerTask.apply grunt, _)



