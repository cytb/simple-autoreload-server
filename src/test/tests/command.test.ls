
describe "command line", ->
  before-all (done)->
    @timeout = 20000ms

    new-one = (f)~>
      @tester = new Tester {
        port: 12352
        name: 'touch-test'
        # +log
      }, f

    @err = []
    @out = []

    @first = true

    <~ new-one

    @html-path = @tester.get-page-path!

    @update-html = (param)~>
      @tester.update-serv-file @html-path, param

    @tester.start-server-process [], (ar)~>
      ar.stderr.on \data, @err~push
      ar.stdout.on \data, ~>
        @out.push it
        return unless @first

        @first = false
        set-timeout done, 0ms

  after-all (done)->
    @tester.kill-server-process 'SIGTERM', done

  It "should be successfully started.", ->
    assert.equals @err.length, 0, 'asure no error on startup'
    assert.match @out.0, "started"

  It "should be reload on touch html.", (done)->
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

    <~ delayed 20ms
    (page) <~ @tester.get-web-phantom @html-path
    (err,result-pre) <~ page.evaluate evaluator

    if err then throw that
    @update-html!
    <~ delayed 50ms

    (err,result-post) <~ page.evaluate evaluator
    if err then throw that

    refute.equals result-pre, result-post
    done!


