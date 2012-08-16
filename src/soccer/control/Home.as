package soccer.control
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.events.MouseEvent3D;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;

	import jiglib.cof.JConfig;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;

	import soccer.model.HomeState;
	import soccer.socket.FlashSocket;
	import soccer.socket.FlashSocketEvent;

	import stoletheshow.control.Controllable;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	/**
	 * TODO: remove after certain time
	 * 
	 * @author Nicolas Zanotti
	 */
	public class Home extends Sprite implements Controllable
	{
		public var ct:LinkedController;
		protected var view:View3D;
		protected var physics:Away3D4Physics;
		protected var ground:RigidBody;
		protected var st:HomeState;
		private var socket:*;

		public function Home()
		{
			ct = new LinkedController(this);
		}

		public function init():void
		{
			st = new HomeState();

			initSocketConnection();
			init3DView();
			initPhysics();
			addGround();

			ct.events.add(stage, KeyboardEvent.KEY_DOWN, onKeyDown);
			ct.events.add(this, MouseEvent.CLICK, onClick);
		}

		private function initSocketConnection():void
		{
			trace("initSocketConnection");

			socket = new FlashSocket("staging.mattenbach.ch:8126");
			socket.addEventListener(FlashSocketEvent.CONNECT, onConnect);
			socket.addEventListener(FlashSocketEvent.MESSAGE, onMessage);
			socket.addEventListener(FlashSocketEvent.IO_ERROR, onError);
			socket.addEventListener(FlashSocketEvent.SECURITY_ERROR, onError);
			socket.addEventListener("kicked", onKicked);
		}

		private function init3DView():void
		{
			view = new View3D();
			view.antiAlias = 0;
			addChild(view);
			this.addChild(new AwayStats(view));

			view.camera.x = -70;
			view.camera.y = 180;
			view.camera.z = -1550;
			view.camera.rotationX = 20;
			view.camera.rotationY = 0;
			view.camera.rotationZ = 0;

//			view.camera.name = "container";
//			var modifier:Object3DModifier = new Object3DModifier(view.camera);
//			addChild(modifier);

			// setup the render loop
			addEventListener(Event.ENTER_FRAME, tick);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		private function initPhysics():void
		{
			JConfig.solverType = "FAST";
			physics = new Away3D4Physics(view, 8);
		}

		private function addGround():void
		{
			var groundMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("grass.png"), true, true);

			ground = physics.createGround(groundMaterial, 5000, 3000, 100, 100, true, 0);
			(ground.skin as Away3D4Mesh).mesh.geometry.scaleUV(20, 12);
			ground.movable = false;
			ground.friction = 0.9;
		}

		private function spawnNewSphere():RigidBody
		{
			var radius:Number = 12;
			var ballMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("ball.png"), true, false);

			var nextSphere:RigidBody = physics.createSphere(ballMaterial, radius, 15, 15, false);
			nextSphere.friction = 1;
			nextSphere.restitution = 1;

			// enable mouseevents on mesh
			var meshSphere:Away3D4Mesh = nextSphere.skin as Away3D4Mesh;
			meshSphere.mesh.mouseEnabled = true;
			meshSphere.mesh.extra = {indexrigid:st.rigidBodies.length};
			meshSphere.mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseClickSphere);

			st.rigidBodies.push(nextSphere);
			st.rigidBodiesExistenceFrames.push(500);

			return nextSphere;
		}

		private function kick(name:String, angle:Number, distance:Number):void
		{
			// the axis in the browser version is the other way around
			angle = -angle;			
			
			
			// only kick the ball if the angle is in the direction of the camera.
			if (angle <= st.LEFT && angle >= st.RIGHT)
			{
				var sphere:RigidBody = spawnNewSphere();
				sphere.x = view.camera.x;
				sphere.y = 24;
				sphere.z = view.camera.z;

				st.linearVelocity.x = (st.STRAIGHT - angle) / st.INCREMENT;
				
				if (distance > st.MAX_DISTANCE) distance = st.MAX_DISTANCE;
				st.linearVelocity.y = distance * st.DISTANCE_MULTIPLIER_Y;
				st.linearVelocity.z = distance * st.DISTANCE_MULTIPLIER_Z;
				
				sphere.setLineVelocity(st.linearVelocity.clone());
			}
		}

		/* ------------------------------------------------------------------------------- */
		/*  Event handlers */
		/* ------------------------------------------------------------------------------- */
		private function tick(event:Event):void
		{
			for (var i:int = 0, n:int = st.rigidBodies.length; i < n; i++)
			{
				st.currentBody = st.rigidBodies[i];
				st.currentLifetime = st.rigidBodiesExistenceFrames[i];

				if (st.currentLifetime > 0)
				{
					st.rigidBodiesExistenceFrames[i] -= 1;

					// temporary hack for dampening the ball movement
					if (st.currentBody.currentState.linVelocity.x > 0) st.currentBody.currentState.linVelocity.x -= 0.1
					if (st.currentBody.currentState.linVelocity.z > 0) st.currentBody.currentState.linVelocity.z -= 0.1
				}
				else if (st.currentLifetime == 0)
				{
					view.scene.removeChild((st.currentBody.skin as Away3D4Mesh).mesh);
					physics.removeBody(st.currentBody);

					st.rigidBodies[i] = null;
					st.rigidBodiesExistenceFrames[i] = -1;
				}
			}

			physics.step();
			view.render();
		}

		private function onClick(event:MouseEvent):void
		{
			// var sphere:RigidBody = spawnNewSphere();
			// sphere.x = view.camera.x;
			// sphere.y = 24;
			// sphere.z = view.camera.z;
			// sphere.setLineVelocity(new Vector3D(0, 40, 50));
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				kick("Local", -st.STRAIGHT, 250);
			}
		}

		private function onMouseClickSphere(mouseEvent:MouseEvent3D):void
		{
			var rigidBodyClick:RigidBody = st.rigidBodies[mouseEvent.target.extra.indexrigid];
			rigidBodyClick.setLineVelocity(new Vector3D(-50 + Math.random() * 100, -50 + Math.random() * 100, -50 + Math.random() * 100));
		}

		/* ------------------------------------------------------------------------------- */
		/*  Socket event handlers */
		/* ------------------------------------------------------------------------------- */
		private function onJoinComplete(name:*):void
		{
			trace("onJoinComplete: " + name);
			trace("listeneing for kicked");
		}

		private function onKicked(event:FlashSocketEvent):void
		{
			var name:String = event.data[0];
			var angle:Number = event.data[1];
			var distance:Number = event.data[2];
			

			trace("onKicked name: " + name);
			trace("onKicked angle: " + angle);
			trace("onKicked distance: " + distance);
			
			kick(name, angle, distance);
		}

		private function onConnect(event:FlashSocketEvent):void
		{
			trace("onConnect");
			socket.emit('join', 'Goal', onJoinComplete);
		}

		private function onError(event:FlashSocketEvent):void
		{
			trace("onError: " + event.data);
		}

		private function onMessage(event:FlashSocketEvent):void
		{
			trace('onMessage: ' + event.data);
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			if (event) tick(event);
		}

		public function dispose():void
		{
			st = null;
		}
	}
}
