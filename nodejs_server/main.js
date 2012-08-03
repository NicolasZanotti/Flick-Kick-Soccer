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

io.sockets.on('connection', onConnection);

function onConnection(socket) {
	socket.on('join', function (name, callback) {
		socket.name = name;
		users[name] = name;

		socket.broadcast.emit('userjoin', users);
		callback(users);
	});

	socket.on('ballkick', function(message) {
		socket.broadcast.emit('balkicked', socket.name, message);
	});

	socket.on('disconnect', function() {
		console.log(socket.name);
		delete users[socket.name];

		socket.broadcast.emit('userschange', users);
	});
}
