package soccer.model
{
	import jiglib.physics.RigidBody;

	/**
	 * @author Nicolas Zanotti
	 */
	public class HomeState
	{
		public var currentBody:RigidBody;
		public var currentLifetime:int;
		public var rigidBodies:Vector.<RigidBody> = new Vector.<RigidBody>;
		public var rigidBodiesExistenceFrames:Array = [];
	}
}
