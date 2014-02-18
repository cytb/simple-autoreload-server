require! {
  \./utils
}

default-injection-code =
  utils.load __dirname, \./client.js

export
  generate-minimist-opt: (opt=@commandline-options)->
    output = {boolean:[],string:[],alias:{},default:{}}

    for name, {type=null,short=[],def=null} of opt
      key = type is String and \string or \boolean
      output[key] ++= name

      for sname in ([] ++ short)
        output.alias[sname] = [name]

      if def?
        output.default[name] = def

    output

  generate-commandline-help:->
    for name, opt of @commandline-options

      nshort = opt.short?         and "-#{opt.short}" or []
      param  = opt.type is String and '<param>'       or []

      optnames = [ (['--' + name] ++ nshort) * ', ' ]
      spec = (optnames ++ param) * ' '

      [ spec, opt.desc ] ++ (
        if opt.def? then opt.def else []
      )

  commandline-options:
    root:
      short: \d
      type:  String
      desc:  'set base directory to publish.'
      def: \.

    port:
      short: \p
      type:  String
      desc:  'set port to listen (http).'
      def: 8080

    'list-directory':
      short: \l
      desc:  'enable directory listing.'
      def: true

    watch:
      type:  String
      short: \w
      desc:  'regex pattern of file to watch.'
      def: /^/

    'watch-delay':
      type:  String
      desc:  'time to delay before fireing watch event (in ms).'
      def: 1ms

    verbose:
      short: \v
      desc:  'enable verbose log.'
      def: false

    'force-reload':
      type:  String
      short: \r
      desc:  'regex pattern for file forced to reload page.'
      def: null

    'broadcast-delay':
      type: String
      desc: 'time to delay before broadcasting file update event (in ms).'
      def: 0ms

    'no-default-script':
      desc:  'disable injection of default client script.'
      def:  false

    'inject-file':
      type:  String
      short: \I
      desc:  'set path to additional file to be injected.'
      def: null

    'inject-method':
      type:  String
      short: \M
      desc:  'specify the method [prepend or append]'
      def: \p

    'inject-match-text':
      type:  String
      short: \T
      desc:  'specify the pattern where to inject'
      def: null

    'inject-match-file':
      type:  String
      short: \F
      desc:  'specify the pattern for file to inject'
      def: null

    version:
      short: \V
      desc:  'show version'

    help:
      short: \h
      desc:  'show help'

  default-injection-code: default-injection-code

  default-module-options: {
    port: 8080
    root: process.cwd!
    +list-directory
    -verbose

    # delay time before fireing watch event (num in ms)
    watch-delay: 1ms

    # Pattern of file name(s) to watch (regex or array)
    watch: /^/

    # This function will be switched by option type
    #
    #   [String/Regex/Array]
    #     Pattern of the file name to which is forced to reload
    #
    #   [Boolean]
    #     Always reload the 'page' on any event if true 
    #
    force-reload: false

    # The time to delay before broadcasting the 'update' packet.
    broadcast-delay: 0ms

    # the event listener on received the message which was sent by client.
    onmessage: ((message)->)

    # code injection settings (array or object)
    inject:

      # raw code
      code:  """
        <script type='text/javascript'>
        (function(){#{default-injection-code}})();
        </script>
      """

      # the pattern of the text to where to insert
      match: /<\/(body|head|html)>/i

      # the pattern of the file-name to which to insert
      file:  /(\.(php|html?|cgi|pl|rb))$/i

      # prepend or append when inject the code
      prepend: true
  }

