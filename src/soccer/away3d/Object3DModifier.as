package soccer.away3d
{
	import stoletheshow.control.Controllable;
	import stoletheshow.control.Controller;
	import away3d.core.base.Object3D;

	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * Allows a 3D object to be controlled with the keyboard.
	 * 
	 * <code>
	 * 		object3D.name = "container";
	 * 		var modifier:Object3DModifier = new Object3DModifier(object3D);
	 *		addChild(modifier);
	 * </code>
	 * 
	 * @author Nicolas Schudel
	 */
	public class Object3DModifier extends Sprite implements Controllable
	{
		public var ct:Controller;
		public var increment:Number = 10;
		protected var _object:Object3D;
		protected var _name:String;

		public function Object3DModifier(object:Object3D, objectNameForTrace:String = "object")
		{
			_object = object;
			_name = objectNameForTrace;
			ct = new Controller(this);
		}

		public function init():void
		{
			ct.events.add(stage, KeyboardEvent.KEY_DOWN, onKeyDown);

			trace("W/S/A/D: Forward/Backward/Left/Right");
			trace("1/2: RotationZ");
			trace("3/4: RotationX");
			trace("5/6: RotationY");
		}

		public function dispose():void
		{
			_object = null;
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			// TODO Make visible controles instead of Keyboard.

			switch (event.keyCode)
			{
				case Keyboard.UP:
					_object.y += increment;
					trace(_name + '.y: ' + (_object.y));
					break;
				case Keyboard.DOWN :
					_object.y -= increment;
					trace(_name + '.y: ' + (_object.y));
					break;
				case Keyboard.A :
					_object.x -= increment;
					trace(_name + '.x: ' + (_object.x));
					break;
				case Keyboard.D :
					_object.x += increment;
					trace(_name + '.x: ' + (_object.x));
					break;
				case Keyboard.S:
					_object.z -= increment;
					trace(_name + '.z: ' + (_object.z));
					break;
				case Keyboard.W :
					_object.z += increment;
					trace(_name + '.z: ' + (_object.z));
					break;
				case Keyboard.NUMBER_1:
					_object.rotationZ -= increment;
					trace(_name + '.rotationZ: ' + (_object.rotationZ));
					break;
				case Keyboard.NUMBER_2:
					_object.rotationZ += increment;
					trace(_name + '.rotationZ: ' + (_object.rotationZ));
					break;
				case Keyboard.NUMBER_3:
					_object.rotationX += increment;
					trace(_name + '.rotationX: ' + (_object.rotationX));
					break;
				case Keyboard.NUMBER_4:
					_object.rotationX -= increment;
					trace(_name + '.rotationX: ' + (_object.rotationX));
					break;
				case Keyboard.NUMBER_5 :
					_object.rotationY += increment;
					trace(_name + '.rotationY: ' + (_object.rotationY));
					break;
				case Keyboard.NUMBER_6 :
					_object.rotationY -= increment;
					trace(_name + '.rotationY: ' + (_object.rotationY));
					break;
				case Keyboard.NUMPAD_ADD :
					increment += 1;
					break;
				case Keyboard.NUMPAD_SUBTRACT :
					increment -= 1;
					break;
				case 32 :
					trace("/*");
					trace(_name + ".x = " + _object.x + ";");
					trace(_name + ".y = " + _object.y + ";");
					trace(_name + ".z = " + _object.z + ";");
					trace(_name + ".rotationX = " + _object.rotationX + ";");
					trace(_name + ".rotationY = " + _object.rotationY + ";");
					trace(_name + ".rotationZ = " + _object.rotationZ + ";");
					trace("*/");
					break;
			}
		}
	}
}
