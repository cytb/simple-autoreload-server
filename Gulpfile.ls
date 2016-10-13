
config =
  debug:  on

require! <[
  fs
  del
  gulp
  gulp-if
  gulp-livescript
  gulp-uglify
  gulp-insert
  gulp-template
  gulp-rename
  gulp-concat
  gulp-chmod
  gulp-spawn-mocha
  run-sequence
]>

require! {
  child_process: {spawn}
  'prelude-ls' : {Obj,obj-to-pairs,map}
  './src/lib/option-list': {options}
  'lodash': {template}
}

run-sequence .= use gulp
gulp.series = (array)->
  (cb)-> run-sequence.apply null, (array ++ cb)

map-pairs = (functor,obj)-->
  obj-to-pairs obj |> map functor

task  = map-pairs (gulp.task.apply gulp, _)
watch = map-pairs (gulp.watch.apply gulp, _)

pipe-line = (generator)->
  (->
    red = (pipe,next)->
      next.on \error, (err)->
        next.emit "error", err

      pipe.pipe next

    generator! |> (.filter (isnt null) |> (.reduce red))
  )

multi-pipe-line = map pipe-line

# basic livescript builder
get-template-param = ->
  pkg = require './package.json'
  fig2 = ->
    it < 10 and ("0" + it.toString!) or it


  let @ = new Date
    {
      pkg, options,
      year: "#{@get-full-year!}"
      date: "#{@get-full-year!}-#{fig2 (@get-month! + 1)}-#{fig2 (@get-date!)}"
    }

pipe-line-ls = (src, mapgen = (->[]))->
  pipe-line ->
    header = template <| fs.read-file-sync 'src/doc/banner.tmpl', 'utf-8'
    pre-build =
      * * gulp.src src, {base:"src/"}
          gulp-livescript!
          gulp-if config.uglify, gulp-uglify!
          gulp-insert.prepend (header get-template-param!)

    post-build =
      * * gulp.dest "./"

    pre-build ++ mapgen! ++ post-build

# config.uglify = on
config.uglify = off
task do
  'debug-on': ->
    config.debug  = on
    config.uglify = off

  'with-debug': gulp.series <[ debug-on auto-reload ]>

  "clean:test": -> del <[ test/ mocha.js ]>
  "clean:lib":  -> del <[ lib/ index.js ]>
  "clean:bin":  -> del <[ bin/ ]>
  "clean:client":  -> del <[ client.html ]>
  "clean:src": <[ clean:lib clean:bin clean:client ]>
  "clean:all": <[ clean:test clean:src ]>

  "copy:test-data": pipe-line ->
    * gulp.src  "src/test/data/**", {base:"src/"}
      gulp.dest "./"

  "build:test": pipe-line-ls <[ src/test/**/*.ls ]>
  "build:lib":  pipe-line-ls <[ src/index.ls src/lib/*.ls ]>
  "build:bin":  pipe-line-ls <[ src/bin/*.ls ]>, ->
    * gulp-insert.prepend '''
          #!/usr/bin/env node

        '''
      gulp-rename {extname:""}

  "build:client": pipe-line-ls <[ src/client.ls ]>, ->
    * gulp-insert.wrap '''
          <script type="text/javascript">
          //<![CDATA[

        ''', '''

          //]]>
          </script>
        '''
      gulp-rename "client.html"

  "build:doc": <[ build:document ]>
  "build:document": pipe-line ->
    * gulp.src <[ src/doc/!(banner).tmpl ]>, {base:'src/doc'}
      gulp-template (get-template-param!)
      gulp-rename {extname:".md"}
      gulp.dest './'

  "build:package.json": ->
    json   = 'package.json'
    pkg    = require json
    pkg.readme = fs.read-file-sync "README.md" .to-string!
    fs.write-file-sync json, (JSON.stringify pkg, null, 2)

  "build:src":     <[ build:lib build:bin build:client ]>
  "build:release": <[ build:src build:doc ]>

  "mocha": pipe-line ->
    * gulp.src <[ test/tests/*.test.js ]>
      gulp-spawn-mocha {}
  "test":     gulp.series <[ build:release clean:test build:test copy:test-data mocha ]>
  "release":  gulp.series <[ test clean:test build:package.json ]>

  "release-npm": gulp.series <[ release ]>
  "release-git": gulp.series <[ release clean:all  ]>

  watch: -> watch do
    'src/doc/!(banner).tmpl':   <[ build:document ]>
    'src/lib/*.ls':     <[ build:lib ]>
    'src/client.ls':    <[ build:client ]>
    'src/bin/*.ls':     <[ build:bin ]>
    'src/test/**/*.ls': <[ test ]>

  'auto-reload': ->
    child = []

    respawn-child = ->
      child .= filter (-> it.kill!)
      init = if config.debug then ["debug-on"] else []
      child.push do
        spawn \gulp, (init ++ ["watch"]), {stdio:'inherit'}

    watch { 'Gulpfile.ls': respawn-child }

    respawn-child!

  'default': ['auto-reload']
