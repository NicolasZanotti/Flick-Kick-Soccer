package soccer.model
{

	/**
	 * Object Factory for App-wide elements.
	 * @author Nicolas Zanotti
	 */
	public class Locator
	{
		protected var _main:Main
		protected var _hasAppState:Boolean = false
		protected var _appState:ApplicationState

		public function Locator(main:Main)
		{
			_main = main;
		}

		public function get main():Main
		{
			return _main;
		}

		public function get appState():ApplicationState
		{
			if (!_hasAppState)
			{
				_appState = new ApplicationState(_main)
				_hasAppState = true
			}

			return _appState
		}
	}
}