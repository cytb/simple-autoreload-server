
describe "autoreload-server as http server", ->

  before (done)->
    @timeout = 8000ms
    @tester-options = {
      port: 12354
      name: 'http-serve'
      log:  "normal"
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
          @stdout.push it
          if first
            first := false
            set-timeout complete, 0ms

    (@tester)<~ new Tester @tester-options
    set-timeout done, 0ms

  after (done)->
    @tester.finalize!
    done!

  It "should send utf8-BOM with proper mimetypes", (done)->
    <~ @start

    ok = false

    require! http
    url = @tester.get-web-url "utf8-bom.html"
    http.get url, ->
      assert.equals (it.headers.'content-type'), "text/html", "should gives text/html as content-type"
      if not ok
        ok := true
        done!

    .on 'error', (err)->
      assert false, "error on http get: '#url'"
      console.log err.message
      console.log err
      if not ok
        ok := true
        done!


