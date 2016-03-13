

module.exports = do ->
  require! {
    './lib/autoreload'
  }

  exports = ->
    server = new autoreload.SimpleAutoreloadServer it
    server.start!
    server

  exports <<< autoreload

