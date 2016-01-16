
describe "Example code", ->
  It "should run successfully.", ->
      ee = null
      try
        /* launcher = require('simple-autoreload-server') */
        launcher = require('../../index.js')
        server = launcher({
          port: 8008
          root: './'
          listDirectory: true
          watch: /\.(png|js|html|json|swf)$/i
          forceReload: [/\.json$/i, "static.swf"]
        })

      catch e
        ee := e

      finally
        assert ee == null, ee

