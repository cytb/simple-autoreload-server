var slice$ = [].slice, join$ = [].join;
(function(it){
  return it.call(typeof global != 'undefined' && global !== null ? global : this);
})(function(){
  var pathes, buster, preludeLs, path, nodePhantom, http, connect, autoreload, colors, testUtils, utils, flatten, newCopy, Tester, ReloadChecker;
  pathes = {
    data: ['tmp', 'test', 'data'],
    serv: ['serv'],
    expect: ['expect'],
    fixture: ['fixture']
  };
  buster = require('buster');
  buster.spec.expose(this);
  this.assert = buster.assert, this.refute = buster.refute, this.expect = buster.expect, this.testCase = buster.testCase;
  this.It = this.it;
  preludeLs = require('prelude-ls');
  path = require('path');
  nodePhantom = require('node-phantom');
  http = require('http');
  connect = require('connect');
  autoreload = require('../../index');
  colors = require('colors');
  testUtils = require('../lib/test-utils');
  utils = require('../../lib/utils');
  flatten = preludeLs.flatten;
  newCopy = utils.newCopy;
  this.delayed = testUtils.delayed, this.randomString = testUtils.randomString;
  this.Tester = Tester = (function(){
    Tester.displayName = 'Tester';
    var touch, store, load, update, prototype = Tester.prototype, constructor = Tester;
    touch = testUtils.touch, store = testUtils.store, load = testUtils.load, update = testUtils.update;
    function Tester(arg$, done){
      var ref$, this$ = this;
      this.name = arg$.name, this.expectExt = (ref$ = arg$.expectExt) != null ? ref$ : ".html", this.log = (ref$ = arg$.log) != null ? ref$ : false, this.port = (ref$ = arg$.port) != null ? ref$ : 18888;
      done == null && (done = function(){});
      this.server = null;
      nodePhantom.create(function(err, phantom){
        var that;
        this$.phantom = phantom;
        if (that = err) {
          throw that;
        }
        return this$.phantom.createPage(function(err, page){
          var that;
          this$.page = page;
          if (that = err) {
            throw that;
          }
          this$.page.onConsoleMessage = function(it){
            return this$.logger("phantom console.log>".magenta, it);
          };
          return done();
        });
      });
    }
    prototype.logger = function(){
      var texts;
      texts = slice$.call(arguments);
      return this.log && console.log(join$.call([("[Tester " + Date.now() + "] " + this.name).yellow].concat(texts), ' '));
    };
    prototype.finalize = function(){
      var ref$;
      this.logger('finalize');
      if ((ref$ = this.page) != null) {
        ref$.close();
      }
      if ((ref$ = this.phantom) != null) {
        ref$.exit();
      }
      return this.stopServer();
    };
    prototype.dataPath = function(){
      var names, joined;
      names = slice$.call(arguments);
      joined = path.join.apply(path, pathes.data.concat(flatten(names)));
      this.logger('data-path', joined);
      return joined;
    };
    prototype.openData = function(){
      var names;
      names = slice$.call(arguments);
      return this.doFileFunc(this.dataPath(names), 'open-data', load);
    };
    prototype.startServer = function(opt, done){
      done == null && (done = function(){});
      this.logger('start-server');
      this.stopServer();
      opt.verbose == null && (opt.verbose = this.log);
      opt.port == null && (opt.port = this.port);
      opt.root == null && (opt.root = this.dataPath(pathes.serv));
      this.server = autoreload(opt);
      return done();
    };
    prototype.stopServer = function(){
      var ref$;
      this.logger('stop-server');
      if ((ref$ = this.server) != null) {
        ref$.stop();
      }
      return this.server = null;
    };
    prototype.checkServer = function(){
      this.logger('check-server');
      this.server || (function(){
        throw new Error('server has not been prepared.');
      }());
      return true;
    };
    prototype.getWebUrl = function(file){
      var port, ref$, ref1$;
      file == null && (file = this.name + ".html");
      port = (ref$ = this.server) != null ? (ref1$ = ref$.options) != null ? ref1$.port : void 8 : void 8;
      return "http://localhost:" + (port != null ? port : 80) + "/" + file;
    };
    prototype.getWebPage = function(file, done){
      var url;
      url = this.getWebUrl(file);
      this.logger('get-web-page', url);
      return this.checkServer() && http.get(url, done);
    };
    prototype.getWebPhantom = function(file, done){
      var url, this$ = this;
      url = this.getWebUrl(file);
      this.logger('get-web-phantom', url);
      return this.checkServer() && this.page.open(url, function(it){
        return done(this$.page, it);
      });
    };
    prototype.getExpectJson = function(file){
      this.logger('get-expect-json');
      return JSON.stringify(JSON.parse(this.getExpectFile(file)));
    };
    prototype.getExpectFile = function(file){
      this.logger('get-expect-file', file);
      return this.openData(pathes.expect, this.name, file + this.expectExt);
    };
    prototype.getState = function(it){
      return {
        state: it && 'ok'.green || 'ng'.red,
        result: it
      };
    };
    prototype.storeServFile = function(file, data){
      return this.doServFileFunc(file, 'store', partialize$.apply(this, [store, [void 8, data], [0]]));
    };
    prototype.touchServFile = function(file){
      return this.doServFileFunc(file, 'touch', touch);
    };
    prototype.updateServFile = function(file, data){
      return this.doServFileFunc(file, 'update', partialize$.apply(this, [update, [void 8, data], [0]]));
    };
    prototype.doServFileFunc = function(servFile, name, func){
      var file;
      file = this.dataPath(pathes.serv, servFile);
      return this.doFileFunc(file, name, func);
    };
    prototype.doFileFunc = function(file, name, func){
      var suc;
      suc = this.getState(func(file));
      this.logger(name, suc.state, file);
      return suc.result;
    };
    return Tester;
  }());
  return this.ReloadChecker = ReloadChecker = (function(){
    ReloadChecker.displayName = 'ReloadChecker';
    var prototype = ReloadChecker.prototype, constructor = ReloadChecker;
    function ReloadChecker(testerOption, defOpt){
      this.testerOption = testerOption;
      if (this.constructor !== arguments.callee) {
        return new arguments.callee(arguments[0], arguments[1], arguments[2]);
      }
      this.setDefaultOption(defOpt);
    }
    prototype.init = function(done){
      var this$ = this;
      return this.tester = new Tester(this.testerOption, function(){
        return this$.tester.startServer({}, done);
      });
    };
    prototype.setDefaultOption = function(defaultOption){
      this.defaultOption = defaultOption != null
        ? defaultOption
        : {
          delay: 50
        };
    };
    prototype.setOption = function(optionArg){
      return this.option = newCopy(optionArg, this.defaultOption);
    };
    prototype.check = function(option){
      var loadedPre, this$ = this;
      option == null && (option = {});
      this.setOption(option);
      loadedPre = this.option.loader();
      return this.tester.getWebPhantom(this.option.pageFile, function(page){
        return delayed(this$.option.delay, function(){
          return page.evaluate(this$.option.evaluator, function(err, resultPre){
            var that, loadedPost;
            if (that = err) {
              throw that;
            }
            loadedPost = this$.option.loader();
            return delayed(this$.option.delay, function(){
              return page.evaluate(this$.option.evaluator, function(err, resultPost){
                var that;
                if (that = err) {
                  throw that;
                }
                return this$.option.done({
                  pre: {
                    loaded: loadedPre,
                    result: resultPre
                  },
                  post: {
                    loaded: loadedPost,
                    result: resultPost
                  }
                });
              });
            });
          });
        });
      });
    };
    return ReloadChecker;
  }());
});
function partialize$(f, args, where){
  var context = this;
  return function(){
    var params = slice$.call(arguments), i,
        len = params.length, wlen = where.length,
        ta = args ? args.concat() : [], tw = where ? where.concat() : [];
    for(i = 0; i < len; ++i) { ta[tw[0]] = params[i]; tw.shift(); }
    return len < wlen && len ?
      partialize$.apply(context, [f, ta, tw]) : f.apply(context, ta);
  };
}