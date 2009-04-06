package charts.series.bars {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import caurina.transitions.Tweener;
	import caurina.transitions.Equations;
	import flash.geom.Point;
	import global.Global;
	import charts.series.Element;
	
	public class Base extends Element
	{
		protected var tip_pos:flash.geom.Point;
		protected var colour:Number;
		protected var group:Number;
		protected var top:Number;
		protected var bottom:Number;
		protected var mouse_out_alpha:Number;
		
		public function Base( index:Number, value:Object, colour:Number, tooltip:String, alpha:Number, group:Number )
		{
			super();
			this.index = index;
			this.parse_value(value);
			this.colour = colour;
			this.tooltip = this.replace_magic_values( tooltip );
			
			this.group = group;
			this.visible = true;
			
			// remember what our original alpha is:
			this.mouse_out_alpha = alpha;
			// set the sprit alpha:
			this.alpha = this.mouse_out_alpha;
			
			this.addEventListener(MouseEvent.MOUSE_OVER, this.mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, this.mouseOut);
			
			//
			// This is UGLY!!! We need to decide if we are passing in a SINGLE style object,
			// or many parameters....
			//
			if( value['on-click'] )
				this.set_on_click( value['on-click'] );
				
			if ( value.axis )
				if ( value.axis == 'right' )
					this.right_axis = true;
		}
		
		//
		// most line and bar charts have a single value which is the
		// Y position, some like candle and scatter have many values
		// and will override this method to parse their value
		//
		protected function parse_value( value:Object ):void {
			
			if( value is Number )
			{
				this.top = value as Number;
				this.bottom = Number.MIN_VALUE;		// <-- align to Y min OR zero
			}
			else
			{
				this.top = value.top;
				
				if( value.bottom == null )
					this.bottom = Number.MIN_VALUE;	// <-- align to Y min OR zero
				else
					this.bottom = value.bottom;
			}
		}
		
		protected function replace_magic_values( t:String ): String {
			
			t = t.replace('#top#', NumberUtils.formatNumber( this.top ));
			t = t.replace('#bottom#', NumberUtils.formatNumber( this.bottom ));
			t = t.replace('#val#', NumberUtils.formatNumber( this.top - this.bottom ));
			
			return t;
		}
		
		
		//
		// for tooltip closest - return the middle point
		//
		public override function get_mid_point():flash.geom.Point {
			
			//
			// bars mid point
			//
			return new flash.geom.Point( this.x + (this.width/2), this.y );
		}
		
		public override function mouseOver(event:Event):void {
			this.is_tip = true;
			Tweener.addTween(this, { alpha:1, time:0.6, transition:Equations.easeOutCirc } );
		}

		public override function mouseOut(event:Event):void {
			this.is_tip = false;
			Tweener.addTween(this, { alpha:this.mouse_out_alpha, time:0.8, transition:Equations.easeOutElastic } );
		}
		
		// override this:
		public override function resize( sc:ScreenCoordsBase ):void {}
		
		//
		// tooltip.left for bars center over the bar
		//
		public override function get_tip_pos(): Object {
			return {x:this.tip_pos.x, y:this.tip_pos.y };
		}
		

		//
		// Called by most of the bar charts.
		// Moves the Sprite into the correct position, then
		// returns the bounds so the bar can draw its self.
		//
		protected function resize_helper( sc:ScreenCoords ):Object {
			var tmp:Object = sc.get_bar_coords(this.index, this.group);

			var bar_top:Number = sc.get_y_from_val(this.top, this.right_axis);
			var bar_bottom:Number;
			
			if( this.bottom == Number.MIN_VALUE )
				bar_bottom = sc.get_y_bottom(this.right_axis);
			else
				bar_bottom = sc.get_y_from_val(this.bottom, this.right_axis);
			
			var top:Number;
			var height:Number;
			var upside_down:Boolean = false;
			
			if( bar_bottom < bar_top ) {
				top = bar_bottom;
				upside_down = true;
			}
			else
			{
				top = bar_top;
			}
			
			height = Math.abs( bar_bottom - bar_top );
			
			//
			// move the Sprite to the correct screen location:
			//
			this.y = top;
			this.x = tmp.x;

			//var d:Number = this.x / this.stage.stageWidth * 3;
			Tweener.removeTweens(this);
			
//			this.y = this.stage.stageHeight + this.height + 3;
//			Tweener.addTween(this, { y:top, time:1, delay:d, transition:Equations.easeOutBounce } );
			
//			this.y = -height - 10;
//			Tweener.addTween(this, { y:top, time:1, delay:d, transition:Equations.easeOutBounce } );
			
			
//			var d:Number = this.x / this.stage.stageWidth * 2;
//			this.y = top;
//			this.alpha = 0;
//			Tweener.addTween(this, { alpha:this.mouse_out_alpha, time:1.2, delay:d, transition:Equations.easeOutQuad } );

//			var d:Number = this.x / this.stage.stageWidth * 2;
//			this.y = top;
//			this.alpha = 0;
//			Tweener.addTween(this, { alpha:this.mouse_out_alpha, time:0.7, delay:d, transition:Equations.easeOutQuad } );
//			this.scaleX = 0.3;
//			Tweener.addTween(this, { scaleX:1, time:1.2, delay:d, transition:Equations.easeOutElastic } );
//			this.scaleY = 0.3;
//			Tweener.addTween(this, { scaleY:1, time:1.2, delay:d, transition:Equations.easeOutElastic } );
			
			//
			// tell the tooltip where to show its self
			//
			this.tip_pos = new flash.geom.Point( this.x + (tmp.width / 2), top );
			
			//
			// return the bounds to draw the item:
			//
			return { width:tmp.width, top:top, height:height, upside_down:upside_down };
		}
	}
}