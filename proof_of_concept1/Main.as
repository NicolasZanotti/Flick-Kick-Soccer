package
{
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Main extends MovieClip
	{
		public var ball:MovieClip;
		public var info:TextField;
		var dragging:Boolean = false;
		var prevX:Number = mouseX;
		var prevY:Number = mouseY;
		var velX:Number = 0;
		var velY:Number = 0;
		var speed:Number = 0;
		var ballVelX:Number = 0;
		var ballVelY:Number = 0;
		
		public function Main()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void
		{
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown)
			ball.addEventListener(MouseEvent.MOUSE_UP, onBallMouseUp)
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onBallMouseUp(event:MouseEvent):void
		{
			ballVelX = velX;
			ballVelY = velY;
			ball.stopDrag();
			dragging = false;
		}

		private function onBallMouseDown(event:MouseEvent):void
		{
			event.updateAfterEvent();

			ball.startDrag();
			dragging = true;
		}

		private function onEnterFrame(event:Event):void
		{
			event.stopPropagation();

			if (!dragging)
			{
				ball.x += ballVelX;
				ball.y += ballVelY;
			}

			velX = mouseX - prevX;
			velY = mouseY - prevY;
			speed = Math.abs(velX) + Math.abs(velY);
			prevX = mouseX;
			prevY = mouseY;
			// info.text = 'Mouse Speed: ' + speed + "\n" + 'Mouse VelocityX: ' + velX + "\n" + 'Mouse VelocityY: ' + velY + "\n";
			info.text = 'ballVelX: ' + ballVelX + "\n" + 'ballVelY: ' + ballVelY;
		}
	}
}
