require! {
  \./utils
}

default-injection-code =
  utils.load __dirname, \./client.js

export
  commandline-options:
    root:
      short: \d
      type:  String
      desc:  'set base directory for publish.'
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
      short: \t
      desc:  'time to delay before broadcasting file update event (in ms).'
      def: 0

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

    # The pattern of the file name to watch (regex or array)
    watch: /^/

    # This option is switched by type
    #
    #   [String/Regex/Array]
    #     The pattern of the file name to which is forced to reload
    #
    #   [Boolean]
    #     if true, the page is always reload on any event
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

