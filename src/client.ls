
class AutoreloadClient
  @get-default-option = ->
    {
      -log, -expose, -keepalive, +override-option, +dispatch-event
      timestamp: '_tsAccessed'
      location:  window.location
    }
      ..scan =
        * * <[ link ]> <[ href ]> <[ update ]>
          * <[ audio img video embed object ]> <[ src ]> <[ update ]>
          * <[ script ]> <[ src ]>  <[ replace ]>
        |> ->
          [ {tag,attribute,method}  for it
                                    for tag       in ..0
                                    for attribute in ..1
                                    for method    in ..2 ]

  import {
    WebSocket:   window.WebSocket   or window.MozWebSocket
    URL:         (window.URL?::? and "href" in window.URL:: and window.URL) or class
      (uri,base)->
        newBase       = document.createElement \base
        newBase.href  = base
        document.head
          ..insertBefore newBase, ..firstChild

        link      = document.createElement \a
        link.href = uri

        for <[ origin protocol username password host
               hostname port pathname search hash href ]>
          @[..] = if link[..]? then link[..].toString! else ''

        newBase.parentNode.removeChild newBase

      toString: -> @href
      href:~
        ->
          password = "#{@password? and ":#{@password}" or ''}"
          auth     = "#{@username and "#{@username}#{password}@" or ''}"
          "#{@protocol}//#{auth}#{@host}#{@pathname}#{@search}#{@hash}"
        (x)-> #do nothing

    CustomEvent: window.CustomEvent or class extends window.Event
      ( ename, {bubbles=no,cancelable=no,detail}={-bubbles,-cancelable})->
        document.createEvent \CustomEvent
          ..initCustomEvent ename, bubbles, cancelable, detail
          return ..
  }

  @dispatcher = (command,handler,data)-->
    @log "#{command}"

    if @options.dispatch-event
      event-detail = {cancelable:yes, detail: {} <<< data <<< {client:@}}
      new @@CustomEvent "#{@@name}.#{command}", event-detail
        return if not window.dispatchEvent ..

    handler.call @, data

  (@options=@@get-default-option!)->
    window.addEventListener \unload, @~on-dispose

  log: (...args)->
    return if not @options.log
    console.debug.apply console, ["AutoreloadClient:"] ++ args

  resolve: -> new (@@URL) it, document.baseURI
  url-matches: (a,b)-> <[
      origin protocol username password
      host hostname port pathname
    ]>.every (->a[it] is b[it])

  add-scan: ({tag,attribute,method='update',filter=->true})->
    | &.length > 1 => @add-scan {tag:&0,attribute:&1,method:&2,filter:&3}
    | not (tag? and attr?) => false
    | _ => @options.scan.push {tag,attribute,method,filter}

  remove-scan: (tag,attribute,method=null)->
    @options.scan .= filter ->
      for key, val of {tag,attribute}
        return true if it[key] isnt val
      return (method? and (it.method isnt method))

  post-message: (type,data)->
    | typeof type isnt \string => @on-message ...
    | _ => @on-message ({type} <<< data)
  connect: -> @post-message {type:'connect'}
  close:   -> @post-message {type:'close'}

  /* events */
  on-connect: @dispatcher \connect, ->
    @options.location
      @websocket = new @@WebSocket "ws://#{..host}#{..pathname}"
        ..onmessage = @~on-message . JSON~parse . (.data)
        ..onclose   = @~on-close

  on-scan: @dispatcher \scan, (data)->
    for data.scan
      continue if typeof ..tag isnt \string or
                  typeof ..attribute isnt \string

      method = @@Manipulator[..method]? and @@Manipulator~[..method] or ..method
      continue if typeof method isnt \function

      (target,attribute,value)<~ @@Manipulator.find ..tag, ..attribute
      {} <<< data <<< {target-url:(@resolve value),target,attribute,value,method}
        switch | not @url-matches ..target-url, ..url => return target
               | data.reload => @on-reload  ..
               | _           => @on-refresh ..

  on-close: @dispatcher \close, ->
    @websocket?.close!
    if not @disposed and @options.keepalive
      @connect!

  on-open:  @dispatcher \open, (data)->
    if @options.override-option
      @options <<< data.options

    # expose
    if name = @options.expose
      if typeof name isnt 'string'
        name = @@display-name
      window[name] = @
      @log "#{@@display-name} instance exposed as window['#{name}']"

  on-message: @dispatcher \message, (data)->
    handler = data.type.replace /^./ , (.toUpperCase!)
    if data.path? => data.url = @resolve that
    (@."on#{handler}") ({} <<< data <<< {
      location: @resolve @options.location
      url:      data.path and (@resolve data.path) or null
    })

  on-refresh: @dispatcher \refresh, (data)->
    new-url = @resolve data.target-url.href


    # url.search-params.set @options.ts-key, Date.now!
    @@QueryString.parse new-url.search
      ..[@options.timestamp] = Date.now!
      new-url.search = "?#{@@QueryString.stringify ..}"

    data.method data.target, data.attribute, new-url.href

  on-reload: @dispatcher \reload, (data)->
    | not data.reload => @on-refresh data
    | _ => @on-dispose!; window.location.reload!

  on-update: @dispatcher \update, (data)->
    {} <<< data <<< {url:@resolve data.path,method:->}
      if @url-matches ..location, ..url
        @on-reload ({} <<< .. <<< {reload:yes,self:yes})
      else
        @on-scan ({} <<< .. <<< {scan: @options.scan.map (->{} <<< it)})

  # no-dispatch
  on-dispose: ->
    @disposed = yes
    @websocket?.close!

  /* utils */
  @QueryString = class LazyQueryString
    is-array = (instanceof Array)

    @parse = (qs='')->
      qs .= search if typeof qs isnt "string"
      object = {}
      for ((qs ? '') is /^\?*([^#]*)$/).1 / '&'
        [,key,,value] = .. is /^([^=]*)(=(.*))?$/
        object[key] = match object[key]
          | (->not it?) => value
          | is-array    => that ++ value
          | _           => [that]
      object

    @stringify = (queryobject={})->
      (* '&') <| for key, val of queryobject => switch
        | not key      => continue
        | not val?     => "#{key}"
        | is-array val => val.map (->"#{key}=#{it}") |> (* '&')
        | _            => "#{key}=#{val}"

  @Manipulator = class Manipulator
    @find = (tag,attribute,functor=(->))->
      for document.getElementsByTagName tag
        if (..getAttribute attribute)?
          functor .., attribute, that

    @move = (src,dest=document.createElement src.tagName)->
      for src.attributes => dest.setAttribute ..nodeName, ..nodeValue
      for src.childNodes => dest.appendChild src.childNodes.firstChild
      dest

    @update = (element,name,value)->
      element.setAttribute name, value
      element

    @replace = (target,name,value)->
      copied = @move target, null
      @update copied, name, value

      target
        ..parentNode.insertBefore copied, ..
        ..parentNode.removeChild ..

/* main */
new AutoreloadClient null .connect!

