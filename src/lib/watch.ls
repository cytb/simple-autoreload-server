require! {
  fs
  path
  \./utils
}

{flatten,readdir-rec} = utils

class RecursiveWatcher
  (@dirpath,@delay=5ms,@on-change=(->))->
    @dirs = flatten readdir-rec @dirpath .filter ->
      try
        fs.lstat-sync it .is-directory!
      catch
        false

    @watchers = []

  start: (@on-change=@on-change)->
    @stop!

    self = @
    sessions = {}

    listener-of = (dir)->
      (type,file)->
        long-path = path.join dir, file
        session   = sessions[long-path]

        on-expired = ->
          delete sessions[long-path]
          self.on-change type, long-path

        if session?
          return if session.expire > Date.now!
          clear-timeout session.timer

        sessions[long-path] =
          expire: Date.now! + self.delay
          timer: set-timeout on-expired, self.delay

    error = ->
      self.on-change \error, it

    @watchers = @dirs.map ->
      fs.watch it
      .on \change, listener-of it
      .on \error,  error

  stop: ->
    @watchers.for-each (.close!)

module.exports = ({root,on-change,delay})->
  new RecursiveWatcher root,delay,on-change

# w.start!
