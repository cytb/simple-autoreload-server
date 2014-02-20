describe "watch module", ->

  before-all (done)->
    @timeout = 2000ms
    require! {
      \../../lib/watch
      \../lib/test-utils
      path
    }

    @path = path
    @dir = path.join.apply path, ([__dirname] ++ <[
      .. .. tmp test data fixture watch-test
    ]>)

    @update = ->
      test-utils.update (path.join @dir, it)

    @do-watch = (opt,done=->)~>
      @watcher = watch ({
        root: @dir
        on-change: ~>
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

