require! {fs, path}

code-path = path.resolve do
  __dirname, \../lib/client.js

default-injection-code =
  fs.read-file-sync code-path, \UTF-8

export {
  # httpd-port to listen
  port: 8080

  # base directory for httpd
  root: process.cwd!

  # use httpd directory listing or not
  -list-directory

  # verbose log
  -verbose

  # The pattern of the file name to watch (regex)
  watch: /^/

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

