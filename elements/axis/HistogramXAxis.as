package elements.axis {
	import flash.display.Sprite;
	import flash.geom.Point;
	import string.Utils;
	import elements.axis.XAxis;
	
	
	public class HistogramXAxis extends XAxis {
		
		public function HistogramXAxis( json:Object, min:Number, max:Number){
			super(json, min, max);
			this.offset = false;
		}
		
	}
	
}