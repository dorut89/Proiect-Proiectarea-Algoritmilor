package {
	
	import flash.display.MovieClip;
	import flash.geom.Point;

	public class LineUtils extends MovieClip{
		
		public function smoothMcMaster(points:Vector.<Point>):Vector.<Point>{
			var nL:Array = [];
			var len = points.length;
			if(len < 5){ return points};
			var j, avX, avY;
			var i = len;
			while(i--){
				if(i==len-1 || i==len-2 || i==1 || i==0){
					nL[i] = new Point(points[i].x, points[i].y);
				}else{
					j=5;
					avX = 0; avY = 0;
					while(j--){
						avX += points[i+2-j].x; avY += points[i+2-j].y;
					}
					avX = avX/5; avY = avY/5;
					nL[i] = nL[i] = new Point((points[i].x+avX)/2, (points[i].y+avY)/2);
				}
			}
			var smoothed:Vector.<Point> = new Vector.<Point>;
			for(i=0;i<nL.length;i++){
				smoothed.push(nL[i]);
			}
			return smoothed;
		}
		
		public function simplifyLang(lookAhead:Number, tolerance:Number, pointV:Vector.<Point>):Vector.<Point>{
			var points:Array = new Array();
			for(var k=0;k<pointV.length;k++){
				points.push(pointV[k]);
			}
			if(lookAhead <= 1 || pointV.length < 3){return pointV;};
			var nP:Vector.<Point> = new Vector.<Point>();
			
			var offset:Number;
			var len:Number;
			var count:Number;
			
			len= points.length;
			
			if(lookAhead > len-1){lookAhead = len-1;};
			
			nP[0] =  new Point(points[0].x, points[0].y);		
			count = 1;
			for(var i=0; i<len; i++){
				if(i+lookAhead > len){lookAhead = len - i -1};
				
				offset = recursiveToleranceBar(points, i, lookAhead, tolerance);
								
				if(offset>0 && points[i+offset]){
						nP[count] = new Point(points[i+offset].x, points[i+offset].y);
						i += offset-1;// don't loop through the skipped points
						count++;
				}
			}
			
			nP[count - 1] = new Point(points[len-1].x, points[len-1].y);
			return nP;
		}
		
		
				// this function is called by simplifyLang
		private function recursiveToleranceBar(points, i, lookAhead, tolerance):Number{
			
			var n = lookAhead;
			var cP, cLP, v1, v2, angle, dx, dy;
			
			cP = points[i];// current point
			
			
			if(!points[i+n]){
				return 0;
			}
			
			// the vector through the current point and the max look ahead point
			v1 = {x:points[i+n].x - cP.x, y:points[i+n].y - cP.y};
			// loop through the intermediate points
			
			
			
			for(var j=1; j<=n; j++){
				  // the vector	through the current point and the current intermediate point
				  cLP = points[i+j]; // current look ahead point
				  v2 = {x: cLP.x - cP.x, y:cLP.y - cP.y};
				  angle = Math.acos((v1.x * v2.x + v1.y * v2.y)/(Math.sqrt(v1.y * v1.y + v1.x * v1.x)*Math.sqrt(v2.y * v2.y + v2.x * v2.x)));
				  if(isNaN(angle)){angle = 0;}
				// the hypothenuse is the line between the current point and the current intermediate point
				dx = cP.x - cLP.x; dy = cP.y - cLP.y;
				var lH = Math.sqrt(dx*dx+dy*dy);// lenght of hypothenuse

				
				// length of opposite leg / perpendicular offset 	
				if( Math.sin(angle) * lH >= tolerance){// too long, exceeds tolerance
					n--;
					if(n>0){// back the vector up one point
						//trace('== recursion, new lookAhead '+n);
						return recursiveToleranceBar(points, i, n, tolerance);
					}else{
						//trace('== return 0, all exceed tolerance');
						return 0;// all intermediate points exceed tolerance
					}
					
				}
				
			}
			
			
			return n;
		}
		
		// this function is called by simplifyLang
		private function recursiveToleranceBar_old(points, i, lookAhead, tolerance):Number{
			
			var n = lookAhead;
			
			var cP, cLP, v1, v2, angle, dx, dy;
			var res;
			cP = points[i];// current point
			// the vector through the current point and the max look ahead point
			v1 =  {x:points[i+n].x - cP.x, y:points[i+n].y - cP.y};
			// loop through the intermediate points
			
			for(var j=1; j<=n; j++){
				  // the vector	through the current point and the current intermediate point
				  cLP =  points[i+j]; // current look ahead point
				  v2 = {x: cLP.x - cP.x, y:cLP.y - cP.y};
				  angle = Math.acos((v1.x * v2.x + v1.y * v2.y)/(Math.sqrt(v1.y * v1.y + v1.x * v1.x)*Math.sqrt(v2.y * v2.y + v2.x * v2.x)));
				  if(isNaN(angle)){angle = 0;}
				// the hypothenuse is the line between the current point and the current intermediate point
				dx = cP.x - cLP.x; dy = cP.y - cLP.y;
				var lH = Math.sqrt(dx*dx+dy*dy);// lenght of hypothenuse

				// length of opposite leg / perpendicular offset 	
				if( Math.sin(angle) * lH >= tolerance){// too long, exceeds tolerance
					n--;
					if(n>0){// back the vector up one point
						//trace('== recursion, new lookAhead '+n);
						res = recursiveToleranceBar(points, i, n, tolerance);
						break;
						//return recursiveToleranceBar(points, i, n, tolerance);
					}else{
						res = 0;
						break;
						//trace('== return 0, all exceed tolerance');
						//return 0;// all intermediate points exceed tolerance
					}
					
				}
			}
	
			return res;
			
			
		}	
	}
}



