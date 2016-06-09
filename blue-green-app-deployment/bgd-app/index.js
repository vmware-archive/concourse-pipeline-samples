var express = require('express'),
  http = require('http'),
  path = require('path'),
  bodyParser = require('body-parser'),
  methodOverride = require('method-override'),
  logger = require('morgan');

var app = express();

var NumberBlackBox = require('./src/NumberBlackBox.js');

var numberBlackBox = new NumberBlackBox();

app.set('port', 8085);
app.use(bodyParser.json());
app.use(logger('dev'));
app.use(methodOverride());

app.all('*', function(req, res) {
  var vcap_app=process.env.VCAP_APPLICATION || '{ "application_name":"","application_version":"","application_uris":""}';
  var app_obj = JSON.parse(vcap_app)
  res.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
  res.write("<html><body><h1>Blue-Green deployment sample app</h1>");
  res.write("<p>Random number is "+numberBlackBox.getNumber()+"</p><hr/>");
  res.write("<h4>Cloud Foundry Application information</h3>");
  res.write("<p><b>CF_INSTANCE_GUID:</b> "+process.env.CF_INSTANCE_GUID+"</p>");
  res.write("<p><b>CF_INSTANCE_INDEX:</b> "+process.env.CF_INSTANCE_INDEX+"</p>");
  res.write("<p><b>VCAP_APPLICATION:</b> "+ JSON.stringify(app_obj,null,'\t')+"</p>");
  res.write("<p>&nbsp;&nbsp;&nbsp;<b>application_name:</b> "+ app_obj.application_name+"</p>");
  res.write("<p>&nbsp;&nbsp;&nbsp;<b>application_version:</b> "+ app_obj.application_version+"</p>");
  res.write("<p>&nbsp;&nbsp;&nbsp;<b>application_uris:</b> "+ app_obj.application_uris+"</p>");
  res.write("</body></html>");
  res.end("\n");

});

var server = http.createServer(app);
var boot = function () {
  server.listen(app.get('port'), function(){
    console.info('Blue-Green-App-Test listening on port ' + app.get('port'));
  });
}
var shutdown = function() {
  server.close();
}
if (require.main === module) {
  boot();
} else {
  console.info('Running app as a module')
  exports.boot = boot;
  exports.shutdown = shutdown;
  exports.port = app.get('port');
}
