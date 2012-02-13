package net.nicoptere.delaunay
{


	/**
	 * @author nicoptere
	 * http://en.nicoptere.net/
	 */

	import flash.display.*;
	import flash.geom.Point;
	import net.nicoptere.delaunay.DelaunayTriangle;
	public class Voronoi 
	{
		/**
		 * draws a Voronoi diagram after a Delaunay triangles set
		 * @param array the delaunay triangles set
		 * @param graphics the output graphics
		 */
		public static function draw( triangles:Vector.<DelaunayTriangle>, graphics:Graphics ):void
		{
			
			if( triangles.length < 3 )return;
			
			var i:int;
			var j:int;
			
			var L:int = triangles.length;
			var t:DelaunayTriangle;
			var tt:DelaunayTriangle;
			
			var p:DelaunayPoint, p0:DelaunayPoint, p1:DelaunayPoint;
			//retrieves the triangles' centers and midSides points 
			for ( i = 0; i < L; i++ )
			{
				
				t = triangles[ i ] as DelaunayTriangle;
				t.getCenter();
				
			}
			
			//compares each triangle to its three neighbours
			L = triangles.length;
			for ( i = 0; i < L; i++ )
			{
				
				t = triangles[ i ] as DelaunayTriangle;
				graphics.lineStyle( 0, 0 );
				t.draw( graphics );
				for ( j = 0; j < L; j++ )
				{
					
					tt = triangles[ j ] as DelaunayTriangle;
					
					// if they have 2 points in common
					if ( 
						( t.p1.equals(tt.p1) || t.p1.equals(tt.p2) ||  t.p1.equals(tt.p3) )
					&& 	(
							( t.p2.equals(tt.p1) || t.p2.equals(tt.p2) ||  t.p2.equals(tt.p3) )  
						||  ( t.p3.equals(tt.p1) || t.p3.equals(tt.p2) ||  t.p3.equals(tt.p3) )
						) 
					)
					
				//	if( p != null && p0 != null && p1 != null )
					{
						
						//then join the centers
						graphics.lineStyle( 0, 0xFFCC00 );
						graphics.moveTo(t.center.x, t.center.y);
						graphics.lineTo(tt.center.x, tt.center.y);
						
						
						
						
						var dp:Point = heightPoint( t.p1, tt.p1, tt.p2 );
						graphics.drawCircle( dp.x, dp.y, 5 );
						
					}	
				}
			}		
			
		}
		static private  function intersection(p1:DelaunayPoint, p2:DelaunayPoint, p3:DelaunayPoint, p4:DelaunayPoint):Point
		{
			var nx:Number, ny:Number, dn:Number;
			var ip:Point = new Point();
			var x4_x3:Number = p4.x - p3.x;
			var y4_y3:Number = p4.y - p3.y;
			var x2_x1:Number = p2.x - p1.x;
			var y2_y1:Number = p2.y - p1.y;
			var x1_x3:Number = p1.x - p3.x;
			var y1_y3:Number = p1.y - p3.y;
			nx = x4_x3 * y1_y3 - y4_y3 * x1_x3;
			ny = x2_x1 * y1_y3 - y2_y1 * x1_x3;
			dn = y4_y3 * x2_x1 - x4_x3 * y2_y1;
			nx /= dn;
			ny /= dn;
			// has intersection
			if(nx>= 0 && nx <= 1 && ny>= 0 && ny <= 1){
				ny = p1.y + nx * y2_y1;
				nx = p1.x + nx * x2_x1;
				ip.x = nx;
				ip.y = ny;
			}else{
				// no intersection
				ip.x = ip.y = -1000;
			}
			return ip
		}

		static private function heightPoint( p:DelaunayPoint, p0:DelaunayPoint, p1:DelaunayPoint ):Point		
		{
			// (d1,d2) is the vector direction of the segment
			var d1:int = p1.x - p0.x;
			var d2:int = p1.y - p0.y;
			
			// (v1, v2) is the vector from end point 1 of segment to point
			var v1:int = p.x - p0.x;
			var v2:int = p.y - p0.y;
		 
			// the dot product between (d1,d2) and (v1, v2)
			var t:int = dotProd(d1, d2, v1, v2);
			var dLengthSquared:int = dotProd(d1, d2, d1, d2);;
			
			
			var ip:Point = new Point();
			if (t <= 0)
			{
				ip.x = p0.x;
				ip.y = p0.y;
		 
			} else if(t >= dLengthSquared) {
				
				ip.x = p1.x;
				ip.y = p1.y;
				
				
			} else {
				
				ip.x = p0.x + ((t / dLengthSquared) * d1);
				ip.y = p0.y + ((t / dLengthSquared) * d2);
			}
			return ip;
		}
		
		static private function getSegmentLength(x1:int, y1:int, x2:int, y2:int):Number 
		{
			return Math.floor(Math.sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1))));
		}
		 
		static private function dotProd(x1:int, y1:int, x2:int, y2:int):int 
		{
			return (x1*x2) + (y1*y2);
		}
	}
}
