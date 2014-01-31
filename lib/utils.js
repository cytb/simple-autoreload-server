/*
 * simple-autoreload-server v0.0.1 - 2014-02-12
 * <https://github.com/cytb/simple-autoreload-server>
 *
 * Copyright (c) 2014 cytb
 *
 * Licensed under the MIT License.
 * <http://www.opensource.org/licenses/mit-license.php>
 */
function bind$(a,b,c){return function(){return(c||a)[b].apply(a,arguments)}}var flatten,regexClone,deepCopy,newCopy,getLogger,createConnectStack,ref$,slice$=[].slice,toString$={}.toString,join$=[].join,out$="undefined"!=typeof exports&&exports||this;flatten=function(a){var b;return b=slice$.call(a),b.reduce(function(a,b){return a.concat("Array"===toString$.call(b).slice(8,-1)&&flatten(b)||[b])},[])},regexClone=function(a){var b,c,d,e,f;c=[];for(d in e={global:a.global,multiline:a.multiline,ignoreCase:a.ignoreCase})f=e[d],c.push(f&&d.charAt(0)||"");return b=c,new RegExp(a.source,join$.call(b,""))},deepCopy=function(a,b){function c(a){var c;switch(c=[typeof e],!1){case!1:return e;case!/^obj/g.test(c[0]):switch(c=[toString$.call(e).slice(8,-1)],!1){case!1:return a.callee(e,a.callee(b[d]));case"RegExp"!==c[0]:return regexClone(e)}}}var d,e;null==a&&(a={}),null==b&&(b={});for(d in a)e=a[d],b[d]=c(arguments);return b},newCopy=function(a,b){return null==a&&(a={}),null==b&&(b={}),deepCopy(a,deepCopy(b))},getLogger=function(a){return function(){var b;return b=slice$.call(arguments),console.log(join$.call([a()].concat(flatten(b))," "))}},createConnectStack=function(a){var b;return b=slice$.call(a),function(a,c,d){var e;return e=bind$(b.slice(),"shift"),function(b){var f;switch(!1){case!b:return d(b);case!(f=e()):return f(a,c,arguments.callee);default:return d()}}()}},ref$=out$,ref$.flatten=flatten,ref$.regexClone=regexClone,ref$.deepCopy=deepCopy,ref$.newCopy=newCopy,ref$.getLogger=getLogger,ref$.createConnectStack=createConnectStack;