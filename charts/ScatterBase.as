package charts {
	
	import charts.series.dots.scat;
	import charts.series.Element;
	import charts.series.dots.dot_factory;
	import string.Utils;
	import flash.geom.Point;
	import flash.display.Sprite;
	import charts.series.dots.DefaultDotProperties;
	
	public class ScatterBase extends Base {

		// TODO: move this into Base
		protected var style:Object;
		
		protected var default_style:DefaultDotProperties;
		
		public function ScatterBase() { }
		
		//
		// called from the base object
		//
		protected override function get_element( index:Number, value:Object ): Element {
			// we ignore the X value (index) passed to us,
			// the user has provided their own x value
			
			var default_style:Object = {
				'dot-size':		this.style['dot-size'],
				'halo-size':	this.style['halo-size'],
				width:			this.style.width,	// stroke
				colour:			this.style.colour,
				tip:			this.style.tip
			};
			
			// Apply dot style defined at the plot level
			object_helper.merge_2( this.style['dot-style'], default_style );
			// Apply attributes defined at the value level
			object_helper.merge_2( value, default_style );
				
			// our parent colour is a number, but
			// we may have our own colour:
			if( default_style.colour is String )
				default_style.colour = Utils.get_colour( default_style.colour );
			
			var tmp:Properties = new Properties( value, this.default_style);
				
			return dot_factory.make( index, tmp );
			
			// return dot_factory.make( 0, new Properties( { } ));// default_style );
		}
		
		// Draw points...
		public override function resize( sc:ScreenCoordsBase ): void {
			
			var tmp:Sprite;
			for ( var i:Number = 0; i < this.numChildren; i++ ) {
				tmp = this.getChildAt(i) as Sprite;
				
				//
				// filter out the line masks
				//
				if( tmp is Element )
				{
					var e:Element = tmp as Element;
					e.resize( sc );
				}
			}
		}

	}
}