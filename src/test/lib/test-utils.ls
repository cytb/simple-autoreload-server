
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

load = (file,encode='utf-8')->
  try
    fs.read-file-sync file, {encode:encode}
  catch
    null

store = (file,data,encode='utf-8')->
  try
    fs.write-file-sync file, data, {encode:encode}
    true
  catch
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
      false

update = (file,data)->
  if data?
  then store file, data
  else touch file

export
  delayed, random-string,
  load, store, touch, update

