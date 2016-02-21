simple-autoreload-server [![Build Status](https://travis-ci.org/cytb/simple-autoreload-server.png?branch=master)](https://travis-ci.org/cytb/simple-autoreload-server)
========================

A simple Web server on Node.js with Live/Autoreload feature.
  - Reload statically on update the html files
  - Refresh dynamically on update the files like css, js, png, and etc.
  - No browser extensions are needed. (uses only WebSocket.)

Usage
----
  1. Install simple-autoreload-server via npm.
     (e.g. npm install simple-autoreload-server)

  2. Start autoreload-server from command line.
     (e.g. autoreload-server -d ./ -p 8080)

  3. Open server url with your browser.
     (e.g. iexplore http://localhost:8080/)

Command Line Usage
----
```sh
autoreload-server [options] [root-dir] [port]
```

Command Line Options
----

option | default | description
:--- | :--- | :---
`--path, -d` | `.` | _set directory to publish._
`--watch, -w` | `**` | _pattern for file to watch._
`--reload, -R` | `false` | _pattern for file to reload the whole page._
`--mount.path, -m` | `.` | _set additional directory to publish._
`--mount.target` | `/` | _server path as route target._
`--mount.watch` | `**` | _pattern for file to watch._
`--host, -H` | `0.0.0.0` | _set host address to publish._
`--port, -p` | `8080` | _set port to listen (http)._
`--config, -C` | `.autoreload.json` | _load json as config._
`--list-directory, -l` | `true` | _enable directory listing._
`--browse, -b` | `false` | _open server url by platform default program._
`--execute, -e` | `` | _execute command when the server has prepared._
`--stop-on-exit` | `false` | _exit when invoked process specified by "--execute" died._
`--ignore-case, -i` | `true` | _ignore case of glob patterns._
`--watch-delay` | `1` | _delay time to supress duplicated watch event (in ms)._
`--verbose, -v` | `false` | _enable verbose logging._
`--builtin-script` | `true` | _enable default built-in script injection._
`--client-module` | `true` | _expose client module to 'window' object.  (unimplemented!)_
`--client-log` | `false` | _inform client to log._
`--recursive, -r` | `true` | _watch sub-directories recursively. (may take a while at startup)_
`--follow-symlinks, -l` | `false` | _follow symbolic-links. (it affects only when the resursive option specified.)_
`--broadcast-delay` | `0` | _delay time of broadcasting event (in ms)._
`--inject.content` | `` | _injects specified content._
`--inject.type` | `file` | _type of "inject.content"._
`--inject.which` | `**/*.{php,htm,html,cgi,pl,rb}` | _specify regex pattern for injection target._
`--inject.where` | `</(body|head|html)>` | _specify regex string where to inject._
`--inject.prepend` | `true` | _injection method. ('prepend' or 'append')_
`--help, -h` | `false` | _show help_
`--version, -V` | `false` | _show version_



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
  path: './',
  listDirectory: true,
  watch:  "*.{png,js,html,json,swf}"
  reload: "{*.json,static.swf}"
});
```

#### Options

See 'src/lib/option-list.ls' for details of options.


Version
----
0.0.22-0

Installation
--------------
install this package via 'npm'.

```sh
npm install simple-autoreload-server
```

License
----
MIT

[simple-autoreload-server]:https://github.com/cytb/simple-autoreload-server

