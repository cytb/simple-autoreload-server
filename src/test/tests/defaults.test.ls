

describe "on default config", ->

  before-all (done)->
    @timeout = 10000ms

    @config-file  = '.autoreload.json'
    @inject-file  = '.autoreload.html'
    @html-file    = 'default-config.html'
    @js-file      = 'default-config.js'
    @css-file     = 'default-config.css'

    @checker = new ReloadChecker {
      name: 'default-config'
      port:12567
      log: "verbose"
    },{
      page-file: @html-file
      delay: 100ms
    }

    <~ @checker.init
    @remove-data = @checker.tester~remove-data-file
    @update      = @checker.tester~update-serv-file
    @update-data = @checker.tester~update-data-file
    @check   = @checker~check
    @fin     = @checker.tester~finalize

    @update-data @inject-file, """
      <script type='text/javascript'>
        window.injectTestId = 'test';
      </script>
    """

    @json-config = {
      watch: "**/**.{css,html}"
    }

    @update @html-file, """
    <html>
      <head>
        <script type='text/javascript' src='#{@js-file}'></script>
        <script type='text/javascript'> window.loadTime = Date.now(); </script>
        <link rel='StyleSheet' type='text/css' href='#{@css-file}' />
      </head>
      <body>
        default config.
      </body>
    </html>
    """

    @update-data @config-file, (JSON.stringify @json-config)

    done!

  after-all ->
    @remove-data @inject-file
    @remove-data @config-file
    @fin!

  It "should inject defualt html file" , (done)->

    @check do
      loader: ~>
        id = random-string 32

        @update-data @inject-file, """
          <script type='text/javascript'>
            window.injectTestId = '#{id}';
          </script>
        """

        # should reload
        @update @html-file

        id

      evaluator: -> window.injectTestId

      done: ({pre,post})~>
        refute.equals pre.loaded, post.loaded,  "generated pre-id shouldnt equals post-id"
        refute.equals pre.result, post.result,  "generated pre-id result shouldnt equals post-id result"
        assert.equals pre.loaded, pre.result,   "generated pre-id should equals pre-id result"
        assert.equals post.loaded, post.result, "generated post-id should equals post-id result"
        done!

  It "shouldn't refresh/reload on update 'js' as described in default config.", (done)->
      @check do
        server-option: {+reload}
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

          refute.equals post.result.id, post.loaded.id,
            "browser's id must match to generated one (post)"

          done!

  It "refresh 'css' file on 'update'", (done)->
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

