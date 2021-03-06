
pathes =
  data: <[ test data ]>
  serv: <[ serv ]>
  expect: <[ expect ]>
  fixture: <[ fixture ]>
  command: <[ bin autoreload ]>

require! {
  mocha
  'prelude-ls': {flatten}
  path
  #node-phantom: \node-phantom-simple # error: netstat
  phantom: phantom-js
  http
  connect
  'child_process': proc
  colors
  '../lib/test-utils'
  '../../index': autoreload
  'es6-promise': {Promise}
  'es6-map': Map
}

# require 
# change base
#
command-path = path.resolve process.cwd!, (path.join.apply path, pathes.command)
process.chdir <| path.join.apply path, pathes.data

exposer = ->

  # mocha.spec.expose @
  # @{it,assert,refute,expect,test-case} = mocha
  @{delayed,random-string} = test-utils

  @Promise = Promise
  @Map     = Map

  # @log = buster.console~log

  # for LiveScript
  @It = @it

  # When = ``when``

  @Tester = class Tester
    {touch,store,load,update,remove} = test-utils

    ({@name,@expect-ext=".html",@log=false,@port=18888,@no-port,@no-serv}={},done=(->))->
      @server = null

      phantom-js.create!
      .then (@phantom)~>
        @phantom.create-page!

      .then (@page)~>
        @page.on \onConsoleMessage, ~>
          @logger "phantom console.log>".magenta, it

        @page.on \onError, ([msg,stack])~>
          @logger "phantom error>".red, msg
          for stack
            @logger "phantom error>".red, ..file, ..line, ..function

        done @
        true

      .catch (err)->
        console.log err
        console.log err.stack

        throw err

    logger: (...texts)->
      @log and console.log do
        ((["[Tester #{Date.now!}] #{@name}".yellow ] ++ texts) * ' ')

    finalize: (done=->)->
      @logger \finalize
      @page?.close!
      @phantom?.exit!
      @stop-server!
      @kill-server-process!
      done!

    data-path: (...names)->
      joined = path.join.apply path, (flatten names)

      @logger \data-path, joined
      joined

    open-data: (...names)->
      console.log path.resolve (@data-path names)
      @do-file-func (@data-path names), \open-data, load

    start-server-process: (opts=[],done=->)->
      @logger \start-server-process
      @kill-server-process!

      bin = command-path
      arg = []
        ..push ['--log', @log] if @log
        ..push (@data-path pathes.serv) if not @no-serv
        ..push ['--port', @port] if not @no-port

      arg = flatten (arg ++ opts)

      @logger \start-server-process, ("\"#{arg * '" "'}\"")
      @server-proc = proc.spawn bin, arg

      @server-proc.on \exit, ~>
        @server-proc = null

      done @server-proc

    kill-server-process: (sig='SIGKILL',done=->)->
      @logger \kill-server-process
      @server-proc?.kill sig

      @server-proc = null
      done!

    start-server: (opt={},done=->)->
      @logger \start-server
      @stop-server!

      opt.log  ?= (@log ? "normal")
      opt.port ?= @port
      opt.path ?= @data-path pathes.serv

      @server = autoreload opt
      done!

    stop-server: ->
      @logger \stop-server
      @server?.stop!
      @server = null

    check-server: ->
      @logger \check-server
      @server or @server-proc or throw new Error do
        'server has not been prepared.'
      true

    get-page-path: (file="#{@name}.html")->file

    get-web-url: (file)->
      page-path = @get-page-path file
      port  = @server?.options?.port or @port
      "http://localhost:#{port ? 80}/#{page-path}"

    get-web-page: (file, done)->
      url = (@get-web-url file)
      @logger \get-web-page, url

      @check-server!
        and http.get url, done

    get-web-phantom: (file,done)->
      url = (@get-web-url file)
      @logger \get-web-phantom, url

      if @check-server!
        @page.open url .then ~>
          done @page, it

    get-expect-json: (file)->
      @logger \get-expect-json
      @get-expect-file file

    get-expect-file: (file)->
      @logger \get-expect-file, file
      @open-data do
        pathes.expect, @name, (file + @expect-ext)

    get-state: ->
      state:  it and 'ok'.green or 'ng'.red
      result: it

    store-serv-file: (file,data)->
      @do-serv-file-func  file, \store, (store _, data)

    touch-serv-file: (file)->
      @do-serv-file-func  file, \touch, touch

    update-serv-file: (file,data)->
      @do-serv-file-func file, \update, (update _, data)

    update-data-file: (file,data)->
      file = @data-path file
      @do-file-func file, \update, (update _, data)

    remove-serv-file: (file,data)->
      @do-serv-file-func  file, \remove, (remove _, data)

    remove-data-file: (file,data)->
      file = @data-path file
      @do-file-func file, \remove, (remove _, data)

    do-serv-file-func: (serv-file,name,func)->
      file = @data-path pathes.serv, serv-file
      @do-file-func file, name, func

    do-file-func: (file,name,func)->
      suc = @get-state (func file)
      @logger name, suc.state, file
      suc.result

  # Load Page Twice (pre/post Phase)
  @ReloadChecker = class ReloadChecker
    (@tester-option,def-opt)->
      return new &callee &0, &1, &2 if @@@ isnt &callee

      @set-default-option def-opt

    init: (done)->
      @tester = new Tester @tester-option, done

    set-default-option: (@default-option={server-option:{},delay:50ms})->

    set-option: (option-arg)->
      @option = test-utils.new-copy do
        option-arg, @default-option

    check: (option={})->
      @set-option option

      <~ @tester.start-server @option.server-option

      <~ delayed @option.delay
      loaded-pre = @option.loader!
      (page) <~ @tester.get-web-phantom @option.page-file

      <~ delayed @option.delay
      (result-pre) <~ page.evaluate @option.evaluator .then
      loaded-post = @option.loader!

      <~ delayed @option.delay

      (result-post) <~ page.evaluate @option.evaluator .then


      @tester.stop-server!

      @option.done {
        pre:
          loaded: loaded-pre
          result: result-pre
        post:
          loaded: loaded-post
          result: result-post
      }
      # page.close!
      #

export do
  expose: (this-obj)->
    exposer.call this-obj

