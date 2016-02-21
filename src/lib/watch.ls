
require! {
  fs
  path
}

class RecursiveWatcher
  ({
    @path,
    @delay=5ms,
    @update=(->),
    @error=(->),
    @recursive=false,
    @follow-symlinks=false
  })->
    @watchers = []

  find-dir: (root)->
    dirs  = []
    queue = [root]

    while dir = queue.shift!
      dirs.push dir

      for file in fs.readdir-sync dir => try
        full-path = path.join dir, file
        node      = fs.lstat-sync full-path
        continue if (not node.is-directory!) or
          (node.is-symbolic-link! and not @follow-symlinks)

        queue.push full-path
      catch ex
        @error ex

    dirs

  start: ({@update=@update,@error=@error}={})->
    @stop!

    sessions = {}

    dirs = @recursive and @find-dir @path or [@path]

    @watchers = dirs .map (dir)~>
      fs.watch dir
      .on \error,  @~error
      .on \change, (type,name)~>

        file = path.join dir, name

        {timer,time-stamp} = sessions[file] ?= {time-stamp: Date.now!}

        clear-timeout timer if timer?

        expired = ~>
          delete sessions[file]
          @update type, file

        time = @delay - (Date.now! - time-stamp)
        sessions[file].timer = set-timeout expired, time

  stop: ->
    @watchers.for-each (.close!)
    @watchers = []

export
  RecursiveWatcher

# w.start!
