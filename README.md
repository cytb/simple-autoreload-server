simple-autoreload-server [![Build Status](https://travis-ci.org/cytb/simple-autoreload-server.png?branch=master)](https://travis-ci.org/cytb/simple-autoreload-server)
========================

A simple Web server on Node.js with Live/Autoreload feature.
  - Reload statically on update the html files
  - Refresh dynamically on update the files like css, js, png, and etc.
  - No browser extensions (but the WebSocket) are needed. 

Command Line Usage
----
```sh
autoreload-server [options] [root-dir] [port]
```

Command Line Options
----

option | default | description
:--- | :--- | :---
`--root, -d <param>` | `.` | _set base directory to publish._
`--port, -p <param>` | `8080` | _set port to listen (http)._
`--list-directory, -l` | `true` | _enable directory listing._
`--watch, -w <param>` | `/^/` | _regex pattern of file to watch._
`--watch-delay <param>` | `1` | _time to delay before fireing watch event (in ms)._
`--verbose, -v` | `false` | _enable verbose log._
`--recursive, -r` | `true` | _watch directory recursively. (may take a while at startup)_
`--force-reload, -f <param>` |  | _regex pattern for file forced to reload page._
`--broadcast-delay <param>` | `0` | _time to delay before broadcasting file update event (in ms)._
`--no-default-script` | `false` | _disable injection of default client script._
`--inject-file, -I <param>` |  | _set path to additional file to be injected._
`--inject-method, -M <param>` | `p` | _specify the method [prepend or append]_
`--inject-match-text, -T <param>` |  | _specify the pattern where to inject_
`--inject-match-file, -F <param>` |  | _specify the pattern for file to inject_
`--version, -V` |  | _show version_
`--help, -h` |  | _show help_



#### Example

```sh
autoreload-server -w "\\.(html|css|js)" ./site-files 8008
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

#### Options

See 'src/lib/options.ls' for details of options.


Version
----
0.0.9

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




