package charts.series.dots {
	
	import flash.display.Sprite;
	import charts.series.Element;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class PointDotBase extends Element {
		
		protected var radius:Number;
		protected var colour:Number;
		
		public function PointDotBase( index:Number, style:Properties ) {
			
			super();
			this.is_tip = false;
			this.visible = true;
			
			// line charts have a value and no X, scatter charts have
			// x, y (not value): radar charts have value, Y does not 
			// make sense.
			if( !style.has('y') )
				style.set('y', style.get('value'));
		
			this._y = style.get('y');
			
			// no X passed in so calculate it from the index
			if( !style.has('x') )
			{
				this.index = this._x = index;
			}
			else
			{
				tr.aces( 'x', style.get('x') );
				this._x = style.get('x');
				this.index = Number.MIN_VALUE;
			}
			
			this.radius = style.get('dot-size');
			this.tooltip = this.replace_magic_values( style.get('tip') );
			
			if ( style.has('on-click') )
				this.set_on_click( style.get('on-click') );
			
			//
			// TODO: fix this hack
			//
			if ( style.has('axis') )
				if ( style.get('axis') == 'right' )
					this.right_axis = true;

		}
		
		public override function resize( sc:ScreenCoordsBase ): void {
			
			if ( this.index != Number.MIN_VALUE ) {
	
				var p:flash.geom.Point = sc.get_get_x_from_pos_and_y_from_val( this.index, this._y, this.right_axis );
				this.x = p.x;
				this.y = p.y;
			}
			else
			{

				//
				// Look: we have a real X value, so get its screen location:
				//
				this.x = sc.get_x_from_val( this._x );
				this.y = sc.get_y_from_val( this._y, this.right_axis );
			}
			
			// Move the mask so it is in the proper place also
			// this all needs to be moved into the base class
			if (this.line_mask != null)
			{
				this.line_mask.x = this.x;
				this.line_mask.y = this.y;
			}
		}
		
		public override function set_tip( b:Boolean ):void {
			//this.visible = b;
			if( b ) {
				this.scaleY = this.scaleX = 1.3;
				this.line_mask.scaleY = this.line_mask.scaleX = 1.3;
			}
			else {
				this.scaleY = this.scaleX = 1;
				this.line_mask.scaleY = this.line_mask.scaleX = 1;
			}
		}
		
		//
		// Dirty hack. Takes tooltip text, and replaces the #val# with the
		// tool_tip text, so noew you can do: "My Val = $#val#%", which turns into:
		// "My Val = $12.00%"
		//
		protected function replace_magic_values( t:String ): String {
			
			t = t.replace('#val#', NumberUtils.formatNumber( this._y ));
			
			// for scatter charts
			t = t.replace('#x#', NumberUtils.formatNumber(this._x));
			t = t.replace('#y#', NumberUtils.formatNumber(this._y));
			
			// debug the dots sizes
			t = t.replace('#size#', NumberUtils.formatNumber(this.radius));
			return t;
		}
		
		protected function calcXOnCircle(aRadius:Number, aDegrees:Number):Number
		{
			return aRadius * Math.cos(aDegrees / 180 * Math.PI);
		}
		
		protected function calcYOnCircle(aRadius:Number, aDegrees:Number):Number
		{
			return aRadius * Math.sin(aDegrees / 180 * Math.PI);
		}
		
	}
}

