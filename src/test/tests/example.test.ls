
describe "Example code", ->
  before (done)->
    @timeout = 8000ms
    done!

  It "for commandline, should run successfully.", (done)->
    cmd = ["-w","**/**.{html,css,js}", "./site-files", "8008"];
    first = true
    stdout = []
    stderr = []
    new Tester {port:8008,+no-port,+no-serv}, (tester)~>
      tester.start-server-process cmd, (ar)~>
        ar.stderr.on \data, stderr~push
        ar.stdout.on \data, ~>
          stdout.push it
          console.log "#it"
          assert.equals stderr.length, 0,  'assure no error on startup'
          assert.match  stdout.0, 'start', 'assure started successfully'
          tester.finalize!
          done!

  It "for module, should run successfully.", ->
      ee = null
      try
        /* launcher = require('simple-autoreload-server') */
        launcher = require('../../index.js')
        server = launcher({
          port: 8008
          path: './'
          listDirectory: true
          watch:  "*.{png,js,html,json,swf}"
          reload: "{*.json,static.swf}"
        })

      catch e
        ee := e

      finally
        assert ee == null, ee

