var fs, delayed, randomString, load, store, touch, update, slice$ = [].slice, out$ = typeof exports != 'undefined' && exports || this;
fs = require('fs');
delayed = function(){
  var argsSrc, args, func, time;
  argsSrc = slice$.call(arguments);
  args = argsSrc.slice();
  return args.length > 0 && (func = args.pop(), time = args.reduce(curry$(function(x$, y$){
    return x$ + y$;
  }), 0), setTimeout(func, time));
};
randomString = function(length, srcString){
  var max;
  length == null && (length = 24);
  srcString == null && (srcString = function(it){
    return it.reduce(function(it){
      return it.concat(arguments[1]);
    }, []);
  }(
  [["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"], ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]]));
  max = srcString.length;
  return function(it){
    return it.join('');
  }(
  function(it){
    return it.map(function(it){
      return srcString[it];
    });
  }(
  (function(){
    var i$, to$, results$ = [];
    for (i$ = 0, to$ = length; i$ < to$; ++i$) {
      results$.push(Math.random() * max | 0);
    }
    return results$;
  }())));
};
load = function(file, encode){
  var e;
  encode == null && (encode = 'utf-8');
  try {
    return fs.readFileSync(file, {
      encode: encode
    });
  } catch (e$) {
    e = e$;
    return null;
  }
};
store = function(file, data, encode){
  var e;
  encode == null && (encode = 'utf-8');
  try {
    fs.writeFileSync(file, data, {
      encode: encode
    });
    return true;
  } catch (e$) {
    e = e$;
    return false;
  }
};
touch = function(file){
  var e, date, e2;
  try {
    fs.openSync(file, 'wx');
    return true;
  } catch (e$) {
    e = e$;
    try {
      date = Date.now() / 1000;
      fs.utimesSync(file, date, date);
      return true;
    } catch (e$) {
      e2 = e$;
      return false;
    }
  }
};
update = function(file, data){
  if (data != null) {
    return store(file, data);
  } else {
    return touch(file);
  }
};
out$.delayed = delayed;
out$.randomString = randomString;
out$.load = load;
out$.store = store;
out$.touch = touch;
out$.update = update;
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