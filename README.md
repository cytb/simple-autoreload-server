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

Overview of Command Line Options
----

option | default | help
:--- | :--- | :---
`--path, -d` | `.` | _set directory to publish._
`--watch, -w` | `**/**` | _pattern for file to watch._
`--reload, -r` | `false` | _pattern for file to reload the whole page._
`--mount.path, -m` | `.` | _set additional directory to publish._
`--mount.target, -t` | `/` | _server side path of mounted direcory_
`--mount.watch, -W` | `**/**` | _pattern of file to watch._
`--host, -H` | `0.0.0.0` | _set host address to publish._
`--port, -p` | `8080` | _set port to listen (http)._
`--config, -c` | `.autoreload.json` | _load options from json._
`--search-config` | `true` | _search for config json in parent directories._
`--list-directory, -l` | `true` | _enable directory listing._
`--browse, -b` | `false` | _open server url by platform default program._
`--execute, -e` | `` | _execute command when the server has prepared._
`--stop-on-exit, -k` | `false` | _exit when invoked process specified by "execute" died._
`--ignore-case, -i` | `true` | _ignore case of glob patterns._
`--include-hidden, -n` | `false` | _glob includes hidden files._
`--default-pages` | `index.{htm,html}` | _default page file pattern for directory request._
`--encoding` | `utf-8` | _encoding for reading texts and inject target files_
`--watch-delay` | `20` | _delay time to supress duplicate watch event (in ms)._
`--verbose, -v` | `false` | _enable verbose logging._
`--silent` | `false` | _disable server logging._
`--builtin-script` | `true` | _enable default built-in script injection._
`--client-module` | `true` | _expose client module to 'window' object._
`--client-log` | `false` | _inform client to log._
`--recursive, -R` | `true` | _watch sub-directories recursively. (may take a while at startup)_
`--follow-symlinks, -L` | `false` | _follow symbolic-links. (it affects only when the resursive option specified.)_
`--inject.content, -I` | `` | _injects specified content._
`--inject.type, -T` | `file` | _type of "inject.content"._
`--inject.which, -F` | `**/**.{php,htm,html,cgi,pl,rb}` | _specify pattern for injection target._
`--inject.where, -P` | `</(body|head|html)>` | _specify regex string where to inject._
`--inject.prepend, -E` | `false` | _insert content before matched._
`--help, -h` | `false` | _show help_
`--version, -V` | `false` | _show version_



#### Example

```sh
autoreload-server -w "**/**.{html,css,js}" ./site-files 8008
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

Client Module Usage
----
See examples, and "src/client.ls" for details.

#### Options

See [Options.md](./Options.md) for details.

Version
----
0.1.3

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

