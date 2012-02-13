package{
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Vector3D
		
	import net.nicoptere.delaunay.*;
	import Point3D;
	
	public class RaceTrack{
		
		public var outerPath:Vector.<Point>;
		public var innerPath:Vector.<Point>;
		public var distancePath:Vector.<Point3D>;
		public var startLine:Array;
		public var startPoint:Point;
		public var raceDirection:int;
		public var nrLaps:int;
		public var refTime:Number;
		public var carRotation:Number;
		
		public var mapProcesed:Boolean;
		
		public var indices:Vector.<int>;
		public var uvts:Vector.<Number>
		public var vertices:Vector.<Number>
		
		public var bitmap:Bitmap;
		
		public function RaceTrack(bmp:Bitmap,startP:Point,dir:int,laps:int,refT:Number,rot:Number){
			bitmap = bmp;
			startPoint = startP;
			raceDirection = dir;
			nrLaps = laps;
			refTime = refT;
			carRotation = rot;
			
			mapProcesed = false;
			
			distancePath = new Vector.<Point3D>;
			
			indices = new Vector.<int>();
			uvts = new Vector.<Number>();
			vertices = new Vector.<Number>();
		}
		
		public function init(){
			var vectorizer:VectorizeMap = new VectorizeMap(bitmap);
			vectorizer.startWork(startPoint,raceDirection,carRotation);
			//if(mapProcesed=vectorizer.getSucces() == false)
				//return;
			outerPath = vectorizer.getOuter();
			var LU:LineUtils = new LineUtils();
			outerPath = LU.simplifyLang(11,1,outerPath);
			outerPath = LU.smoothMcMaster(outerPath);
			innerPath = vectorizer.getInner();
			innerPath = LU.simplifyLang(11,1,innerPath);
			innerPath = LU.smoothMcMaster(innerPath);
			startLine = vectorizer.startLine;
			
			var triangles:Vector.<DelaunayTriangle> = new Vector.<DelaunayTriangle>();
			triangles = Delaunay.Triangulate(outerPath.concat(innerPath));
			var pointTester:PolygonTest = new PolygonTest();
			var triang:Vector.<DelaunayTriangle> = new Vector.<DelaunayTriangle>;
			for(var k=0;k<triangles.length;k++){
				if(pointTester.insidePolygon(innerPath,triangles[k])==false && 
					pointTester.insidePolygon(outerPath,triangles[k])==true)							
							triang.push(triangles[k]);
			}
			
			var t:DelaunayTriangle;
			var indice=0;
			var crt=0;
			
			while (triang.length>0 )
			{
				t = ( triang.shift() as DelaunayTriangle );
				//t = locateTrianglePoints(t);
				
				vertices.push(t.p1.x,t.p1.y,
							  t.p2.x,t.p2.y,
							  t.p3.x,t.p3.y);
				
				indices.push(indice,indice+1,indice+2);				
				uvts.push(0,0,0,1,1,1);
				indice +=3;		
			}
			
			var prevP:Point;
			for(var l=0;l<outerPath.length;l++){
				if(l == 0){
					distancePath.push(new Point3D(outerPath[l].x,outerPath[l].y));
				}else{
					distancePath.push(new Point3D(outerPath[l].x,outerPath[l].y,
							distancePath[l-1].l + Point.distance(outerPath[l],prevP)));
				}
				prevP = outerPath[l];
			}
		}
		
		private function locateTrianglePoints(who:DelaunayTriangle):DelaunayTriangle{
			var count:uint;
			
			who.p1.where = (myIndexOf(innerPath,who.p1) != -1) ? "inner" : "outer";
			who.p2.where = (myIndexOf(innerPath,who.p2) != -1) ? "inner" : "outer";
			who.p3.where = (myIndexOf(innerPath,who.p3) != -1) ? "inner" : "outer";
			if(who.p1.where == "inner") count++;
			if(who.p2.where == "inner") count++;
			if(who.p3.where == "inner") count++;
			
			if(who.p1.where != who.p2.where){
				who.line = "12";
			}else if(who.p1.where != who.p3.where){
				who.line = "13";
			}else if(who.p2.where != who.p3.where){
				who.line = "23";
			}else{
				who.line = "00";
				trace("PROBLEM",who.p1.where,who.p2.where,who.p3.where);
			}
			
			return who;
		}
		private function myIndexOf(where:Vector.<Point>,who:DelaunayPoint):int{
			for(var i=0;i<where.length;i++){
				if(where[i].x == who.x && where[i].y == who.y)
					return i;
			}
			return -1;
		}
	}
}