package tle7.starlingSlider
{
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.ClippedSprite;
	import starling.utils.Color;
	
	public class Slider extends Sprite
	{
		private var mClip:ClippedSprite;
		private var plane:Quad;
		private var list:Sprite;
		
		private var touch:Touch;
		private var startPressTime:Number;
		private var draging:Boolean = false;
		private var dragItem:Boolean = false;
		
		private var startP:Number;
		private var targetP:Number;
		private var lengthMouse:Number;
		private var power:Number;
		
		private var rect:Rectangle;
		private var type:String;
		private var typePos:String;
		private var typeSize:String;
		private var typeTouch:String;
		private var gap:Number;
		
		public var touched:Signal;
		
		public function Slider(rect:Rectangle,type:String,gap:Number=0,power:Number=0)
		{
			this.rect = rect;
			this.type = type;
			this.gap = gap;
			this.power = power;
			
			mClip = new ClippedSprite();
			this.addChild(mClip);
			plane = new Quad(width,height,Color.BLACK);
			plane.alpha = 0;
			mClip.addChild(plane);
			list = new Sprite();
			mClip.addChild(list);
			mClip.clipRect = rect;
			
			this.x = rect.x;
			this.y = rect.y;
			
			if(type=='horizontal'){
				typePos = 'x';
				typeSize = 'width';
				typeTouch = 'globalX';
			}else if(type=='vertical'){
				typePos = 'y';
				typeSize = 'height';
				typeTouch = 'globalY';
			}
			touched = new Signal(Object,Slider);
			
			setSlide();
		}
		
		public function addContent(obj:DisplayObject):void {
			if(list.numChildren>0)
				obj[typePos] = list.getChildAt(list.numChildren-1)[typePos] + list.getChildAt(list.numChildren-1)[typeSize] + gap;
			list.addChild(obj);
		}
		
		public function get getRect():Rectangle {
			return rect;
		}
		
		//////////////////////////////////////////////////////////
		///////////////////   touch  slide   /////////////////////
		//////////////////////////////////////////////////////////
		private function setSlide():void {
			
			this.addEventListener(TouchEvent.TOUCH, touchScreen);
		}
		private function touchScreen(e:TouchEvent):void {
			touch = e.getTouch(mClip);
			if(touch!=null){
				//trace(touch.target.parent);
				if(touch.phase == TouchPhase.BEGAN){
					pressTag();
				}else if(touch.phase == TouchPhase.ENDED){
					dropThis();
				}
				return;
			}
		}
		
		protected function dragLoop(e:Event):void {
			if((draging && list[typePos] > rect[typeSize]*.5) || (!draging && list[typePos] > 0)){
				targetP = 0;
				draging = false;
			}else if((draging && list[typePos]+list[typeSize] < rect[typeSize]*.5) || (!draging && list[typePos]+list[typeSize] < rect[typeSize])){
				targetP = -(list[typeSize]) + rect[typeSize];
				draging = false;
			}
			if(draging){
				list[typePos] = touch[typeTouch]-lengthMouse;
			}else{
				list[typePos] += (targetP-list[typePos])/10;
				//trace(Math.floor(main.x),Math.floor(targetPx));
				if(Math.floor(list[typePos])==Math.floor(targetP)){
					list[typePos] = targetP;
					this.removeEventListener(Event.ENTER_FRAME,dragLoop);
				}
			}
		}
		protected function pressTag():void {
			lengthMouse = Math.abs(list[typePos]) + touch[typeTouch];
			startPressTime = getTimer();
			startP = touch[typeTouch];
			draging = true;
			this.addEventListener(Event.ENTER_FRAME,dragLoop);
		}
		protected function dropThis():void {
			if(draging){
				targetP = (list[typePos] + (touch[typeTouch] - startP)) + ((touch[typeTouch] - startP)*power);
				draging = false;
				var diffTime:Number = getTimer()-startPressTime;
				//trace(diffTime);
				if(diffTime > 400){
					targetP = list[typePos];
				}else if(diffTime < 70){
					touched.dispatch(touch.target,this);
				}
			}
		}
		
		
		//////////////////////////
		public function clear():void {
			touched.removeAll();
			this.removeEventListener(TouchEvent.TOUCH, touchScreen);
			this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			this.removeChildren(0,this.numChildren-1,true);
			mClip = null;
		}
	}
}