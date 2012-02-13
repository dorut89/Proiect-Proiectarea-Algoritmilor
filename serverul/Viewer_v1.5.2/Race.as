package{
	
	import fl.controls.Slider;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import caurina.transitions.Tweener;
	import flash.events.TimerEvent;
	import flash.utils.Timer
	
	public class Race extends Sprite{
		
		public var track:RaceTrack;
		public var that:MovieClip;
		public var trackContainer:Sprite;
		public var mapContainer:Sprite;
		public var minimapHolder:Sprite;
		public var minimapContainer:Sprite;
		public var backgroundContainer:Sprite;
		public var clasamentContainer:Sprite;
		public var minimapBackground:Sprite;
		public var underCircuit:Sprite;
		public var treeContainer:Sprite;
		public var underMask;
		public var map:Sprite;
		public var panMap:Sprite;
		public var clasamentItems:Array;
		public var scale:Number;
		public var miniScale:Number;
		public var miniMapSize = 140;
		public var players:Array;
		public var minimapPoints:Array;
		public var mapCars:Array;
		public var numberTrees:Number = 20;
		public var viewMode:String = "all";
		public var viewWhich:int=0;
		public var readyGo:ReadyGo;
		public var sendData:SocketSend;
		public var zoom:Slider;
		public var clTip:ClasamentTip;
		public var toolTip:bToolTip
		public var fullB:FullscreenBtn;
		public var alert:Alert;
		public var isConected:Boolean = true;
		public var whichTip:int = 0;
		
		public var totalT:TotalTime;
		public var lapBestTime:LapBestTime;
		public var lapCurentTime:LapCurentTime;
		public var lapNr:LapsNr;
		public var posNr:PosNr;
		
		private var gameStartTime:Number;
		private var lastTime:Number;
		
		private var carsTimes:Array;
		private var lapsTimes:Array;
		private var carsBestTime:Array;
		
		private var carConfig:Array;
		private var white:WhiteBack;
		
		private var nrCar:int;
		
		public function Race(raceTrack:RaceTrack,cont:MovieClip,sock:SocketSend){
			track = raceTrack as RaceTrack;
			that = cont;
			trackContainer = new Sprite();
			backgroundContainer = new Sprite();
			clasamentContainer = new Sprite();
			clasamentItems = new Array();
			minimapHolder = new Sprite();
			minimapContainer = new Sprite();
			mapContainer = new Sprite();
			minimapBackground = new Sprite();
			map = new Sprite();
			underCircuit = new Sprite();
			underMask = new Sprite();
			treeContainer = new Sprite();
			sendData = sock;
			sendData.addEventListener("socketClose",sockCon);
			sendData.addEventListener("socketIO",sockCon);
			clTip = new ClasamentTip();
			
			totalT = new TotalTime();
			lapBestTime = new LapBestTime();
			lapCurentTime = new LapCurentTime();
			lapNr = new LapsNr();
			posNr = new PosNr();
			that.stage.addEventListener(Event.RESIZE, resizeHandler);
			
			map.addChild(backgroundContainer);
			
			init();		
			initPlayers();
			init2();
	
			createMiniMap(this.track.innerPath,this.track.outerPath);
			
			initMinimapPlayers();
			initMapPlayers();			
			initPositions();
			
			readyStart();
			
			
			
			white = new WhiteBack();
			white.width = that.stage.stageWidth;
			white.height = that.stage.stageHeight;
			white.alpha = 0;
			addChild(white);
			initClasament();
			clTip.visible = false;
			
			addChild(clTip);
			fullB = new FullscreenBtn();
			addChild(fullB);
			that.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreenChange);
			fullB.addEventListener(MouseEvent.CLICK,goFullScreen);
			fullB.x = that.stage.stageWidth-fullB.width - 20;
			fullB.y = that.stage.stageHeight-fullB.height - 20;
			toolTip = new bToolTip();
			addChild(toolTip);
			toolTip.x = -100
			toolTip.y = -100;
			//toolTip.alpha = 0;
			alert = new Alert();
			addChild(alert);
		}		
		public function sockCon(evt:Event){
			trace(evt);
			
			if(evt.type == "socketClose"){
				isConected = false;
				alert.showAlert("Conexiunea cu serverul s-a inchis!");
			}
			if(evt.type == "socketIO"){
				isConected = false;
				alert.showAlert("Nu se poate comunica cu serverul.");
			}
			sendData.removeEventListener("newMSG",onMsgReceived);
				
		}
		public function init(){
			removeEverything();
			nrCar = that.config.numarMasini;
			var asphalt:Asphalt = new Asphalt();
			var asphaltBD:BitmapData = new BitmapData(asphalt.width,asphalt.height);
			asphaltBD.draw(new Asphalt());
			addChild(map);
			map.addChild(underCircuit);
			map.addChild(underMask);
			map.addChild(mapContainer);
			//map.addChild(treeContainer);
			drawCircuit(asphaltBD);
			scale = (that.stage.stageWidth)/trackContainer.width;
			var prevScale:Number = (that.stage.stageHeight)/trackContainer.height;
			trackContainer.scaleX = trackContainer.scaleY = scale;
			
			if(scale > prevScale){				
				scale = prevScale;				
			}
			trackContainer.scaleX = trackContainer.scaleY = scale;
			mapContainer.addChild(trackContainer);
			
			drawUnderCircuit();
			underCircuit.scaleX = underCircuit.scaleY = scale;
			underMask.scaleX = underMask.scaleY = scale;
			
			mapContainer.x = (that.stage.stageWidth)/2 - mapContainer.width/2;
			mapContainer.y = (that.stage.stageHeight)/2 - mapContainer.height/2;
			
			underCircuit.x = (that.stage.stageWidth)/2 - underCircuit.width/2;
			underCircuit.y = (that.stage.stageHeight)/2 - underCircuit.height/2;
			
			underMask.x = (that.stage.stageWidth)/2 - underMask.width/2;
			underMask.y = (that.stage.stageHeight)/2 - underMask.height/2;
			trace(map.getBounds(trackContainer));
			var grass:Grass = new Grass();
			var grassBD:BitmapData = new BitmapData(grass.width,grass.height);
			grassBD.draw(new Grass());
			drawBackground(grassBD);
			
		}
		public function init2(){
			var glow:GlowFilter = new GlowFilter(0xFFE1CE,1,5,5,2);
			addChild(totalT);
			totalT.x = that.stage.stageWidth/2 - totalT.width/2;
			totalT.y = 8;
			totalT.field.text = "00:00.00";
			
			addChild(lapBestTime);
			lapBestTime.x = 8;
			lapBestTime.y = 8;
			lapBestTime.field.text = "00:00.00";
			
			addChild(lapCurentTime);
			lapCurentTime.x = 8;
			lapCurentTime.y = lapBestTime.y+lapBestTime.height+8;
			lapCurentTime.field.text = "00:00.00";
			lapCurentTime.visible = false;
			
			addChild(lapNr);
			lapNr.x = 8;
			lapNr.y = lapCurentTime.y+lapCurentTime.height+8;
			lapNr.field.text = String(track.nrLaps);
			
			addChild(posNr);
			posNr.x = that.stage.stageWidth - posNr.width-8;
			posNr.y = 8;
			posNr.field.text = "0";
			posNr.visible = false;
			
			
						
		}
		
		public function initClasament(){
			var bevel:BevelFilter = new BevelFilter(2,45,0xFFFFFF,1,0x000000,0.8,5,5,0.7);
			var newColorTransform:ColorTransform;
			for(var i=0;i<players.length;i++){
				var item:ClasamentItem = new ClasamentItem();
				item.pos.text = String(i*nrCar+1);
				item.nume.text = players[i].name+"(a)";;
				item.time.text = "0 m";
				item.disqBar.visible = false;
				clasamentContainer.addChild(item);
				item.y = item.height*i*nrCar;
				item.filters = [bevel];				
				item.id = String(i*nrCar+1);
				item.addEventListener(MouseEvent.MOUSE_OVER,itemOver);
				item.addEventListener(MouseEvent.MOUSE_OUT,itemOut);
				item.addEventListener(MouseEvent.CLICK,itemClick);
				
				newColorTransform = item.posBg.transform.colorTransform;
				newColorTransform.color = players[i].color;
				item.posBg.transform.colorTransform = newColorTransform;				
				
				clasamentItems.push(item);
				
				if(nrCar > 1){
					var item2 = new ClasamentItem();
					item2.pos.text = String(i*nrCar+2);
					item2.nume.text = players[i].name+"(b)";
					item2.time.text = "0 m";
					item2.disqBar.visible = false;
					clasamentContainer.addChild(item2);
					item2.y = item.height*(i*nrCar+1);
					item2.filters = [bevel];				
					item2.id = String(i*nrCar+2);
					item2.addEventListener(MouseEvent.MOUSE_OVER,itemOver);
					item2.addEventListener(MouseEvent.MOUSE_OUT,itemOut);
					item2.addEventListener(MouseEvent.CLICK,itemClick);
					
					newColorTransform = item2.posBg.transform.colorTransform;
					newColorTransform.color = players[i].color;
					item2.posBg.transform.colorTransform = newColorTransform;				
					
					clasamentItems.push(item2);
				}
			}
			addChild(clasamentContainer);
			clasamentContainer.x = that.stage.stageWidth - 190-8;
			clasamentContainer.y = posNr.y+posNr.height+8;
			//clasamentContainer.alpha = 0.7;
			
		}
		public function initPlayers(){
			players = new Array();
			
			players = that.config.clients;
			carConfig = new Array();
			carsTimes = new Array();
			carsBestTime = new Array();
			for(var i=0;i<players.length*nrCar;i++){
				var obj:Object = new Object();
				obj.acc = 0;
				obj.brk = 0;
				obj.spd = 0;
				obj.str = 0;
				obj.disqualified = false;
				obj.pos = i+1;
				obj.distance = 0;
				obj.lap = 0;
				carConfig.push(obj);
				carsTimes.push(new Array(track.nrLaps+1));
				carsTimes[i][0] = 0;
				carsBestTime.push(0);				
				
			}
			//trace(players);
		}
		public function initMinimapPlayers(){
			minimapPoints = new Array();
			for(var i=0;i<players.length;i++){
				var pointCont:Sprite = new Sprite();
				
				pointCont.graphics.beginFill(players[i].color,0.8);
				pointCont.graphics.lineStyle(0.4,0x00000,0.2);
				pointCont.graphics.drawCircle(0,0,4/miniScale);
				
				minimapPoints.push(pointCont);				
				minimapContainer.addChild(pointCont);
				
				pointCont = new Sprite();
				
				pointCont.graphics.beginFill(players[i].color,0.8);
				pointCont.graphics.lineStyle(0.4,0x00000,0.2);
				pointCont.graphics.drawCircle(0,0,4/miniScale);
				
				minimapPoints.push(pointCont);				
				minimapContainer.addChild(pointCont);
				//minimapPoints[i].x = i*10;
			}
			minimapContainer.addChild(panMap);
		}
		public function initMapPlayers(){
			mapCars = new Array();
			var newColorTransform:ColorTransform;
			for(var i=0;i<players.length;i++){
				
					var car1:CarNr1 = new CarNr1();
					
					newColorTransform = car1.body.transform.colorTransform;
					newColorTransform.color = players[i].color;
					car1.body.transform.colorTransform = newColorTransform;			
					car1.carNum.num.text = players[i].id;
					car1.scaleX = car1.scaleY = 0.13*scale;
					car1.addEventListener(MouseEvent.MOUSE_OVER,carOver);
					car1.addEventListener(MouseEvent.MOUSE_OUT,carOut);
					car1.id = String(i*nrCar);
					mapCars.push(car1);
					
					mapContainer.addChild(car1);					
					if(nrCar > 1){
						var car2:CarNr2 = new CarNr2();
						
						for(var j=1;j<=4;j++){
							newColorTransform = car2["body"+j].transform.colorTransform;
							newColorTransform.color = players[i].color;
							car2["body"+j].transform.colorTransform = newColorTransform;
						}			
						car2.carNum.num.text = players[i].id;
						car2.scaleX = car2.scaleY = 0.13*scale;
						car2.addEventListener(MouseEvent.MOUSE_OVER,carOver);
						car2.addEventListener(MouseEvent.MOUSE_OUT,carOut);
						car2.id = String(i*nrCar+1);
						mapCars.push(car2);
						
						mapContainer.addChild(car2);
					}
				
				//mapCars[i].x = i*30;
			}
		}
		public function createMiniMap(inner:Vector.<Point>,outer:Vector.<Point>){
			var glow:GlowFilter = new GlowFilter(0x000000,1)
			minimapBackground.graphics.beginFill(0xFFFFFF,0.1);
			minimapBackground.graphics.lineStyle(1,0xFFFFFF,0.2);
			minimapBackground.graphics.drawRect(0,0,that.stage.stageWidth,that.stage.stageHeight);
			
			minimapHolder.graphics.lineStyle(3,0x000000,1);
			minimapHolder.graphics.moveTo(outer[0].x,outer[0].y);
			for(var i=1;i<outer.length;i++){
				minimapHolder.graphics.lineTo(outer[i].x,outer[i].y);
			}
			minimapHolder.graphics.moveTo(inner[0].x,inner[0].y);
			for(i=1;i<inner.length;i++){
				minimapHolder.graphics.lineTo(inner[i].x,inner[i].y);
			}
			
			minimapHolder.graphics.lineStyle(1,0,0);
			minimapHolder.graphics.drawRect(0,0,track.bitmap.bitmapData.width,track.bitmap.bitmapData.height);
			
			minimapHolder.graphics.lineStyle(0,0,0);
			minimapHolder.graphics.beginFill(0xFFFFFF,1);
			minimapHolder.graphics.drawTriangles(track.vertices); 
			minimapHolder.graphics.endFill();
			
			minimapContainer.addChild(minimapBackground);
			minimapContainer.addChild(minimapHolder);
			
			minimapHolder.filters = [glow];
			
			minimapHolder.scaleX = minimapHolder.scaleY = scale;
			minimapHolder.x = (minimapBackground.width)/2 - minimapHolder.width/2;
			minimapHolder.y = (minimapBackground.height)/2 - minimapHolder.height/2;
			
			miniScale = miniMapSize/minimapContainer.width;
			var prevScale:Number = miniMapSize/minimapContainer.height;
			minimapContainer.scaleX = minimapContainer.scaleY = miniScale;
			
			if(miniScale > prevScale){				
				miniScale = prevScale;				
			}
			minimapContainer.scaleX = minimapContainer.scaleY = miniScale;
			addChild(minimapContainer);
			minimapContainer.x = 8;
			minimapContainer.y = that.stage.stageHeight - minimapContainer.height - 8;
			
			panMap = new Sprite();
			panMap.graphics.beginFill(0xFFFFFF,0.1);
			panMap.graphics.lineStyle(1,0xFFFFFF,0.2);
			panMap.graphics.drawRect(0,0,minimapBackground.width,minimapBackground.height);
			
			panMap.addEventListener(MouseEvent.MOUSE_DOWN,panMapClick);
			panMap.addEventListener(MouseEvent.MOUSE_UP,panMapUp);
			
			zoom = new Slider();
			zoom.x = 8;
			zoom.y = minimapContainer.y - 12 - zoom.height;
			zoom.width = minimapContainer.width;
			zoom.liveDragging = true;
			zoom.tickInterval = 7;
			zoom.minimum = 30;
			zoom.maximum = 100;
			addChild(zoom);
			zoom.addEventListener(Event.CHANGE,zooming);
		}
		public function zooming(evt:Event = null){
			panMap.scaleX = panMap.scaleY = 1.3-zoom.value/100;
			map.scaleX = map.scaleY = 1/panMap.scaleX;
			
			if(panMap.x + panMap.width > minimapBackground.width){
				panMap.x = minimapBackground.width - panMap.width;
			}
			if(panMap.x < 0){
				panMap.x = 0;
			}
			if(panMap.y + panMap.height > minimapBackground.height){
				panMap.y = minimapBackground.height - panMap.height;
			}
			if(panMap.y < 0){
				panMap.y = 0;
			}
			map.x = panMap.x * (that.stage.stageWidth - map.width) / (minimapBackground.width - panMap.width);
			map.y = panMap.y * (that.stage.stageHeight - map.height) / (minimapBackground.height - panMap.height);
			
			
		}
		public function panMapClick(evt:Event){
			xOff = minimapContainer.mouseX-panMap.x;
			yOff = minimapContainer.mouseY-panMap.y;
			
			this.addEventListener(Event.ENTER_FRAME,panMapMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,panMapUp);
		}
		public function panMapUp(evt:Event){
			this.removeEventListener(Event.ENTER_FRAME,panMapMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,panMapUp);
		}
		var xOff:int;
		var yOff:int;
		public function panMapMove(evt:Event){
			var xVal:int = minimapContainer.mouseX;;
			var yVal:int = minimapContainer.mouseY;
			var xOld:int = panMap.x;
			var yOld:int = panMap.y;
			panMap.x = xVal-xOff;
			panMap.y = yVal-yOff;
				
			if(panMap.x + panMap.width > minimapBackground.width){
				panMap.x = minimapBackground.width - panMap.width;
			}
			if(panMap.x < 0){
				panMap.x = 0;
			}
			if(panMap.y + panMap.height > minimapBackground.height){
				panMap.y = minimapBackground.height - panMap.height;
			}
			if(panMap.y < 0){
				panMap.y = 0;
			}
			map.x = panMap.x * (that.stage.stageWidth - map.width) / (minimapBackground.width - panMap.width);
			map.y = panMap.y * (that.stage.stageHeight - map.height) / (minimapBackground.height - panMap.height);
		}
		private function removeEverything(){
			if(that.numChildren!=0){
				var k:int = that.numChildren;
				while( k -- )
				{
					if (!(k is Alert)){
						trace("found alert");
						that.removeChildAt( k );
					}
				}
			}
		}
		public function drawCircuit(texture:BitmapData){
			textureCircuit(texture);
			drawPath(this.track.innerPath,this.track.outerPath);
		}
		
		public function drawPath(inner:Vector.<Point>,outer:Vector.<Point>){			
			var wall:Wall = new Wall();
			var wallBD:BitmapData = new BitmapData(wall.width,wall.height);
			wallBD.draw(wall);
			var rot:Matrix = new Matrix();
			
			trackContainer.graphics.lineStyle(1,0xFFFFFF,0.3);
			trackContainer.graphics.moveTo(outer[0].x,outer[0].y);		
			for(var i=1;i<outer.length;i++){
				rot.rotate(Math.atan2(outer[i].y-outer[i-1].y,outer[i].x-outer[i-1].x));
				trackContainer.graphics.lineBitmapStyle(wallBD,rot,true,true);
				trackContainer.graphics.lineTo(outer[i].x,outer[i].y);
			}
			//var r:Rectangle = trackContainer.bitmapData.getColorBoundsRect(0xFF000000, 0x00000000, true);
			//trace(r);
			
			trackContainer.graphics.moveTo(inner[0].x,inner[0].y);
			for(i=1;i<inner.length;i++){
				rot.rotate(Math.atan2(inner[i].y-inner[i-1].y,inner[i].x-inner[i-1].x));
				trackContainer.graphics.lineBitmapStyle(wallBD,rot,true,true);
				trackContainer.graphics.lineTo(inner[i].x,inner[i].y);
			}
			
			var startline:StartLine = new StartLine();
			var startlineBD:BitmapData = new BitmapData(startline.width,startline.height);
			startlineBD.draw(startline);

			rot.rotate(Math.atan2(track.startLine[1].y-track.startLine[0].y,track.startLine[1].x-track.startLine[0].x));
			trackContainer.graphics.lineStyle(2);
			trackContainer.graphics.lineBitmapStyle(startlineBD,rot,true,true);
			trackContainer.graphics.moveTo(track.startLine[0].x,track.startLine[0].y);
			trackContainer.graphics.lineTo(track.startLine[1].x,track.startLine[1].y);
			
			trackContainer.graphics.lineStyle(1,0,0);
			trackContainer.graphics.drawRect(0,0,track.bitmap.bitmapData.width,track.bitmap.bitmapData.height);
		}
		
		public function textureCircuit(texture:BitmapData){
			trackContainer.graphics.beginBitmapFill(texture, null, false,true);
			trackContainer.graphics.drawTriangles(track.vertices,track.indices,track.uvts); 
			trackContainer.graphics.endFill();
		}
		public function drawBackground(texture:BitmapData){
			backgroundContainer.graphics.clear();
			backgroundContainer.graphics.beginBitmapFill(texture, null, true,true);
			backgroundContainer.graphics.drawRect(0,0,that.stage.stageWidth,that.stage.stageHeight);
			backgroundContainer.graphics.endFill();
		}
		public function drawUnderCircuit(){
			underCircuit.graphics.clear();
			var ground:Ground = new Ground();
			var groundBD:BitmapData = new BitmapData(ground.width,ground.height);
			groundBD.draw(ground);

			underCircuit.graphics.beginBitmapFill(groundBD, null, true,true);
			underCircuit.graphics.drawRect(0,0,track.bitmap.bitmapData.width,track.bitmap.bitmapData.height);
			underCircuit.graphics.endFill();
			
			underMask.graphics.beginFill(0xFFFFFF);
			underMask.graphics.drawTriangles(track.vertices); 
			underMask.graphics.endFill();
			
			underMask.graphics.lineStyle(1,0,0);
			underMask.graphics.drawRect(0,0,track.bitmap.bitmapData.width,track.bitmap.bitmapData.height);
			
			var glow:GlowFilter = new GlowFilter(0,0.6,50,50,4);
			underMask.filters = [glow];
			underMask.cacheAsBitmap = true;
			underCircuit.cacheAsBitmap = true;
			underCircuit.mask = underMask;
		}
		public function initPositions(){
			for(var i=0;i < players.length*nrCar;i++){
				//updateCarPos(i,track.startPoint.x,track.startPoint.y,track.carRotation);
				updateCarPos(i,track.startPoint.x,track.startPoint.y,track.carRotation);
			}
			//var tem = getNearestPoint(track.outerPath[track.outerPath.length-2]);
			
			//trace("@!!!!!!!!!!!!!!!!",getDistanceToPoint(tem,track.outerPath[track.outerPath.length-2]));
		}
		public function updateCarPos(id:uint,xPos:int,yPos:int,rot:Number){
			
			mapCars[id].x = xPos * scale;
			mapCars[id].y = yPos * scale;
			mapCars[id].rotation = -rot;
			
			minimapPoints[id].x = minimapHolder.x + xPos * scale;
			minimapPoints[id].y = minimapHolder.y + yPos * scale;
			 	
		}
		public function getNearestPoint(p:Point):int{
			var dist:Number=9999999999999;
			var newDist:Number=0;
			var index:uint=0;
			for(var i=0;i<track.distancePath.length;i++){
				newDist = Point.distance(p,new Point(track.distancePath[i].x,track.distancePath[i].y));
				if(newDist < dist){
					dist = newDist;
					index = i;
				}
			}
			return index;
		}
		public function getDistanceToPoint(index:uint,p:Point):Number{
			var sig:int = sign(Math.atan2(track.distancePath[index].y - p.y,track.distancePath[index].x - p.x));
			var dist:Number = track.distancePath[index].l + Point.distance(p,new Point(track.distancePath[index].x,track.distancePath[index].y))*sig;
			return dist;
		}
		private function sign(num:Number):int{
			return (num > 0)?1:-1;
		}
		public function readyStart(){
			readyGo = new ReadyGo();
			addChild(readyGo);
			readyGo.alpha = 1;
			readyGo.x = that.stage.stageWidth/2;
			readyGo.y = that.stage.stageHeight/2-150;
			
			readyGo.addEventListener("animFinnish",startRace);
			
			//TO DO wait for ready from server
			trace("Add ready event");
			sendData.addEventListener("newREADY",checkReady);
			//readyGo.start();
		}
		public function checkReady(evt:Event){
			trace("Ready triggered");
			var data:ByteArray = new ByteArray();
			trace(sendData.response);
			var response:String = sendData.response.toString().replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ');
			trace(response);
			if(response == "ready"){
				trace("READY");
				startingRace();
			}
		}
		
		public function startingRace(){
			trace("Start animation");
			readyGo.start();
			
		}
		
		var timer:Timer = new Timer(100);
		
		public function startRace(evt:Event){
			removeChild(readyGo);
			var data:ByteArray = new ByteArray();
			data.writeInt(123456789);
			sendData.send(data);
			sendData.changeListener("waitMSG");
			//sendData.addEventListener("newMSG",onMsgReceived);		
			this.addEventListener(Event.ENTER_FRAME,onMsgReceived);
			//timer.addEventListener(TimerEvent.TIMER,onMsgReceived);
			//timer.start();
			gameStartTime = getTimer();
			lastTime = getTimer();
			
			updateTime(lastTime-gameStartTime,totalT.field);
			
		}
		public var bytesRead:int = 0;
		public function onMsgReceived(evt:Event){
			var data:ByteArray = new ByteArray();
			data = sendData.tmp;
			var ints:Array = new Array();
			var isNewLap:Boolean;
			
			trace("Am citit: "+bytesRead+ " din "+sendData.response.length);
			
			if((sendData.response.length - bytesRead) < 32){
				trace("nu am destul de citit");
				/*if(bytesRead >= 84284){
					sendData.isNewMsg = true;
					sendData.response = new ByteArray();
					bytesRead = 0;
				}*/
				//sendData.addEventListener("newMSG",onMsgReceived);
				return;
			}else{
				//sendData.removeEventListener("newMSG",onMsgReceived);
			}
			for(var i=0;i<8;i++){
				ints.push(sendData.response.readInt());
				bytesRead+=4;
			}
			var obj:Object = new Object();
			trace("new msg: ",ints[0] ,ints[1],ints[2],ints[3],ints[4],ints[5],ints[6],ints[7])
			if(ints[0] == -1 && ints[1] == -1 && ints[2] == -1 && ints[3] == -1 && ints[4] == -1 && ints[5] == -1 && 
								ints[6] == -1 && ints[7] == -1){
				//race end
				trace("race end");
				//sendData.removeEventListener("newMSG",onMsgReceived);
				this.removeEventListener(Event.ENTER_FRAME,onMsgReceived);
				doRaceEnd();
				return;
			}else if(ints[0] >= 0 && ints[1] >= 0 && ints[2] >= 0 && ints[3] >= 0 && ints[4] >= 0 && ints[5] >= 0 && 
				ints[6] == -1 && ints[7] == -1){					
				
				//set car parameters				
				carConfig[(ints[0]-1)*nrCar+ints[1]].acc = 40*ints[2]/100;
				carConfig[(ints[0]-1)*nrCar+ints[1]].brk = 40*ints[3]/100;
				carConfig[(ints[0]-1)*nrCar+ints[1]].spd = 400*ints[4]/100;
				carConfig[(ints[0]-1)*nrCar+ints[1]].str = 2*ints[5]/100;
				
				//carConfig[(ints[0]-1)*nrCar+ints[1]] = obj;
			
				//return;
				
			}else if(ints[0] >= 0 && ints[1] >= 0 && ints[2] == -1 && ints[3] == -1 && ints[4] == -1 && ints[5] == -1 && 
				ints[6] == -1 && ints[7] == -1){			
					//disqualify car
					trace("disqualify car");
					carConfig[(ints[0]-1)*nrCar+ints[1]].disqualified = true;
					//carConfig[(ints[0]-1)*nrCar+ints[1]] = obj;
					
			}else{					
				//update car pos
				updateCarPos((ints[0]-1)*nrCar+ints[1],ints[2],ints[3],ints[4]);
				carConfig[(ints[0]-1)*nrCar+ints[1]].distance = ints[5];
				if(carConfig[(ints[0]-1)*nrCar+ints[1]].lap != ints[7] || ints[7] == 1)
					updateBestTime((ints[0]-1)*nrCar+ints[1]);
				carConfig[(ints[0]-1)*nrCar+ints[1]].lap = ints[7];
				updatePositions((ints[0]-1)*nrCar+ints[1],ints[6]);
				//updateTable();
				
			}
				
			
			if(viewMode == "one")
				movePanMap(viewWhich);
			//TO DO update clasament
			updateTable();
			//TO DO Update timers
			lastTime = getTimer();
			var time = lastTime-gameStartTime;
			updateTime(time,totalT.field);
			
			for(i=0;i<carConfig.length;i++){
				if(carConfig[i].lap >0){
					carsTimes[i][carConfig[i].lap] = time-carsTimes[i][carConfig[i].lap-1];
					if(carConfig[i].lap >1){
						carsTimes[i][carConfig[i].lap-1] += carsTimes[i][carConfig[i].lap-2];
					}
				}else
					carsTimes[i][carConfig[i].lap] = time;
			}
			if(viewMode == "one"){
				updateTime(carsTimes[viewWhich][carConfig[viewWhich].lap],lapCurentTime.field);
				
			}
			if(viewMode == "one"){
				updateTime(carsBestTime[viewWhich],lapBestTime.field);
				
				lapNr.field.text = carConfig[viewWhich].lap+"/"+track.nrLaps;
				posNr.field.text = carConfig[viewWhich].pos+"/"+carConfig.length;
			}else{
				var best = getMax(carsBestTime);
				updateTime(best,lapBestTime.field);
				lapNr.field.text = String(track.nrLaps);
			}
			updateTime(carsBestTime[whichTip],clTip.tBest);
			clTip.tDistance.text = carConfig[whichTip].distance+ "m";
			onMsgReceived(null);
		}
		public function updateBestTime(id:int){
			if(carsBestTime[id] > carsTimes[id][carConfig[id].lap] || carConfig[id].lap == 1)
				carsBestTime[id]= carsTimes[id][carConfig[id].lap];
		}
		public function getMax(who:Array):int{
			var best = who[0];
			for(var i=1;i<who.length;i++){
				if(best < who[i])
					best = who[i];
			}
			return best;
			
		}
		public function updateTable(){	
			var newColorTransform:ColorTransform;
			for(var i=0;i<carConfig.length;i++){
				var item = new ClasamentItem();
				item = clasamentItems[carConfig[i].pos-1];
				//check disqualify
				if(carConfig[i].disqualified == true){
					//update all positions
					updatePositions(i,clasamentItems.length);
					item.pos.text = carConfig[i].pos;
					if(i % 2 == 0)
						item.nume.text = players[int(i/nrCar)].name+"(a)";
					else	
						item.nume.text = players[int(i/nrCar)].name+"(b)";
					item.time.text = carConfig[i].distance+'m';
					item.id = i+1;
					item.disqBar.visible = true;
					newColorTransform = item.posBg.transform.colorTransform;
					newColorTransform.color = 0xFF6F6F;
					item.posBg.transform.colorTransform = newColorTransform;
					newColorTransform = item.numeBg.transform.colorTransform;
					newColorTransform.color = 0xFF6F6F;
					item.numeBg.transform.colorTransform = newColorTransform;
					newColorTransform = item.timeBg.transform.colorTransform;
					newColorTransform.color = 0xFF6F6F;
					item.timeBg.transform.colorTransform = newColorTransform;
				}else{	
					//trace(item, carConfig, i);
					item.pos.text = carConfig[i].pos;
					if(i % 2 == 0)
						item.nume.text = players[int(i/nrCar)].name+"(a)";
					else	
						item.nume.text = players[int(i/nrCar)].name+"(b)";
					item.id = i+1;
					if(viewMode == "all")
						item.time.text = carConfig[i].distance+'m';
					else{
						item.time.text = (carConfig[i].distance-carConfig[viewWhich].distance)+'m';						
					}
				}
				
			}
		}
		
		var count = 0;
		public function updatePositions(id:int,pos:int){	
			var i;
			//trace(count++ +": "+"	update position: "+id+" "+pos);
			if(carConfig[id].pos < pos){
				//trace("noua pozitie e mai mai mare");
				for(i=0;i<carConfig.length;i++){
					//trace("Pozitiile: "+carConfig[i].pos+" "+carConfig[id].pos+" "+pos);
					if(carConfig[i].pos > carConfig[id].pos &&
						carConfig[i].pos <= pos){
							//trace("Scad")
							carConfig[i].pos--;
					}
				}					
				carConfig[id].pos = pos;
			}else{
				//trace("noua pozitie e mai mai mica");
				for(i=0;i<carConfig.length;i++){
					//trace("Pozitiile: "+carConfig[i].pos+" "+carConfig[id].pos+" "+pos);
					if(carConfig[i].pos < carConfig[id].pos &&
						carConfig[i].pos >= pos){
						//trace("Cresc")
						carConfig[i].pos++;
					}
				}					
				carConfig[id].pos = pos;				
			}
		}
		
		public function updateTime(mss:Number,who:TextField){
			//milliseconds = mss;
			var seconds = Math.floor(mss/1000);
			var minutes = Math.floor(seconds/60);
			var minutesTXT = minutes.toString();
			var secondsTXT = (seconds-minutes*60).toString();;
			var tensTXT = (Math.round((mss-seconds*1000)/10)).toString();;
			if (int(minutesTXT)<10) {
				minutesTXT = "0"+minutesTXT;
			}
			if (int(secondsTXT)<10) {
				secondsTXT = "0"+secondsTXT;
			}
			if (int(tensTXT)<10) {
				tensTXT = "0"+tensTXT;
			}
			who.text = minutesTXT+":"+secondsTXT+"."+tensTXT;
			
		}
		public function itemOver(evt:Event){
			
			var id:int = int(evt.currentTarget.id);
			var who:int = int((id-1));
			var which:int = int((id-1)%2);
			whichTip = who;
			//trace("over",id,who,which);
			var glow:GlowFilter = new GlowFilter(players[int(who/nrCar)].color,1,15,15,1.8,3);
			mapCars[who].filters = [glow];
			minimapPoints[who].filters = [glow];
			
			clTip.x = clasamentContainer.x;
			clTip.y = clasamentContainer.y + evt.currentTarget.y + evt.currentTarget.height/2;
			clTip.tName.text = players[int(who/nrCar)].name;
			clTip.acc.text = carConfig[int(who)].acc;
			clTip.brk.text = carConfig[int(who)].brk;
			clTip.spd.text = carConfig[int(who)].spd;
			clTip.str.text = carConfig[int(who)].str;
			clTip.perc.percAcc.x = 1;
			clTip.perc.percAcc.width = carConfig[int(who)].acc/20 * 188 / 2;
			clTip.perc.percBrk.x = clTip.perc.percAcc.x + clTip.perc.percAcc.width;
			clTip.perc.percBrk.width = carConfig[int(who)].brk/20 * 188 / 2;
			clTip.perc.percSpd.x = clTip.perc.percBrk.x + clTip.perc.percBrk.width;
			clTip.perc.percSpd.width = carConfig[int(who)].spd/200 * 188 / 2;
			clTip.perc.percStr.x = clTip.perc.percSpd.x + clTip.perc.percSpd.width;
			clTip.perc.percStr.width = carConfig[int(who)].str * 188 / 2;
			
			/*clTip.acc.value = Math.random()*100;
			clTip.brk.value = Math.random()*100;
			clTip.spd.value = Math.random()*100;
			clTip.str.value = Math.random()*100;*/
			clTip.visible = true;
			
		}
		public function itemOut(evt:Event){
			var id:int = int(evt.currentTarget.id);
			var who:int = int((id-1));
			var which:int = int((id-1)%2);
			//trace("out",id,who,which);
			var glow:GlowFilter = new GlowFilter(players[int(who/nrCar)].color);
			mapCars[who].filters = null;
			minimapPoints[who].filters = null;
			clTip.visible = false;
			
		}
		public function itemClick(evt:Event){
			
			if(viewMode == "all" || (viewMode == "one" && evt.currentTarget.id-1 != viewWhich)){
				zoom.value = 100;
				zoom.enabled = false;
				zooming();
				viewMode = "one";
				viewWhich = int(evt.currentTarget.id-1);			
				movePanMap(evt.currentTarget.id-1);
				posNr.visible = true;
				lapCurentTime.visible = true;
			}else{
				zoom.value = 30;
				zoom.enabled = true;
				zooming();
				viewMode = "all";
				posNr.visible = false;
				lapCurentTime.visible = false;			
				movePanMap(evt.currentTarget.id-1);
			}
			
		}
		public function movePanMap(cid:int){
			
			panMap.x = minimapPoints[cid].x-panMap.width/2;
			panMap.y = minimapPoints[cid].y-panMap.height/2;
				
			if(panMap.x + panMap.width > minimapBackground.width){
				panMap.x = minimapBackground.width - panMap.width;
			}
			if(panMap.x < 0){
				panMap.x = 0;
			}
			if(panMap.y + panMap.height > minimapBackground.height){
				panMap.y = minimapBackground.height - panMap.height;
			}
			if(panMap.y < 0){
				panMap.y = 0;
			}
			map.x = panMap.x * (that.stage.stageWidth - map.width) / (minimapBackground.width - panMap.width);
			map.y = panMap.y * (that.stage.stageHeight - map.height) / (minimapBackground.height - panMap.height);
		}
		
		public function resizeHandler(evt:Event){
			init2();
			
			
			clasamentContainer.x = that.stage.stageWidth - 190-8;
			clasamentContainer.y = posNr.y+posNr.height+8;
			
			
			
			var grass:Grass = new Grass();
			var grassBD:BitmapData = new BitmapData(grass.width,grass.height);
			grassBD.draw(new Grass());
			drawBackground(grassBD);
			underCircuit.scaleX = underCircuit.scaleY = 1;
			underMask.scaleX = underMask.scaleY = 1;
			trackContainer.scaleX = trackContainer.scaleY = 1;
			scale = (that.stage.stageWidth)/trackContainer.width;
			var prevScale:Number = (that.stage.stageHeight)/trackContainer.height;
			trackContainer.scaleX = trackContainer.scaleY = scale;
			
			if(scale > prevScale){				
				scale = prevScale;				
			}
			trackContainer.scaleX = trackContainer.scaleY = scale;
			//mapContainer.addChild(trackContainer);
			
			
			underCircuit.scaleX = underCircuit.scaleY = scale;
			underMask.scaleX = underMask.scaleY = scale;
			//minimapHolder.scaleX = minimapHolder.scaleY = scale;
			
			minimapBackground.graphics.clear();
			minimapBackground.graphics.beginFill(0xFFFFFF,0.1);
			minimapBackground.graphics.lineStyle(1,0xFFFFFF,0.2);
			minimapBackground.graphics.drawRect(0,0,that.stage.stageWidth,that.stage.stageHeight);
			
			minimapContainer.scaleX = minimapContainer.scaleY = 1;
			minimapHolder.scaleX = minimapHolder.scaleY = scale;
			minimapHolder.x = (minimapBackground.width)/2 - minimapHolder.width/2;
			minimapHolder.y = (minimapBackground.height)/2 - minimapHolder.height/2;
			
			miniScale = miniMapSize/minimapContainer.width;
			
			minimapContainer.scaleX = minimapContainer.scaleY = miniScale;
			
			//minimapContainer.scaleX = minimapContainer.scaleY = miniScale;
			
			panMap.graphics.clear();
			panMap.graphics.beginFill(0xFFFFFF,0.1);
			panMap.graphics.lineStyle(1,0xFFFFFF,0.2);
			panMap.graphics.drawRect(0,0,minimapBackground.width,minimapBackground.height);
			
			//initPositions();
			
			
			mapContainer.x = (that.stage.stageWidth)/2 - mapContainer.width/2;
			mapContainer.y = (that.stage.stageHeight)/2 - mapContainer.height/2;
			
			underCircuit.x = (that.stage.stageWidth)/2 - underCircuit.width/2;
			underCircuit.y = (that.stage.stageHeight)/2 - underCircuit.height/2;
			
			underMask.x = (that.stage.stageWidth)/2 - underMask.width/2;
			underMask.y = (that.stage.stageHeight)/2 - underMask.height/2;
			minimapContainer.x = 8;
			minimapContainer.y = that.stage.stageHeight - minimapContainer.height - 8;
			zoom.x = 8;
			zoom.y = minimapContainer.y - 12 - zoom.height;
			for(var i=0;i<mapCars.length;i++){
				mapCars[i].scaleX = mapCars[i].scaleY =scale*0.13;
				//minimapPoints[i].scaleX = minimapPoints[i].scaleY = miniScale;
			}
			fullB.x = that.stage.stageWidth-fullB.width - 20;
			fullB.y = that.stage.stageHeight-fullB.height - 20;
			
			white.width = that.stage.stageWidth;
			white.height = that.stage.stageHeight;
			white.x=white.y = 0;
		}		
		public function onFullscreenChange(e:FullScreenEvent = null):void {
			trace(that.stage.stageWidth);
		}
		public function goFullScreen(evt:MouseEvent){
			if (that.stage.displayState == StageDisplayState.NORMAL){
				//set stage display state
				that.stage.displayState = StageDisplayState.FULL_SCREEN;
			}else{
				that.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		public function carOver(evt:Event){
			var id = int(evt.currentTarget.id);
			
			toolTip.showTip("Masina NR: "+(id%2+1)+" a echipei:"+players[int(id/nrCar)].name);
		}
		public function carOut(evt:Event){
			toolTip.hideTip();
		}
		public function doRaceEnd(){
			var points:Array = new Array(7,4,3,2,1,-1,-2);
			for(var i=0;i<carConfig.length;i++){
				var item = new ClasamentItem();
				item = clasamentItems[carConfig[i].pos-1];
									//trace(item, carConfig, i);
				item.pos.text = carConfig[i].pos;
				if(i % 2 == 0)
					item.nume.text = players[int(i/nrCar)].name+"(a)";
				else	
					item.nume.text = players[int(i/nrCar)].name+"(b)";
				item.id = i+1;
				if(carConfig[i].disqualified == false){
					if((carConfig[i].pos) < points.length)
						item.time.text = points[carConfig[i].pos-1]+'p';
					else
						item.time.text = '??p';
				}else
					item.time.text = points[points.length-1]+'p';
			}	
			Tweener.addTween(this.white, {alpha:1, time:2, transition:"easeOut"})
			Tweener.addTween(this.clasamentContainer, {x:that.stage.stageWidth/2 - clasamentContainer.width/2,
				y:that.stage.stageHeight/2 - clasamentContainer.height/2, time:2, transition:"easeOut"})
		}
	}
}