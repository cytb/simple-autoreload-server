Usage of options for simple-autoreload-server.
========================

This document provides details of commandline or module options.

# Option types

Options has a type which of string, pattern, number, and boolean.

string
---
parsed as string itself. this option can be specified multiple times on commandline,
and an array of string passed to module.

(e.g. --option a --option b => [ "a", "b" ])

It depends on the option that which value is chosen.

number
---
parsed as number itself.

boolean
---
parsed as boolean. don't pass additional parameter.
if you want set 'false' to option on commandline, add nagation prefix ('no' or 'without')
(e.g. --no-option, --without-option)

pattern
---
* Commandline
  Option without additional parameter is parsed as boolean.
  In this case, pattern matches all of target on true.
  and if it has negation prefix, pattern matches none of target.

  if additional parameter is provided, it is parsed as "glob pattern".

  glob implementation depends on minimatch v3.0.0.
  
  e.g.
    - --pattern-option => matches all
    - --no-pattern-option => matches none
    - --pattern-option "\*\*" => matches ** (glob pattern)
    - --pattern-option null => matches "null" (glob pattern)

* Module (function argument)

  if Array is provided, it will be parsed as list of 'pattern'
  and only the string which can match all of these patterns will be matched.

  if String is provided, it is parsed as "glob pattern".

  RegExp object, or Function is provided, it will be used itself.
  (Function has to return true if matched.)

  otherwise, the pattern matches all if value is truthy and none if falsy.

# List of options


path 
---

specifies root directory to publish.

|option||
|:---|:---|
|full-flag| --path|
|short-flag| -d|
|module| path|
|type| string
|default| "."|



---


watch 
---

pattern for file to watch.
if true, it matches any files, and matches nothing on false.

|option||
|:---|:---|
|full-flag| --watch|
|short-flag| -w|
|module| watch|
|type| pattern
|default| "\*\*/\*\*"|



---


reload 
---

pattern for file to reload the whole page.
whether or not to reload actually depends on behavior of client script.
if true, it matches any files, and matches nothing on false.

|option||
|:---|:---|
|full-flag| --reload|
|short-flag| -r|
|module| reload|
|type| pattern
|default| false|



---


mount.path 
---

specifies additional directory to publish.

program can accept multiple times in commandline.
other 'mount.*' options are attached to corresponding path by order in commandline.

|option||
|:---|:---|
|full-flag| --mount.path|
|short-flag| -m|
|module| mount.path|
|type| string
|default| "."|



### Examples

- autoreload -H localhost -p 8080 -m ./html -m ./node_modules --mount.path ./build

  the server publishes content of './html', './node_modules' and './build' at 'https://localhost:8080/'.
if all of those directories contain 'index.html' and client requests 'https://localhost:8080/index.html',
the first one will be sent ('./html/index.html' in this case).


---


mount.target 
---

server side path of mounted direcory.

|option||
|:---|:---|
|full-flag| --mount.target|
|short-flag| -t|
|module| mount.target|
|type| string
|default| "/"|



### Examples

- autoreload . 8080 -m ./www/js -t /components

  the server publishes content of './' to server-root(http://localhost:8080/),
"./www/js" to "/components" (http://localhost:8080/components/).


---


mount.watch 
---

pattern of file to watch.

|option||
|:---|:---|
|full-flag| --mount.watch|
|short-flag| -W|
|module| mount.watch|
|type| pattern
|default| "\*\*/\*\*"|



---


host 
---

specifies server address to listen.
'0.0.0.0' means listening all of the (ipv4) interfaces on computer.

|option||
|:---|:---|
|full-flag| --host|
|short-flag| -H|
|module| host|
|type| string
|default| "0.0.0.0"|



---


port 
---

specifies server http(s) port to listen.

|option||
|:---|:---|
|full-flag| --port|
|short-flag| -p|
|module| port|
|type| number
|default| "8080"|



---


config 
---

load json as config before starting server.
the config overwritten by command-line options and function arguments.
all of specified pathes regarded as relative path from config location.
(function arguments, and command-line parameters as well.)

the server logs nothing when the default config does not exist.

|option||
|:---|:---|
|full-flag| --config|
|short-flag| -c|
|module| config|
|type| string
|default| ".autoreload.json"|



---


search-config 
---

search for config file in parent directories.
it is no harm when specified absolute path.

|option||
|:---|:---|
|full-flag| --search-config|
|short-flag| (none)|
|module| searchConfig|
|type| boolean
|default| true|



---


list-directory 
---

enable directory listing.
it should be disabled if you want to invoke default request handler.

|option||
|:---|:---|
|full-flag| --list-directory|
|short-flag| -l|
|module| listDirectory|
|type| boolean
|default| true|



---


browse 
---

invokes platform default program with argumemts after launched. 

if provided true via function argument 
or '--browse' option followed by nothing via command-line, 
the program invokes the default with the server url.

if the 'String' value was specified, it will be passed instead of the server url.
the server does nothing if specified Boolean of 'false' or 'null'.

|option||
|:---|:---|
|full-flag| --browse|
|short-flag| -b|
|module| browse|
|type| string
|default| false|



### Examples

- autoreload -d . -p 8088 -H 192.168.1.15 -b

  opens https://192.168.1.15:8088/


- autoreload -d . -p 8088 -b "http://server1.localdomain:80/"

  opens "http://server1.localdomain:80/"


---


execute 
---

executes command when the server has been prepared.
the command is passed to shell.
in other words it has not been invoked directly.

you can pass Array of above values or many times on command-line,
and then the server invokes with each values.


|option||
|:---|:---|
|full-flag| --execute|
|short-flag| -e|
|module| execute|
|type| string
|default| ""|



### Examples

- autoreload -e "firefox"

  opens firefox via shell


---


stop-on-exit 
---

the server will stop when invoked process specified by 'execute' option died.
if there are multiple processes invoked by 'execute' option,
the server keep running until all of that has been killed.

|option||
|:---|:---|
|full-flag| --stop-on-exit|
|short-flag| -k|
|module| stopOnExit|
|type| boolean
|default| false|



---


ignore-case 
---

ignoring case of glob-string of patterns.

this option is no harm to regex pattern of 'pattern' type.
all of the glob patterns that were passed as 'String' type
via function arguments or command-line option will be affected.

|option||
|:---|:---|
|full-flag| --ignore-case|
|short-flag| -i|
|module| ignoreCase|
|type| boolean
|default| true|



---


include-hidden 
---

make globs to include hidden (dot) files.
this option is no harm except for glob string patterns.

|option||
|:---|:---|
|full-flag| --include-hidden|
|short-flag| -n|
|module| includeHidden|
|type| boolean
|default| false|



---


default-pages 
---

default page file pattern for directory request.

|option||
|:---|:---|
|full-flag| --default-pages|
|short-flag| (none)|
|module| defaultPages|
|type| pattern
|default| "index.{htm,html}"|



---


encoding 
---

encoding for reading texts and inject target files

|option||
|:---|:---|
|full-flag| --encoding|
|short-flag| (none)|
|module| encoding|
|type| string
|default| "utf-8"|



---


watch-delay 
---

delay time to supress duplicate watch event (in milil-seconds).
the watch event is often fired multiple times in short duration.

|option||
|:---|:---|
|full-flag| --watch-delay|
|short-flag| (none)|
|module| watchDelay|
|type| number
|default| 20|



---


log 
---

set log mode. choose from followings.
'silent' -> 'minimum' -> 'normal' -> 'verbose' -> 'noisy'
(number also acceptable: silent is 0, minimum is 1, ..., and noisy is 4)

|option||
|:---|:---|
|full-flag| --log|
|short-flag| -v|
|module| log|
|type| string
|default| "normal"|



---


builtin-script 
---

enable injection of default built-in script.

if you want to replace for built-in script by another script,
specify this option to false or with negative prefix ('no-') without equal,
and use 'inject' option.

|option||
|:---|:---|
|full-flag| --builtin-script|
|short-flag| (none)|
|module| builtinScript|
|type| boolean
|default| true|



---


client-module 
---

expose client side built-in module to 'window' object.
if you want to use client module in built-in script, set true or String value.

If true,   module will be exposed to 'window.AutoreloadClient'.
If String, module will be exposed in window with specified name.

This option does nothing when 'builtin-script' is false.
when the module is initialized, it emits the 'AutoreloadClient.*' events on 'window'.
see 'examples'.

|option||
|:---|:---|
|full-flag| --client-module|
|short-flag| (none)|
|module| clientModule|
|type| string
|default| true|



---


client-log 
---

inform client to log.
the server only send a option to client on connect by this option.
whether or not to logs actually depends on behavior of client script.

|option||
|:---|:---|
|full-flag| --client-log|
|short-flag| (none)|
|module| clientLog|
|type| boolean
|default| false|



---


recursive 
---

watch sub-directories recursively. this may take a while at startup.
the server does not detect cyclic structure and it may cause infinit loop.
unset follow-symlinks option if need.

|option||
|:---|:---|
|full-flag| --recursive|
|short-flag| -R|
|module| recursive|
|type| boolean
|default| true|



---


follow-symlinks 
---

lookup files in symbolic-links target when watch directory. 
this option affects only when the resursive option is enabled.

|option||
|:---|:---|
|full-flag| --follow-symlinks|
|short-flag| -L|
|module| followSymlinks|
|type| boolean
|default| false|



---


inject.content 
---

injects specified content. see also: 'inject.type'.
if no inject.content options are provided,
and the file '.autoreload.html' exists in current directory
(or config json directory), server try to inject as a builtin-script.

|option||
|:---|:---|
|full-flag| --inject.content|
|short-flag| -I|
|module| inject.content|
|type| string
|default| ""|



---


inject.type 
---

specifies type of 'inject.content' option.
'file': treat 'inject.content' as file path.
'raw':  'inject.content' will be injected directly.

|option||
|:---|:---|
|full-flag| --inject.type|
|short-flag| -T|
|module| inject.type|
|type| string
|default| "file"|



---


inject.which 
---

specify pattern for injection target.

|option||
|:---|:---|
|full-flag| --inject.which|
|short-flag| -F|
|module| inject.which|
|type| pattern
|default| "\*\*/\*\*.{htm,html}"|



---


inject.where 
---

this is not a 'pattern' type.
specify regex string where to inject.
content will be injected before matched string.

|option||
|:---|:---|
|full-flag| --inject.where|
|short-flag| -P|
|module| inject.where|
|type| string
|default| "</(body&#124;head&#124;html)>"|



---


inject.prepend 
---

change injection method to 'prepend'.
if true, content will be injected 'before' matched string.

|option||
|:---|:---|
|full-flag| --inject.prepend|
|short-flag| -E|
|module| inject.prepend|
|type| boolean
|default| false|



---


help 
---

show help and exit.
ignored if it was appeared on json or function arguments.

|option||
|:---|:---|
|full-flag| --help|
|short-flag| -h|
|module| help|
|type| boolean
|default| false|



---


version 
---

shows version.
ignored if it was appeared on json or function arguments.

|option||
|:---|:---|
|full-flag| --version|
|short-flag| -V|
|module| version|
|type| boolean
|default| false|



---


onmessage  (only for module)
---

specifies server onmessage handler.
server calls this function on broadcast the message.

|option||
|:---|:---|
|name|onmessage|
|default| null|




---


connect-app  (only for module)
---

specifies 'connect' app object as server base.
server middleware layers willbe stacked to this object.

|option||
|:---|:---|
|name|connectApp|
|default| null|




---





