require! {
  fs
  minimist
  \../lib/options
  \../lib/utils
  \../lib/autoreload
}

# show usage
usage = ->

  prog = 'autoreload'

  console.log 'Usage:'
  console.log ' ',prog,'[options] [directory] [port]'
  console.log ''
  console.log 'Options:'

  arr = options.generate-commandline-help!

  for [spec,desc,def] in arr
    console.log '  ',   spec
    console.log '    ', desc
    console.log '    ', "default: #def" if def?
    console.log '',

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

minim-opt   = options.generate-minimist-opt!
def-mod-opt = options.default-module-options

# parse options
parsed = minimist do
  process.argv.slice 2
  minim-opt

# show version
if parsed.version
  version!
  return true

# show help
if parsed.help
  version!
  console.log ""
  usage!
  return true

# unnamed params
[root=parsed.root,port=parsed.port] = parsed._

# String Option -> RegExp
regex = (param)->
  p = parsed[param]
  d = minim-opt['default'][param]
  try
    match typeof! p
      | \String => new RegExp p
      | \RegExp => p
      | _       => d
  catch
    d

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

  client-log:
    parsed.'client-log'

  verbose:
    parsed.verbose

  force-reload:
    (regex 'force-reload') or def-mod-opt.force-reload

  list-directory:
    parsed.'list-directory'

  watch-delay:
    parsed.'watch-delay'

  broadcast-delay:
    parsed.'broadcast-delay'

  inject:
    default-inject-opt ++ get-cmd-inject-opt!


