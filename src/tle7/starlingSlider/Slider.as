package tle7.starlingSlider
{
	import flash.geom.Point;
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
		private var touchPoint:Point = new Point(), upPoint:Point = new Point();
		
		private var startP:Number;
		private var targetP:Number;
		private var lengthMouse:Number;
		private var power:Number;
		private var _percent:Number = 0;
		private var _pHeight:Number;
		
		private var rect:Rectangle;
		private var type:String;
		private var typePos:String;
		private var typeSize:String;
		private var typeTouch:String;
		private var gap:Number;
		
		public var touched:Signal;
		public var changedPosition:Signal;
		
		public function Slider(rect:Rectangle,type:String,gap:Number=0,power:Number=0)
		{
			touched = new Signal(Object,Slider);
			changedPosition = new Signal(Number);
			
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
			
			setSlide();
		}
		
		public function addContent(obj:DisplayObject):void {
			if(list.numChildren>0)
				obj[typePos] = list.getChildAt(list.numChildren-1)[typePos] + list.getChildAt(list.numChildren-1)[typeSize] + gap;
			list.addChild(obj);
			_pHeight = list[typeSize]-rect[typeSize];
		}
		
		public function get getRect():Rectangle {
			return rect;
		}
		
		public function get position():Number {
			return _percent;
		}
		
		public function set position(val:Number):void {
			draging = false;
			if(this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			_percent = val;
			list[typePos] = -(_percent*_pHeight);
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
			if(draging){
				if(list[typePos] > 0){
					targetP = 0;
					list[typePos] = touch[typeTouch] - lengthMouse;
					list[typePos] *= .5;
				}else if(list[typePos]+list[typeSize] < rect[typeSize]){
					targetP = -(list[typeSize]) + rect[typeSize];
					list[typePos] = touch[typeTouch] - lengthMouse;
					list[typePos] -=((list[typePos]+list[typeSize]) - rect[typeSize]) * .5;
				}else list[typePos] = touch[typeTouch] - lengthMouse;
				startPressTime = getTimer();
				startP = touch[typeTouch];
			}else{
				if(list[typePos] > 0) targetP = 0;
				else if(list[typePos]+list[typeSize] < rect[typeSize]) targetP = -(list[typeSize]) + rect[typeSize];
				
				list[typePos] += (targetP-list[typePos])/10;
				if(Math.floor(list[typePos])==Math.floor(targetP) ||
					Math.floor(list[typePos])-1==Math.floor(targetP) ||
					Math.floor(list[typePos])+1==Math.floor(targetP)){
					list[typePos] = targetP;
					this.removeEventListener(Event.ENTER_FRAME,dragLoop);
				}
			}
			_percent = Math.abs(list[typePos])/_pHeight;
			changedPosition.dispatch(_percent);
		}
		protected function pressTag():void {
			lengthMouse = touch[typeTouch] - list[typePos];
			startPressTime = getTimer();
			touchPoint.x = touch.globalX;
			touchPoint.y = touch.globalY;
			startP = touch[typeTouch];
			draging = true;
			this.addEventListener(Event.ENTER_FRAME,dragLoop);
		}
		protected function dropThis():void {
			if(draging){
				draging = false;
				var diffTime:Number = getTimer()-startPressTime;
				//trace(diffTime);
				if(diffTime > 250){
					targetP = list[typePos];
				}else if(diffTime < 90){
					upPoint.x = touch.globalX; upPoint.y = touch.globalY;
					if(Point.distance(touchPoint,upPoint) < 10) touched.dispatch(touch.target,this);
					targetP = (list[typePos] + (touch[typeTouch] - startP)) + ((touch[typeTouch] - startP)*power);
				}
				if(list[typePos] > 0) targetP = 0;
				else if(list[typePos]+list[typeSize] < rect[typeSize]) targetP = -(list[typeSize]) + rect[typeSize];
			}
		}
		
		
		//////////////////////////
		public function clear():void {
			touched.removeAll();
			this.removeEventListener(TouchEvent.TOUCH, touchScreen);
			this.removeEventListener(Event.ENTER_FRAME,dragLoop);
			this.removeChildren(0,this.numChildren-1,true);
			mClip = null;
			list = null;
		}
	}
}
