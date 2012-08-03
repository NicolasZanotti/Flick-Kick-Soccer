package soccer.model
{
	import stoletheshow.display.StateChangeable;

	/**
	 * @author Nicolas Zanotti
	 */
	public class ApplicationState implements StateChangeable
	{
		protected var _main:Main;
		/*
		 * Frame labels
		 */
		public static const INTERNAL_LOADER:String = "INTERNAL_LOADER";
		public static const EXTERNAL_LOADER:String = "EXTERNAL_LOADER";
		public static const ERROR:String = "ERROR";
		public static const HOME:String = "HOME";

		public function ApplicationState(main:Main)
		{
			_main = main;
		}

		/* ------------------------------------------------------------------------------- */
		/*  Getters and setters */
		/* ------------------------------------------------------------------------------- */
		public function get state():String
		{
			return _main.state;
		}

		public function set state(name:String):void
		{
			_main.state = name;
		}
	}
}