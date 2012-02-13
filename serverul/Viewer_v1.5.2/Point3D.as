package{
	
	import flash.geom.Point;
	
	public class Point3D extends Point{
		
		public var l:Number;
		
		public function Point3D(x:Number=0,y:Number=0,len:Number=0){
			l = len;
			super(x,y);
		}
	}
}