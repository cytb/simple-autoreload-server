describe("websocket server", function(){
  beforeAll(function(done){
    var newTester, this$ = this;
    this.timeout = 5000;
    this.messages = [];
    this.expect = function(file, data){
      var e, msg;
      e = this$.tester.getExpectJson(file);
      msg = "expects content of the file '" + file + "'";
      if (data != null) {
        return assert.equals(data, e, msg);
      } else {
        return assert(0 <= this$.messages.indexOf(e), msg);
      }
    };
    newTester = function(it){
      return this$.tester = new Tester({
        name: 'websocket-echo',
        expectExt: '.json'
      }, it);
    };
    return newTester(function(){
      return this$.tester.startServer({
        port: 12565,
        inject: [],
        onmessage: function(msg, sock){
          return this$.messages.push(JSON.stringify(JSON.parse(msg)));
        }
      }, function(){
        this$.file = 'websocket-echo.html';
        this$.update = bind$(this$.tester, 'updateServFile');
        return this$.tester.getWebPhantom(this$.file, function(page){
          this$.page = page;
          return done();
        });
      });
    });
  });
  before(function(){
    return this.messages = [];
  });
  afterAll(function(){
    return this.tester.finalize();
  });
  It("should be connected successfully.", function(done){
    this.expect('connected-1');
    this.expect('connected-2');
    return done();
  });
  return It("should send 'update' message.", function(done){
    var this$ = this;
    this.update(this.file);
    return delayed(200, function(){
      this$.expect('update');
      return done();
    });
  });
});
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}