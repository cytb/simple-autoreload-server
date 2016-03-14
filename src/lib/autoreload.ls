
require! {
  http
  https
  fs
  path
  child_process

  opener
  connect
  colors
  'faye-websocket': WebSocket

  './watch':  {RecursiveWatcher}
  './option': {OptionHelper}
}

class Injecter
  ({@content,@ignore-case,@type,@which,@where,@prepend,@include-hidden,@encoding})->
    @file-matcher = OptionHelper.read-pattern do
        @which, @ignore-case, @include-hidden

    if @where instanceof RegExp
      @content-regex = @where
    else
      flag = @ignore-case is false and "" or "i"
      @content-regex = new RegExp @where, flag

    @length-of = @prepend and (->0) or (.length)
    @get-code  = match @type
      | "raw"  => -> @content
      | "file" => @@@get-cached-loader process.cwd!, @content, @encoding
      | _      => -> @content

  is-target: ->
    @file-matcher it

  match-content: ->
    @content-regex.exec it

  inject: (file, text)->
    if (@is-target file) and (m = @match-content text)
      pos  = m.index + @length-of m.0
      text = "#{text.slice 0,pos}#{@get-code!}#{text.slice pos}"
    text

  @create = -> new Injecter it

  @get-cached-loader = (base,file,enc='utf-8')->
    last   = null
    p      = path.resolve base, file
    cached = ""
    ->
      {mtime} = fs.stat-sync p
      if last isnt mtime
        cached := fs.read-file-sync p, {encoding:enc}
        cached := cached.to-string!
        last   := mtime
      cached

class InjectionRouter
  ({@path,@target,@inject,@default-pages,@encoding,@list-directory})->
    @injecters = @inject.map Injecter~create
    @default-pages = OptionHelper.read-pattern @default-pages

  route: (req,res,next)->
    next! if not (req.method in <[ GET HEAD ]>)

    url = connect.utils.parse-url req
    rel = path.relative @target, url.pathname
    file = path.resolve @path, rel

    is-dirpath = url.pathname.char-at (url.pathname.length - 1)

    try
      stat = fs.stat-sync file
      if stat.is-directory! and is-dirpath
        dir = file
        files = fs.readdir-sync dir
          .map (path.join dir, _)
          .filter (name)->
            try fs.stat-sync name ?.is-file!
            catch e => false
          .sort!.filter @~default-pages

        if files.length > 0
          file := files.0
          stat := fs.stat-sync file

      if not (stat.is-file! and @injecters.some (.is-target file))
        return next!

      text = fs.read-file-sync file, @{encoding}
      text = @injecters.reduce (->&1.inject file, &0), text
      res.set-header "Content-Length", Buffer.byte-length text
      res.end text, @encoding
    catch
      next!

# Main class
class SimpleAutoreloadServer

  @log-prefix = (host)->
    "[autoreload \##{process.pid} #host]".cyan

  (option={})->
    @websockets = []
    @running = no

    @setup-options option

  setup-options: (options,logger=->)->
    options = {} <<< options
    option-helper = new OptionHelper

    get-root-def = (pname,name,alter=name)->
      (options,def-map)->
        | options[pname]?.[name]?   => that
        | options[pname]?.0?.[name] => that
        | options[name]? => that
        | _ => def-map[alter]

    defaults = {}
    defaults-src =
      mount:  <[ watch recursive followSymlinks ignoreCase includeHidden ]>
      inject: <[ where which type prepend includeHidden ]>

    for key,names of defaults-src
      base = (defaults[key] ?= {})
      for def in names
        base[def] = get-root-def key, def

    assured = option-helper.assure options, defaults
    # json
    json = null
    pre-file = file = null
    dir = null
    if assured.search-config
      next-dir = process.cwd!
      do
        dir      := next-dir
        pre-file := file
        file     := path.resolve dir, assured.config
        try
          fs.read-file-sync file, @{encoding}
            json := JSON.parse ..to-string!

        next-dir = path.join dir, ".."
      while (not json?) and (pre-file isnt file)

    base := json ? {}

    if json?
      @basedir = path.resolve dir, (path.dirname file)
      process.chdir @basedir
    else
      @basedir = process.cwd!

    new-base = ({} <<< base <<< options)
    for <[ inject mount ]>
      new-base[..] = [] ++ (base[..] ? []) ++ (options[..] ? [])

    out = option-helper.assure new-base, defaults

    if not out.inject? or out.inject.length < 1
      out.inject = []
      try
        file = path.resolve @basedir, '.autoreload.html'
        if (fs.lstat-sync file)?.is-file!
          out.inject.push {content: file}
      out := option-helper.assure out, defaults

    # check onmessage
    if out.onmessage not instanceof Function
      out.onmessage = (->)

    @options = out

    if json?
      @log "verbose", "options", "config loaded: #{file}"
      @log "verbose", "options", "change working directory to #{dir}"

  log-level:
    * * level: \silent  tags: <[ ]>
      * level: \minimum tags: <[ normal error ]>
      * level: \normal  tags: <[ normal info error ]>
      * level: \verbose tags: <[ normal info error verbose ]>
      * level: \noisy   tags: <[ normal info error verbose debug ]>

  log-level-map: {silent:0, minimum:1, normal:2, verbose:3, noisy:4}

  get-log-level: (level = "normal")->
    | typeof level is "boolean" => level and 2 or 0
    | typeof level is "string" =>
      for i from 0 til @log-level.length
        return i if @log-level[i].level is level
      2
    | 0 <= level and level < @log-level.length => level
    | _ => 2

  log: (mode, tag, text)->
    level = @get-log-level @options.log

    return if not (mode in @log-level[level].tags)

    colored-tag = match mode
    | \error   => "error@#tag".red
    | _        => tag.green

    prefix = @@@log-prefix "localhost:#{@options.port}"
    console.log "#prefix #colored-tag #text"

  stop: ->
    try
      @watcher?.stop!
      @server?.close!

      @running = no

      @log "normal", "server", "stopped."

    catch ex
      @log "error",  "server", ex.message

  start: (done)->
    mounts = []
    try
      @stop! if @running

      mounts ++= ({} <<< @options <<< {target:"/"})
      mounts ++= (@options.mount ? [])

      dirs = for mounts
        ({} <<< .. <<< {path:path.resolve @basedir, ..path})

      @watchers = @create-watchers dirs
      @server   = @create-server   dirs

      @watchers.map (.start!)

    catch ex
      @log "error", "server", ex.message
      @log "error", "server", ex.stack
      if done?
        done ex, @
      return null

    listen = @options{port,host,path}

    @server
      ..on \upgrade, (req, sock, head)~>
        return unless WebSocket.is-web-socket req

        addr = "#{sock.remote-address}:#{sock.remote-port}"

        new WebSocket req, sock, head
          ..on \open, ~>
            @log "verbose", \websocket, "#addr - new connection"
            ..send JSON.stringify {type:\open, log:@options.client-log}

          ..on \message, ({data})~>
            @log "verbose", \websocket, "#addr - received message #data"
            @options.onmessage data, ..

          ..on \close, ~>
            @log "verbose", \websocket, "#addr - connection closed"
            @websockets .= filter (isnt ..)

          @websockets.push ..

      ..on \error, (err)~> match err.code
        | \EADDRINUSE =>
          @log "error", \server, "
            Cannot use #{"#{listen.host}".green}:#{"#{listen.port}".green} as a listen address. Error: #{err.message}
          "
          @watchers.map (.stop!)

      ..listen (listen.port .|. 0), listen.host, 511, ~>
        @running = yes
        @abspath = "#{path.resolve process.cwd!, listen.path}"

        for mounts.slice 1
          @log "info", "server", "mounted #{..path} to #{..target}"

        @log "normal", "server", "started on :#{"#{listen.port}".green} at #{@abspath}"

        if @options.execute? and @options.execute
          @log "info", "server", "execute command: #{that}"
          child = child_process.exec that, {stdio:\ignore}
            ..unref!

          if @options.stop-on-exit
            @log "info", "server", "server will stop when the command has exit."
            child.on \exit, ~>
              @log "info", "server", "child command has finished."
              @stop!

        if @options.browse
          {port,address} = @server.address!

          if address in <[ 0.0.0.0 :: ]>
            address := "localhost"

          server-url = switch typeof @options.browse
            | "string" => @options.browse
            | _        => "http://#{address}:#{port}/"

          @log "info", "server", "open #server-url"
          opener server-url, {stdio: \ignore} .unref!

        if done?
          done null, @

  # Create watch
  create-watchers: (dirs)->

    # show notes
    if @options.recursive
      @log "verbose", "server", "init with recursive-option. this may take a while."

    should-reload = OptionHelper.read-pattern do
      @options.reload, @options.ignore-case, @options.include-hidden

    # create watch array
    watch-objs = dirs.map (dir)~>
      matcher = OptionHelper.read-pattern dir.watch, dir.ignore-case, dir.include-hidden

      new RecursiveWatcher dir with do
        delay: @options.watch-delay
        error: ({message},src)~> @log "error", "watch", "#{src} Error: #message"
        update:(,target)~>
          if not matcher target
            @log "debug", "watch", "#{"(ignored)".cyan} #target"
          else
            @log "verbose", "watch", "updated #target"
            http-path = ''
            try if (path.relative dir.path, target) is /^[^/].*$/
              http-path := "/#{that.0}"

            @broadcast do
              type:   \update
              path:   http-path
              reload: should-reload http-path

    watch-objs

  # Creating httpd-server
  create-server: (dirs)->

    inject   = [] ++ @options.inject
    encoding = @options.encoding


    if @options.builtin-script
      inject .= concat {
        which:   new RegExp ".*\\.html?$"
        where:   new RegExp "</(body|head|html)>", "i"
        type:    "file"
        content: path.resolve __dirname, \../client.html
        +prepend
        encoding
      }

    # reinterpret path
    for ([] ++ inject)
      if ..type is "file"
        ..content = path.resolve @basedir, ..content

    app = @options.connect-app ? connect!

    # logger
    if (@get-log-level @options.log) >= @log-level.verbose
      app.use <| connect.logger '
        :ar-prefix :remote-addr :method 
        ":url HTTP/:http-version" 
        :status :referrer :user-agent
      '

    for dirs
      if @options.list-directory
        app.use ..target, (connect.directory ..path, {+icons})

      opts = ({} <<< ..{path,target} <<< {inject,encoding} <<< @{default-pages})
      app.use ..target, (new InjectionRouter opts)~route
      app.use ..target, (connect.static ..path)

    http.create-server app

  broadcast: (data)->
    try
      json = JSON.stringify data
      @log "debug", "broadcast", "to #{@websockets.length} sockets: #{json}"
      for @websockets => ..send json
    catch ex
      @log "error", "broadcast", ex.message

connect.logger.token \ar-prefix, (r)~>
  SimpleAutoreloadServer.log-prefix r.headers.host
  |> (+ " httpd".green)

export
  SimpleAutoreloadServer
