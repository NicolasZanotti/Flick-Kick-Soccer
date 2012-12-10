package
{
	import flash.text.TextFieldType;
	import flash.events.Event;

	import fl.events.ComponentEvent;

	import flash.text.TextFormat;

	import fl.controls.Button;
	import fl.controls.TextArea;
	import fl.controls.TextInput;

	import stoletheshow.control.Controllable;
	import stoletheshow.control.Controller;

	import com.pnwrain.flashsocket.FlashSocket;
	import com.pnwrain.flashsocket.events.FlashSocketEvent;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author Nicolas Zanotti
	 */
	public class Main extends Sprite implements Controllable
	{
		public var ct:Controller;
		public var mcOverlay:MovieClip;
		public var btLoginSubmit:Button;
		public var tiLoginName:TextInput;
		public var tfLoginMessage:TextField;
		public var tfLoginInfo:TextField;
		public var tfChatUsers:TextField;
		public var btChatSubmitMessage:Button;
		public var tiChatMessage:TextInput;
		public var taChatLog:TextArea;
		protected var socket:FlashSocket;
		protected var client:Object = {'name':'', 'message':''};

		public function Main()
		{
			ct = new Controller(this);
		}

		public function init():void
		{
			// Configure components
			var largeTextFormat:TextFormat = new TextFormat();
			largeTextFormat.font = "_sans";
			largeTextFormat.size = 28;

			var mediumTextFormat:TextFormat = new TextFormat();
			mediumTextFormat.font = "_sans";
			mediumTextFormat.size = 20;

			tiLoginName.setStyle("textFormat", largeTextFormat);
			tiChatMessage.setStyle("textFormat", largeTextFormat);
			btLoginSubmit.setStyle("textFormat", mediumTextFormat);
			btChatSubmitMessage.setStyle("textFormat", mediumTextFormat);
			taChatLog.setStyle("textFormat", mediumTextFormat);

			// Configure listeners
			ct.events.add(btLoginSubmit, MouseEvent.CLICK, onBtloginsubmitClick);
			ct.events.add(tiLoginName, ComponentEvent.ENTER, onBtloginsubmitClick);

			// Initialize socket
			socket = new FlashSocket("staging.mattenbach.ch:8125");
			socket.addEventListener(FlashSocketEvent.CONNECT, onConnect);
			socket.addEventListener(FlashSocketEvent.MESSAGE, onMessage);
			socket.addEventListener(FlashSocketEvent.IO_ERROR, onError);
			socket.addEventListener(FlashSocketEvent.SECURITY_ERROR, onError);

			// Reset state
			tiLoginName.setFocus();
		}

		private function updateUsers(users:Object):void
		{
			var name:String;
			var htmlText:String = '<ul>';

			for (var i in users)
			{
				name = users[i] == client.name ? '<strong>' + users[i] + '</strong>' : users[i];
				htmlText += '<li>' + name + '</li>';
			}

			htmlText += '</ul>';

			tfChatUsers.htmlText = htmlText;
		}

		/* ------------------------------------------------------------------------------- */
		/*  User Events */
		/* ------------------------------------------------------------------------------- */
		protected function onBtloginsubmitClick(event:Event):void
		{
			event.stopPropagation();
			if (tiLoginName.text.length > 0)
			{
				tfLoginMessage.text = "";
				client.name = tiLoginName.text;
				socket.emit('join', client.name, onLoginComplete);
			}
			else
			{
				tfLoginMessage.text = "Please enter a name.";
			}
		}

		private function onChatInit():void
		{
			// Server events
			socket.addEventListener("userjoin", onChatUserChange);
			socket.addEventListener("userschange", onChatUserChange);
			socket.addEventListener("messageadded", onMessageAdded);

			// User events
			ct.events.add(btChatSubmitMessage, MouseEvent.CLICK, onChatMessageSubmit);
			ct.events.add(tiChatMessage, ComponentEvent.ENTER, onChatMessageSubmit);
			ct.events.add(taChatLog, Event.RENDER, onChatLogRender);

			tiChatMessage.setFocus();
		}

		private function onChatMessageSubmit(event:Event):void
		{
			if (tiChatMessage.text.length == 0) return;

			client.message = tiChatMessage.text;

			taChatLog.appendText(client.name + ": " + client.message + "\n");

			socket.emit('chatmessagesubmit', client.message);

			tiChatMessage.text = "";
		}

		private function onChatLogRender(event:Event):void
		{
			taChatLog.textField.selectable = false;
			taChatLog.textField.type = TextFieldType.DYNAMIC;
		}

		/* ------------------------------------------------------------------------------- */
		/*  Socket Callbacks */
		/* ------------------------------------------------------------------------------- */
		private function onLoginComplete(users:Object):void
		{
			trace("onLoginComplete: " + users);

			disposeLogin();
			onChatInit();
			updateUsers(users);
		}

		/* ------------------------------------------------------------------------------- */
		/*  Socket Eventhandlers */
		/* ------------------------------------------------------------------------------- */
		private function onMessageAdded(event:FlashSocketEvent):void
		{
			var name:String = event.data[0];
			var message:String = event.data[1];

			taChatLog.appendText(name + ": " + message + "\n");
		}

		private function onChatUserChange(event:FlashSocketEvent):void
		{
			var users:Object = event.data[0];
			updateUsers(users);
		}

		private function onConnect(event:FlashSocketEvent):void
		{
			trace("onConnect: " + event.data);
		}

		private function onError(event:FlashSocketEvent):void
		{
			trace("onError: " + event.data);
		}

		private function onMessage(event:FlashSocketEvent):void
		{
			trace('onMessage: ' + event.data);
		}

		/* ------------------------------------------------------------------------------- */
		/*  Disposal */
		/* ------------------------------------------------------------------------------- */
		public function dispose():void
		{
			socket.emit('disconnect', null);
		}

		private function disposeLogin():void
		{
			ct.events.remove(btLoginSubmit, MouseEvent.CLICK, onBtloginsubmitClick);
			ct.events.remove(tiLoginName, ComponentEvent.ENTER, onBtloginsubmitClick);

			removeChild(btLoginSubmit);
			removeChild(tiLoginName);
			removeChild(mcOverlay);
			removeChild(tfLoginInfo);
		}
	}
}
