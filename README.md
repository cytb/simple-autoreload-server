simple-autoreload-server [![Build Status](https://travis-ci.org/cytb/simple-autoreload-server.png?branch=master)](https://travis-ci.org/cytb/simple-autoreload-server)
========================

A simple Web server on Node.js with autoreload/livereload feature.
  - Reload statically on update the html files
  - Refresh dynamically on update the files like css, js, png, and etc.
  - No browser extensions are needed. (uses only WebSocket.)
  - Broadcast handleable event on client side window.

Usage
----
  1. Install simple-autoreload-server via npm.

     (e.g. npm install simple-autoreload-server)

  2. Start autoreload-server from command line.

     (e.g. autoreload-server -d ./ -p 8080)

  3. Open server url with your browser.

     (e.g. iexplore http://localhost:8080/)

Installation
--------------
install this package via 'npm'.

```sh
npm install simple-autoreload-server
```

Command Line Usage
----
```sh
autoreload-server [options] [root-dir] [port]
```

### Example

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

### Options

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
`--watch-delay` | `20` | _delay time to supress duplicate watch event (ms)._
`--log, -v` | `normal` | _set log-level_
`--builtin-script` | `true` | _enable default built-in script injection._
`--client-module` | `true` | _expose client module to 'window' object._
`--client-log` | `false` | _inform client to log._
`--recursive, -R` | `true` | _watch sub-directories recursively._
`--follow-symlinks, -L` | `false` | _follow symbolic-links. (requires 'recursive' option)_
`--inject.content, -I` | `` | _injects specified content._
`--inject.type, -T` | `file` | _type of "inject.content"._
`--inject.which, -F` | `**/**.{htm,html}` | _specify pattern for injection target._
`--inject.where, -P` | `</(body|head|html)>` | _specify regex string where to inject._
`--inject.prepend, -E` | `false` | _insert content before matched._
`--help, -h` | `false` | _show help_
`--version, -V` | `false` | _show version_


See [Options.md](./Options.md) for details.

Client Module Usage
----
***note: available only for the web page injected the built-in script module.***

Client module will be exposed as window.AutoreloadClient (default).

and the module emits some events. set listener to window object to handle events.

e.g.

  window.addEventListener("AutoreloadClient.update", function(ev){...});


Currently, following events are handleable on client side.

event   | desc
:---    |:---
update  | file update detected
refresh | refresh request.
reload  | reload request.
scan    | before dom element scanning.
open    | connected.
close   | disconnected.
message | received a message above.

(server will send 'update' events only the file matched to 'watch' option.)

Some of events emit another events. (chained)

event   | emits
:---    |:---
message | (any events by server response)
update  | scan
scan    | refresh, reload
reload  | refresh (on failed or canceled)

internal operation and chain of event emission are cancelable by using "event.preventDefault()".

event listeners will receive an event object with 'detail' key.
and the 'detail' object has some of parameters below.

key       | desc
:---      |:---
client    | client module instance.
path      | path of file updated.
url       | url of file updated.
type      | original message type from server.
scan      | scan target list.
reload    | reload or not. (on reload event, set false to switch 'refresh')
target    | dom object of refresh target.
targetUrl | url of refresh target. (url which contained as dom attribute)

and the contents of './examples' may be a useful reference for usage of client module.
or see '[src/client.ls](./src/client.ls)' for more information.

Version
----
0.1.7

License
----
MIT

[simple-autoreload-server]:https://github.com/cytb/simple-autoreload-server

