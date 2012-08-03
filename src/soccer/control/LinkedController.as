package soccer.control
{
	import soccer.model.Locator;

	import stoletheshow.control.Controllable;
	import stoletheshow.control.Controller;


	/**
	 * Link the controller to the models
	 *
	 * @author Nicolas Zanotti
	 */
	public class LinkedController extends Controller
	{
		public function LinkedController(owner : Controllable)
		{
			super(owner);
		}

		public function get locator() : Locator
		{
			return (_owner.root as Main).locator;
		}
	}
}