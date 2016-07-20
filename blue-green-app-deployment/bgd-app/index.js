var express = require('express'),
  http = require('http'),
  path = require('path'),
  bodyParser = require('body-parser'),
  methodOverride = require('method-override'),
  logger = require('morgan'),
  fs = require('fs'),
  url = require('url');

var app = express();

var NumberBlackBox = require('./src/NumberBlackBox.js');
var app_port_number = process.env.PORT || 3000;

app.set('port', app_port_number);
app.use(bodyParser.json());
app.use(logger('dev'));
app.use(methodOverride());

app.get('/images/*', function(req, res) {   // serve image files
  var request = url.parse(req.url, true);
  var action = request.pathname;
  var img = fs.readFileSync('.'+request.pathname);
  res.writeHead(200, {'Content-Type': 'image/gif' });
  res.end(img, 'binary');
});

app.all('*', function(req, res) {   // serve all other requests
  var vcap_app=process.env.VCAP_APPLICATION || '{ "application_name":"","application_version":"","application_uris":""}';
  var app_obj = JSON.parse(vcap_app)
  var icon_name = (app_obj.application_name.indexOf("blue")>= 0)?"Blue-station.png":"Green-station.png";
  res.writeHead(200, {"Content-Type": "text/html; charset=UTF-8"});
  res.write("<html><body style='font-family: Arial'><img align='left' src='./images/Blue-Green-icon.png'>");
  res.write("<h1><br><br><br>&nbsp;&nbsp;Blue-Green deployments</h1><hr>");
  res.write("<p><img src='./images/"+icon_name+"'></p>");
  res.write("<hr>");
  res.write("<p><b>Application name:</b> "+ app_obj.application_name+"</p>");
  res.write("<p><b>Application version:</b> "+ app_obj.application_version+"</p>");
  res.write("<p><b>Application URIs:</b> "+ app_obj.application_uris+"</p>");
  res.write("<hr><p><b>VCAP_APPLICATION:</b> "+ JSON.stringify(app_obj,null,'\t')+"</p>");
  res.write("<hr><p>Current time: "+new Date().toString()+"</p><hr/>");
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
