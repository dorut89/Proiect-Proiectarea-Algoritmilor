package net.nicoptere.delaunay
{


	//Credit to Paul Bourke (pbourke@swin.edu.au) for the original Fortran 77 Program :))
	//Converted to a standalone C# 2.0 library by Morten Nielsen (www.iter.dk)
	//Check out: http://astronomy.swin.edu.au/~pbourke/terrain/triangulate/
	//You can use this code however you like providing the above credits remain in tact

	/**
	 * @author nicoptere
	 * http://en.nicoptere.net/
	 */
	import net.nicoptere.delaunay.DelaunayPoint;
	import flash.display.Graphics;
	
	public class DelaunayTriangle 
	{
		//points of the DelaunayTriangle
		public var p1:DelaunayPoint;
		public var p2:DelaunayPoint;
		public var p3:DelaunayPoint;
		
		public var line:String;
		
		//gravity center
		public var center:DelaunayPoint;
		
		//middle of the sides
		public var mid0:DelaunayPoint;//p1 > p2
		public var mid1:DelaunayPoint;//p2 > p3
		public var mid2:DelaunayPoint;//p3 > p1
		
		public function DelaunayTriangle( p1:DelaunayPoint, p2:DelaunayPoint, p3:DelaunayPoint )
		{
		
			this.p1 = p1;
			this.p2 = p2;
			this.p3 = p3;
			
		}
		
		/**
		 * retrieves the gravity center of the DelaunayTriangle
		 */
		public function getCenter():void
		{
			
			if( center == null ) center = new DelaunayPoint( 0,0 );
			center.x = ( p1.x + p2.x + p3.x ) / 3;
			center.y = ( p1.y + p2.y + p3.y ) / 3;
			
		}
		
		/**
		 * retrieves the midPoint of the DelaunayTriangle's sides. might be useful in some cases
		*/
		public function getSidesCenters():void
		{
			if( mid0 == null || mid1 == null || mid2 == null )
			{
				mid0 = new DelaunayPoint( 0, 0 );
				mid1 = new DelaunayPoint( 0, 0 );
				mid2 = new DelaunayPoint( 0, 0 );
			} 
			
			mid0.x = p1.x + ( p2.x - p1.x )/2;
			mid0.y = p1.y + ( p2.y - p1.y )/2;
			
			mid1.x = p2.x + ( p3.x - p2.x )/2;
			mid1.y = p2.y + ( p3.y - p2.y )/2;	
			
			mid2.x = p3.x + ( p1.x - p3.x )/2;
			mid2.y = p3.y + ( p1.y - p3.y )/2;
		}
		
		public function draw( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( p2.x, p2.y );
			g.lineTo( p3.x, p3.y );
			g.lineTo( p1.x, p1.y );
		}
	}
}
