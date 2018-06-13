module.exports = function(io) {
	var crypto = require('crypto');
	var sockets = io.sockets;

	sockets.on('connection', function(client) {
		client.on('join', function(sala) {
			if (!sala) {
				var timestamp = new Date().toString()
				var md5 = crypto.createHash('md5');
				sala = md5.update(timestamp).digest('hex');
			}
			console.log(sala);
			client.join(sala);
		});

		client.on('disconnect', function(sala) {
			sockets.in(sala).emit('reset-connection', 'Saiu!');
			client.leave(sala);
		});

		client.on('send-server', function(data) {
			console.log(data);
			
			var msg = 'Opa, funcionando!';
			client.broadcast.emit('new-user', usuario);
			sockets.in(sala).emit('send-client', msg);
		});
	});
};

