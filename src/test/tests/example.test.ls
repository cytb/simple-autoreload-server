
describe "Example code", ->
  It "should run successfully.", ->
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

