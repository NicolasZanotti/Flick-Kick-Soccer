package
{
	import flash.display.SimpleButton;

	import com.greensock.TweenLite;
	import com.greensock.data.TweenLiteVars;
	import com.greensock.easing.Expo;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
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
		var speed:Number = 0;
		var ballVelX:Number = 0;
		var ballVelY:Number = 0;
		var angle:Number;

		public function Ball()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event):void
		{
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown)
			ball.addEventListener(MouseEvent.MOUSE_UP, onBallMouseUp)
			reset.addEventListener(MouseEvent.CLICK, onResetClick)
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onResetClick(event:MouseEvent):void
		{
			TweenLite.killTweensOf(ball);
			ball.x = target.x = stage.stageWidth / 2;
			ball.y = target.y = stage.stageHeight / 2;
			ball.stopDrag();
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
		}

		private function onBallMouseUp(event:MouseEvent):void
		{
			ballVelX = velX;
			ballVelY = velY;

			target.x = ball.x;
			target.y = ball.y;



//			var angle:Number = angleToDestination(ball.x, ball.y, (ball.x + velX), (ball.y + velY));

			var angle:Number = Math.atan2((ball.y + velY) - ball.y, (ball.x + velX) - ball.x);

			trace('angle: ' + (angle));
			
			target.x += Math.cos(angle) * speed;
			target.y += Math.sin(angle) * speed;
			
			var distance:Number = Point.distance(new Point(ball.x, ball.y), new Point(target.x, target.y))
			

			ball.stopDrag();
			ball.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown)

			var animation:TweenLiteVars = new TweenLiteVars();
			animation.x(target.x);
			animation.y(target.y);
			animation.onComplete(onAnimationComplete);
			animation.ease(Expo.easeOut);

			TweenLite.to(ball, distance * 0.002, animation);
		}

		public function angleToDestination(originX:Number, originY:Number, destinationX:Number, destinationY:Number):Number
		{
			return Math.atan2(destinationY - originY, destinationX - originX);
		}

		private function onAnimationComplete():void
		{
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
		}

		private function onBallMouseDown(event:MouseEvent):void
		{
			event.updateAfterEvent();
			ball.startDrag();
		}

		private function onEnterFrame(event:Event):void
		{
			event.stopPropagation();
			velX = mouseX - prevX;
			velY = mouseY - prevY;
			speed = Math.abs(velX) + Math.abs(velY);
			prevX = mouseX;
			prevY = mouseY;
			info.text = 'Mouse Speed: ' + speed + "\n" + 'Mouse VelocityX: ' + velX + "\n" + 'Mouse VelocityY: ' + velY + "\n";
		}
	}
}
