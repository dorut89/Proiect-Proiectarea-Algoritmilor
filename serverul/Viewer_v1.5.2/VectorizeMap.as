package{
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.filters.ConvolutionFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class VectorizeMap extends MovieClip{
		
		var edge:ConvolutionFilter;
		var filtersArray:Array;
		var matrixX:Number;
		var matrixY:Number;
		var matrix:Array;
		var directions:Array;
		var path:Vector.<Point>;
		var path2:Vector.<Point>;
		var bitmap:Bitmap;
		var myBitmapData:BitmapData;
		var bmpData:BitmapData;
		var startLine:Array = [];
		//var _succes:Boolean;
		public function VectorizeMap(bitmapP:Bitmap){
			edge = new ConvolutionFilter();
			filtersArray = new Array();
			matrixX = 3;
			matrixY = 3;
			matrix = new Array( 0, -1, 0, -1, 4, -1, 0, -1, 0 );
			directions = new Array(	new Point(0,-1),new Point(1,-1),new Point(1,0),new Point(1,1),
					     new Point(0,1),new Point(-1,1),new Point(-1,0),new Point(-1,-1),new Point(0,-1));
			path = new Vector.<Point>();
			path2 = new Vector.<Point>();
			
			myBitmapData = new BitmapData(bitmapP.bitmapData.width,bitmapP.bitmapData.height,false,0xFF000000);
			bmpData = new BitmapData(bitmapP.bitmapData.width,bitmapP.bitmapData.height,false,0xFF000000);
			myBitmapData = bitmapP.bitmapData.clone();
			this.bitmap = new Bitmap(myBitmapData);
			
			//_succes = false;
		}
		
		public function startWork(startPt:Point,dir:int,rot:Number){
			var succes:Boolean = findEdges();
			determineStartLine(startPt,rot);
			trace("going on x");
			var startPoint:Point = determineStartPoint(startPt,1,"y");
			trace("Start point: " + startPoint);
			generatePath(startPoint,dir,"1");
			coloratePath(0xFF00FF00);
			startPoint = determineStartPoint(startPt,-1,"y");
			trace("Start point: " + startPoint);
			if(startPoint.equals(new Point()) == true){
				coloratePath(0xFFFFFFFF);
				trace("este null: going on x");
				startPoint = determineStartPoint(startPt,1,"x");
				trace("Start point: " + startPoint);
				path = new Vector.<Point>;
				generatePath(startPoint,dir,"1");
				coloratePath(0xFF00FF00);
				startPoint = determineStartPoint(startPt,-1,"x");
				trace("Start point: " + startPoint);
				if(startPoint.equals(new Point()) == true){
					coloratePath(0xFFFFFFFF);
					trace("este null: going on xy");
					startPoint = determineStartPoint(startPt,1,"xy");
					trace("Start point: " + startPoint);
					path = new Vector.<Point>;
					generatePath(startPoint,dir,"1");
					coloratePath(0xFF00FF00);
					startPoint = determineStartPoint(startPt,-1,"xy");
					trace("Start point: " + startPoint);
					//if(startPoint.equals(new Point()) == true){
						//MovieClip(root).alert.showAlert("Imaginea nu a putut fi procesata... :(");
						//_succes = false;
						//return;
					//}
				}
			}
			generatePath(startPoint,dir,"2");
			//_succes = true;
			//generateSecondPath();
			////traceVect();
		}
		public function getSucces(){
			
			//return _succes;
		}
		public function findEdges():Boolean{
			edge.matrixX = matrixX;
			edge.matrixY = matrixY;
			edge.matrix = matrix;
			
			filtersArray.push(edge);
			
			bitmap.filters = filtersArray;
			bmpData.draw(bitmap);
			var bit:Bitmap = new Bitmap(bmpData);
			//addChild(bit);
			bit.x = 300;
			myBitmapData.draw(bitmap);
			return true;
		}
		public function coloratePath(col:uint){
			var j:int;
			for(j=0;j<path.length;j++){
				myBitmapData.setPixel32(path[j].x,path[j].y,col);
			}
		}
		public function determineStartLine(pt:Point,rot:Number){
			var i;
			var m1:Number = Math.tan(-rot*Math.PI/180);
			var m2:Number = -1/m1;
			
			var xNew:Number;
			var yNew:Number;
			var temp;
			if(Math.abs(rot) != 0 && Math.abs(rot) != 90 && Math.abs(rot) != 180){
				for(i=pt.y+1;i<bitmap.height;i++){
					xNew = (i - pt.y)/m2 + pt.x;
					if((temp = myBitmapData.getPixel32(xNew,i)) == 0xFFFFFFFF || 
							   myBitmapData.getPixel32(xNew,i) == 0){
						startLine.push(new Point(xNew,i));
						break;
					}
				}
				for(i=pt.y-1;i>0;i--){
					xNew = (i - pt.y)/m2 + pt.x;
					if((temp = myBitmapData.getPixel32(xNew,i)) == 0xFFFFFFFF || 
									   myBitmapData.getPixel32(xNew,i) == 0){
						startLine.push(new Point(xNew,i));
						break;
					}
				}
			}else if(Math.abs(rot) == 0 || Math.abs(rot) == 180){
				for(i=pt.y+1;i<bitmap.height;i++){
					yNew = i;
					if((temp = myBitmapData.getPixel32(pt.x,i)) == 0xFFFFFFFF || 
							   myBitmapData.getPixel32(pt.x,i) == 0){
						startLine.push(new Point(pt.x,i));
						break;
					}
				}
				for(i=pt.y-1;i>0;i--){
					yNew = i;
					if((temp = myBitmapData.getPixel32(pt.x,i)) == 0xFFFFFFFF || 
									   myBitmapData.getPixel32(pt.x,i) == 0){
						startLine.push(new Point(pt.x,i));
						break;
					}
				}
			}else if(Math.abs(rot) == 90){
				trace("90");
				for(i=pt.x+1;i<bitmap.width;i++){
					xNew = i;
					if((temp = myBitmapData.getPixel32(i,pt.y)) == 0xFFFFFFFF || 
							   myBitmapData.getPixel32(i,pt.y) == 0){
						startLine.push(new Point(i,pt.y));
						break;
					}
				}
				for(i=pt.x-1;i>0;i--){
					xNew = i;
					if((temp = myBitmapData.getPixel32(i,pt.y)) == 0xFFFFFFFF || 
									   myBitmapData.getPixel32(i,pt.y) == 0){
						startLine.push(new Point(i,pt.y));
						break;
					}
				}
			}
		}
		public function determineStartPoint(pt:Point,dir:int,axys:String):Point{
			
			
			var bit:Bitmap = new Bitmap(myBitmapData);
			//addChild(bit);
			//bit.x = 300;
			var cc:Cros = new Cros();
			cc.name = "cros"
			
			var i:int;
			var j:int;
			//addChild(bitmap);
			addChild(cc);
			getChildByName("cros").x = pt.x+300;
			getChildByName("cros").y = pt.y;
			//trace("!!!!!!!!!!!!!!!!!pixel: ",pt.x,pt.y,myBitmapData.getPixel32(pt.x,pt.y));
			if(axys == "y"){
				if(dir == 1){
					//trace("Ma uit in jos");
					for(i=pt.y+1;i<bitmap.height;i++){
						////trace("pixel: ",pt.x,i,myBitmapData.getPixel(pt.x,i));
						if(myBitmapData.getPixel32(pt.x,i) == 0xFFFFFFFF){
							//trace("Am gasit jos: ",pt.x,i);
							return new Point(pt.x,i);
						}
					}
				}else if(dir == -1){
					//trace("Ma uit in sus");
					for(i=pt.y-1;i>0;i--){
						////trace("pixel: ",pt.x-1,i,myBitmapData.getPixel32(pt.x-1,i));
						if(myBitmapData.getPixel32(pt.x-1,i) == 0xFFFFFFFF){

							return new Point(pt.x-1,i);
							
						}else if(myBitmapData.getPixel32(pt.x,i) == 0xFF00FF00){
							//trace("SUS null");
							return new Point();
						}
					}
				}
			}else if(axys == "x"){
				if(dir == 1){
					//trace("Ma uit dreapta");
					for(i=pt.x;i<bitmap.width;i++){
						////trace("pixel: ",pt.x,i,bmpData.getPixel(pt.x,i));
						if(myBitmapData.getPixel32(i,pt.y) == 0xFFFFFFFF){
							return new Point(i,pt.y);
						}
					}
				}else if(dir == -1){
					//trace("Ma uit la stanga");
					for(i=pt.x;i>0;i--){
						//trace("pixel: ",i,pt.y,myBitmapData.getPixel32(i,pt.y));
						if(myBitmapData.getPixel32(i,pt.y) == 0xFFFFFFFF){
							
							return new Point(i,pt.y);
						}else if(myBitmapData.getPixel32(i,pt.y) == 0xFF00FF00){
							//trace("SUS null");
							return new Point();
						}
					}
				}
			}else if(axys == "xy"){
				if(dir == 1){
					//trace("Ma uit dreapta");
					for(i=pt.x,j=pt.y;i<bitmap.width,j<bitmap.height;i++,j++){
						////trace("pixel: ",pt.x,i,bmpData.getPixel(pt.x,i));
						if(myBitmapData.getPixel32(i,j) == 0xFFFFFFFF){
							return new Point(i,j);
						}
					}
				}else if(dir == -1){
					//trace("Ma uit la stanga");
					for(i=pt.x,j=pt.y;i>0,j>0;i--,j--){
						//trace("pixel: ",i,pt.y,myBitmapData.getPixel32(i,pt.y));
						if(myBitmapData.getPixel32(i,j) == 0xFFFFFFFF){							
							return new Point(i,j);
						}else if(myBitmapData.getPixel32(i,j) == 0xFF00FF00){
							//trace("SUS null");
							return new Point();
						}
					}
				}
			}
			//trace("end function");
			
			return new Point();
		}
		public function generatePath(startPt:Point,dir:int,who:String){
			var stepPt:Point = new Point();
			var prevPt:Point = new Point();
			var curPt:Point = new Point();
			var paths:Vector.<Point> = new Vector.<Point>;
			paths.push(startPt);
			//("start: "+startPt);
			prevPt = startPt;
			for(var i=5*dir;i<5*(1+dir);i++){
				stepPt = prevPt.add(directions[i]);
				if(bmpData.getPixel(int(stepPt.x),int(stepPt.y)) == 0xFFFFFF)
					break;
			}

			paths.push(stepPt);
			////trace("second: "+stepPt);
			//prevPt = stepPt;
			var nr = 0;
			while(stepPt.equals(startPt) == false){
				nr++;
				curPt = stepPt;
				for(i=0;i<8;i++){					
					stepPt = curPt.add(directions[i]);
					////trace("Prev :" + prevPt + ";Step: "+stepPt+"Pixel: "+bmpData.getPixel32(int(stepPt.x),int(stepPt.y))+" _ "+(stepPt != prevPt));
					if((bmpData.getPixel32(int(stepPt.x),int(stepPt.y)) == 0xFFFFFFFF) &&
							(stepPt.equals(prevPt)==false)){
						
						break;
					}
				}
				paths.push(stepPt);
				////trace(stepPt);
				prevPt = curPt;
				
			}
			if(who == "1"){
				path = paths;
			}else if(who == "2"){
				path2 = paths;
			}
		}
		/*
		
		*/
		public function getOuter():Vector.<Point>{
			return (path.length > path2.length) ? path : path2;
		}
		public function getInner():Vector.<Point>{
			return (path.length > path2.length) ? path2 : path;
		}
		
		public function traceVect(){
			var vec:Vector.<uint> = bmpData.getVector(new Rectangle(0,0,bitmap.width,bitmap.height));
			var str:String;
			str = "-";
			var bmp:BitmapData = new BitmapData(bitmap.width,bitmap.height);
			
			for(var i=0;i<bitmap.height;i++){
				for(var j=0;j<bitmap.width;j++){
					/*if(vec[i*bitmap.width+j] == 4294967295)
						str += "0";
					else 		
						str +="3";*/
					var cul:uint = bmpData.getPixel(j,i);
					if(cul == 0)
						cul = 0xFF0000;
					bmp.setPixel(j,i,cul);
				}
				//trace(str+"-");
				str ="-";
			}
			var img:Bitmap = new Bitmap(bmp);
			addChild(img);
			/*for(var i = 0;i<100;i+=3){
				str +=path[i].x.toString()+",0,"+path[i].y.toString()+",";
				str +=path[i+1].x.toString()+",0,"+path[i+1].y.toString()+",";
				str +=path[i+2].x.toString()+",0,"+path[i+2].y.toString()+",";
				str +=path[i+2].x.toString()+",0,"+path[i+2].y.toString()+",";
			}
			//trace(str);*/
			/*graphics.lineStyle(1,0);
			graphics.moveTo(path[0].x,path[0].y);
			//trace(path[path.length-1]);
			for(var i=1;i<path.length;i++){
				//trace("Line to ",path[i].x,path[i].y);
				graphics.lineTo(path[i].x,path[i].y);
			}*/
		}
	}
}