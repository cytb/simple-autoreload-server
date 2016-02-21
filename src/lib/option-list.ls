export
  options:
    * * "label": "path"
        "short": "d"
        "type":  "string"
        "def":   "."
        "help":  "set directory to publish."
        "desc":  """
          specifies directory to publish.
        """

      * "label": "watch"
        "short": "w"
        "type":  "pattern"
        "def":   "**"
        "help":  "pattern for file to watch."
        "desc":  """
          pattern for the file to watch.

            it matches any files if passed true function argument
          or specified command-line option as flag.

            it matches nothing if passed false via function argument
          or specified command-line option with the negative prefix.
        """

      * "label": "reload"
        "short": "R"
        "type":  "pattern"
        "def":   false
        "help":  "pattern for file to reload the whole page."
        "desc":  """
          pattern for file to reload the whole page.
          it depends on client script whether or not to reload actually.

          it always matches if passed true via function argument
          or specified command-line option as flag.

          it matches nothing if passed false via function argument
          or specified command-line option with negative prefix ('no-').
        """

      * "label": "mount.path"
        "short": "m"
        "type":  "string"
        "def":   "."
        "help":  "set additional directory to publish."
        "desc":  """
          specifies additional directory to publish.

          if Array of values or multiple 'mount.path' option on command-line was passed,
          the server publishes all the specified directories on server-root.
          and then client request will be processed in same order.
        """
        "examples":
          * * "command": "autoreload -H localhost -p 8080 -m ./html -m ./node_modules --mount.path ./build"
              "result" : """
                the server publishes content of './html', './node_modules' and './build' at 'https://localhost:8080/'.
                if all of those directories contain 'index.html' and client requests 'https://localhost:8080/index.html',
                first one will be sent ('./html/index.html' in this case).
              """

      * "label": "mount.target"
        "short": null
        "type":  "string"
        "def":   "/"
        "help":  "server path as route target."
        "desc":  """
          server path as route target.
        """

      * "label": "mount.watch"
        "short": null
        "type":  "pattern"
        "def":   "**"
        "help":  "pattern for file to watch."
        "desc":  """
          pattern for the file to watch.

            it matches any files if passed true function argument
          or specified command-line option as flag.

            it matches nothing if passed false via function argument
          or specified command-line option with the negative prefix.

          if Array of values or multiple 'mount.watch' option on command-line was passed,
          the server associates each options to each 'mount.path' in same order.
        """



      * "label": "host"
        "short": "H"
        "type":  "string"
        "def":   "0.0.0.0"
        "help":  "set host address to publish."
        "desc":  """
          specifies server address to listen.
          '0.0.0.0' means listening all of the (ipv4) interfaces on computer.
        """

      * "label": "port"
        "short": "p"
        "type":  "number"
        "def":   "8080"
        "help":  "set port to listen (http)."
        "desc":  """
          specifies server http(s) port to listen.
        """

      * "label": "config"
        "short": "C"
        "type":  "string"
        "def":   ".autoreload.json"
        "help":  "load json as config."
        "desc":  """
          load options from specific json before starting server.
          these options are overwritten by command-line options and function arguments.

          the server inform when the config does not exist except for default location.
        """

      * "label": "list-directory"
        "short": "l"
        "type":  "boolean"
        "def":   true
        "help":  "enable directory listing."
        "desc":  """
          enable directory listing.
          it should be disabled if you want to invoke default request handler.
        """

      * "label": "browse"
        "short": "b"
        "type":  "string"
        "def":   false
        "help":  "open server url by platform default program."
        "desc":  """
          invokes platform default program with argumemts after launched. 

          if true via function argument, or '--browse' option followed by nothing via command-line, 
          the program invokes the default with the server url.

          if the 'String' value was specified, it will be passed instead of the server url.
          the server does nothing if specified Boolean of 'false' or 'null'.

        """
        "examples":
          * * "command": "autoreload -d . -p 8088 -H 192.168.1.15 -b"
              "result":  "opens https://192.168.1.15:8088/"
            * "command": 'autoreload --no-ssl -d . -p 8088 -b "http://server1.localdomain:80/"'
              "result":  'opens "http://server1.localdomain:80/"'

      * "label": "execute"
        "short": \e
        "type":  "string"
        "def":   ""
        "help":  "execute command when the server has prepared."
        "desc":  """
          executes command when the server has been prepared.
          the command is passed to shell.
          in other words it has not been invoked directly.

          you can pass Array of above values or many times on command-line,
          and then the server invokes with each values.

        """
        "examples":
          * * "command": 'autoreload -e "firefox"'
              "result":  "opens firefox via shell"

      * "label": "stop-on-exit"
        "short": null
        "type":  "boolean"
        "def":   false
        "help":  "exit when invoked process specified by \"--execute\" died."
        "desc":  """
          the server will stop when invoked process specified by 'execute' option died.
          if there are multiple processes invoked by 'execute' option,
          the server keep running until all of that has been killed.
        """

      * "label": "ignore-case"
        "short": "i"
        "type":  "boolean"
        "def":   true
        "help":  "ignore case of glob patterns."
        "desc":  """
          ignoring case of glob-string of patterns.

          this option has no effect on regex pattern of 'pattern' type.

          all of the glob patterns that were passed as 'String' type
          via function arguments or command-line option will be affected.
        """

      * "label": "watch-delay"
        "short": null
        "type":  "number"
        "def":   1ms
        "help":  "delay time to supress duplicated watch event (in ms)."
        "desc":  """
          delay time to supress duplicated watch event.
          the watch event is fired multiple times sometimes.
        """

      * "label": "verbose"
        "short": "v"
        "type":  "boolean"
        "def":   false
        "help":  "enable verbose logging."
        "desc":  """
          enable verbose logging.
        """

      * "label": "builtin-script"
        "short": null
        "type":  "boolean"
        "def":   true
        "help":  "enable default built-in script injection."
        "desc":  """
          enable injection of default built-in script.

          if you want to replace for built-in script by another script,
          specify this option to false or with negative prefix ('no-') without equal,
          and use 'inject' option.
        """

      * "label": "client-module"
        "short": null
        "type":  "string"
        "def":   true
        "help":  "expose client module to 'window' object.  (unimplemented!)"
        "desc":  """
          (unimplemented!)
          expose client module to 'window' object.

          if you want to use client module in built-in script, set true or String value.

          if specified true, module will be exposed to 'window.AutoreloadClient'.
          if String,         module will be exposed in window with specified value.

          this option does nothing when 'builtin-script' is disabled.
          when the module is initialized, it emits the '*.ready' event on 'window'.
          the name of event-id depends on this option. (e.g. default is 'AutoreloadClient.ready')
        """

      * "label": "client-log"
        "short": null
        "type":  "boolean"
        "def":   false
        "help":  "inform client to log."
        "desc":  """
          inform client to log.
          the server only send a option to client on connect by this option.
          it is depends on client script whether or not to logs actually.
        """

      * "label": "recursive"
        "short": "r"
        "type":  "boolean"
        "def":   true
        "help":  "watch sub-directories recursively. (may take a while at startup)"
        "desc":  """
          watch sub-directories recursively.
          it may take a while at startup.

          the server does not detect cyclic structure and it may cause infinit loop.
          unset follow-symlinks option if need.
        """

      * "label": "follow-symlinks"
        "short": "l"
        "type":  "boolean"
        "def":   false
        "help":  "follow symbolic-links. (it affects only when the resursive option specified.)"
        "desc":  """
          lookup files on symbolic-links when watch directory. 
          it affects only when the resursive option specified.
        """

      * "label": "broadcast-delay"
        "short": null
        "type":  "string"
        "def":   0ms
        "help":  "delay time of broadcasting event (in ms)."
        "desc":  """
          delay time of broadcasting event (in ms).
        """


      * "label": "inject.content"
        "short": null
        "type":  "string"
        "def":   ""
        "help":  "injects specified content."
        "desc":  """
          injects specified content.
          the behavior of this option depends on 'inject.raw'.
        """

      * "label": "inject.type"
        "short": null
        "type":  "string"
        "def":   "file"
        "help":  'type of "inject.content".'
        "desc":  """
          specifies type of 'inject.content' option.

          file: treat 'inject.content' as file path.
          raw:  'inject.content' will be injected directly.
        """

      * "label": "inject.which"
        "short": null
        "type":  "pattern"
        "def":   "**/*.{php,htm,html,cgi,pl,rb}"
        "help":  "specify regex pattern for injection target."
        "desc":  """
          injects specified file.
        """

      * "label": "inject.where"
        "short": null
        "type":  "string"
        "def":   "</(body|head|html)>"
        "help":  "specify regex string where to inject."
        "desc":  """
          specify regex string where to inject.
        """

      * "label": "inject.prepend"
        "short": null
        "type":  "string"
        "def":   true
        "help":  "injection method. ('prepend' or 'append')"
        "desc":  """
          specifies injection method.

          'prepend' inserts content before 'where' matched.
          'append'  inserts content after 'where' matched.
        """

      * "label": "help"
        "short": "h"
        "type":  "boolean"
        "def":   false
        "help":  "show help"
        "desc":  """
          shows help and exit.
          ignored if it was apeared on json or function arguments.
        """

      * "label": "version"
        "short": "V"
        "type":  "boolean"
        "def":   false
        "help":  "show version"
        "desc":  """
          shows version.
          ignored if it was apeared on json or function arguments.
        """


