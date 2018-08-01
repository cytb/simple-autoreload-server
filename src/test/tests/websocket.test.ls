{assert} = require \chai
require \../helper/autoreload .expose global

describe "websocket server", ->

  before (done)->

    @timeout = 6000ms

    @messages = []

    {deep-match} = require \../lib/test-utils

    @expect = (file,data)~>
      S = JSON~parse
      e   = S( @tester.get-expect-json file )
      msg = -> "expects content of the file '#file': (#{it})"

      if data?
        assert.include S(data), e, (msg data)
      else
        assert do
          @messages.some -> deep-match S(it), e
          msg @messages

    new-tester = ~>
      @tester = new Tester {
        name: \websocket-echo
        expect-ext: \.json
        log: "verbose"
      }, it

    <~ new-tester
    <~ @tester.start-server {
      # +verbose
      port:12565
      # inject: []
      reload: /force-reload$/
      onmessage: (msg,sock)~>
        @messages.push msg
    }

    @file = \websocket-echo.html

    @update = @tester~update-serv-file

    (@page) <~ @tester.get-web-phantom @file
    done!

  before-each ->
    @messages = []

  after ->
    @tester.finalize!

  It "should be connected successfully.", (done)->
    <~ delayed 200ms
    @expect \connected-1
    @expect \connected-2
    done!

  It "should send 'update' message.", (done)->
    @update @file

    <~ delayed 200ms
    @expect \update-1
    done!

  It "should send 'update' message with reload.", (done)->
    @update "#{@file}-force-reload"

    <~ delayed 200ms
    @expect \update-2
    done!

