describe("client ->", function(){
  return describe("response js", function(){
    beforeAll(function(done){
      var checker, this$ = this;
      this.timeout = 10000;
      this.htmlFile = 'touch-test.html';
      this.jsFile = 'touch-test.js';
      this.cssFile = 'touch-test.css';
      this.frameFile = 'touch-test.frame.html';
      checker = new ReloadChecker({
        name: 'client-code-injection',
        port: 12567
      }, {
        pageFile: this.htmlFile,
        delay: 100
      });
      return checker.init(function(){
        this$.update = bind$(checker.tester, 'updateServFile');
        this$.check = bind$(checker, 'check');
        this$.fin = bind$(checker.tester, 'finalize');
        this$.update(this$.htmlFile, "<html>\n  <head>\n    <link rel='StyleSheet' type='text/css' href='" + this$.cssFile + "' />\n    <script type='text/javascript' src='" + this$.jsFile + "'></script>\n    <script type='text/javascript'> window.loadTime = Date.now(); </script>\n  </head>\n  <body>\n    <div> <iframe src='" + this$.frameFile + "'></iframe> </div>\n    <div> <span>" + this$.htmlFile + "</span> </div>\n  </body>\n</html>");
        this$.update(this$.frameFile, "<html> <head>\n  <title> frame </title>\n  </head>\n  <body>\n    <div> frame </div>\n  </body>\n</html>");
        return done();
      });
    });
    afterAll(function(){
      return this.fin();
    });
    It("should let browser 'reload' 'html'on 'touch'.", function(done){
      var this$ = this;
      return this.check({
        loader: function(){
          return this$.update(this$.htmlFile);
        },
        evaluator: function(){
          return window.loadTime;
        },
        done: function(arg$){
          var pre, post;
          pre = arg$.pre, post = arg$.post;
          refute.equals(pre.result, post.result);
          return done();
        }
      });
    });
    It("should 'not' let browser 'reload' 'html'on 'update' the js.", function(done){
      var this$ = this;
      return this.check({
        loader: function(){
          return this$.update(this$.jsFile);
        },
        evaluator: function(){
          return window.loadTime;
        },
        done: function(arg$){
          var pre, post;
          pre = arg$.pre, post = arg$.post;
          assert.equals(pre.result, post.result);
          return done();
        }
      });
    });
    describe("should let browser 'refresh'", function(){
      It("'js' file on 'update'.", function(done){
        var this$ = this;
        return this.check({
          loader: function(){
            var id;
            id = randomString(16);
            this$.update(this$.jsFile, "window.testId = '" + id + "';");
            return {
              id: id
            };
          },
          evaluator: function(){
            return {
              id: window.testId,
              mtime: window.loadTime
            };
          },
          done: function(arg$){
            var pre, post;
            pre = arg$.pre, post = arg$.post;
            assert.equals(pre.result.mtime, post.result.mtime, "modified time must be same");
            assert.equals(pre.result.id, pre.loaded.id, "browser's id must match to generated one (pre)");
            assert.equals(post.result.id, post.loaded.id, "browser's id must match to generated one (post)");
            return done();
          }
        });
      });
      return It("'css' file on 'update'", function(done){
        var file, this$ = this;
        file = this.cssFile;
        return this.check({
          loader: function(){
            var font;
            font = randomString(16, ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]);
            this$.update(file, "body {font-family: " + font + ";}");
            return {
              font: font
            };
          },
          evaluator: function(){
            var href, cssRules, cssText;
            return {
              css: (function(){
                var i$, ref$, len$, ref1$, j$, len1$, results$ = [];
                for (i$ = 0, len$ = (ref$ = document.styleSheets).length; i$ < len$; ++i$) {
                  ref1$ = ref$[i$], href = ref1$.href, cssRules = ref1$.cssRules;
                  for (j$ = 0, len1$ = (ref1$ = cssRules).length; j$ < len1$; ++j$) {
                    cssText = ref1$[j$].cssText;
                    results$.push([cssText]);
                  }
                }
                return results$;
              }()).join(' '),
              mtime: window.loadTime
            };
          },
          done: function(arg$){
            var pre, post;
            pre = arg$.pre, post = arg$.post;
            assert.equals(pre.result.mtime, post.result.mtime, "modified time must be same");
            assert.match(pre.result.css, pre.loaded.font, "browser style must be set (pre)");
            assert.match(post.result.css, post.loaded.font, "browser style must be set (post)");
            return done();
          }
        });
      });
    });
    return It("should 'not' let browser to 'reload' the 'html' fileon 'touch' the unrelated 'html' file.", function(done){
      var files, loaded, this$ = this;
      files = ['touch.html', 'touch-test1.html', 'touch-test2.html', 'touch-test3.html', 'touch-test.frame.html'];
      loaded = false;
      return this.check({
        loader: function(){
          var loaded;
          if (loaded) {
            files.forEach(this$.update);
          }
          return loaded = !loaded;
        },
        evaluator: function(){
          return window.loadTime;
        },
        done: function(arg$){
          var pre, post;
          pre = arg$.pre, post = arg$.post;
          assert.equals(pre.result, post.result);
          return done();
        }
      });
    });
  });
});
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}