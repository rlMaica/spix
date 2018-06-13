var express = require('express');
var load = require('express-load');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var routes = require('./routes/index');
var users = require('./routes/users');

var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/users', users);

// load('sockets')
//   .into(io);

io.on('connection', function(socket){
  console.log('#+# usuário conectado #+#');

  socket.on('join', function(key){
    console.log('conectado: ' + key);
    socket.join(key);
  });

  socket.on('send-connected', function(key) {
    io.in(key).emit('user-connected', 'Conectou!');
  });

  socket.on('send-server', function(data) {
    console.log('Foto: ' + data.index + ' - ' + (data.size));
    io.in(data.key).emit('send-client', 'ativo');
    io.in(data.key).emit('send-front', data);
  });

  socket.on('disconnect', function(key){
    console.log('#-# usuário desconectado #-#');
    io.in(key).emit('reset-connection', 'Saiu!');
  });
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});


// module.exports = app;

server.listen(3000, function() {
  console.log(' ');
  console.log('  /$$$$$$  /$$$$$$$  /$$$$$$ /$$   /$$');
  console.log(' /$$__  $$| $$__  $$|_  $$_/| $$  / $$');
  console.log('| $$  \__/| $$  \ $$  | $$  |  $$/ $$/');
  console.log('|  $$$$$$ | $$$$$$$/  | $$   \  $$$$/ ');
  console.log(' \____  $$| $$____/   | $$    >$$  $$ ');
  console.log(' /$$  \ $$| $$        | $$   /$$/\  $$');
  console.log('|  $$$$$$/| $$       /$$$$$$| $$  \ $$');
  console.log(' \______/ |__/      |______/|__/  |__/');
  console.log(' ');
  console.log('######################################');
});