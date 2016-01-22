
require! {
  fs
  path
  \./utils
}

{flatten,visit-dir} = utils

class RecursiveWatcher
  ({
    @root,
    @delay=5ms,
    @on-change=(->),
    @on-error=(->),
    @recursive=false,
    @follow-symlink=false
  })->

    if @follow-symlink
      filter = ({stat})->
        stat.is-directory!
    else
      filter = ({stat})->
        stat.is-directory! and
          (not stat.is-symbolic-link!)

    param = {
      dirpath:  @root
      filter
      on-error: (ex)~>
        @on-error ex, @root
    }

    @dirs = if @recursive
      then flatten (visit-dir param)
      else [@root]

    @watchers = []

  start: ({@on-change=@on-change,@on-error=@on-error}={})->
    @stop!

    self = @
    sessions = {}

    get-handler-change = (dir)->
      (type,file)->
        return if not (file? and dir?)

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

    get-handler-error = (dir)->
      (err)-> self.on-error err, dir

    @watchers = @dirs.map ->
      fs.watch it
      .on \change, get-handler-change it
      .on \error,  get-handler-error  it

  stop: ->
    @watchers.for-each (.close!)

module.exports = ({root,on-change,delay}:opts)->
  new RecursiveWatcher opts

# w.start!
