
/*
 * simple-autoreload-server v0.0.7 - 2014-02-17
 * <https://github.com/cytb/simple-autoreload-server>
 *
 * Copyright (c) 2014 cytb
 *
 * Licensed under the MIT License License.
 * <http://www.opensource.org/licenses/mit-license.php>
 */

var utils,defaultInjectionCode,ref$,out$="undefined"!=typeof exports&&exports||this;utils=require("./utils"),defaultInjectionCode=utils.load(__dirname,"./client.js"),ref$=out$,ref$.commandlineOptions={root:{"short":"d",type:String,desc:"set base directory for publish.",def:"."},port:{"short":"p",type:String,desc:"set port to listen (http).",def:8080},"list-directory":{"short":"l",desc:"enable directory listing.",def:!0},watch:{type:String,"short":"w",desc:"regex pattern of file to watch.",def:/^/},verbose:{"short":"v",desc:"enable verbose log.",def:!1},"force-reload":{type:String,"short":"r",desc:"regex pattern for file forced to reload page.",def:null},"broadcast-delay":{"short":"t",desc:"time to delay before broadcasting file update event (in ms).",def:0},"no-default-script":{desc:"disable injection of default client script.",def:!1},"inject-file":{type:String,"short":"I",desc:"set path to additional file to be injected.",def:null},"inject-method":{type:String,"short":"M",desc:"specify the method [prepend or append]",def:"p"},"inject-match-text":{type:String,"short":"T",desc:"specify the pattern where to inject",def:null},"inject-match-file":{type:String,"short":"F",desc:"specify the pattern for file to inject",def:null},version:{"short":"V",desc:"show version"},help:{"short":"h",desc:"show help"}},ref$.defaultInjectionCode=defaultInjectionCode,ref$.defaultModuleOptions={port:8080,root:process.cwd(),listDirectory:!0,verbose:!1,watch:/^/,forceReload:!1,broadcastDelay:0,onmessage:function(){},inject:{code:"<script type='text/javascript'>\n(function(){"+defaultInjectionCode+"})();\n</script>",match:/<\/(body|head|html)>/i,file:/(\.(php|html?|cgi|pl|rb))$/i,prepend:!0}};