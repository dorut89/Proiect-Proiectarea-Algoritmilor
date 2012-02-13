package{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	
	public class ReadyGo extends MovieClip{
		
		public function ReadyGo(){
			super();
			theText.txt.text = String(5);
			theText.alpha = 0;
			theText.scaleX = theText.scaleY = 0.4;
			//start();
		}
		public function start(){
			Tweener.addTween(theText, {alpha:0,scaleX:1.4,scaleY:1.4, time:1, transition:"easeOut", onComplete:step,onCompleteParams:["5"]})
		}
		public function step(str:String){
			if(str == "-1"){
				str = "GO!";
			}
			theText.txt.text = str;
			theText.alpha = 0;
			theText.scaleX = theText.scaleY = 0.4;			
			
			Tweener.addTween(theText, {alpha:1,scaleX:1,scaleY:1, time:0.5, transition:"easeOut"});
			if(str == "GO!")
				Tweener.addTween(theText, {alpha:0,scaleX:2,scaleY:2, time:1, delay:0.8, transition:"easeOut", onComplete:finnished})
			else
				Tweener.addTween(theText, {alpha:0,scaleX:1.4,scaleY:1.4, time:0.5, delay:0.5, transition:"easeOut", onComplete:step,onCompleteParams:[(String(int(str)-1))]})
		}
		
		public function finnished(){
			dispatchEvent(new Event("animFinnish"));
		}
		
	}
}