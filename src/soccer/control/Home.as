package soccer.control
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;

	import stoletheshow.control.Controllable;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	/**
	 * @author Nicolas Zanotti
	 */
	public class Home extends Sprite implements Controllable
	{
		public var ct:LinkedController;
		// engine variables
		private var _view:View3D;
		// scene objects
		private var _plane:Mesh;

		public function Home()
		{
			ct = new LinkedController(this);
		}

		public function init():void
		{
			trace("init");

			// setup the view
			_view = new View3D();

			addChild(_view);

			// setup the camera
			_view.camera.z = -600;
			_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());

			// setup the scene
			_plane = new Mesh(new PlaneGeometry(700, 700), new ColorMaterial());
			_view.scene.addChild(_plane);

			// setup the render loop
			addEventListener(Event.ENTER_FRAME, tick);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		private function tick(event:Event):void
		{
			event.stopPropagation();
			
			_plane.rotationY += 1;

			_view.render();
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		public function dispose():void
		{
		}
	}
}
