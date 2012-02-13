package{
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	
	import caurina.transitions.Tweener;
	
	public class ConfigPanel extends MovieClip{
		
		public var server:Object = new Object();
		public var clients:Array = new Array();
		public var numarMasini:int;
		private var selectedPlayer:int=-1;
		private var prevColor:uint;

		
		public function ConfigPanel(){
			
			svIP.addEventListener(Event.CHANGE,textInputChange);
			svPort.addEventListener(Event.CHANGE,textInputChange);
			clIP.addEventListener(Event.CHANGE,textInputChange);
			clPort.addEventListener(Event.CHANGE,textInputChange);
			clName.addEventListener(Event.CHANGE,textInputChange);
			clColor.addEventListener(Event.CHANGE,colorChange);
			clSelect.addEventListener(Event.CHANGE,carChange);
			clList.addEventListener(Event.CHANGE,playerChange);
			clAdd.addEventListener(MouseEvent.CLICK,addPlayer);
			clDel.addEventListener(MouseEvent.CLICK,delPlayer);
			closeBtn.addEventListener(MouseEvent.CLICK,closeWindow);
			okBtn.addEventListener(MouseEvent.CLICK,closeWindow);
			nrMasini.addEventListener(Event.CHANGE,checkMasini);
			clSelect.addItem({label:"Masina 1", id:1});
			clSelect.addItem({label:"Masina 2", id:2});
			
			clIP.enabled = false;
			clPort.enabled = false;
			clName.enabled = false;
			clColor.enabled = false;
			clSelect.enabled = false;
						
			cars.car1.visible = true;
			cars.car2.visible = false;
			
			clColor.selectedColor = 0xFF0000;
			this.numarMasini = 2;
			changeColor(0xFF0000);
			this.alpha = 0;
			this.visible = false;
			this.x = stage.stageWidth;
			this.y = 0;
		}
		
		/*public function populate(){
			clients = MovieClip(parent).mySo.data as Array;
			
			
			selectedPlayer = 0;
			playerChange2();
			
		}*/
		public function closeWindow(evt:Event){
			if(checkData() == -1)
				return;
			Tweener.addTween(this, {alpha:0,y:0,x:stage.stageWidth,visible:false, time:1, transition:"easeOut"})
			/*MovieClip(parent).mySo.data = null;
			for(var i:int;i<clients.length;i++){
				MovieClip(parent).mySo.data.push({name:clients[i].name, id:clients[i].id,color:clients[i].color,IP:clients[i].ip,Port:clients[i].port,car:1});
			}*/
		}
		
		public function textInputChange(evt:Event){
			trace("change");
			if(selectedPlayer != -1){
				if(evt.currentTarget == svIP){
					server.IP = evt.currentTarget.text;
				}else if(evt.currentTarget == svPort){
					server.port = evt.currentTarget.text;
				}else if(clList.length > 0){
					if(evt.currentTarget == clIP){
						trace(evt.currentTarget.text);
						clients[selectedPlayer].IP = evt.currentTarget.text;
					}else if(evt.currentTarget == clName){
						//clList.selectedItem.label = evt.currentTarget.text;
						clients[selectedPlayer].name = evt.currentTarget.text;
						clList.replaceItemAt({label:evt.currentTarget.text},clList.selectedIndex);
					}else if(evt.currentTarget == clPort){
						clients[selectedPlayer].Port = evt.currentTarget.text;
					}
				}
			}
		}
		
		public function colorChange(evt:Event){
			var foundCol:Boolean = false;
			if(selectedPlayer != -1){
				if(clList.length > 0){
					for(var i=0;i<clList.length;i++){
						if(clients[i].color == evt.currentTarget.selectedColor){
							foundCol = true;
							break;
						}
					}
					if(foundCol == false){
						clients[selectedPlayer].color = evt.currentTarget.selectedColor;
						changeColor(evt.currentTarget.selectedColor);
						prevColor = evt.currentTarget.selectedColor;
					}else{
						MovieClip(parent).alert.showAlert("Culoarea masinii este deja luata. Alegeti alta culoare!");
						evt.currentTarget.selectedColor = prevColor;
					}
				}
			}
			
		}
		
		public function playerChange(evt:Event){
			clIP.enabled = true;
			clName.enabled = true;
			clColor.enabled = true;
			clSelect.enabled = true;
			clPort.enabled = true;
			selectedPlayer = evt.currentTarget.selectedIndex;
			clName.text = clients[selectedPlayer].name;
			clIP.text = clients[selectedPlayer].IP;
			clPort.text = clients[selectedPlayer].Port;
			clColor.selectedColor = clients[selectedPlayer].color;
			prevColor = clients[selectedPlayer].color; 
			changeColor(clients[selectedPlayer].color);
			clSelect.selectedIndex = clients[selectedPlayer].car-1;
			cars.car1.carNum.num.text = clients[selectedPlayer].id; 
			cars.car2.carNum.num.text = clients[selectedPlayer].id; 
			if(clients[selectedPlayer].car == 1){
				cars.car1.visible = true;
				cars.car2.visible = false;
			}else if(clients[selectedPlayer].car == 2){
				cars.car1.visible = false;
				cars.car2.visible = true;
			}
			
		}
		public function playerChange2(){
			clIP.enabled = true;
			clName.enabled = true;
			clColor.enabled = true;
			clSelect.enabled = true;
			clPort.enabled = true;
			//selectedPlayer = evt.currentTarget.selectedIndex;
			clName.text = clients[selectedPlayer].name;
			clIP.text = clients[selectedPlayer].IP;
			clPort.text = clients[selectedPlayer].Port;
			clColor.selectedColor = clients[selectedPlayer].color;
			prevColor = clients[selectedPlayer].color; 
			changeColor(clients[selectedPlayer].color);
			clSelect.selectedIndex = clients[selectedPlayer].car-1;
			cars.car1.carNum.num.text = clients[selectedPlayer].id; 
			cars.car2.carNum.num.text = clients[selectedPlayer].id; 
			if(clients[selectedPlayer].car == 1){
				cars.car1.visible = true;
				cars.car2.visible = false;
			}else if(clients[selectedPlayer].car == 2){
				cars.car1.visible = false;
				cars.car2.visible = true;
			}
			
		}
		public function carChange(evt:Event){
			if(evt.currentTarget.selectedItem.id == 1){
				cars.car1.visible = true;
				cars.car2.visible = false;
				
			}else if(evt.currentTarget.selectedItem.id == 2){
				cars.car1.visible = false;
				cars.car2.visible = true;
			}
			if(clList.length >0)
				clients[selectedPlayer].car = evt.currentTarget.selectedItem.id;
		}
		
		public function addPlayer(evt:Event){
			if(clList.length < 20){
				clIP.enabled = true;
				clName.enabled = true;
				clColor.enabled = true;
				clSelect.enabled = true;
				clPort.enabled = true;
				clList.addItem({label:"Player "+(clList.length+1)});
				if(MovieClip(parent).debugMode)
					clients.push({name:"Player "+clList.length, id:clList.length,color:0xFF0000,IP:"127.0.0.1",Port:"2345",car:1});
				else	
					clients.push({name:"Player "+clList.length, id:clList.length,color:0xFF0000,IP:"",Port:"",car:1});
				clIP.text ="";
				clPort.text = "";
				clName.text = "Player "+clList.length;
				clSelect.selectedIndex = 0;
				selectedPlayer = clList.selectedIndex = clList.length-1;
				clColor.selectedColor = 0xFF0000;
				prevColor = 0xFF0000;
				cars.car1.visible = true;
				cars.car1.carNum.num.text = clList.length;
				cars.car2.carNum.num.text = clList.length;
				cars.car2.visible = false;
				changeColor(0xFF0000);
				clList.selectedIndex = clList.length-1;
				clList.scrollToIndex(clList.length-1);
				
			}else{
				MovieClip(parent).alert.showAlert("S-a ajuns la numarul maxim de 20 de clienti.");
			}
		}
		public function delPlayer(evt:Event){
			if(selectedPlayer != -1){
				var temp:Array = new Array();
				for(var i=0;i<selectedPlayer;i++){
					temp.push(clients[i]);
				}
				for(i=selectedPlayer+1;i<clList.length-1;i++){
					clients[i].id--; 
					temp.push(clients[i]);					
				}
				clients = temp;
				clList.removeItemAt(selectedPlayer);
				selectedPlayer = -1;
				clIP.enabled = false;
				clName.enabled = false;
				clColor.enabled = false;
				clSelect.enabled = false;
				clPort.enabled = false;
			}else{
				MovieClip(parent).alert.showAlert("Nu este nici un client selectat pentru a fi sters. Selectati unul din lista!");
			}
			
		}
		public function changeColor(colo:uint){
			var newColorTransform:ColorTransform;
			newColorTransform = cars.car1.body.transform.colorTransform;
			newColorTransform.color = colo;
			cars.car1.body.transform.colorTransform = newColorTransform;				
			for(var i=1;i<=4;i++){
				newColorTransform = cars.car2["body"+i].transform.colorTransform;
				newColorTransform.color = colo;
				cars.car2["body"+i].transform.colorTransform = newColorTransform;
			}
		}
		public function checkMasini(evt:Event){
			if(nrMasini.selected == true)
				this.numarMasini = 1;
			else
				this.numarMasini = 2;
		}
		public function checkData():int{
			var isIPs:RegExp = /(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))/gi;
			for(var i=0;i<clients.length;i++){
				if(clients[i].name == ""){
					MovieClip(parent).alert.showAlert("Problema la numele clientului numarul "+i);
					return -1;
				}
				if(!MovieClip(parent).debugMode)
					if(clients[i].color == 0xFF0000){
						MovieClip(parent).alert.showAlert("Problema la culoarea masinii "+clients[i].name+". Aceasta culoare (0xFF0000) este rezervata, alegeti alta!");
						return -1;
					}
				isIPs.lastIndex = 0;
				if(isIPs.test(clients[i].IP.toString()) || clients[i].IP.toString()=="localhost" ){
				}else{
					MovieClip(parent).alert.showAlert("IP-ul clientului "+ clients[i].name+" introdus nu este corect! Trebuie sa fie de forma: \"X.X.X.X\" sau \"localhost\"");
					return -1;
				}
				if(int(clients[i].Port)<1024 || int(clients[i].Port)>65535){
					MovieClip(parent).alert.showAlert("Port-ul clientului "+ clients[i].name+" introdus nu este corect! Verificati ca este un intreg cuprins intre 1024 si 655535");
					return -1;
				}
				if(MovieClip(parent).convertIP(clients[i].IP.toString()) == -1){
					MovieClip(parent).alert.showAlert("IP-ul clientului "+ clients[i].name+" introdus nu este corect! Trebuie sa fie de forma: \"X.X.X.X\" sau \"localhost\"");
					return -1;
				}
			}
			return 1;
		}
	}
}