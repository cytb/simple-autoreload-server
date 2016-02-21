
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
  gulp-busterjs 
  run-sequence
]>

require! {
  child_process: {spawn}
  'prelude-ls' : {Obj,obj-to-pairs,map}
  'package.json': pkg
  'src/lib/option-list': {options}
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
      next.on \error, ->
        console.log arguments
        next.emit "end"

      try
        pipe.pipe next
      catch
        next.end!

    generator! |> (.filter (isnt null) |> (.reduce red))
  )

multi-pipe-line = map pipe-line

# basic livescript builder
get-template-param = ->
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

  "clean:test": -> del <[ test/ buster.js ]>
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
      gulp-chmod 775

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
    * gulp.src "src/doc/README.tmpl", {base:'src/doc'}
      gulp-template (get-template-param!)
      gulp-rename 'README.md'
      gulp.dest './'

  "build:src": <[ build:lib build:bin build:client ]>
  "build:all": <[ build:src build:doc ]>

  "buster-js": pipe-line ->
    * gulp.src <[ test/tests/*.test.js ]>
      gulp-busterjs do
        name:         "tests"
        root-path:    \./
        environment:  \node
        test-helpers: <[ test/helper/autoreload.js ]>

  "test":     gulp.series <[ clean:test build:test copy:test-data buster-js ]>
  "release":  gulp.series <[ build:all test clean:test ]>

  "release-npm": gulp.series <[ release ]>
  "release-git": gulp.series <[ release clean:all  ]>

  watch: -> watch do
    'src/*.tmpl':       <[ build:document ]>
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
