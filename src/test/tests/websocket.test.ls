
describe "websocket server", ->

  before-all (done)->
    @timeout = 5000ms

    @messages = []

    @expect = (file,data)~>
      e   = @tester.get-expect-json file
      msg = "expects content of the file '#file'"

      if data?
        assert.equals data, e, msg
      else
        assert (0 <= @messages.index-of e), msg

    new-tester = ~>
      @tester = new Tester {
        name: \websocket-echo
        expect-ext: \.json
        # +log
      }, it

    <~ new-tester
    <~ @tester.start-server {
      # +verbose
      port:12565
      inject: []
      force-reload: /force-reload$/
      onmessage: (msg,sock)~>
        @messages.push <|
        JSON.stringify <|
        JSON.parse msg
    }

    @file = \websocket-echo.html

    @update = @tester~update-serv-file

    (@page) <~ @tester.get-web-phantom @file
    done!
  before ->
    @messages = []

  after-all ->
    @tester.finalize!

  It "should be connected successfully.", (done)->
    @expect \connected-1
    @expect \connected-2
    done!

  It "should send 'update' message.", (done)->
    @update @file

    <~ delayed 100ms
    @expect \update1
    done!

  It "should send 'update' message.", (done)->
    @update "#{@file}-force-reload"

    <~ delayed 100ms
    @expect \update2
    done!

