
(->
  flatten = ([...array])->
    array.reduce ((p,n)->
      p ++ ((typeof! n is \Array and flatten n) or [n])
    ), []

  # Code injected by auoreload-server
  dom-any = ->
     (document.getElementsByTagName it).0

  dom-insert = (target,tag)->
    target.appendChild <|
      document.createElement tag

  dom-remove = ->
    it.parentNode.removeChild it

  dom-move-to-new = (target)->
    elem = document.create-element do
      target.tag-name.to-lower-case!

    for {node-value,node-name} in target.attributes
      elem.set-attribute node-name, node-value

    for node in target.child-nodes
      elem.append-child node

    elem

  resolve-path-by-dom = (base-dir,url)->
    anchor-resolve = ->
      resolver = document.createElement \a
      resolver.href = it
      resolver.href # browser magic at work here

    # from http://jsfiddle.net/ecmanaut/RHdnZ/
    resolve-inner = (base-elem,base-path,url)->
      genuine-base = base-elem.href

      base-elem.href = base-path
      resolved = anchor-resolve url
      base-elem.href = genuine-base

      resolved

    base = dom-any \base
    resolve-base = base or dom-insert do
      document.head or dom-any \head
      \base

    resolved = resolve-inner resolve-base, base-dir,url

    base? and (dom-remove resolve-base)
    resolved

  class Path
    pre-string = (str,pattern)->
      if pattern.exec str
        then str.slice 0,that.index else str

    dir-path = (pre-string _, /\/[^/]+\/?$/)
    base-dir-path = -> (pre-string it, /\/[^/]*$/) + '/'

    abs-path = (it)->
      base-dir = (dom-any \base)?.href or
        base-dir-path location.pathname

      resolve-path-by-dom base-dir, it

    (src) ->
      if @@@ isnt Path
        return src and new Path src

      @source = src
      @rel-path = pre-string src, /(\?|#)(.*)$/

      @abs-path = abs-path @rel-path
      @abs-dir  = dir-path @abs-path
      @is-dir   = @abs-path is /\/$/

      @hash         = (src is /\#(.*)$/)?.1 ? ''
      @query-string = (src is /\?([^#]*)/)?.1 ? ''
      @params = {}

      for P in @query-string / '&'
        when P is /([^=]+)(?:=(.*))?$/
          @params[ that.1 ] = that.2

    includes: (rhs)->
      | not rhs?  => false
      | rhs@@ isnt @@@ => @includes (new Path rhs)
      | @is-dir    => @abs-path |> (rhs.abs-path.index-of _ is 0)
      | otherwise  => @abs-path |> (rhs.abs-path is)

    to-query-string: ->
      (for k,v of @params => "#k=#{v ? ''}") * '&'

    toString: ->
      qs   = if @to-query-string! then "?#{that}" else ''
      hash = if @hash then '#' + that else ''

      "#{@rel-path}#{qs}#{hash}"

  on-update = (data)->
    ts-key = '_tsAccessed'

    P = Path data.path

    tags = (...names)->
      flatten names
      .map (->[].slice.call document.getElementsByTagName it)
      |> flatten

    get-related-elems = (tag-names,attrs)->
      list = [{
        elem: elem
        attr: attr
        path: Path elem.getAttribute attr
        set: (elem.setAttribute attr, _)
      } for elem in tags tag-names
        for attr in attrs ]
      .filter ({path})-> P.includes path

      if 0 < list.length and data.force-reload
        location.reload!
        return []
      list

    do-common-setter = (text,path,set)->
      console.debug text, path.to-string!
      path.params[ts-key] = Date.now!
      set path.to-string!

    do-refresh-all = (tag-names,...attrs)->
      for {path,set} in get-related-elems tag-names, attrs
        do-common-setter "refresh", path, set

    do-reinsert-all = (tag-names,...attrs)->
      for {elem,attr,path} in get-related-elems tag-names, attrs
        new-one = dom-move-to-new elem
        set = (new-one.set-attribute attr, _)

        do-common-setter "reinsert", path, set
        elem.parent-node
          ..insert-before new-one, elem
          ..remove-child  elem

    if Path location.pathname .abs-path is P.abs-path
      location.reload!

    do-refresh-all  <[ link ]>, \href
    do-refresh-all  <[ audio img video embed object ]>, \src
    do-reinsert-all <[ script ]>, \src

  WebS = WebSocket ? MozWebSocket ? (->
    throw new Error 'Autoreload Client - WebSocket is not available on this browser.'
  )

  L = window.location

  # ssl = (L.protocol is /(s?)(\:)?$/)?.1 ? ''
  # new WebSocket "ws#{ssl}://#{L.host}#{L.pathname}/ws"

  new WebS "ws://#{L.host}#{L.pathname}/ws"
    ..onopen = ->
      console.log 'Autoreload Client - connected to server.'

    ..onmessage = ({data}:msg)->
      console.debug 'message from server', data
      data-obj = JSON.parse data
      data-obj and switch data-obj.type
        | \update => on-update data-obj

)!
