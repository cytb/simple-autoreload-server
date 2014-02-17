simple-autoreload-server
========================

[simple-autoreload-server] is simple live/auto reloading web server on Node.js.
  - Reload statically on update the html files
  - Refresh dynamically on update the files like css, js, png, and etc.
  - No browser extensions (but the WebSocket) are needed. 

Command Line Usage
----
```sh
autoreload [optoins] [root-dir] [port]
```


Command Line Options
----

--root | -d <param>
  set base directory for publish.
  default: .

--port | -p <param>
  set port to listen (http).
  default: 8080

--list-directory | -l
  enable directory listing.
  default: true

--watch | -w <param>
  regex pattern of file to watch.
  default: /^/

--watch-delay <param>
  time to delay before fireing watch event (in ms).
  default: 1

--verbose | -v
  enable verbose log.
  default: false

--force-reload | -r <param>
  regex pattern for file forced to reload page.
  

--broadcast-delay <param>
  time to delay before broadcasting file update event (in ms).
  default: 0

--no-default-script
  disable injection of default client script.
  default: false

--inject-file | -I <param>
  set path to additional file to be injected.
  

--inject-method | -M <param>
  specify the method [prepend or append]
  default: p

--inject-match-text | -T <param>
  specify the pattern where to inject
  

--inject-match-file | -F <param>
  specify the pattern for file to inject
  

--version | -V
  show version
  

--help | -h
  show help
  


#### Example

```sh
autoreload -w "\\.(html|css|js)" ./site-files 8008
```

Module Usage (Example)
----
```
var launcher = require('simple-autoreload-server');

var server = launcher({
  port: 8008,
  root: './',
  listDirectory: true,
  watch: /\.(png|js|html|json|swf)$/i,
  forceReload: [/\.json$/i, "static.swf"]
});
```

#### Option

See 'src/lib/options.ls' for details of options.


Version
----
0.0.7

Installation
--------------
install this package via 'npm'.

```sh
npm install simple-autoreload-server
```

License
----
[MIT License]


[simple-autoreload-server]:https://github.com/cytb/simple-autoreload-server
[MIT License]:http://www.opensource.org/licenses/mit-license.php




