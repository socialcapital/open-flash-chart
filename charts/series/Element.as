package charts.series {
	
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import elements.axis.XAxisLabels;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import global.Global;
	
	public class Element extends Sprite implements has_tooltip {
		//
		// for line data
		//
		public var _x:Number;
		public var _y:Number;
		
		public var index:Number;
		protected var tooltip:String;
		private var link:String;
		private var hover_link:String = null;
		public var is_tip:Boolean;
		
		public var line_mask:Sprite;
		protected var right_axis:Boolean;
		
		protected var selected:Boolean = false;
		protected var cached_sc:ScreenCoordsBase;
		
		
		public function Element()
		{
			this.right_axis = false;	
		}
		
		public function resize( sc:ScreenCoordsBase ):void {
			this.cached_sc = sc;
			var p:flash.geom.Point = sc.get_get_x_from_pos_and_y_from_val( this._x, this._y, this.right_axis );
			this.x = p.x;
			this.y = p.y;
		}
		
		//
		// for tooltip closest - return the middle point
		//
		public function get_mid_point():flash.geom.Point {
			
			//
			// dots have x, y in the center of the dot
			//
			return new flash.geom.Point( this.x, this.y );
		}
		
		public function get_x(): Number {
			return this._x;
		}

		/**
		 * When true, this element is displaying a tooltip
		 * and should fade-in, pulse, or become active
		 * 
		 * override this to show hovered states.
		 * 
		 * @param	b
		 */
		public function set_tip( b:Boolean ):void {}
		
		
		//
		// if this is put in the Element constructor, it is
		// called multiple times for some reason :-(
		//
		protected function attach_events():void {
			
			// weak references so the garbage collector will kill them:
			this.addEventListener(MouseEvent.MOUSE_OVER, this.mouseOver, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OUT, this.mouseOut, false, 0, true);
		}
		
		public function mouseOver(event:Event):void {
			this.pulse();
		}
		
		public function pulse():void {
			// pulse:
			Tweener.addTween(this, {alpha:.5, time:0.4, transition:"linear"} );
			Tweener.addTween(this, {alpha:1,  time:0.4, delay:0.4, onComplete:this.pulse, transition:"linear"});
		}

		public function mouseOut(event:Event):void {
			// stop the pulse, then fade in
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:1, time:0.4, transition:Equations.easeOutElastic } );
		}
		
		public function set_on_click( s:String ):void {
			this.link = s;
			this.buttonMode = true;
			this.useHandCursor = true;
			// weak references so the garbage collector will kill it:
			this.addEventListener(MouseEvent.MOUSE_UP, this.mouseUp, false, 0, true);
		}
		
		public function set_on_hover( s:String ):void {
			this.hover_link = s;
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener(MouseEvent.MOUSE_OVER, this.mouseHover, false, 0, true);
		}
		
		public function mouseHover(event:Event){
			ExternalInterface.call( this.hover_link, this.index );
		}
		
		private function mouseUp(event:Event):void {
			var ele:Element = Global.getInstance().selected_element;
			Global.getInstance().selected_element = this;
			if ( ele != null )
				ele.resize(this.cached_sc);
			
			if ( this.link.substring(0, 6) == 'trace:' ) {
				// for the test JSON files:
				tr.ace( this.link );
			}
			else if ( this.link.substring(0, 5) == 'http:' )
				this.browse_url( this.link );
			else if ( this.link.substring(0, 6) == 'https:' )
				this.browse_url( this.link );
			else
				ExternalInterface.call( this.link, this.index );
			this.resize(this.cached_sc);
		}
			
		private function browse_url( url:String ):void {
			var req:URLRequest = new URLRequest(this.link);
			try
			{
				navigateToURL(req);
			}
			catch (e:Error)
			{
				trace("Error opening link: " + this.link);
			}
		}
		
		public function get_tip_pos():Object {
			return {x:this.x, y:this.y};
		}
		
		
		//
		// this may be overriden by Collection objects
		//
		public function get_tooltip():String {
			return this.tooltip;
		}

		/**
		 * Replace #x_label# with the label. This is called
		 * after the X Label object has been built (see main.as)
		 * 
		 * @param	labels
		 */
		public function tooltip_replace_labels( labels:XAxisLabels ):void {
			
			tr.aces('x label', this._x, labels.get( this._x ));
			this.tooltip = this.tooltip.replace('#x_label#', labels.get( this._x ) );
		}
		
		/**
		 * Mem leaks
		 */
		public function die():void {
			
			if ( this.line_mask != null ) {
				
				this.line_mask.graphics.clear();
				this.line_mask = null;
			}
		}
	}
}