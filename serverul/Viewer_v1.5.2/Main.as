package{
	
	import flash.events.Event;
	import flash.events.DataEvent;
	import flash.events.KeyboardEvent;
	import flash.net.*;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.display.TriangleCulling;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.FullScreenEvent;
	import flash.system.Security;
	
	import net.nicoptere.delaunay.*;
	
	import BMPDecoder;
	import VectorizeMap;
	import LineUtils;
	import caurina.transitions.Tweener;
	
	public class Main extends MovieClip{
		
		private var fileRef:FileReference = new FileReference();
		private static const BMP_DATA_OFFSET_POSITION:int = 0xA;
		private static const WIDTH_POSITION:int = 0x12;
		private static const HEIGHT_POSITION:int = 0x16;
		public var mapContainer:Sprite;
		public var car:Car;
		public var bitmap:Bitmap;
		var bitmap2:Bitmap;
		public var scale:Number;
		public var sendData:SocketSend;
		public var dataByteArr:ByteArray;
		public var path:Vector.<Point>;
		public var path2:Vector.<Point>;
		public var alert:Alert;
		public var newCnt:Sprite;
		private var xStageScale:Number;
		private var yStageScale:Number;
		
		////////////////////////////////////
		public var realWidth:int;
		public var realHeight:int;
		private var mapLoaded:Boolean;
		private var isConected:Boolean;
		private var numOfLaps:int;
		private var theDirection:int;
		private var theRotation:int;
		private var theRefTime:String="01:01";
		private var theTime:int;
		private var theStartPoint:Point;
		
		public var tempClasament:Array=new Array();
		public var mySo:SharedObject;
		private var isNewRace:Boolean = false;
		
		public var debugMode = false;
		
		public function Main(){
			
			this.topCnt.browse.browseI.setStyle("textFormat",new TextFormat("_sans", 14, 0xFF9900, true, false, false, '', '', TextFormatAlign.RIGHT, 0, 10, 0, 0));
			this.reftime.txtRT.setStyle("textFormat",new TextFormat("_sans", 14, 0xFF9900, true, false, false, '', '', TextFormatAlign.RIGHT, 0, 10, 0, 0));
			this.topCnt.wd.txtWD.setStyle("textFormat",new TextFormat("_sans", 14, 0xFF9900, true, false, false, '', '', TextFormatAlign.RIGHT, 0, 10, 0, 0));
			this.topCnt.ht.txtHT.setStyle("textFormat",new TextFormat("_sans", 14, 0xFF9900, true, false, false, '', '', TextFormatAlign.RIGHT, 0, 10, 0, 0));
			this.topCnt.browse.browseB.addEventListener(MouseEvent.CLICK,browseClick);
			this.startBtn.addEventListener(MouseEvent.CLICK,startRace);
			this.config.svConnect.addEventListener(MouseEvent.CLICK,connectSocket);
			this.optionBtn.addEventListener(MouseEvent.CLICK,showWindow);
			fullscreenBtn.addEventListener(MouseEvent.CLICK,goFullScreen);
			
			
			stage.align = StageAlign.TOP_LEFT;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreenChange);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			this.topCnt.wd.txtWD.addEventListener(Event.CHANGE,txtChange);
			this.topCnt.ht.txtHT.addEventListener(Event.CHANGE,txtChange);
			this.reftime.txtRT.addEventListener(Event.CHANGE,txtChange);
			this.laps.nrLaps.addEventListener(Event.CHANGE,txtChange);
			
			realWidth = 0;
			realHeight = 0;
			mapLoaded = false;
			isConected = false
			numOfLaps = 1;
			theDirection = 0;
			theRefTime = "";
			theStartPoint = new Point();
			theRotation = -90;
			
			this.minimapHolder.visible = false;
			car = new Car();
			dataByteArr = new ByteArray();
			path = new Vector.<Point>;
			path2 = new Vector.<Point>;
			alert = new Alert();
			xStageScale = stage.stageWidth;
			yStageScale = stage.stageHeight;
			//checkSO();
			addChild(alert);
			if(debugMode)
				alert.showAlert("Warning running in Debug Mode");
		}
	/*	public function checkSO(){
			mySo = SharedObject.getLocal("viewerTemp");
			if(mySo.data == null){
				isNewRace = true;
			}else{
				isNewRace = false;
				config.populate();
			}
		}*/
		public function txtChange(evt:Event){
			switch(evt.currentTarget.name){
				case "txtWD": realWidth = int(evt.currentTarget.text);break;
				case "txtHT": realHeight = int(evt.currentTarget.text);;break;
				case "txtRT": theRefTime = evt.currentTarget.text;;break;
				case "nrLaps": numOfLaps = evt.currentTarget.value;;break;
			}
			
		}
		public function showWindow(evt:Event){
			config.visible = true;
			Tweener.addTween(config, {alpha:1,x:stage.stageWidth/2 - config.width/2,
							 y:stage.stageHeight/2 - config.height/2, time:1, transition:"easeOut"})
		}
		public function connectSocket(evt:Event):void{
			var isIP:RegExp = /(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))/gi;
			var ipOK:Boolean = false;
			var portOK:Boolean = false;
			
			if(debugMode){
				sendData = new SocketSend("127.0.0.1",20934);
			}else{
				if(isIP.test(config.svIP.text) || config.svIP.text=="localhost")
					ipOK = true;
				else{
					alert.showAlert("IP-ul introdus nu este corect! Trebuie sa fie de forma: \"X.X.X.X\" sau \"localhost\"");
					return;
				}
				if(int(config.svPort.text)>1024 && int(config.svPort.text)<65535)
					portOK = true;
				else{
					alert.showAlert("Port-ul introdus nu este corect! Verificati ca este un intreg cuprins intre 1024 si 655535");
					return;
				}
				alert.hideAlert(null);			
				trace("IncaRC Policy");
				Security.loadPolicyFile("xmlsocket://"+config.svIP.text+":"+String(843));
				trace("Am incarcat Policy");
				sendData = new SocketSend(config.svIP.text,uint(config.svPort.text));
				
			}
			sendData.addEventListener("socketConect",sockCon);
			sendData.addEventListener("socketClose",sockCon);
			sendData.addEventListener("socketIO",sockCon);
			
		}
		public function sockCon(evt:Event){
			trace(evt);
			if(evt.type == "socketConect"){
				isConected = true;
				alert.showAlert("Conexiunea cu serverul s-a realizat cu succes!");
			}
			if(evt.type == "socketClose"){
				isConected = false;
				alert.showAlert("Conexiunea cu serverul s-a inchis!");
			}
			if(evt.type == "socketIO"){
				isConected = false;
				alert.showAlert("Conexiunea cu serverul nu s-a putut realiza cu succes!");
			}
				
		}
		public function browseClick(evt:Event){
			
			var imageTypes:FileFilter = new FileFilter("Images (*.bmp)", "*.bmp");
			var allTypes:Array = new Array(imageTypes);
			
			fileRef.addEventListener(Event.COMPLETE, uploadComplete);
			fileRef.addEventListener(Event.SELECT, syncVariables);
			fileRef.browse(allTypes);
			
		}
		public function syncVariables(evt:Event){
			this.topCnt.browse.browseI.text = fileRef.name;
			fileRef.load();
			
		}
		public function uploadComplete(event:Event):void {
			
			if(fileRef.data == null)
				return;
			var decoder:BMPDecoder = new BMPDecoder();
			if(event!=null)
				theStartPoint = new Point();
			mapContainer = new Sprite();
			mapLoaded = false;
			trace(mapContainer.stage);
			if(container.numChildren > 0)
				container.removeChildAt(container.numChildren-1);
			
			var rectangle:Shape = new Shape;
			dataByteArr = new ByteArray();
			dataByteArr = fileRef.data;
			bitmap = new Bitmap(decoder.decode(dataByteArr));
			if(decoder.nBitsPerPixel != 1){
				alert.showAlert("Fisierul incarcat nu respecta formatul dorit. Incarcati doar fisiere .BMP pe 1 bit, monocrome, unde negru reprezinta circuitul pe care masinile pot circula.");
				return;
			}
			this.minimapHolder.visible = true;
			scale = 1;
			if(bitmap.width > minimapHolder.width - 40){
				scale = (minimapHolder.width - 40)/bitmap.width;
				bitmap.scaleX = bitmap.scaleY = scale;
			}
			if(bitmap.height > minimapHolder.height - 40){
				scale = (minimapHolder.height - 40)/bitmap.height;
				bitmap.scaleX = bitmap.scaleY = scale;
			}
			
			var blur:BlurFilter = new BlurFilter(3,3);
			bitmap.filters = [blur];
			rectangle.graphics.clear();
			rectangle.graphics.lineStyle(1,0xFFFFFF,0.6);
			rectangle.graphics.beginFill(0xFFFFFF,0.1); 
			rectangle.graphics.drawRect(-bitmap.width/2, -bitmap.height/2, bitmap.width, bitmap.height); 
			rectangle.graphics.endFill();
			mapContainer = new MovieClip();
			mapContainer.addChild(rectangle);
			
			mapContainer.addChild(bitmap);
			bitmap.x = -bitmap.width/2;
			bitmap.y = -bitmap.height/2;
			
			
			mapContainer.x = this.minimapHolder.x + this.minimapHolder.width/2;;
			mapContainer.y = this.minimapHolder.y + this.minimapHolder.height/2;;
			
			//mapContainer.rotationX =-45;
			bitmap.smoothing = true;
			
			car = new Car();
			car.scaleX = car.scaleY = 0.14;
			mapContainer.addChild(car);
			
			
			var tempBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
			var outline:GlowFilter=new GlowFilter(0x000000,1.0,5,5,10,1, true);
			//new GlowFilter(
			tempBitmap.filters=[outline];
			var tempBitmapdata:BitmapData = new BitmapData(bitmap.bitmapData.width,bitmap.bitmapData.height,true,0xFF0000);
			tempBitmapdata.draw(tempBitmap);
			bitmap2 = new Bitmap(tempBitmapdata);
			
			//outline.quality=BitmapFilterQuality.MEDIUM;
			
			//addChild(bitmap2);
			
			container.addChild(mapContainer);
			car.dragger.addEventListener(MouseEvent.MOUSE_DOWN,dragClick);
			car.dragger.addEventListener(MouseEvent.MOUSE_UP,dragUp);
			car.rotator.addEventListener(MouseEvent.MOUSE_DOWN,rotateClick);
			car.rotator.addEventListener(MouseEvent.MOUSE_UP,rotateUp);
			this.addEventListener(KeyboardEvent.KEY_DOWN,keyboardPress);
			mapLoaded = true;
		}

		public function keyboardPress(evt:KeyboardEvent){
			if(evt.keyCode == 37)
				car.rotation --;
			if(evt.keyCode == 39)
				car.rotation ++;
		}
		
		public function rotateClick(evt:Event){
			this.addEventListener(Event.ENTER_FRAME,carRotate);
			stage.addEventListener(MouseEvent.MOUSE_UP,rotateUp);
		}
		public function rotateUp(evt:Event){
			this.removeEventListener(Event.ENTER_FRAME,carRotate);
			stage.removeEventListener(MouseEvent.MOUSE_UP,rotateUp);
		}
		public function carRotate(evt:Event){
			
			car.rotation = -90+ Math.atan2( mapContainer.mouseY - car.y,mapContainer.mouseX - car.x ) * 180 / Math.PI;
			theRotation  = -Math.atan2( mapContainer.mouseY - car.y,mapContainer.mouseX - car.x ) * 180 / Math.PI;
			//trace(car.rotation);
			//trace(car.rotation*Math.PI/180);
			setDirection();
			trace(theRotation+ " - "+ theDirection);
		}
		
		public function dragClick(evt:Event){
			this.addEventListener(Event.ENTER_FRAME,carMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,dragUp);
		}
		public function dragUp(evt:Event){
			this.removeEventListener(Event.ENTER_FRAME,carMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,dragUp);
		}
		
		public function carMove(evt:Event){
			var xVal:int = bitmap.mouseX;;
			var yVal:int = bitmap.mouseY;
			var found:Boolean=false;
			//trace(xVal, yVal, bitmap.width/scale, bitmap.height/scale);
			
			if(bitmap2.bitmapData.getPixel(xVal,yVal) == 0xFFFFFF){
				//trace(xVal,yVal);
				car.x = xVal*scale - bitmap.width/2;
				car.y = yVal*scale - bitmap.height/2;
				found = true;
			}else{
				//trace(yVal*scale);
				for(var i=yVal; i < bitmap.height/scale;i++){
					if(bitmap2.bitmapData.getPixel(xVal,i) != 0){
						//trace(xVal + " - "+ (bitmap.y+i) + " - "+bitmap.bitmapData.getPixel(xVal,bitmap.y+i));
						car.x = xVal*scale - bitmap.width/2;
						car.y = (i)*scale - bitmap.height/2;
						found = true;
						break;
					}
				}
				if(found == false)
					for(i=yVal; i > 0;i--){
						if(bitmap2.bitmapData.getPixel(xVal,i) != 0){
							//trace(xVal + " - "+ (bitmap.y+i) + " - "+bitmap.bitmapData.getPixel(xVal,bitmap.y+i));
							car.x = xVal*scale - bitmap.width/2;
							car.y = (i)*scale - bitmap.height/2;
							found = true;
							break;
						}
					}
			}
			if(found==false){
				//trace("a",xVal,yVal,bitmap.width/scale);
				for(var j=xVal; j < bitmap.width/scale;j++){
					if(bitmap2.bitmapData.getPixel(j,yVal) != 0){
						//trace(xVal + " - "+ (bitmap.y+i) + " - "+bitmap.bitmapData.getPixel(xVal,bitmap.y+i));
						car.x = (j)*scale - bitmap.width/2;
						car.y = yVal*scale - bitmap.height/2;
						found = true;
						break;
					}
				}
				if(found == false)
					for(j=xVal; j > 0;j--){
						if(bitmap2.bitmapData.getPixel(j,yVal) != 0){
							car.x = (j)*scale - bitmap.width/2;
							car.y = yVal*scale - bitmap.height/2;
							found = true;
							break;
						}
					}
			}
			theStartPoint = new Point(int((car.x+bitmap.width/2)/scale),int((car.y+bitmap.height/2)/scale));
		}
		
		public function startRace(evt:Event){
			
			if(debugMode){
				if(this.reftime.txtRT.text == "")
					theRefTime = "5:0";
				if(this.topCnt.wd.txtWD.text == "")
					realWidth = 2;
				if(this.topCnt.ht.txtHT.text == "")
					realHeight = 3;				
			}
			theTime = getSeconds(theRefTime);
			
			/////////********DISABLE FOR TESTING
			if(mapLoaded == false){
				alert.showAlert("Nu este incarcata nici o harta. Incarcati o harta in format .BMP pe 1bit.");
				return;
			}
			if(realWidth == 0 || isNaN(realWidth) || realHeight == 0 || isNaN(realHeight) ){
				alert.showAlert("Dimensiunile reale sunt gresite. Verificati ca sunt introduse corect.");
				return;
			}
			
			if(theStartPoint.equals(new Point())){
				alert.showAlert("Nu a fost setat punctul si directia de start a masinilor. Folositi mouse-ul pentru a pozitiona si roti masina pe circuit.");
				return;
			}
			if(config.clients.length < 2){
				alert.showAlert("Este nevoie de minim doi clienti/jucatori pentru a porni cursa. Adaugati clienti din meniul Options disponibil de pe butonul din dreapta sus");
				return;
			}
			if(theRefTime == "" || theTime == -1){
				alert.showAlert("Timpul minim de referinta este introdus gresit. Verificati ca acesta este de forma: \"MM:SS\".");
				return;
			}
			if(isConected == false){
				alert.showAlert("Conexiunea cu serverul nu este realizata.");
				return;
			}
			if(config.checkData() == -1){
				alert.showAlert("Datele clientilor sunt incomplete sau incorecte.");
				return;
			}
			//////////////////////
			alert.showAlert("Se incepe initializarea hartii. Acest proces e posibil sa dureze 2 - 3 secunde.");
												
			//sendData.connect(config.svIP.text,uint(config.svPort.text));
			sayHello();
			prepareMap()
			//addChild(alert);
			//alert.hideAlert(null);

		}
		public function getSeconds(str:String):int{
			if(str.indexOf(":") == -1) return -1;
			var str1 = str.substring(0,str.indexOf(":"));
			var str2 = str.substr(str.indexOf(":")+1);
			if(isNaN(str1) || isNaN(str2))
					return -1;
			return int(str1)*60+int(str2);
		}
		public function sayHello(){
			var data:ByteArray = new ByteArray();
			
			data.writeUTFBytes("v");
			
			sendData.send(data);
			sendData.addEventListener("newMessage",testACK);
		}
		public function testACK(evt:Event){
			var data:ByteArray = new ByteArray();
			trace("LL");
			trace(sendData.response);
			var response:String = sendData.response.toString().replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ');
			trace(response);
			if(response == "ACK"){
				trace("ACK");
				sendImage();
			}
		}
		public function sendImage(){
			trace("sendImage");
			var data:ByteArray = new ByteArray();
			data.writeInt(dataByteArr.length);
			trace("LAL "+dataByteArr);
			sendData.send(data);
			sendData.send(dataByteArr);
			sendOther();
		}
		public function sendOther(){
			trace("sendImage");
			var data:ByteArray = new ByteArray();
			data.writeInt(realWidth);
			data.writeInt(realHeight);
			data.writeInt(theStartPoint.x);
			data.writeInt(theStartPoint.y);
			data.writeInt((1-theDirection));
			data.writeInt(int(theRotation));
			data.writeInt(numOfLaps);
			data.writeInt(theTime);
			data.writeInt(config.numarMasini);
			
			data.writeInt(config.clients.length);
			for(var i=0;i< config.clients.length;i++){
				data.writeInt(config.clients[i].id);
				if(config.check.selected == true)
					data.writeUTF(config.clients[i].name);
				data.writeInt(convertIP(config.clients[i].IP));
				data.writeInt(config.clients[i].Port);
			}
			sendData.send(data);
			sendData.changeListener("waitReady");
		}
		public function prepareMap(){
			//TO DO add direction parameter
			sendData.removeEventListener("socketConect",sockCon);
			sendData.removeEventListener("socketClose",sockCon);
			sendData.removeEventListener("socketIO",sockCon);
			var raceTrack:RaceTrack = new RaceTrack(bitmap, theStartPoint,theDirection,numOfLaps,theTime,theRotation);
			raceTrack.init();
			//if(raceTrack.mapProcesed == true){
				var race:Race = new Race(raceTrack,this,sendData);
				addChild(race);
				//return true;
			//}
			//return false;
		}
		public function setDirection(){
			if((theRotation <= 0 && theRotation >= -90) || (theRotation >= 0 && theRotation <= 90))
				theDirection = 1;
			else
				theDirection = 0;
		}
		public function convertIP(ip:String):int{
			if(ip == "localhost")
				ip = "127.0.0.1";
			var ips:Array = ip.split(".");
			var intIP:int;
			for(var i=ips.length-1;i>=0;i--){
				if(int(ips[i]) > 255 || int(ips[i]) < 0)
					return -1;
				intIP += int(ips[i])*Math.pow(256,3-i);
			}
			trace(intIP);
			return intIP;
		}
		var cont:MovieClip = new MovieClip();
		
		public function goFullScreen(evt:MouseEvent){
			if (stage.displayState == StageDisplayState.NORMAL){
				//set stage display state
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}else{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		public function onFullscreenChange(e:FullScreenEvent = null):void {
			trace(stage.stageWidth);
		}
		public function resizeHandler(evt:Event){
			
			titlu.x = stage.stageWidth/2 - titlu.width/2
			titlu.y = 27;
			
			optionBtn.x = stage.stageWidth - optionBtn.width - 10;
			optionBtn.y = 8;
			
			optionBMP.x = optionBtn.x - optionBMP.width - 10;
			optionBMP.y = 4
			
			fullscreenBtn.x = optionBMP.x - fullscreenBtn.width - 10;
			fullscreenBtn.y = 4
			bar1.width = stage.stageWidth - 80;
			bar1.x = stage.stageWidth/2 - bar1.width/2
			bar1.y = 80;
			
			logo.x = bar1.x;
			logo.y = 6;
			 
			topCnt.x = bar1.x + bar1.width/2 - topCnt.width/2;
			topCnt.y = bar1.y + bar1.height/2 - topCnt.height/2-1;
			
			minimapHolder.x = bar1.x;
			minimapHolder.y = bar1.y+bar1.height+20;;
			minimapHolder. width = bar1.width;
			
			
			bar2.x = bar1.x;
			bar2.width = bar1.width;
			bar2.y = stage.stageHeight - bar2.height - 20;
			minimapHolder.height = bar2.y - minimapHolder.y - 20;
			
			laps.x = bar2.x + bar2.width/2 - laps.width/2;
			laps.y = bar2.y + 6;
			
			reftime.x = bar2.x + bar2.width/2 - reftime.width/2;
			reftime.y = laps.y + laps.height + 6;
			
			startBtn.x = bar2.x+ bar2.width - startBtn.width - 20;
			startBtn.y = bar2.y + bar2.height/2 - startBtn.height/2;
			
			back.backBack.width = stage.stageWidth;
			back.backBack.height = stage.stageHeight;
			
			back.backCar.x = stage.stageWidth/2 - back.backCar.width/2;
			back.backCar.y = stage.stageHeight/2 - back.backCar.height/2;;
			
			back.backFlag.x = stage.stageWidth/2 - back.backFlag.width/2;;
			back.backFlag.y = stage.stageHeight/2 - back.backFlag.height/2;;
			
			version.x = stage.stageWidth - version.width - 5;
			version.y = stage.stageHeight -  version.height-7;
			var carx = car.x;
			var cary = car.y;
			var pscale = scale;
			uploadComplete(null);
			car.x = carx/(pscale/scale);
			car.y = cary/(pscale/scale);
			car.rotation = -90- theRotation;
			xStageScale = stage.stageWidth;
			yStageScale = stage.stageHeight;
			if(config.alpha > 0)
				showWindow(null);
		}
	}
	
}