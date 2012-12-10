(function($, socket) {
	$(document).ready(function() {
		
		// Configure components
		var chat = $('.chat-module');
		var chatLog = chat.find('.chat-log');
		var chatSubmit = chat.find('.chat-submit');
		var chatMessage = chat.find('.chat-message');
		var chatUsers = chat.find('.chat-users');

		var login = $('.login-module');
		var loginSubmit = login.find('.login-submit');
		var loginName = login.find('.login-name');

		var client = {'name': '', 'message': ''};

		// Event handlers
		function onLoginInit() {
			// Client events
			loginSubmit.click(onLoginSubmit);
			loginName.keydown(onLoginKeyDown);

			// Restore state
			chat.hide();
		}

		function onLoginSubmit() {
			client.name = loginName.val();

			if (client.name !== "") {
				socket.emit('join', client.name, onLoginComplete);
			} else {
				console.log("Please enter a name");
			}
		}

		function onLoginKeyDown(event) {
			if(event.keyCode == 13) {
				onLoginSubmit();
				return false;
			}
		}

		function onLoginComplete(users) {
			onLoginDispose();
			onChatInit();
			onChatUserChange(users);
		}

		function onLoginDispose() {
			login.hide();
		}

		function onChatInit() {
			// Client events
			chatSubmit.click(onChatMessageSubmit);
			chatMessage.keydown(onChatMessageKeyDown);
			$(window).unload(onChatUserExit);

			// Server events
			socket.on('userjoin', onChatUserChange);
			socket.on('userschange', onChatUserChange);
			socket.on('messageadded', onMessageAdded);

			// Restore state
			chat.show();
			chatMessage.focus();
		}

		function onChatMessageSubmit() {

			function isValidInput(txt) {
				return txt === "" ? false : true;
			}

			var input = chatMessage.val();

			if (!isValidInput(input)) return;

			client.message = input;

			onMessageAdded(client.name, client.message);

			socket.emit('chatmessagesubmit', client.message);

			chatMessage.val("");
		}

		function onChatMessageKeyDown(event) {
			if(event.keyCode == 13) {
				onChatMessageSubmit();
				return false;
			}
		}

		function onMessageAdded(name, message) {
			chatLog.append(name + ": " + message + "\n");
		}

		function onChatUserChange(users) {
			chatUsers.empty();

			for (var i in users) {
				var name = users[i] == loginName.val() ? '<strong>' + users[i] + '</strong>' : users[i];
				chatUsers.append('<li>' + name + '</li>');
			}
		}

		function onChatUserExit() {
			console.log('onChatUserExit');
			socket.emit('disconnect');
		}


		onLoginInit();
	});
})(jQuery, io.connect('http://staging.mattenbach.ch:8125'));
