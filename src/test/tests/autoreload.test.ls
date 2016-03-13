

describe "client side script", ->

  before-all (done)->
    @timeout = 8000ms

    @html-file  = 'touch-test.html'
    @js-file    = 'touch-test.js'
    @css-file   = 'touch-test.css'
    @frame-file = 'touch-test.frame.html'

    @checker = new ReloadChecker {
      name: \client-code-injection
      port:12567
      +log
    },{
      page-file: @html-file
      delay: 100ms
    }

    <~ @checker.init
    @update  = @checker.tester~update-serv-file
    @check   = @checker~check
    @fin     = @checker.tester~finalize

    @update @html-file, """
    <html>
      <head>
        <link rel='StyleSheet' type='text/css' href='#{@css-file}' />
        <script type='text/javascript' src='#{@js-file}'></script>
        <script type='text/javascript'> window.loadTime = Date.now(); </script>
      </head>
      <body>
        <div> <iframe src='#{@frame-file}'></iframe> </div>
        <div> <span>#{@html-file}</span> </div>
      </body>
    </html>
    """

    @update @frame-file, """
    <html> <head>
      <title> frame </title>
      </head>
      <body>
        <div> frame </div>
      </body>
    </html>
    """

    # evaluate-twice (pre and post)
    done!

  after-all -> @fin!

  It "should let browser 'reload' 'html'
      on 'touch'.", (done)->

    @check do
      loader:    ~> @update @html-file
      evaluator: -> window.loadTime

      done: ({pre,post})~>
        refute.equals pre.result, post.result
        done!

  It "should let browser 'reload' 'html'
      on 'touch' 'js' with 'reload' option.", (done)->

    @check do
      server-option: {+reload}
      loader:    ~> @update @js-file
      evaluator: -> window.loadTime

      done: ({pre,post})~>
        refute.equals pre.result, post.result
        done!

  It "should 'not' let browser 'reload' 'html'
      on 'update' the js.", (done)->

    @check do
      loader:    ~> @update @js-file
      evaluator: -> window.loadTime
      done: ({pre,post})~>
        assert.equals pre.result, post.result
        done!

  describe "should let browser 'refresh'",->

    It "'js' file on 'update'.", (done)->

      @check do
        loader: ~>
          id = random-string 16
          @update @js-file, "window.testId = '#id';"
          {id}

        evaluator: ->
          id:    window.test-id
          mtime: window.load-time

        done: ({pre,post})~>
          assert.equals pre.result.mtime, post.result.mtime,
            "modified time must be same"

          assert.equals pre.result.id, pre.loaded.id,
            "browser's id must match to generated one (pre)"

          assert.equals post.result.id, post.loaded.id,
            "browser's id must match to generated one (post)"

          done!

    It "'css' file on 'update'", (done)->
      file = @css-file

      @check do
        loader: ~>
          font = random-string 16, ([\a to \z] * '')

          @update file, "body {font-family: #font;}"
          {font:font}

        evaluator: ->
            css: [ [css-text] \
                  for {href,css-rules} in document.style-sheets
                  for {css-text} in css-rules ] * ' '
            mtime: window.load-time

        done: ({pre,post})~>
          assert.equals pre.result.mtime, post.result.mtime,
            "modified time must be same"

          assert.match pre.result.css, pre.loaded.font,
            "browser style must be set (pre)"

          assert.match post.result.css, post.loaded.font,
            "browser style must be set (post)"

          done!

  # htmls
  It "should 'not' let browser to 'reload' the 'html' file
      on 'touch' the unrelated 'html' file.
  ", (done)->

    files = <[
      touch.html
      touch-test1.html
      touch-test2.html
      touch-test3.html
      touch-test.frame.html
    ]>

    loaded = false

    @check do
      loader: ~>
        files.for-each @update if loaded
        loaded = !loaded

      evaluator: -> window.load-time

      done: ({pre,post})~>
        assert.equals pre.result, post.result
        done!

