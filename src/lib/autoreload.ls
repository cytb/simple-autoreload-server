
require! {
  http
  connect
  colors
  path
  child_process
  \./utils
  \./watch
}

static-transform = require \connect-static-transform
WebSocket = require \faye-websocket
m-options = require \./options

def-options = m-options.default-module-options

# utils
{flatten,regex-clone,new-copy,get-logger,create-connect-stack} = utils

module.exports = (options)->
  ars-obj = new SimpleAutoreloadServer options
    ..init!
    ..start!

# Main class
class SimpleAutoreloadServer
  open-default = (arg)->
    {platform} = process
    open = switch
    | platform == /^dar/ => 'open'
    | platform == /^win/ => 'start ""'
    | otherwise => 'xdg-open'

    child = child_process.exec "#{open} '#{arg}'", {stdio: \ignore}
    child.unref!

  get-tagged-logger = (color,prefix="")->
    (tag,...texts)->
        @log-impl.apply @, ( ["#{prefix}#{tag}"[color]] ++ texts )

  (options={})->
    @living-sockets = []

    @log-impl = get-logger ~>
      @@log-prefix "localhost:#{@options.port}"

    @normal-log = get-tagged-logger 'green'
    @error-log  = get-tagged-logger 'red', 'error@'
    @verb-log   = (->)

    @set-options options
    @running = false

  set-options: (options-arg={})->
    options = new-copy options-arg, def-options

    # check onmessage
    if \function isnt typeof options.onmessage
      options.onmessage = (->)

    # set logger state
    if options.verbose
      @verb-log = @normal-log

    @options = options


  stop: ->
    try
      @watcher?.stop!
      @server?.close!

      @running = false
      @normal-log "server", "stopped."
    catch e
      @error-log "server", e.message

  start: ->
    try
      @stop! if @running
      @watcher.start!
    catch e
      @error-log "server", e.message


    port = @options.port
    root = @options.root

    s-port = port.to-string!green
    s-root = root.to-string!green

    @server
      .on \upgrade, @create-upgrade-listerner!
      .on \error, (err)~>
        if err.code is \EADDRINUSE
          @error-log \server,
            "Cannot use :#s-port as a listen address.",
            "Error:", err.message

          @watcher.stop!

      .listen port, ~>
        @running = true
        @normal-log "server", "started on :#s-port at #root"

        if @options.execute?
          @verb-log "server", "execute command: #{that}"
          child = child_process.exec that, {stdio: \ignore}
          child.unref!

          if @options.stop-on-exit
            @verb-log "server", "server will stop when the command has exit."
            child.on \exit, ~>
              @normal-log "server", "child command has finished."
              @stop!

        if @options.browse
          {port,address} = @server.address!

          if address is "0.0.0.0"
            address = "localhost"

          server-url = "http://#{address}:#{port}/"
          @verb-log "server", "open #server-url"
          open-default server-url

  init: ->
    @watcher = @create-watcher!
    @server  = @create-server!

  create-upgrade-listerner: ->
    return (req, sock, head)~>
      return unless WebSocket.is-web-socket req

      addr = "#{sock.remote-address}:#{sock.remote-port}"
      verb-log-ws = (~>@verb-log \websocket, addr, "-", it)

      websock = new WebSocket req, sock, head

      websock
      .on \open, ~>
        verb-log-ws "new connection"
        websock.send JSON.stringify {type:\open, -client, log:@options.client-log}

      .on \message, ({data})~>
        verb-log-ws "received message", data
        @options.onmessage data, websock

      .on \close, ~>
        verb-log-ws "connection closed"
        @living-sockets .= filter (isnt websock)
      |> @living-sockets.push

  # Create watch
  create-watcher: ->

    # show notes
    if @options.recursive
      @verb-log "server", "init with recursive-option. this may take a while."

    root     = @options.root
    self     = this

    do-reload = @@@create-reload-matcher @options.force-reload

    # Watch
    watch-obj = watch do
      root:           root
      delay:          @options.watch-delay
      recursive:      @options.recursive
      follow-symlink: @options.follow-symlink
      on-error:(error,dir-path)->
        self.error-log "watch", dir-path, "Error:", error.message

      on-change:(ev,source-path)->
        matcher = ->
          typeof! it is \RegExp and it.test source-path

        unless flatten [ self.options.watch ] .some matcher
        then
          self.verb-log "watch", "(ignored)".cyan, source-path
          return

        self.normal-log "watch", "updated", source-path

        http-path = (do
          try
            relative-path = path.relative root, source-path

            # returning '' if it is outer
            relative-path isnt /^\// and "/#relative-path" or ''
          catch
             ''
        )

        self.broadcast do
          type:\update
          path:http-path
          force-reload: do-reload http-path

    # fix Este to catch the error
    watch-obj

  # Creating httpd-server
  create-server: ->
    root = path.resolve @options.root

    server =
      # head of middleware conf
      * null

      # logger 
        @options.verbose and connect.logger ([
            ":ar-prefix :remote-addr :method"
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

  @log-prefix = (host)->
    pid  = process.pid
    # root = @options.root
    "[autoreload \##pid #host]".cyan

  @apply-rec = (obj,func)->
    match typeof! obj
    | \Array => flatten obj .map func
    | _      => [func obj]

  # static methods
  # create static-transform
  @create-strans = (root,option-arg)->
    (option)<- @apply-rec option-arg
    match typeof! option
      | \Function =>
        static-transform do
          root: root
          match: /^/ig
          transform: (file-path, data, send)->
            send <| option file-path, data
      | \Object =>
        optm = new-copy def-options.inject, option
        index-of = if optm.prepend then (-> 0) else (.length)

        static-transform do
          root:root
          match:optm.file
          transform: (file-path, text, send)->
            m = (optm.match.exec text) ? {0:text, index:0}
            i = m.index + index-of m.0
            S = text~slice
            send "#{S 0,i}#{option.code}#{S i}"
      | _ => throw new Error "Unacceptable object: #option"

  # static methods
  # create static-transform
  @create-reload-matcher = (option-arg)->
    if typeof option-arg is \boolean
      return ->option-arg

    array = @apply-rec option-arg, (option)->
      match typeof! option
        | \Function => option
        | \RegExp   => option~test
        | \String   => (-> option.index-of it >= 0)
        | _ => throw new Error 'Unacceptable object: #option'

    # matcher
    (file-path)-> array.some (->it file-path)


connect.logger.token \ar-prefix, (r)~>
  SimpleAutoreloadServer.log-prefix r.headers.host
  |> (+ " httpd".green)

