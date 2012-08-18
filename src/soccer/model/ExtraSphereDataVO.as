package soccer.model
{
	/**
	 * @author Nicolas Zanotti
	 */
	public class ExtraSphereDataVO
	{
		public var indexrigid:int;
		public var countedAsGoal:Boolean;
		public var lifeTime:int;

		public function ExtraSphereDataVO(indexrigid:int, countedAsGoal:Boolean, lifeTime:int)
		{
			this.indexrigid = indexrigid;
			this.countedAsGoal = countedAsGoal;
			this.lifeTime = lifeTime;
		}
	}
}
