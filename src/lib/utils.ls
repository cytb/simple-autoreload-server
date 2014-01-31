
# Utils

flatten = ([...array])->
  array.reduce ((p,n)->
    p ++ ((typeof! n is \Array and flatten n) or [n])
  ), []

regex-clone = (r)->
  flags = for k,v of r{global,multiline,ignore-case}
    v and k.char-at 0 or ''
  new RegExp r.source, flags * ''

deep-copy = (src={},out={})->
  for k,v of src
    out[k] = match typeof v
    | _       => v
    | /^obj/g => match typeof! v
      | _       => &callee v, (&callee out[k])
      | \RegExp => regex-clone v
  out

new-copy = (src={},out={})->
  deep-copy src, deep-copy out

get-logger = (log-prefix)->
  (...texts)-> console.log do
    ([log-prefix!] ++ (flatten texts)) * ' '

#
# Connect Middle-ware API
#   Ref: https://gist.github.com/danielbeardsley/1041099
#
# notes: [...x] clones it using slice() internaly
create-connect-stack = ([...middle-wares])->
  (req,res,next)->
    mw = middle-wares.slice!~shift
    do (err)->
      | err => next err
      | mw! => that req, res, &callee
      | _   => next!

export {
  flatten, regex-clone, deep-copy, new-copy,
  get-logger, create-connect-stack
}
