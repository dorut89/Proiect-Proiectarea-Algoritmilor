package{
	
	import flash.filters.DropShadowFilter;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	
	public class Alert extends MovieClip{
		
		public function Alert(){
			var dropShadow:DropShadowFilter = new DropShadowFilter(5,45,0,1,5,5,0.5);
			this.filters = [dropShadow];
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStage);
			closeBtn.addEventListener(MouseEvent.CLICK,hideAlert);
			trace("waiting");
		}
		private function addedToStage(evt:Event){
			trace("added");
			this.x = stage.stageWidth/2 - this.width/2;
			this.y = -this.height-10;
			this.alpha = 0;
		}
		public function showAlert(str:String){
			trace("ALALALALAL"+this+" "+ stage);
			this.x = stage.stageWidth/2 - this.width/2;
			this.y = -this.height-10;
			this.alpha = 0;
			this.msg.text = str;
			Tweener.addTween(this, {alpha:0.92,x:stage.stageWidth/2 - this.width/2,
							 y:0, time:0.7, transition:"easeOut"})
		}
		public function hideAlert(evt:Event){
			Tweener.addTween(this, {alpha:0,x:stage.stageWidth/2 - this.width/2,
							 y:-this.height-10, time:1, transition:"easeOut"})
		}
	}
}