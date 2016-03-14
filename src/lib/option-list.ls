export
  options:
    * * "label": "path"
        "short": "d"
        "type":  "string"
        "def":   "."
        "help":  "set directory to publish."
        "desc":  """
          specifies root directory to publish.
        """

      * "label": "watch"
        "short": "w"
        "type":  "pattern"
        "def":   "**/**"
        "help":  "pattern for file to watch."
        "desc":  """
          pattern for file to watch.
          if true, it matches any files, and matches nothing on false.
        """

      * "label": "reload"
        "short": "r"
        "type":  "pattern"
        "def":   false
        "help":  "pattern for file to reload the whole page."
        "desc":  """
          pattern for file to reload the whole page.
          whether or not to reload actually is depends on behavior of client script.
          if true, it matches any files, and matches nothing on false.
        """

      * "label": "mount.path"
        "short": "m"
        "type":  "string"
        "def":   "."
        "help":  "set additional directory to publish."
        "desc":  """
          specifies additional directory to publish.

          program can accept multiple times in commandline.
          other 'mount.*' options are attached to corresponding path by order in commandline.
        """
        "examples":
          * * "command": "autoreload -H localhost -p 8080 -m ./html -m ./node_modules --mount.path ./build"
              "result" : """
                the server publishes content of './html', './node_modules' and './build' at 'https://localhost:8080/'.
                if all of those directories contain 'index.html' and client requests 'https://localhost:8080/index.html',
                the first one will be sent ('./html/index.html' in this case).
              """

      * "label": "mount.target"
        "short": "t"
        "type":  "string"
        "def":   "/"
        "help":  "server side path of mounted direcory"
        "desc":  """
          server side path of mounted direcory.
        """
        "examples":
          * * "command": "autoreload . 8080 -m ./www/js -t /components"
              "result" : """
                the server publishes content of './' to server-root(http://localhost:8080/),
                "./www/js" to "/components" (http://localhost:8080/components/).
              """

      * "label": "mount.watch"
        "short": "W"
        "type":  "pattern"
        "def":   "**/**"
        "help":  "pattern of file to watch."
        "desc":  """
          pattern of file to watch.
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
        "short": "c"
        "type":  "string"
        "def":   ".autoreload.json"
        "help":  "load options from json."
        "desc":  """
          load json as config before starting server.
          the config overwritten by command-line options and function arguments.
          all of specified pathes regarded as relative path from config location.
          (function arguments, and command-line parameters as well.)

          the server logs nothing when the default config does not exist.
        """

      * "label": "search-config"
        "short": null
        "type":  "boolean"
        "def":   true
        "help":  "search for config json in parent directories."
        "desc":  """
          search for config file in parent directories.
          it is no harm when specified absolute path.
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

          if provided true via function argument 
          or '--browse' option followed by nothing via command-line, 
          the program invokes the default with the server url.

          if the 'String' value was specified, it will be passed instead of the server url.
          the server does nothing if specified Boolean of 'false' or 'null'.
        """
        "examples":
          * * "command": "autoreload -d . -p 8088 -H 192.168.1.15 -b"
              "result":  "opens https://192.168.1.15:8088/"
            * "command": 'autoreload -d . -p 8088 -b "http://server1.localdomain:80/"'
              "result":  'opens "http://server1.localdomain:80/"'

      * "label": "execute"
        "short": "e"
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
        "short": "k"
        "type":  "boolean"
        "def":   false
        "help":  "exit when invoked process specified by \"execute\" died."
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

          this option is no harm to regex pattern of 'pattern' type.
          all of the glob patterns that were passed as 'String' type
          via function arguments or command-line option will be affected.
        """

      * "label": "include-hidden"
        "short": "n"
        "type":  "boolean"
        "def":   false
        "help":  "glob includes hidden files."
        "desc":  """
          make globs to include hidden (dot) files.
          this option is no harm except for glob string patterns.
        """

      * "label": "default-pages"
        "short": null
        "type":  "pattern"
        "def":   "index.{htm,html}"
        "help":  "default page file pattern for directory request."
        "desc":  """
          default page file pattern for directory request.
        """

      * "label": "encoding"
        "short": null
        "type":  "string"
        "def":   "utf-8"
        "help":  "encoding for reading texts and inject target files"
        "desc":  """
          encoding for reading texts and inject target files
        """

      * "label": "watch-delay"
        "short": null
        "type":  "number"
        "def":   20ms
        "help":  "delay time to supress duplicate watch event (ms)."
        "desc":  """
          delay time to supress duplicate watch event (in milil-seconds).
          the watch event is often fired multiple times in short duration.
        """

      * "label": "log"
        "short": "v"
        "type":  "string"
        "def":   "normal"
        "help":  "set log-level"
        "desc":  """
          set log mode. choose from followings.
          'silent' -> 'minimum' -> 'normal' -> 'verbose' -> 'noisy'
          (number also acceptable: silent is 0, minimum is 1, ..., and noisy is 4)
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
        "help":  "expose client module to 'window' object."
        "desc":  """
          expose client side built-in module to 'window' object.
          if you want to use client module in built-in script, set true or String value.

          If true,   module will be exposed to 'window.AutoreloadClient'.
          If String, module will be exposed in window with specified name.

          This option does nothing when 'builtin-script' is false.
          when the module is initialized, it emits the 'AutoreloadClient.*' events on 'window'.
          see 'examples'.
        """

      * "label": "client-log"
        "short": null
        "type":  "boolean"
        "def":   false
        "help":  "inform client to log."
        "desc":  """
          inform client to log.
          the server only send a option to client on connect by this option.
          whether or not to logs actually is depends on behavior of client script.
        """

      * "label": "recursive"
        "short": "R"
        "type":  "boolean"
        "def":   true
        "help":  "watch sub-directories recursively."
        "desc":  """
          watch sub-directories recursively. this may take a while at startup.
          the server does not detect cyclic structure and it may cause infinit loop.
          unset follow-symlinks option if need.
        """

      * "label": "follow-symlinks"
        "short": "L"
        "type":  "boolean"
        "def":   false
        "help":  "follow symbolic-links. (requires 'recursive' option)"
        "desc":  """
          lookup files in symbolic-links target when watch directory. 
          this option affects only when the resursive option is enabled.
        """

      * "label": "inject.content"
        "short": "I"
        "type":  "string"
        "def":   ""
        "help":  "injects specified content."
        "desc":  """
          injects specified content. see also: 'inject.type'.
          if no inject.content options are provided,
          and the file '.autoreload.html' exists in current directory
          (or config json directory), server try to inject as a builtin-script.
        """

      * "label": "inject.type"
        "short": "T"
        "type":  "string"
        "def":   "file"
        "help":  'type of "inject.content".'
        "desc":  """
          specifies type of 'inject.content' option.
          'file': treat 'inject.content' as file path.
          'raw':  'inject.content' will be injected directly.
        """

      * "label": "inject.which"
        "short": "F"
        "type":  "pattern"
        "def":   "**/**.{htm,html}"
        "help":  "specify pattern for injection target."
        "desc":  """
          specify pattern for injection target.
        """

      * "label": "inject.where"
        "short": "P"
        "type":  "string"
        "def":   "</(body|head|html)>"
        "help":  "specify regex string where to inject."
        "desc":  """
          this is not a 'pattern' type.
          specify regex string where to inject.
          content will be injected before matched string.
        """

      * "label": "inject.prepend"
        "short": "E"
        "type":  "boolean"
        "def":   false
        "help":  "insert content before matched."
        "desc":  """
          change injection method to 'prepend'.
          if true, content will be injected 'before' matched string.
        """

      * "label": "help"
        "short": "h"
        "type":  "boolean"
        "def":   false
        "help":  "show help"
        "desc":  """
          show help and exit.
          ignored if it was appeared on json or function arguments.
        """

      * "label": "version"
        "short": "V"
        "type":  "boolean"
        "def":   false
        "help":  "show version"
        "desc":  """
          shows version.
          ignored if it was appeared on json or function arguments.
        """

      * "label": "onmessage"
        "short": null
        "type":  "function"
        "def":   null
        "help":  "onmessage event handler."
        "desc":  """
          specifies server onmessage handler.
          server calls this function on broadcast the message.
        """
        "nocli": true

      * "label": "connect-app"
        "short": null
        "type":  "object"
        "def":   null
        "help":  "specify 'connect' app object as server base."
        "desc":  """
          specifies 'connect' app object as server base.
          server middleware layers willbe stacked to this object.
        """
        "nocli": true


