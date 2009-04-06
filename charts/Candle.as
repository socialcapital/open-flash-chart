﻿package charts {
	import charts.series.Element;
	import charts.series.bars.ECandle;
	import string.Utils;

	
	public class Candle extends BarBase {
		
		public function Candle( json:Object, group:Number ) {
			
			super( json, group );
		}
		
		//
		// called from the base object
		//
		protected override function get_element( index:Number, value:Object ): Element {
			
			
			var default_style:Object = {
					colour:		this.style.colour,
					tip:		this.style.tip,
					alpha:      this.style.alpha
			};
			
			if( value is Number )
				default_style.top = value;
			else
				object_helper.merge_2( value, default_style );
				
			// our parent colour is a number, but
			// we may have our own colour:
			if( default_style.colour is String )
				default_style.colour = Utils.get_colour( default_style.colour );
				
			// tr.ace_json(default_style);
			
			return new ECandle( index, default_style, this.group );
		}
	}
}