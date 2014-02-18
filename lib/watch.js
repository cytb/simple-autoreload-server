
/*
 * simple-autoreload-server v0.0.7 - 2014-02-19
 * <https://github.com/cytb/simple-autoreload-server>
 *
 * Copyright (c) 2014 cytb
 *
 * Licensed under the MIT License License.
 * <http://www.opensource.org/licenses/mit-license.php>
 */

var fs,path,utils,flatten,readdirRec,RecursiveWatcher;fs=require("fs"),path=require("path"),utils=require("./utils"),flatten=utils.flatten,readdirRec=utils.readdirRec,RecursiveWatcher=function(){function a(a,b,c){this.dirpath=a,this.delay=null!=b?b:5,this.onChange=null!=c?c:function(){},this.dirs=flatten(readdirRec(this.dirpath)).filter(function(a){var b;try{return fs.lstatSync(a).isDirectory()}catch(c){return b=c,!1}}),this.watchers=[]}a.displayName="RecursiveWatcher";var b=a.prototype;return b.start=function(a){var b,c,d,e;return this.onChange=null!=a?a:this.onChange,this.stop(),b=this,c={},d=function(a){return function(d,e){var f,g,h;if(f=path.join(a,e),g=c[f],h=function(){return delete c[f],b.onChange(d,f)},null!=g){if(g.expire>Date.now())return;clearTimeout(g.timer)}return c[f]={expire:Date.now()+b.delay,timer:setTimeout(h,b.delay)}}},e=function(a){return b.onChange("error",a)},this.watchers=this.dirs.map(function(a){return fs.watch(a).on("change",d(a)).on("error",e)})},b.stop=function(){return this.watchers.forEach(function(a){return a.close()})},a}(),module.exports=function(a){var b,c,d;return b=a.root,c=a.onChange,d=a.delay,new RecursiveWatcher(b,d,c)};