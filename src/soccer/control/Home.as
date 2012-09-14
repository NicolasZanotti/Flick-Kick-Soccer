package soccer.control
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	import jiglib.cof.JConfig;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Mesh;
	import jiglib.plugin.away3d4.Away3D4Physics;

	import soccer.model.ExtraSphereDataVO;
	import soccer.model.HomeState;
	import soccer.socket.FlashSocket;
	import soccer.socket.FlashSocketEvent;

	import stoletheshow.control.Controllable;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	/**
	 * @author Nicolas Zanotti
	 */
	public class Home extends Sprite implements Controllable
	{
		public var ct:LinkedController;
		public var tfPoints:TextField;
		private var view:View3D;
		private var physics:Away3D4Physics;
		private var sky:Mesh;
		private var ground:RigidBody, goalPostLeft:RigidBody, goalPostRight:RigidBody, goalPostTop:RigidBody, banner1:RigidBody;
		private var st:HomeState;
		private var socket:FlashSocket;
		CONFIG::HIGH_QUALITY_3D
		{
			import away3d.materials.lightpickers.StaticLightPicker;

			private var lightPicker:StaticLightPicker;
		
		}
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
			addLights();
			addGround();
			addGoal();
			addSky();
			addBanners();

			tfPoints.x = stage.stageWidth - (tfPoints.width + 20);

			CONFIG::HIGH_QUALITY_3D
			{
				ct.events.add(stage, KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}

		private function initSocketConnection():void
		{
			trace("initSocketConnection");

			socket = createSocket();
			socket.addEventListener(FlashSocketEvent.CONNECT, onConnect);
			socket.addEventListener(FlashSocketEvent.MESSAGE, onMessage);
			socket.addEventListener(FlashSocketEvent.IO_ERROR, onError);
			socket.addEventListener(FlashSocketEvent.SECURITY_ERROR, onError);
			socket.addEventListener("kicked", onKicked);

			CONFIG::MOBILE
			{
				import flash.desktop.NativeApplication;

				ct.events.add(NativeApplication.nativeApplication, Event.ACTIVATE, onActivate);
				ct.events.add(NativeApplication.nativeApplication, Event.DEACTIVATE, onDeactivate);
			}
		}

		private function createSocket():FlashSocket
		{
			return new FlashSocket("staging.mattenbach.ch:8126");
		}

		private function onDeactivate(event:Event):void
		{
			if (socket && socket.connected) socket.send("disconnect");
		}

		private function onActivate(event:Event):void
		{
			if (!socket.connecting || !socket.connected) socket = createSocket();
		}

		private function init3DView():void
		{
			view = new View3D();
			addChild(view);

			CONFIG::HIGH_QUALITY_3D
			{
				view.antiAlias = 16;
				trace('view.antiAlias: ' + (view.antiAlias));
			}

			CONFIG::DEBUG
			{
				import away3d.debug.AwayStats;

				this.addChild(new AwayStats(view));
			}

			view.camera.x = 0;
			view.camera.y = 120;
			view.camera.z = -1550;
			view.camera.rotationX = 15;
			view.camera.rotationY = 0;
			view.camera.rotationZ = 0;

			CONFIG::DEBUG
			{
				import soccer.away3d.Object3DModifier;

				var modifier:Object3DModifier = new Object3DModifier(view.camera, 'view.camera');
				addChild(modifier);
			}

			// setup the render loop
			ct.events.add(this, Event.ENTER_FRAME, tick);
		}

		private function initPhysics():void
		{
			CONFIG::MOBILE
			{
				JConfig.solverType = "FAST";
			}

			physics = new Away3D4Physics(view, 8);
		}

		private function addLights():void
		{
			CONFIG::HIGH_QUALITY_3D
			{
				import away3d.lights.DirectionalLight;

				var sun:DirectionalLight = new DirectionalLight();

				sun.color = 0xfffed4;
				sun.ambient = 0.4;
				sun.diffuse = 0.8;

				sun.x = 0;
				sun.y = 1000;
				sun.z = 0;
				sun.rotationX = 135;
				sun.rotationY = 180;
				sun.rotationZ = 0;

				view.scene.addChild(sun);

				lightPicker = new StaticLightPicker([sun]);
			}
		}

		private function addGround():void
		{
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("grass.png"), true, true);
			var segments:uint = 100;
			var groundWidth:int = 5000;

			CONFIG::HIGH_QUALITY_3D
			{
				material.lightPicker = lightPicker;
				segments = 200;
				groundWidth = 6040;
			}

			ground = physics.createGround(material, groundWidth, 3000, 100, 100, true, 0);
			physics.getMesh(ground).geometry.scaleUV(5000 / 200, 3000 / 200);
			ground.movable = false;
			ground.mass = 100;
			ground.friction = 0.9;
		}

		private function addSky():void
		{
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("sky.png"), false, false);
			var widthAndHeight:Number = 4600;

			CONFIG::DESKTOP
			{
				widthAndHeight = 6200;
			}

			sky = new Mesh(new PlaneGeometry(widthAndHeight, widthAndHeight), material);
			sky.x = 0;
			sky.y = 140;
			sky.z = 1520;
			sky.rotationX = -80;
			sky.rotationY = 0;
			sky.rotationZ = 0;

			view.scene.addChild(sky);
		}

		private function addGoal():void
		{
			var material:ColorMaterial = new ColorMaterial(0xFFFFFF);
			CONFIG::HIGH_QUALITY_3D
			{
				material.lightPicker = lightPicker;
			}

			var distanceBetweenPosts:Number = 600;
			var postThickness:Number = 20;
			var postHeight:Number = 200;

			// Left
			goalPostLeft = physics.createCube(material, postThickness, postHeight, postThickness);
			goalPostLeft.movable = false;
			goalPostLeft.x = -(distanceBetweenPosts / 2);
			goalPostLeft.y = (postHeight / 2);
			goalPostLeft.z = -460;

			physics.getMesh(goalPostLeft).geometry.scaleUV(1, 10);

			// Right
			goalPostRight = physics.createCube(material, postThickness, postHeight, postThickness);
			goalPostRight.movable = false;
			goalPostRight.x = distanceBetweenPosts / 2;
			goalPostRight.y = (postHeight / 2) + 1;
			goalPostRight.z = -460;

			physics.getMesh(goalPostRight).geometry.scaleUV(1, 10);

			// Top
			goalPostTop = physics.createCube(material, distanceBetweenPosts + postThickness, postThickness, postThickness);
			goalPostTop.movable = false;
			goalPostTop.x = 0;
			goalPostTop.y = postHeight;
			goalPostTop.z = -460;

			physics.getMesh(goalPostTop).geometry.scaleUV(10, 1);
		}

		private function activateBanner():void
		{
			banner1.movable = true;
		}

		private function addBanners():void
		{
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("banner1.png"), true, false);

			CONFIG::HIGH_QUALITY_3D
			{
				setTimeout(activateBanner, 100);
			}

			banner1 = physics.createCube(material, 512, 128, 10, 20, 20, 20, false);
			banner1.movable = false;
			banner1.mass = 10;
			banner1.friction = 1;
			banner1.x = 740;
			banner1.y = (128 * 0.5);
			banner1.z = -130;
			banner1.rotationX = 0;
			banner1.rotationY = 10;
			banner1.rotationZ = 0;
		}

		private function addSphere():RigidBody
		{
			var radius:Number = 12;
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture("ball.png"), true, false);
			var segments:uint = 15;

			CONFIG::HIGH_QUALITY_3D
			{
				material.lightPicker = lightPicker;
				segments = 30;
			}

			var sphere:RigidBody = physics.createSphere(material, radius, segments, segments, false);
			sphere.friction = 1;
			sphere.restitution = 1;

			// enable mouseevents on mesh
			var sphereMesh:Away3D4Mesh = sphere.skin as Away3D4Mesh;
			sphereMesh.mesh.mouseEnabled = true;
			sphereMesh.mesh.extra = new ExtraSphereDataVO(st.rigidBodies.length, false, st.RIGID_BODY_LIFETIME);
			sphereMesh.mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseClickSphere);

			st.rigidBodies.push(sphere);

			return sphere;
		}

		private function kick(name:String, angle:Number, distance:Number):void
		{
			// the angle is inverted in the browser version
			angle = -angle;

			// only kick the ball if the angle is in the direction of the camera.
			if (angle <= st.LEFT && angle >= st.RIGHT)
			{
				var sphere:RigidBody = addSphere();
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
				st.currentExtraData = physics.getMesh(st.currentBody).extra as ExtraSphereDataVO;

				if (st.currentExtraData.lifeTime > 0)
				{
					st.currentExtraData.lifeTime -= 1;

					// check if a goal was made
					if (!st.currentExtraData.countedAsGoal)
					{
						if ((st.currentBody.z > goalPostTop.z && st.currentBody.z < (goalPostTop.z + st.HITTEST_MARGIN)) && st.currentBody.y < (goalPostTop.y + st.HITTEST_MARGIN) && (st.currentBody.x > goalPostLeft.x && st.currentBody.x < goalPostRight.x))
						{
							st.currentExtraData.countedAsGoal = true;
							st.points += 1;
							tfPoints.text = st.points.toString() + (st.points == 1 ? " Punkt" : " Punkte");
						}
					}

					// temporary hack for dampening the ball movement
					if (st.currentBody.currentState.linVelocity.x > 0) st.currentBody.currentState.linVelocity.x -= 0.1
					if (st.currentBody.currentState.linVelocity.z > 0) st.currentBody.currentState.linVelocity.z -= 0.1
				}
				else if (st.currentExtraData.lifeTime == 0)
				{
					physics.removeBody(st.currentBody);
					view.scene.removeChild(physics.getMesh(st.currentBody));

					st.rigidBodies.splice(i, 1);

					n = st.rigidBodies.length;
				}
			}

			// if (banner1.y < 1) banner1.y = 1;

			physics.step();
			view.render();
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				// kick("Local", -st.STRAIGHT, 595);

				banner1.x = 740;
				banner1.y = 128 * 0.5;
				banner1.z = -130;
				banner1.rotationX = 0;
				banner1.rotationY = 10;
				banner1.rotationZ = 0;
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
			tfPoints.text = "No connection";
		}

		private function onMessage(event:FlashSocketEvent):void
		{
			trace('onMessage: ' + event.data);
		}

		public function dispose():void
		{
			st = null;
		}
	}
}
