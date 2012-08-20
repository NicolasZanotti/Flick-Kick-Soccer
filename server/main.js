var express = require('express');
var app = express.createServer();
var io = require('socket.io').listen(app);

var users = {};

app.listen(8126);
console.log("listening on Port 8126");

app.use(express.static(__dirname + '/public'));

app.get('/', function (req, res) {
	res.sendfile(__dirname + '/public/index.html');
});

io.set('transports', ['flashsocket', 'websocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']);
io.sockets.on('connection', onConnection);

function onConnection(socket) {
	socket.on('join', function (name, callback) {
		socket.name = name.length ? name : "Player" + io.sockets.clients().length;
		users[socket.name] = socket.name;

		console.log(socket.name + " has joined");
		console.log(users);
		
		callback(socket.name);
	});

	socket.on('kick', function(angle, distance) {
		socket.broadcast.emit('kicked', socket.name, angle, distance);
	});

	socket.on('disconnect', function() {
		console.log(socket.name);
		delete users[socket.name];
		socket.broadcast.emit('userschange', users);
	});
}
