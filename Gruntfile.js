var slice$ = [].slice;
module.exports = function(grunt){
  var files, esteFiles, banner, shebang, path, ref$, each, flatten, pathConv, esteListener, conv, relJs, tmpJs, srcLs, convTmpToRel;
  files = {
    bin: ['bin/autoreload'],
    src: ['index', 'lib/client', 'lib/autoreload', 'lib/default-options', 'lib/utils'],
    test: ['test/buster', 'test/lib/test-utils', 'test/helper/autoreload', 'test/tests/autoreload.test', 'test/tests/websocket.test'],
    testData: ['test/data'],
    gruntjs: ['Gruntfile']
  };
  esteFiles = {
    gruntjs: {
      files: ['src/Gruntfile.ls'],
      tasks: ['config']
    },
    ls: {
      files: ['src/index.ls', 'src/lib/*.ls', 'src/bin/*.ls'],
      tasks: ['src-debug', 'test']
    },
    test: {
      files: ['src/test/**/*.ls'],
      tasks: ['test']
    }
  };
  banner = '/*\n * <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>\n * <<%= pkg.homepage %>>\n *\n * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>\n *\n * Licensed under the <%= pkg.licenses[0].type %> License.\n * <<%= pkg.licenses[0].url %>>\n */\n';
  shebang = '#!/usr/bin/env node\n';
  path = require('path');
  ref$ = require('prelude-ls'), each = ref$.each, flatten = ref$.flatten;
  pathConv = curry$(function(files, decoKey, decoVal, conf){
    var k, v, cur, ref$;
    for (k in files) {
      v = files[k];
      cur = ((ref$ = conf[k]) != null
        ? ref$
        : conf[k] = {}).files = {};
      each(fn$)(
      v);
    }
    return conf;
    function fn$(it){
      return cur[decoKey(it)] = decoVal(it);
    }
  });
  esteListener = function(file){
    var matcher, obj;
    matcher = function(it){
      return grunt.file.match(it.files, file).length > 0;
    };
    return flatten(
    function(it){
      return it.map(function(it){
        return it.tasks;
      });
    }(
    function(it){
      return it.filter(matcher);
    }(
    (function(){
      var i$, ref$, results$ = [];
      for (i$ in ref$ = esteFiles) {
        obj = ref$[i$];
        results$.push(obj);
      }
      return results$;
    }()))));
  };
  ref$ = (conv = function(arg$){
    var pre, post;
    pre = arg$[0], post = arg$[1];
    return function(it){
      return pre + "" + it + post;
    };
  }, {
    relJs: conv(["", '.js']),
    tmpJs: conv(['tmp/js/', '.js']),
    srcLs: conv(['src/', '.ls'])
  }), relJs = ref$.relJs, tmpJs = ref$.tmpJs, srcLs = ref$.srcLs;
  convTmpToRel = function(obj){
    return pathConv({
      src: files.src,
      test: files.test,
      gruntjs: files.gruntjs
    }, relJs, tmpJs, pathConv({
      bin: files.bin
    }, function(it){
      return it;
    }, tmpJs, obj));
  };
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    clean: {
      tmp: ['tmp/**/*', 'tmp'],
      src: ['lib/**/*', 'lib', 'bin/**/*', 'bin', 'index.js'],
      test: ['test/**/*', 'test']
    },
    buster: {
      test: {}
    },
    livescript: pathConv({
      bin: files.bin,
      src: files.src,
      test: files.test,
      gruntjs: files.gruntjs
    }, tmpJs, srcLs, {
      options: {
        bare: true
      }
    }),
    uglify: convTmpToRel({
      options: {
        mangle: {
          except: ['module.exports']
        }
      },
      src: {
        options: {
          banner: banner
        }
      },
      bin: {
        options: {
          banner: shebang + banner
        }
      }
    }),
    copy: convTmpToRel({
      testTmp: {
        expand: true,
        cwd: 'src/test/data',
        src: '**',
        dest: 'tmp/test/data/'
      }
    }),
    esteWatch: {
      options: {
        dirs: ['src/**/', 'test/**/', 'tmp/**/'],
        livereload: {
          enabled: false
        },
        ignoredFiles: {
          indexOf: function(it){
            return (!/\.(ls|js)$/ig.test(it) && 1) || -1;
          }
        }
      },
      "*": esteListener
    }
  });
  each(partialize$.apply(grunt, [grunt.loadNpmTasks, [void 8], [0]]))(
  ['grunt-buster', 'grunt-livescript', 'grunt-este-watch', 'grunt-contrib-uglify', 'grunt-contrib-copy', 'grunt-contrib-clean']);
  grunt.task.registerTask('reload', 'Reload the Gruntfile and restart Gruntjs', function(){
    var gruntfile, x$;
    gruntfile = path.resolve('Gruntfile.js');
    delete require.cache[gruntfile];
    x$ = grunt.task;
    x$.clearQueue();
    x$.run(['esteWatch']);
    return x$;
  });
  return each(partialize$.apply(grunt.registerTask, [grunt.registerTask.apply, [grunt, void 8], [1]]))(
  [['config', ['livescript:gruntjs', 'copy:gruntjs', 'reload']], ['clean-all', ['clean:test', 'clean:src', 'clean:tmp']], ['src-debug', ['livescript:src', 'copy:src']], ['release', ['clean-all', 'livescript:src', 'livescript:bin', 'uglify:src', 'uglify:bin', 'test', 'clean:test', 'clean:tmp']], ['test', ['livescript:test', 'copy:test', 'copy:testTmp', 'buster']], ['default', ['esteWatch']]]);
};
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}
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