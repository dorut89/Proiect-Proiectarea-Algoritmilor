package{
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	class SocketSend extends Socket {
		
		var response:ByteArray = new ByteArray();
		public var isNewMsg:Boolean;
		
		public function SocketSend(host:String = null, port:uint = 0) {
			super(host, port);
			configureListeners();
			response = new ByteArray();
			isNewMsg = true;
		}
	
		private function configureListeners():void {
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataACKHandler);
		}
		
		public function changeListener(list:String){
			if(list == "waitReady"){
				removeEventListener(ProgressEvent.SOCKET_DATA, socketDataACKHandler);
				addEventListener(ProgressEvent.SOCKET_DATA, socketDataREADYHandler);
			}else if(list == "waitMSG"){
				removeEventListener(ProgressEvent.SOCKET_DATA, socketDataREADYHandler);
				addEventListener(ProgressEvent.SOCKET_DATA, socketDataMSGHandler);
			}
		}
		public function send(byte:ByteArray):void {
			byte.position = 0;
			trace("Sending: "+byte.bytesAvailable);
			trace("::: " + byte.toString() + ":::");
			this.writeBytes(byte,0,byte.bytesAvailable);
			this.flush();
		}
	
		private function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
			dispatchEvent(new Event("socketClose"));
		}
	
		private function connectHandler(event:Event):void {
			trace("connectHandler: " + event);
			dispatchEvent(new Event("socketConect"));
		}
	
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			dispatchEvent(new Event("socketIO"));
		}
	
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
	
		private function socketDataACKHandler(event:ProgressEvent):void {
			trace("socketDataHandler: " + event);
			if(isNewMsg == true)
				response = new ByteArray();
				
			this.readBytes(response,response.length,this.bytesAvailable);
			isNewMsg = false;
			trace("--"+response.toString()+"--");
			if(response.toString().indexOf('\n') != -1){
				dispatchEvent(new Event("newMessage"));
				isNewMsg = true;
			}
		}
		private function socketDataREADYHandler(event:ProgressEvent):void {
			trace("socketDataHandler: " + event);
			if(isNewMsg == true)
				response = new ByteArray();
				
			this.readBytes(response,response.length,this.bytesAvailable);
			isNewMsg = false;
			trace("--"+response.toString()+"--");
			if(response.toString().indexOf('\n') != -1){
				dispatchEvent(new Event("newREADY"));
				isNewMsg = true;
			}
		}
		public var tmp:ByteArray = new ByteArray();
		private function socketDataMSGHandler(event:ProgressEvent):void {
			//trace("socketDataHandler: " + event);
			//trace(isNewMsg);
			if(isNewMsg == true){
				trace("mesaj nou");
				response = new ByteArray();
			}
			trace("AM de citit si total: "+this.bytesAvailable, response.length);
			/*var howMuch:int = this.bytesAvailable%(32-response.length);
			if(howMuch == 0)
				howMuch = 32-response.length;*/
			//trace("Reading: "+howMuch);
			this.readBytes(response,response.length,this.bytesAvailable);
			isNewMsg = false;
			trace("--"+response.length+"--");
			//if(response.length == 32){
				//tmp = response;
				dispatchEvent(new Event("newMSG"));
				//isNewMsg = true;
			//}
			
		}
	}
}