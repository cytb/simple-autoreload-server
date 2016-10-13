{assert} = require \chai
require \../helper/autoreload .expose global

describe "watch module", ->

  before (done)->
    @timeout = 2000ms
    require! {
      path
      '../../lib/watch': {RecursiveWatcher}
      '../lib/test-utils': {update}
    }

    @path = path
    @dir = path.join.apply path, ([__dirname] ++ <[
      .. .. test data fixture watch-test
    ]>)

    @update = ->
      update (path.join @dir, it)

    @do-watch = (opt,done=->)~>
      @watcher = new RecursiveWatcher ({
        path: @dir
        update: ~>
          @watcher.stop!
          done!
      } <<<< opt)

      @watcher.start!
      @watcher

    done!

  It 'should receive event on fire any fs-change', (done)->
    @do-watch {}, ->
      assert true
      done!

    @update "test.txt"

  It 'should watch recursive if specified recursive option', (done)->
    @do-watch {+recursive}, ->
      assert true
      done!

    target = @path.join "sub1", "sub2", "test.txt"
    @update target

  It 'should not watch recursive without option', (done)->
    no-event = true

    @do-watch {-recursive}, ->
      no-event := false

    target = @path.join "sub1", "sub2", "test.txt"
    @update target

    set-timeout (->
      assert no-event
      done!
    ), 500ms

