
describe "command line", ->
  before-all (done)->
    @timeout = 20000ms

    require! {
        proc: child_process
        path
    }
    bin =  path.resolve __dirname, \../../bin/autoreload
    @ar  = proc.spawn bin, []

    @err = []
    @out = []

    @first = true

    @ar.stderr.on \data, @err~push
    @ar.stdout.on \data, ~>
      @out.push it
      if @first
        @first = false
        set-timeout done, 0ms

  after-all ->
    @ar.kill \SIGTERM

  It "should be successfully started.", ->
    assert.equals @err.length, 0, 'asure no error on startup'
    assert.match @out.0, "started"


