package soccer.control
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	import awayphysics.dynamics.AWPDynamicsWorld;

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
		private var _view:View3D;
		private var _plane:Mesh;
		private var _physicsWorld:AWPDynamicsWorld;


		public function Home()
		{
			ct = new LinkedController(this);
		}

		public function init():void
		{
			this.addChild(new AwayStats(_view));
			
			// setup the view
			_view = new View3D();
			_view.antiAlias = 0;

			addChild(_view);

			// setup the camera
			_view.camera.z = -600;
			_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());

			// setup the scene
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("grass.png"), true, true);
			var geometry:PlaneGeometry = new PlaneGeometry(1000, 1000, 100, 100);

			_plane = new Mesh(geometry, material);
			_plane.geometry.scaleUV(4,4);
			_view.scene.addChild(_plane);
			
			// init the physics world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			

			// setup the render loop
			addEventListener(Event.ENTER_FRAME, tick);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		/* ------------------------------------------------------------------------------- */
		/*  Event handlers */
		/* ------------------------------------------------------------------------------- */
		private function tick(event:Event):void
		{
			event.stopPropagation();

			_view.render();
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			if (event) tick(event);
		}

		public function dispose():void
		{
		}
	}
}
