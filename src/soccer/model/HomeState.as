package soccer.model
{
	import flash.geom.Vector3D;

	import jiglib.physics.RigidBody;

	/**
	 * @author Nicolas Zanotti
	 */
	public class HomeState
	{
		public const LEFT:Number = 3.14;
		public const STRAIGHT:Number = 1.57;
		public const RIGHT:Number = 0;
		public const MAX_FORCE:Number = 80;
		public const MAX_DISTANCE:Number = 700;
		public const INCREMENT:Number = STRAIGHT / MAX_FORCE;
		public const DISTANCE_MULTIPLIER_Y:Number = .12;
		public const DISTANCE_MULTIPLIER_Z:Number = .16;
		public const RIGID_BODY_LIFETIME:int = 400;
		public const HITTEST_MARGIN:int = 25;
		public var currentBody:RigidBody;
		public var currentExtraData:ExtraSphereDataVO;
		public var rigidBodies:Vector.<RigidBody> = new Vector.<RigidBody>;
		public var linearVelocity:Vector3D = new Vector3D();
		public var points:uint;
		
	}
}
