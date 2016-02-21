
require! {
  http
  https
  fs
  path
  child_process

  opener
  connect
  colors
  'connect-static-transform': static-transform
  'faye-websocket': WebSocket

  './watch':  {RecursiveWatcher}
  './option': {OptionHelper}
}

class Injecter
  ({@content,@ignore-case,@type,@which,@where,@prepend})->
    @file-matcher = OptionHelper.read-pattern do
        @which, @ignore-case

    if @where instanceof RegExp
      @content-regex = @where
    else
      flag = @ignore-case is false and "" or "i"
      @content-regex = new RegExp @where, flag

    @length-of = if @prepend then (-> 0) else (.length)
    @get-code = match @type
      | "raw"  => -> @content
      | "file" => @@@get-cached-loader process.cwd!, @content
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

  @get-cached-loader = (base,file,enc='utf8')->
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

  @create = -> new Injecter it

# Main class
class SimpleAutoreloadServer

  @log-prefix = (host)->
    "[autoreload \##{process.pid} #host]".cyan

  (option={})->
    @websockets = []
    @running = no

    @options = OptionHelper.setup ({} <<< option)

  log: (mode, tag, text)->

    return if (mode is \verbose) and not @options.verbose

    colored-tag = match mode
    | \error   => "error@#tag".red
    | \normal  => tag.green
    | \verbose => tag.green
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
    try
      @stop! if @running

      dirs = for [@options with {target:"/"}] ++ (@options.mount ? [])
        .. with {path:path.resolve ..path}

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
        @log "normal", "server", "started on :#{"#{listen.port}".green} at #{listen.path}"

        if @options.execute?
          @log "verbose", "server", "execute command: #{that}"
          child = child_process.exec that, {stdio: \ignore}
            ..unref!

          if @options.stop-on-exit
            @log "verbose", "server", "server will stop when the command has exit."
            child.on \exit, ~>
              @log "normal", "server", "child command has finished."
              @stop!

        if @options.browse
          {port,address} = @server.address!

          if address is <[ 0.0.0.0 :: ]>
            address := "localhost"

          server-url = switch typeof @options.browse
            | "string" => @options.browse
            | _        => "http://#{address}:#{port}/"

          @log "verbose", "server", "open #server-url"
          opener server-url, {stdio: \ignore} .unref!

        if done?
          done null, @

  # Create watch
  create-watchers: (dirs)->

    # show notes
    if @options.recursive
      @log "verbose", "server", "init with recursive-option. this may take a while."

    should-reload = OptionHelper.read-pattern @options.reload, @options.ignore-case

    # create watch array
    watch-objs = dirs.map (dir)~>
      matcher = OptionHelper.read-pattern dir.watch, dir.ignore-case

      new RecursiveWatcher dir with do
        delay: @options.watch-delay
        error: ({message},src)~> @log "error", "watch", "#src Error: #message"
        update:(,target)~>
          if not matcher target
            @log "verbose", "watch", "#{"(ignored)".cyan} #target"
          else
            @log "normal", "watch", "updated #target"
            http-path = ''
            try if (path.relative dir.path, target) is /^[^/].*$/
              http-path := "/#{that.0}"

            @broadcast do
              type:   \update
              path:   http-path
              reload: should-reload http-path

    # fix Este to catch the error
    watch-objs

  # Creating httpd-server
  create-server: (dirs)->

    injects = [] ++ @options.inject

    if @options.builtin-script
      injects .= concat {
        which:   "**/*.htm{l,}"
        where:   new RegExp "</(body|head|html)>", "i"
        type:    "file"
        content: path.resolve __dirname, \../client.html
        +prepend
      }

    injecters = injects.map Injecter~create

    app = connect!
    # logger
    if @options.verbose
      app.use <| connect.logger '
        :ar-prefix :remote-addr :method 
        ":url HTTP/:http-version" 
        :status :referrer :user-agent
      '

    for dirs
      if @options.list-directory
        app.use ..target, (connect.directory ..path, {+icons})

      app.use ..target, static-transform do
        match: /^/
        root: ..path
        normalize: (path.relative ..target, _)
        transform: (file, text, send)->
          send <| injecters.reduce (->&1.inject file, &0), text

      app.use ..target, (connect.static ..path)

    http.create-server app

  broadcast: (data)->
    try
      json = JSON.stringify data
      @log "verbose", "broadcast", "to #{@websockets.length} sockets: #{json}"
      for @websockets => ..send json
    catch ex
      @log "error", "broadcast", ex.message

connect.logger.token \ar-prefix, (r)~>
  SimpleAutoreloadServer.log-prefix r.headers.host
  |> (+ " httpd".green)

export
  SimpleAutoreloadServer
