
require! fs

# TestUtils

delayed = (...args-src)->
  args = args-src.slice!
  args.length > 0 and do
    func = args.pop!
    time = args.reduce (+), 0

    set-timeout func, time

random-string = (
  length = 24chars,
  src-string = [
      [\a to \z] [\A to \Z] [0 to 9]
  ] |> (.reduce (.concat &1), [])
)->
  max = src-string.length
  for til length
      (Math.random! * max) .|. 0
  |> (.map (src-string.))
  |> (.join '')

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

export
  delayed, random-string,
  load, store, touch, update
  deep-match

