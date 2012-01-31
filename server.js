/**
 * first npm install socket.io
 * second node server.js
 */
var io = require('socket.io').listen(8081);
//io.disable('destroy upgrade');
//io.disable('heartbeats');
io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('hi', function (data) {
  		console.log(' data ' + data);
 	    socket.emit('hello', { hello: ' ' + data.name});
  });
});