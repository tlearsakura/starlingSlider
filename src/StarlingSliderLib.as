package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import starling.core.Starling;
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class StarlingSliderLib extends flash.display.Sprite
	{
		private var sl:Starling;
		
		public function StarlingSliderLib()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		
		protected function onInit(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onInit);
			
			sl = new Starling(Main, stage);
			sl.start();
		}
	}
}

import flash.geom.Rectangle;

import starling.display.Quad;
import starling.display.Sprite;

import tle7.starlingSlider.Slider;
import tle7.starlingSlider.SliderType;

class Main extends starling.display.Sprite {
	
	private var slider1:Slider;
	private var slider2:Slider;
	private var slider3:Slider;
	
	public function Main() {
		
		slider1 = new Slider(new Rectangle(50,50,700,70),SliderType.HORIZONTAL,10,11);
		slider1.touched.add(onTouchItem);
		slider1.changedPosition.add(onChangePosition1);
		var box:Quad;
		for(var i:uint=1; i<=20; i++){
			box = new Quad(50,30,Math.random()*uint.MAX_VALUE);
			slider1.addContent(box);
		}
		this.addChild(slider1);
		
		slider2 = new Slider(new Rectangle(50,100,100,450),SliderType.VERTICAL,10,12);
		slider2.touched.add(onTouchItem);
		for(i=1; i<=20; i++){
			box = new Quad(50,100,Math.random()*uint.MAX_VALUE);
			slider2.addContent(box);
		}
		this.addChild(slider2);
		
		slider3 = new Slider(new Rectangle(150,120,600,420),SliderType.HORIZONTAL,10,15);
		slider3.touched.add(onTouchItem);
		for(i=1; i<=10; i++){
			box = new Quad(200,420,Math.random()*uint.MAX_VALUE);
			slider3.addContent(box);
		}
		this.addChild(slider3);
	}
	
	private function onTouchItem(item:Object,slider:Slider):void
	{
		//trace(item,slider);
	}
	
	private function onChangePosition1(val:Number):void
	{
		//trace('slider1',val);
	}
}