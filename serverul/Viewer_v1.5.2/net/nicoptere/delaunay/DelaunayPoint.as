package net.nicoptere.delaunay
{

	/**
	 * @author nicoptere
	 */
	public class DelaunayPoint
	{
		
		public var id:int;
		public var x:Number;
		public var y:Number;
		public var where:String;
		
		public function DelaunayPoint( x:Number, y:Number, id:int = -1 )
		{
			this.x = x;
			this.y = y;
			if( id != -1 ) this.id = id;
		}
		
		public function equals( other:DelaunayPoint ):Boolean
		{
			return ( x == other.x && y == other.y );
		}
	
	}
}
