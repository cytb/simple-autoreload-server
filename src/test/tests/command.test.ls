{assert} = require \chai
require \../helper/autoreload .expose global

describe "command line script", ->
  before-each (done)->
    @timeout = 8000ms
    @tester-options = {
      port: 12352
      name: 'touch-test'
      log: "verbose"
    }

    @stderr = []
    @stdout = []
    @commandline-options = []

    @start = (complete,error=(->))~>
      first = true
      @tester.start-server-process @commandline-options, (@ar)~>
        @ar.stderr.on \data, @stderr~push
        @ar.stdout.on \data, ~>
          console.log "#it"
          @stdout.push "#it"
          if first
            first := false
            set-timeout complete, 0ms

    @update-html = (param)~>
      @tester.update-serv-file @html-path, param

    (@tester)<~ new Tester @tester-options
    @html-path = @tester.get-page-path!
    set-timeout done, 0ms

  after-each (done)->
    @tester.finalize!
    done!

  It "should start server successfully.", (done)->
    <~ @start

    # wait for outputing two lines
    if @stdout.length < 2
      delayed 100ms, &callee
      return


    assert.equal   @stderr.length, 0,       'assure no error on startup'
    assert.include @stdout.1,      'start', 'assure started successfully'
    assert.equal   @stderr.length, 0,       'assure no error on startup'

    <~ delayed 100ms
    done!

  It "should execute command when server listen.", (done)->
    out-file  = "test.echo.log"
    random    = (Math.random! * 1000000) .|. 0
    command   = "echo #{random} > #{@tester.data-path out-file}"

    @commandline-options = ["--execute", command]

    <~ @start

    <~ delayed 300ms
    assert.include (@tester.open-data out-file).to-string!, random.to-string!, 'should match generated random int.'
    done!

  It "should stop server with handled-error message if already started on same addr.", (done)->
    <~ @start

    new Tester @tester-options, (t)~>
      (ar)<~t.start-server-process []

      out = []
      err = []

      ar.stderr.on \data, err~push
      ar.stdout.on \data, -> out~push "#it"

      <~ ar.on \exit
      assert.equal err.length, 0,  "#{err.map (.to-string!)}, should not print handled error to 'stderr'."
      assert.include  out.1, "error", "should print handled error to 'stdout'."

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
    (result-pre) <~ page.evaluate evaluator .then
    @update-html!

    <~ delayed 400ms

    (result-post) <~ page.evaluate evaluator .then
    assert.not-equal result-pre, result-post
    done!


