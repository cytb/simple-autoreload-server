var ar, connect;
try {
  ar      = require("simple-autoreload-server");
  connect = require("connect");
} catch (e) {
  // in examples dir
  try {
    ar      = ar      || require("../../index.js");
    connect = connect || require("../../node_modules/connect");
  } catch (e) {
    console.error("module loading failed");
    process.exit();
  }
}

var log = [];
var logLength = 100;

var app = connect();
var server;

app.use(connect.bodyParser());
app.use("/", function(req, res, next){
  var url = connect.utils.parseUrl(req);
  switch(url.pathname){
    case "/":
      res.writeHead(301, {Location: "/index.html"});
      res.end();
      return;
    case "/log": 
      res.end(JSON.stringify(log));
      return;
    case "/push":
      if( req.method != "POST" ){ break; }
      try {
        var q = req.body;
        if( q.name && q.text ){
          q = {name:q.name,text:q.text};
          q.time = Date.now();
          server.broadcast({type:"chat",data:q});
          log = log.slice(log.length - logLength + 1).concat(q);
          res.end('complete\n');
        }
      } catch (e){
        console.log(e);
      }
      return;
  }
  next();
});


server = ar({
  connectApp: app,
  port:8089,
  path: "public/",
  listDirectory: false,
  verbose: true
});

