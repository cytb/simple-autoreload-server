
require! {
  connect
  colors
  WebSocket: \faye-websocket
  http
  \este-watch
  path
  static-transform: \connect-static-transform
  \./utils
  def-options: \./default-options
}

# utils
{flatten,regex-clone,new-copy,get-logger,create-connect-stack} = utils

module.exports = (options)->
  ars-obj = new SimpleAutoreloadServer options
    ..init!
    ..start!

# Main class
class SimpleAutoreloadServer
  (options={})->
    @living-sockets = []
    @normal-log = get-logger @~log-prefix
    @verb-log   = (->)
    @set-options options

  set-options: (options-arg={})->
    options = new-copy options-arg, def-options

    # check onmessage
    if \function isnt typeof options.onmessage
      options.onmessage = (->)

    # set logger state
    if options.verbose
      @verb-log = (tag,...texts)~>
        @normal-log.apply @, ( [tag.to-string!green] ++ texts )

      connect.logger.token \prefix, ~>
        @log-prefix! + " httpd".green

    @options = options

  log-prefix: ->
    pid  = process.pid
    root = @options.root
    port = @options.port
    "[autoreload \##pid @#root :#port]".cyan

  stop: ->
    @watcher?.dispose!
    @server?.close!

    @normal-log "Server stopped."

  start: ->
    @watcher.start!
    @server
      ..listen @options.port
      ..add-listener \upgrade, @create-upgrade-listerner!

    root-path = @options.root.to-string!green
    port      = @options.port.to-string!green

    @normal-log "Server started on :#port at #root-path"

  init: ->
    @watcher = @create-watcher!
    @server  = @create-server!


  create-upgrade-listerner: ->
    return (req, sock, head)~>
      return unless WebSocket.isWebSocket req

      addr = "#{sock.remote-address}:#{sock.remote-port}"
      verb-log-ws = (~>@verb-log \websocket, addr, "-", it)

      websock = new WebSocket req, sock, head

      websock
      .on \open, ~>
        verb-log-ws "new connection"
        websock.send JSON.stringify {type:\open, -client}

      .on \message, ({data})~>
        verb-log-ws "received message", data
        @options.onmessage data, websock

      .on \close, ~>
        verb-log-ws "connection closed"
        @living-sockets .= filter (isnt websock)
      |> @living-sockets.push

  # Create este-watch
  create-watcher: ->
    root = @options.root
    self = this

    # Watch
    este-obj = este-watch [root], (ev)->
      return unless flatten [ self.options.watch ] .some ->
        typeof! it is \RegExp and it.test ev.filepath

      self.verb-log "watch", "event on", ev.filepath

      file-path = (do
        try
          http-file-path = path.relative root, ev.filepath

          # returning '' if it is out of root-dir
          http-file-path isnt /^\// and "/#http-file-path" or ''
        catch
           ''
      )

      self.broadcast {type:\update, path:file-path}

    # fix Este to catch the error
    dir-change = este-obj.on-dir-change
    este-obj
      ..on-dir-change = ->
        try
          # call original function
          dir-change.apply @, &
        catch e
          self.normal-log 'Exception'.red, e

    este-obj

  # Creating httpd-server
  create-server: ->
    root = @options.root

    server =
      # head of middleware conf
      * null

      # logger 
        @options.verbose and connect.logger ([
            ":prefix :remote-addr :method"
            '":url HTTP/:http-version"'
            ":status :referrer :user-agent"
        ] * ' ')


      # script injectors (array)
        @@create-strans root, @options.inject

      # static server
        @options.list-directory and
          connect.directory root, icons:true

        connect.static root

      # process array
      |> flatten
      |> (.filter Boolean)
      |> create-connect-stack
      |> connect! .use
      |> http.create-server

    # return
    server

  broadcast: (
    message,
    websockets=@living-sockets,
    delay=@options.broadcast-delay
  )->
    json-data = JSON.stringify message

    <~(set-timeout _, delay)
    @verb-log "broadcast",
      "to #{websockets.length} sockets :", json-data
    websockets.for-each (->it?.send json-data)

  # static methods
  # create static-transform
  @create-strans = (root,inject-opt,recur=true)->
    callee = &callee

    match typeof! inject-opt
    | \Array =>
      recur or throw new Error '''
        autoreload -
        the injection option has too deep recursion.
      '''
      inject-opt.map (->callee root, it.0, false)

    | \Function =>
      transform = inject-opt
      ST = static-transform do
        root: root
        match: /^/ig
        transform: (file-path, data, send)->
          send <| transform file-path, data
      [ST]

    | \Object =>
      optm = new-copy def-options.inject, inject-opt

      index-of = if optm.prepend then (-> 0) else (.length)

      ST = static-transform do
        root:root
        match:optm.file
        transform: (file-path, text, send)->
          m = (optm.match.exec text) ? {0:text, index:0}
          i = m.index + index-of m.0
          S = text~slice

          send "#{S 0,i}#{inject-opt.code}#{S i}"
      [ST]


/*

exports.listen = (options-arg,listen-done=(->))->
  options  = new-copy options-arg, def-options
  root     = options.root

  if \function isnt typeof options.onmessage
    options.onmessage = (->)

  if options.verbose
    verb-log := (tag,...texts)->
      log.apply @, ( [tag.to-string!green] ++ texts )

    connect.logger.token \prefix, ->
      log-prefix! + " httpd".green

  # WebSocket
  living-sockets = []

  # Watch
  este = este-watch [root], (ev)->
    return unless flatten [ options.watch ] .some ->
      typeof! it is \RegExp and it.test ev.filepath

    verb-log "watch", "event on", ev.filepath

    file-path = (do
      try
        f = path.relative root, ev.filepath

        # returning '' if it is out of root-dir
        f isnt /^\// and "/#f" or ''
      catch
         ''
    )

    json-data = JSON.stringify do
      { type: \update, path: file-path}

    <-(set-timeout _, options.update-delay)
    living-sockets.for-each (->it?.send json-data)

  # fix Este to catch the error
  dir-change = este.on-dir-change
  este
    ..on-dir-change = ->
      try
        dir-change.apply @, &
      catch e
        normal-log 'Exception'.red, e
    ..start!

  # Create server
  server =

  # head of middleware conf
    * null

  # logger 
      options.verbose and connect.logger ([
          ":prefix :remote-addr :method"
          '":url HTTP/:http-version"'
          ":status :referrer :user-agent"
      ] * ' ')


  # script injectors (array)
      create-strans root, options.inject

  # static server
      options.list-directory and
        connect.directory root, icons:true

      connect.static root

  # process
    |> flatten
    |> (.filter Boolean)
    |> create-connect-stack
    |> connect! .use
    |> http.create-server

  server
    ..listen options.port
    ..add-listener \upgrade, (req, s, head)->
      return unless WebSocket.isWebSocket req

      addr = "#{s.remote-address}:#{s.remote-port}"

      living-sockets.push <|
      ws = new WebSocket req, s, head
      .on \open, ->
        verb-log \websocket, addr, "-", "new connection"

        @send JSON.stringify do
          {type:\open, -client}

      .on \message, ({data})->
        verb-log \websocket, addr, "-", "received message", data
        options.onmessage data, ws

      .on \close, ->
        verb-log \websocket, addr, "-", "connection closed"

        living-sockets .= filter (isnt ws)


  # started (logged)
  root-path = path.resolve options.root

  log "Simple Autoreload Server started at",
    ":#{options.port.to-string!green}"
  log "on #{root-path.to-string!green}"

  # store options
  server.options = options

  # call next chain
  listen-done server

  # and return
  server


*/
