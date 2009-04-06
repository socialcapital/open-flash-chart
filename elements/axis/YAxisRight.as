package elements.axis {
	import flash.display.Sprite;
	
	public class YAxisRight extends YAxisBase {

		function YAxisRight( json:Object ) {
			
			super( json, 'y_axis_right' );
			
			//
			// OK, the user has set the right Y axis,
			// but forgot to specifically set visible to
			// true, I think we can forgive them:
			//
			if( json.y_axis_right )
				style.visible = true;
				
			this.labels = new YAxisLabelsRight( this, json );
			this.addChild( this.labels );
		}
		
		public override function get_style():Object {
			//
			// default values for a right axis (turned off)
			//
			var style:Object = {
				stroke:			2,
				'tick-length':	3,
				colour:			'#784016',
				offset:			false,
				'grid-colour':	'#F5E1AA',
				'grid-visible':	false,	// <-- this is off by default for RIGHT axis
				'3d':			0,
				steps:			1,
				visible:		false,
				min:			0,
				max:			10
			};
			
			return style;
		}
		
		public override function resize( label_pos:Number, sc:ScreenCoords ):void {
			
			super.resize_helper( label_pos, sc, true);
		}
	}
}