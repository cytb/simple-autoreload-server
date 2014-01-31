#!/usr/bin/env node
/*
 * simple-autoreload-server v0.0.1 - 2014-02-12
 * <https://github.com/cytb/simple-autoreload-server>
 *
 * Copyright (c) 2014 cytb
 *
 * Licensed under the MIT License.
 * <http://www.opensource.org/licenses/mit-license.php>
 */
var fs,ref$,root,ref1$,port;fs=require("fs"),ref$=process.argv.slice(2),root=null!=(ref1$=ref$[0])?ref1$:".",port=null!=(ref1$=ref$[1])?ref1$:8080,require("lib/autoreload")({root:root,port:/^\d+$/.exec(port)&&parseInt(port)||8080});