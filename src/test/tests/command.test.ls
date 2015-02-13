
describe "command line script", ->
  before-all (done)->
    @timeout = 20000ms

    @tester-options = {
      port: 12352
      name: 'touch-test'
      +log
    }

    new-one = (f)~>
      new Tester @tester-options, f

    @err = []
    @out = []

    @first = true

    (@tester)<~ new-one

    @html-path = @tester.get-page-path!

    @update-html = (param)~>
      @tester.update-serv-file @html-path, param

    @tester.start-server-process [], (@ar)~>
      @ar.stderr.on \data, @err~push
      @ar.stdout.on \data, ~>
        @out.push it
        return unless @first

        @first = false
        set-timeout done, 0ms

  after-all (done)->
    @tester.finalize!
    done!

  It "should start server successfully.", (done)->
    <~ (.call @)

    # wait for outputing two lines
    if @out.length < 2
      delayed 100ms, &callee
      return

    assert.equals @err.length, 0, 'asure no error on startup'
    assert.match  @out.1, 'start'

    <~ delayed 100ms
    done!

  It "should stop server with handled-error message if already started on same addr.", (done)->
    a-out = []
    a-err = []

    new Tester @tester-options, (t)~>
      (ar)<~t.start-server-process []

      ar.stderr.on \data, a-err~push
      ar.stdout.on \data, a-out~push

      <~ ar.on \exit

      assert.equals a-err.length, 0, "should not print handled error to 'stderr'."
      assert.match  a-out.1, "error", "should print handled error to 'stdout'."

      t.finalize!
      done!


  It "server should reload on touch html.", (done)->
    @update-html """
    <html>
      <head>
        <script type='text/javascript'> window.loadTime = Date.now(); </script>
      </head>
      <body>
        <div> Test </div>
      </body>
    </html>
    """

    evaluator = (-> window.loadTime)

    <~ delayed 400ms
    (page) <~ @tester.get-web-phantom @html-path
    (err,result-pre) <~ page.evaluate evaluator

    if err then throw that
    @update-html!
    <~ delayed 200ms

    (err,result-post) <~ page.evaluate evaluator
    if err then throw that

    refute.equals result-pre, result-post
    done!


