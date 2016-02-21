
require! fs

# TestUtils

delayed = (time,func)->
  set-timeout func, time

random-string = (
  length = 24chars,
  src    = ([[\a to \z], [\A to \Z], [0 to 9]].reduce (++),[]) * ''
)->
  [ src.char-at (Math.random! * src.length) for til length ] * ''

load = (file)->
  try
    # try without encode (due to node-js bug)
    # if failed there may be BOM at beggining of file.
    # see https://github.com/joyent/node/issues/4039
    fs.read-file-sync file
  catch
    console.log e
    null

store = (file,data)->
  try
    # due to bug (same to load)
    fs.write-file-sync file, data
    true
  catch
    console.log e
    false

touch = (file)->
  try
    fs.open-sync file, \wx
    true
  catch
    try
      date = (Date.now! / 1000ms)
      fs.utimes-sync file, date, date
      true
    catch e2
      console.log e,e2
      false

update = (file,data)->
  if data?
  then store file, data
  else touch file

deep-match = (obj,needle,matcher=(a,b)->a==b)->
  for k, v in needle
    matched = k of obj and if typeof v is object
      then &callee obj[k], v
      else matcher obj[k], v
    return false unless matched
  true

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


export
  delayed, random-string,
  load, store, touch, update
  new-copy
  deep-match

