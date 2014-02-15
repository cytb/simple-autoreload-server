require! {
  fs
  minimist
  \../lib/options
  \../lib/utils
  \../lib/autoreload
}

cmd-opt-to-minimist-opt = (opt={})->
  output = {boolean:[],string:[],alias:{},default:{}}

  for name, {type=null,short=[],def=null} of opt
    key = type is String and \string or \boolean
    output[key] ++= name

    for sname in ([] ++ short)
      output.alias[sname] = [name]

    if def?
      output.default[name] = def

  output

# show usage
usage = (cmd-opts)->

  prog = 'autoreload'

  console.log 'Usage:'
  console.log ' ',prog,'[options] [directory] [port]'
  console.log ''

  console.log 'Options:'

  for name, opt of cmd-opts

    nshort = opt.short?         and "-#{opt.short}" or []
    param  = opt.type is String and '<param>'       or []

    [ (['--' + name] ++ nshort) * ' | ' ] ++ param
    |> (* ' ')
    |> (console.log '  ', _)

    console.log "    ", opt.desc
    console.log "    ", "default: #{opt.def}" if opt.def?
    console.log ""

# show version
version = ->
  pkg  = utils.load __dirname, \../package.json
  json = JSON.parse pkg

  console.log """
    #{json.name} v#{json.version}
  """


###
# main function

<- (.call @)

cmd-opt     = options.commandline-options
def-mod-opt = options.default-module-options

# parse options
parsed = minimist do
  process.argv.slice 2
  cmd-opt-to-minimist-opt cmd-opt

# show version
if parsed.version
  version!
  return true

# show help
if parsed.help
  version!
  console.log ""
  usage cmd-opt
  return true

# unnamed params
[root=parsed.root,port=parsed.port] = parsed._

# String Option -> RegExp
regex = (param)->
  if typeof parsed[param] is \string then
    try
      new RegExp parsed[param]
    catch
      cmd-opt[param].def

# construct 'module-option.inject',
get-cmd-inject-opt = ->
  a-file   = [] ++ parsed.'inject-file'
  a-method = [] ++ parsed.'inject-method'
  a-m-text = [] ++ parsed.'inject-match-text'
  a-m-file = [] ++ parsed.'inject-match-file'

  out = []

  for file in a-file
    m-file = a-m-file.shift!

    continue unless file? and m-file?

    m-text  = a-m-text.shift! ? null
    prepend = !(a-method.shift! is /^a(p(p(e(n(d)?)?)?)?)$/)

    out ++= do
      code:  load __dirname, file
      match: m-text
      file:  m-file
      prepend: prepend

  out

default-inject-opt = unless parsed.'no-default-script'
  then [def-mod-opt.inject] else []


# start server
serv = autoreload do
  root: root
  port: port
  watch:
    regex \watch

  verbose:
    parsed.verbose

  force-reload:
    (regex 'force-reload') or def-mod-opt.force-reload

  list-directory:
    parsed.'list-directory'

  broadcast-delay:
    parsed.broadcast-delay

  inject:
    default-inject-opt ++ get-cmd-inject-opt!


