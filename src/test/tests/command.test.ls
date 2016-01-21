
describe "command line script", ->
  before (done)->
    @timeout = 20000ms
    @tester-options = {
      port: 12352
      name: 'touch-test'
      +log
    }

    @stderr = []
    @stdout = []
    @commandline-options = []

    @start = (complete,error=(->))~>
      first = true
      @tester.start-server-process @commandline-options, (@ar)~>
        @ar.stderr.on \data, @stderr~push
        @ar.stdout.on \data, ~>
          @stdout.push it
          if first
            first := false
            set-timeout complete, 0ms

    @update-html = (param)~>
      @tester.update-serv-file @html-path, param

    (@tester)<~ new Tester @tester-options
    @html-path = @tester.get-page-path!
    set-timeout done, 0ms

  after (done)->
    @tester.finalize!
    done!

  It "should start server successfully.", (done)->
    <~ @start

    # wait for outputing two lines
    if @stdout.length < 2
      delayed 100ms, &callee
      return

    assert.equals @stderr.length, 0,       'assure no error on startup'
    assert.match  @stdout.1,      'start', 'assure started successfully'

    <~ delayed 100ms
    done!

  It "should execute command when server listen.", (done)->
    out-file  = "test.echo.log"
    random    = (Math.random! * 1000000) .|. 0
    command   = "echo #{random} > #{@tester.data-path out-file}"

    @commandline-options = ["--execute", command]

    <~ @start

    <~ delayed 300ms
    assert.match (@tester.open-data out-file), random.to-string!, 'should match generated random int.'
    done!

  It "should stop server with handled-error message if already started on same addr.", (done)->
    <~ @start

    new Tester @tester-options, (t)~>
      (ar)<~t.start-server-process []

      out = []
      err = []

      ar.stderr.on \data, err~push
      ar.stdout.on \data, out~push

      <~ ar.on \exit
      assert.equals err.length, 0,  "#{err.map (.to-string!)}, should not print handled error to 'stderr'."
      assert.match  out.1, "error", "should print handled error to 'stdout'."

      t.finalize!
      done!


  It "server should reload on touch html.", (done)->
    <~ @start

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


