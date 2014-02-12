simple-autoreload-server
========================

[simple-autoreload-server] is Node.js based Simple Live/Auto Reloading Web Server
  - Reload statically on update the html files
  - Refresh dynamically on update the files: css, js, png, and etc.
  - Required no browser extensions but need WebSocket.

Command Line Usage
----
```sh
autreload [root-dir [port]]
```
#### Example

```sh
autreload ./site-files 8008
```

Module Usage (Example)
----
```
var launcher = require('simple-autoreload-server');

var server = launcher({
  port: 8008,
  root: './',
  listDirectory: true,
  watch: /.(png|js|html)$/i
  forceReload: [/.json$/i, "static.swf"]
});
```

Options
----
See 'src/lib/default-options.ls' for the option details.

Version
----
v0.0.2

Installation
--------------
You can install this package via 'npm'.

License
----
[MIT]


[simple-autoreload-server]:https://github.com/cytb/simple-autoreload-server
[MIT]:http://www.opensource.org/licenses/mit-license.php




