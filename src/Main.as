package
{
	import soccer.model.ApplicationState;
	import soccer.model.Locator;

	import stoletheshow.control.Controllable;
	import stoletheshow.control.Controller;
	import stoletheshow.display.StatefulMovieClip;
	import stoletheshow.loaders.Bootstrapper;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	/**
	 * @author Nicolas Zanotti
	 */
	public final class Main extends StatefulMovieClip implements Controllable
	{
		public var ct:Controller;
		public var bootStrapper:Bootstrapper;
		public var loaderAnimation:MovieClip;
		public var errorMessageFPVersion:Sprite;
		private var _locator:Locator;

		public function Main()
		{
			ct = new Controller(this);
		}

		/* ------------------------------------------------------------------------------- */
		/*  Controller Methods */
		/* ------------------------------------------------------------------------------- */
		public function init():void
		{
			bootStrapper = new Bootstrapper(this, 4).withLoaderAnimation(loaderAnimation).withPlayerVerionError(11, errorMessageFPVersion);

			// Configure stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// Add listeners
			ct.events.add(bootStrapper, Bootstrapper.CLASSES_FRAME_COMPLETE, onClassesFrameComplete);
			ct.events.add(bootStrapper, Bootstrapper.TOTALFRAMES_COMPLETE, onTotalFramesComplete);
			ct.events.add(EventDispatcher(loaderInfo["uncaughtErrorEvents"]), "uncaughtError", onGlobalError);
			ct.events.add(stage, KeyboardEvent.KEY_DOWN, onKeyDown);

			CONFIG::MOBILE
			{
				import flash.desktop.NativeApplication;
				import flash.system.Capabilities;

				trace(Capabilities.screenResolutionX);
				trace(Capabilities.screenResolutionY);

				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			}

			bootStrapper.init();
		}

		public function dispose():void
		{
			_locator = null;
		}

		/* ------------------------------------------------------------------------------- */
		/*  Event Handlers */
		/* ------------------------------------------------------------------------------- */
		private function onKeyDown(event:KeyboardEvent):void
		{
			event.stopPropagation();
			event.preventDefault();

			if (state != ApplicationState.HOME && (event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.BACKSPACE))
			{
				trace("returning home");
				state = ApplicationState.HOME;
			}
		}

		private function onActivate(event:Event):void
		{
			trace("activate");
		}

		private function onDeactivate(event:Event):void
		{
			trace("deactivate");

			// TODO stop all sounds
		}

		private function onClassesFrameComplete(e:Event = null):void
		{
			_locator = new Locator(this);
		}

		private function onTotalFramesComplete(e:Event = null):void
		{
			ct.events.remove(bootStrapper, Bootstrapper.CLASSES_FRAME_COMPLETE, onClassesFrameComplete);
			ct.events.remove(bootStrapper, Bootstrapper.TOTALFRAMES_COMPLETE, onTotalFramesComplete);
			bootStrapper = null;
		}

		private function onGlobalError(e:ErrorEvent):void
		{
			state = ApplicationState.ERROR;

			function showErrorOnFrameRefresh():void
			{
				loaderAnimation.gotoAndStop(1);
				loaderAnimation.tf.text = e.text ? e.text : "An Error occurred. Please reload.";
			}
			setTimeout(showErrorOnFrameRefresh, Math.ceil(1000 / loaderInfo.frameRate));
		}

		/* ------------------------------------------------------------------------------- */
		/*  Getters and Setters */
		/* ------------------------------------------------------------------------------- */
		public function get locator():Locator
		{
			return _locator;
		}
	}
}