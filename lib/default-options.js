
/*
 * simple-autoreload-server v0.0.2 - 2014-02-13
 * <https://github.com/cytb/simple-autoreload-server>
 *
 * Copyright (c) 2014 cytb
 *
 * Licensed under the MIT License.
 * <http://www.opensource.org/licenses/mit-license.php>
 */

var fs,path,codePath,defaultInjectionCode,ref$,out$="undefined"!=typeof exports&&exports||this;fs=require("fs"),path=require("path"),codePath=path.resolve(__dirname,"../lib/client.js"),defaultInjectionCode=fs.readFileSync(codePath,"UTF-8"),ref$=out$,ref$.port=8080,ref$.root=process.cwd(),ref$.listDirectory=!1,ref$.verbose=!1,ref$.watch=/^/,ref$.forceReload=!1,ref$.broadcastDelay=0,ref$.onmessage=function(){},ref$.inject={code:"<script type='text/javascript'>\n(function(){"+defaultInjectionCode+"})();\n</script>",match:/<\/(body|head|html)>/i,file:/(\.(php|html?|cgi|pl|rb))$/i,prepend:!0};