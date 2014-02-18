<- (.call (global ? @))

pathes =
  data: <[ tmp test data ]>
  serv: <[ serv ]>
  expect: <[ expect ]>
  fixture: <[ fixture ]>
  command: <[ bin autoreload ]>

buster = require \buster
buster.spec.expose @
@{assert,refute,expect,test-case} = buster

# @log = buster.console~log

# for LiveScript
@It = @it

# require 
require! {
  \prelude-ls
  path
  #node-phantom: \node-phantom-simple # error: netstat
  \node-phantom
  http
  connect
  autoreload: \../../index
  colors
  \../lib/test-utils
  \../../lib/utils
  proc: child_process
}

{flatten} = prelude-ls
{new-copy} = utils

@{delayed,random-string} = test-utils

# When = ``when``

@Tester = class Tester
  {touch,store,load,update} = test-utils

  ({@name,@expect-ext=".html",@log=false,@port=18888},done=(->))->
    @server = null

    (err,@phantom) <~ node-phantom.create
    if err then throw that

    (err,@page) <~ @phantom.create-page
    if err then throw that

    @page.onConsoleMessage = ~>
      @logger "phantom console.log>".magenta, it

    done!

  logger: (...texts)->
    @log and console.log do
      ((["[Tester #{Date.now!}] #{@name}".yellow ] ++ texts) * ' ')

  finalize: ->
    @logger \finalize
    @page?.close!
    @phantom?.exit!
    @stop-server!

  data-path: (...names)->
    joined = path.join.apply path,
      pathes.data ++ flatten names

    @logger \data-path, joined
    joined

  open-data: (...names)->
    @do-file-func (@data-path names), \open-data, load

  start-server-process: (opts=[],done=->)->
    @logger \start-server-process
    @kill-server-process!

    @server-proc = proc.spawn do
      (path.join.apply path, pathes.command)
      (@log and ['--verbose'] or []) ++ [
        (@data-path pathes.serv),
        '--port', @port,
      ] ++ opts

    done @server-proc

  kill-server-process: (sig='SIGKILL',done=->)->
    @logger \kill-server-process
    @server-proc?.kill sig

    @server-proc = null
    done!

  start-server: (opt={},done=->)->
    @logger \start-server
    @stop-server!

    opt.verbose ?= @log
    opt.port ?= @port
    opt.root ?= @data-path pathes.serv

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
    port = @server?.options?.port or @port
    "http://localhost:#{port ? 80}/#{page-path}"

  get-web-page: (file, done)->
    url = (@get-web-url file)
    @logger \get-web-page, url

    @check-server!
      and http.get url, done

  get-web-phantom: (file,done)->
    url = (@get-web-url file)
    @logger \get-web-phantom, url

    @check-server!
      and @page.open url, ~>done @page, it

  get-expect-json: (file)->
    @logger \get-expect-json
    JSON.stringify JSON.parse @get-expect-file file

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

  do-serv-file-func: (serv-file,name,func)->
    file = @data-path pathes.serv, serv-file
    @do-file-func file, name, func

  do-file-func: (file,name,func)->
    suc = @get-state func file
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
    @option = new-copy do
      option-arg, @default-option

  check: (option={})->
    @set-option option

    <~ @tester.start-server @option.server-option

    <~ delayed @option.delay
    loaded-pre = @option.loader!
    (page) <~ @tester.get-web-phantom @option.page-file

    <~ delayed @option.delay
    (err,result-pre) <~ page.evaluate @option.evaluator

    if err then throw that
    loaded-post = @option.loader!

    <~ delayed @option.delay
    (err,result-post) <~ page.evaluate @option.evaluator
    if err then throw that

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

