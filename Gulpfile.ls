
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
  gulp-mocha
]>

require! {
  child_process: {spawn}
  'prelude-ls' : {Obj,obj-to-pairs,map}
  './src/lib/option-list': {options}
  'lodash': {template}
}

map-pairs = (functor,obj)-->
  obj-to-pairs obj |> map functor

# task  = map-pairs (gulp.task.apply gulp, _)
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

# fuckin gulp
function clean-test(done)
  del <[ test/ mocha.js ]>
  done!
clean-test.displayName = "clean:test"

function clean-lib(done)
  del <[ lib/ index.js ]>
  done!

clean-lib.displayName = "clean:lib"

function clean-bin(done)
  del <[ bin/ ]>
  done!

clean-bin.displayName = "clean:bin"

function clean-client(done)
  del <[ client.html ]>
  done!

clean-client.displayName = "clean:client"

clean-src = gulp.parallel clean-lib, clean-bin, clean-client
clean-all = gulp.parallel clean-test, clean-src

copy-test-data = pipe-line ->
  * gulp.src  "src/test/data/**", {base:"src/"}
    gulp.dest "./"

copy-test-data.displayName = "copy:test-data"

build-test = pipe-line-ls <[ src/test/**/*.ls ]>
build-test.displayName = "build:test"

build-lib = pipe-line-ls <[ src/index.ls src/lib/*.ls ]>
build-lib.displayName = "build:lib"

build-bin = pipe-line-ls <[ src/bin/*.ls ]>, ->
  * gulp-insert.prepend '''
        #!/usr/bin/env node

      '''
    gulp-rename {extname:""}

build-bin.displayName = "build:bin"

build-client = pipe-line-ls <[ src/client.ls ]>, ->
  * gulp-insert.wrap '''
        <script type="text/javascript">
        //<![CDATA[

      ''', '''

        //]]>
        </script>
      '''
    gulp-rename "client.html"
build-client.displayName = "build:client"

build-doc = pipe-line ->
  * gulp.src <[ src/doc/!(banner).tmpl ]>, {base:'src/doc'}
    gulp-template (get-template-param!)
    gulp-rename {extname:".md"}
    gulp.dest './'

build-doc.displayName = "build:doc"

build-document = build-doc

function build-package-json(done)
  json   = './package.json'
  pkg    = require json
  pkg.readme = fs.read-file-sync "README.md" .to-string!
  fs.write-file-sync json, (JSON.stringify pkg, null, 2)
  done!

build-package-json.displayName = "build:package.json"

build-src = gulp.parallel build-lib, build-bin, build-client
build-release = gulp.parallel build-src, build-doc

mocha = pipe-line ->
  * gulp.src <[ test/tests/*.test.js ]>
    gulp-mocha {+exit}

mocha.displayName = "mocha"

test = gulp.series (gulp.parallel build-release, clean-test), (gulp.parallel build-test, copy-test-data), mocha
test.displayName = "test"

release = gulp.series test, (gulp.parallel clean-test, build-package-json)
npm-version = gulp.series build-document, build-package-json
release-npm = release

release-git = gulp.series release, clean-all
task-watch = -> watch do
    'src/doc/!(banner).tmpl':  build-document
    'src/lib/*.ls':     build-lib
    'src/client.ls':    build-client
    'src/bin/*.ls':     build-bin
    'src/test/**/*.ls': test

function auto-reload(done)
  child = []

  respawn-child = ->
    child .= filter (-> it.kill!)
    init = if config.debug then ["debug-on"] else []
    child.push do
      spawn \gulp, (init ++ ["watch"]), {stdio:'inherit'}

  watch { 'Gulpfile.ls': respawn-child }

  respawn-child!
  done!

auto-reload.displayName = "auto-reload"

function debug-on(done)
    config.debug  = on
    config.uglify = off

debug-on.displayName = "debug-on"

with-debug = gulp.series debug-on, auto-reload

export do
  "debug-on":     debug-on
  "with-debug":   with-debug
  "clean:test":   clean-test
  "clean:lib":    clean-lib
  "clean:bin":    clean-bin
  "clean:client": clean-client
  "clean:src":    clean-src
  "clean:all":    clean-all

  "copy:test-data": copy-test-data
  "build:test": build-test
  "build:lib":  build-lib
  "build:bin":   build-bin
  "build:client": build-client
  "build:document": build-document
  "build:doc": build-doc
  "build:package.json": build-package-json
  "build:src": build-src
  "build:release": build-release
  "mocha": mocha
  "test":    test
  "release": release
  "npm-version": npm-version
  "release-npm": release-npm
  "release-git": release-git

  "watch": task-watch
  "auto-reload": auto-reload
  "default": auto-reload

