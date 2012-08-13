package
{
	import com.greensock.TweenLite;
	import com.greensock.data.TweenLiteVars;
	import com.greensock.easing.Expo;

	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class Ball extends MovieClip
	{
		public var ball:MovieClip;
		public var info:TextField;
		public var target:MovieClip;
		public var reset:SimpleButton;
		var prevX:Number = mouseX;
		var prevY:Number = mouseY;
		var velX:Number = 0;
		var velY:Number = 0;
		var ballStartX:Number = 0;
		var ballStartY:Number = 0;
		var speed:Number = 0;
		var SPEED_MULTIPLIER:Number = 6;
		var MINIMUM_SPEED:Number = 3;
		var DURATION_MULTIPLIER:Number = 0.005;
		var angle:Number;
		var distance:Number;
		var distanceX:Number;
		var distanceY:Number;
		var animation:TweenLiteVars;

		public function Ball()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(event:Event):void
		{
			// Configure components
			animation = new TweenLiteVars();
			animation.onComplete(onAnimationComplete);
			animation.ease(Expo.easeOut);
			// Expo.easeOut

			// target.visible = false;

			// Configure listeners
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown)
			ball.addEventListener(MouseEvent.MOUSE_UP, onBallMouseUp)
			reset.addEventListener(MouseEvent.CLICK, onResetClick)
		}

		private function onResetClick(event:MouseEvent):void
		{
			TweenLite.killTweensOf(ball);
			ball.x = target.x = stage.stageWidth / 2;
			ball.y = target.y = stage.stageHeight / 2;
			ball.stopDrag();
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
		}

		private function onBallMouseDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)
			ball.startDrag();

			ballStartX = ball.x;
			ballStartY = ball.y;
		}

		private function onBallMouseUp(event:MouseEvent):void
		{
			ball.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)

			target.x = ball.x;
			target.y = ball.y;

			if (ballStartX != ball.x && ballStartY != ball.y)
			{
				ball.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown)
				
				angle = Math.atan2((ball.y + velY) - ball.y, (ball.x + velX) - ball.x);

				target.x += Math.cos(angle) * speed;
				target.y += Math.sin(angle) * speed;

				distanceX = ball.x - target.x;
				distanceY = ball.y - target.y;
				distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

				animation.x(target.x);
				animation.y(target.y);
				
				TweenLite.to(ball, distance * DURATION_MULTIPLIER, animation);
			}
		}

		private function onAnimationComplete():void
		{
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
		}

		private function onMouseMove(event:MouseEvent):void
		{
			event.stopPropagation();
			velX = mouseX - prevX;
			velY = mouseY - prevY;
			speed = Math.abs(velX) + Math.abs(velY);
			speed = speed > MINIMUM_SPEED ? speed * SPEED_MULTIPLIER : 0;

			prevX = mouseX;
			prevY = mouseY;
			info.text = 'Mouse Speed: ' + speed + "\n" + 'Mouse VelocityX: ' + velX + "\n" + 'Mouse VelocityY: ' + velY + "\n";
		}
	}
}
