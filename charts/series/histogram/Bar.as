package charts.series.histogram {
	
	import elements.axis.AxisLabel;
	
	import flash.display.JointStyle;
	import flash.events.Event;
	
	import global.Global;
	
	public class Bar extends Base {
	
		protected var is_hovered:Boolean = false;
		protected var screen_coords:ScreenCoordsBase = null;
		
		protected var label:AxisLabel;
		
		public function Bar( index:Number, style:Object, group:Number ) {
			
			super(index, style, style.colour, style.tip, style.alpha, group);
		}
		
		private function do_resize( sc:ScreenCoordsBase ):void {
			var h:Object = this.resize_helper( sc as ScreenCoords );
			
			if ( this.label != null )
				this.label.visible = false;
			
			if ( label == null )
				this.add_label();
			
			this.graphics.clear();
			
			if (this.is_hovering()){
				this.set_line(false);
			}else{
				this.set_line(true);
			}
			
			this.graphics.moveTo( 0, 0 );
			this.graphics.beginFill( this.colour, this._alpha );
			this.graphics.lineTo( h.width, 0 );
			this.graphics.lineTo( h.width, h.height );
			this.graphics.lineTo( 0, h.height );
			this.graphics.lineTo( 0, 0 );
			this.graphics.endFill();
			
			if (this.is_selected()){
				this.draw_selector(h, sc, Global.getInstance().kl_color_scheme["grey-selector"]);
			}else if (this.is_hovering()){
				this.draw_selector(h, sc, Global.getInstance().kl_color_scheme["blue-selector"]);
			}
		}
		
		public override function resize( sc:ScreenCoordsBase ):void {
			this.cached_sc = sc;
			this.screen_coords = sc;
			this.do_resize(sc);
		}
		
		
		public override function mouseOver(event:Event):void {
			this.is_tip = true;
			
			this.is_hovered = true;
			this.do_resize(this.screen_coords);
			//Tweener.addTween(this, { alpha:1, time:0.6, transition:Equations.easeOutCirc } );
		}

		public override function mouseOut(event:Event):void {
			this.is_tip = false;
			
			this.is_hovered = false;
			this.do_resize(this.screen_coords);
			//Tweener.addTween(this, { alpha:this.mouse_out_alpha, time:0.8, transition:Equations.easeOutElastic } );
		}
		
		private function draw_selector( h:Object, sc:ScreenCoordsBase, color:uint ):void{
			this.draw_label();
			
			this.graphics.lineStyle(2.0, color, 1.0, true, "normal", null, JointStyle.ROUND, 3)
			this.graphics.drawRoundRectComplex( 0, sc.top - sc.bottom + h.height+1, h.width, sc.height, 10, 10, 0, 0);
			
			var sl:Number = this.kl_selector*sc.height*kl_selector_stub_size;
			
			var a:Object = {x: h.width, y: h.height + sl + 1};
			var c:Object = {x: h.width/2, y: h.height + (this.kl_selector*sc.height) + 1};
			var e:Object = {x: 0, y: h.height + sl + 1};
			
			var g:Object = {x: a.x, y:a.y - sl};
			var f:Object = {x: e.x, y:e.y - sl};
			
			var s:Number = 0.90;
			var b:Object = this.point_between(a,c, s);
			var d:Object = this.point_between(c,e, 1-s);
			
			this.graphics.beginFill( color, 1.0 );
			
			this.graphics.moveTo( g.x, g.y );
			this.graphics.lineTo( a.x, a.y);
			this.graphics.lineTo(b.x, b.y);
			this.graphics.curveTo(c.x, c.y, d.x, d.y);
			this.graphics.lineTo(e.x, e.y);
			this.graphics.lineTo(f.x, f.y);
			
			this.graphics.endFill();
		}
		
		private function point_between(a:Object, b:Object, s: Number):Object{
			return {x: a.x+(b.x-a.x)*s, y: a.y+(b.y-a.y)*s};
		}
		
		private function is_hovering():Boolean{
			return this.kl_selector > 0 && this.is_hovered;
		}
		
		private function is_selected():Boolean{
			return this.kl_selector > 0 && this == Global.getInstance().selected_element;;
		}
		
		private function set_line(visible:Boolean):void{
			this.graphics.lineStyle(1.0, Global.getInstance().kl_color_scheme["border-grey"], 1.0, false, "normal", null, JointStyle.ROUND, 3);// : this.graphics.lineStyle(1.0, this.colour, 0, false, "normal", null, JointStyle.ROUND, 3)
		}
		
		private function draw_label():void{
			this.label.visible = true;
			this.resize_label();
		}
		
		private function add_label():void {
			label = new AxisLabel();
			var g:Global = Global.getInstance();
			label.text = g.kl_selector_labels[index];
			
			label.visible = false
			
			this.addChild(label);
		}
		
		private function resize_label():void{
			var sc:ScreenCoordsBase = this.cached_sc;
			var h:Object = this.resize_helper( sc as ScreenCoords );
			label.y = sc.top - sc.bottom + h.height + sc.height + this.kl_selector*sc.height*kl_selector_stub_size*0.5-label.textHeight/2;
		}
			
	}
}