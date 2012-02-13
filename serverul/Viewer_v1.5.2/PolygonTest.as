package  
{
	import flash.geom.Point;
	import net.nicoptere.delaunay.DelaunayTriangle;
	import net.nicoptere.delaunay.DelaunayPoint;
	
	public class PolygonTest
	{
		
		public function PolygonTest(){}		
		
		
		public function insidePolygon(pointList:Vector.<Point>, triangle:DelaunayTriangle):Boolean
		{
			
			var counter:int = 0;
			var i:int;
			var xinters:Number;
			var p1:Point;
			var p2:Point;
			var n:int = pointList.length;
			triangle.getCenter();
			var p:DelaunayPoint = triangle.center;
			
			p1 = pointList[0];
			for (i = 1; i <= n; i++)
			{
				p2 = pointList[i % n];
				if (p.y > Math.min(p1.y, p2.y))
				{
					if (p.y <= Math.max(p1.y, p2.y))
					{
						if (p.x <= Math.max(p1.x, p2.x))
						{
							if (p1.y != p2.y) {
								xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
								if (p1.x == p2.x || p.x <= xinters)
									counter++;
							}
						}
					}
				}
				p1 = p2;
			}
			if (counter % 2 == 0)
			{
				return(false);
			}
			else
			{
				return(true);
			}
		}
		
		
	}

}