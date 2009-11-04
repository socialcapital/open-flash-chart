package charts.series.histogram {
	import charts.Base;
	
	import elements.axis.AxisLabel;
	
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	import global.Global;
	
	public class Bar extends charts.series.histogram.Base {
	
		protected var is_hovered:Boolean = false;
		protected var screen_coords:ScreenCoordsBase = null;
		
		protected var label:AxisLabel;
		
		public function Bar( index:Number, style:Object, group:Number ) {
			super(index, style, style.colour, style.tip, style.alpha, group);
			if ( this.kl_default_selected == index || this.kl_default_selected == -1){
				Global.getInstance().selected_element = this;
			}
		}
		
		private function do_resize( sc:ScreenCoordsBase ):void {
			
			this.graphics.clear();
			var h:Object = this.resize_helper( sc as ScreenCoords );
			
			//if ( this.kl_selector != 0 ){
			//	this.hide_default_labels();
			//}
			
			if ( this.label != null )
				this.label.visible = false;
			
			if ( label == null && Global.getInstance().kl_selector_labels != null)
				this.add_label();
			
			if (this.is_hovering() && this.show_selector()){
				this.set_line(false);
			}else{
				this.set_line(true);
			}
			
			this.draw_bar(h);
			
			if (this.is_selected() && this.show_selector()){
				this.draw_selector(h, sc, Global.getInstance().kl_color_scheme["grey-selector"]);
			}else if (this.is_hovering() && this.show_selector()){
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
			this.draw_label(h);
			
			this.graphics.lineStyle(3.0, color, 1.0, true, "normal", null, JointStyle.ROUND, 3)
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
			
			this.move_to_top();
		}
		
		private function point_between(a:Object, b:Object, s: Number):Object{
			return {x: a.x+(b.x-a.x)*s, y: a.y+(b.y-a.y)*s};
		}
		
		private function show_selector():Boolean{
			return this.kl_selector > 0;
		}
		
		private function is_hovering():Boolean{
			return this.is_hovered != null && this.is_hovered;
		}
		
		private function is_selected():Boolean{
			return Global.getInstance().selected_element != null && this == Global.getInstance().selected_element;
		}
		
		private function set_line(visible:Boolean):void{
			this.graphics.lineStyle(1.0, Global.getInstance().kl_color_scheme["border-grey"], 1.0, false, "normal", null, JointStyle.ROUND, 3);// : this.graphics.lineStyle(1.0, this.colour, 0, false, "normal", null, JointStyle.ROUND, 3)
		}
		
		private function draw_label(h:Object):void{
			this.label.visible = true;
			this.resize_label(h);
		}
		
		private function add_label():void {
			label = new AxisLabel();
			var g:Global = Global.getInstance();
			label.text = g.kl_selector_labels[index];
			
			label.visible = false
			
			var fmt:TextFormat = new TextFormat();
			fmt.color = 0xFFFFFF
			fmt.font = "Verdana";
			fmt.align = "left";
			fmt.size = 10;
			label.setTextFormat(fmt);
			label.autoSize = "center";
			
			this.addChild(label);
		}
		
		private function resize_label(h:Object):void{
			var sc:ScreenCoordsBase = this.cached_sc;
			var h:Object = this.resize_helper( sc as ScreenCoords );
			label.y = sc.top - sc.bottom + h.height + sc.height + this.kl_selector*sc.height*kl_selector_stub_size*0.5-label.textHeight/2;
			label.x = h.width/2 - label.textWidth/2 - 1;
		}
		
		//repositions this element above the rest, so that the kl-selector's border is not under other bar elements
		private function move_to_top():void{
			var parent:charts.Base = this.parent as charts.Base;
			
			parent.move_above_rest(this);
		}
		
		
		//hide the labels covered by this kl-selector
		private function hide_default_labels():void{
			var g:Global = Global.getInstance();
			
			g.x_labels.show_all();
			
			if ( is_hovering() && this.show_selector())
				hide_labels_around_index(this.index);
			
			if ( g.selected_element != null ) {
				hide_labels_around_index( g.selected_element.index );
			}
		}
		
		
		//hide the labels on either side of the histogram bar
		private function hide_labels_around_index(i:Number):void{
			var g:Global = Global.getInstance();
			g.x_labels.hide_label(i);
			g.x_labels.hide_label(i+1);
		}
		
		private function draw_bar(h:Object):void{
			var sc:ScreenCoordsBase = this.cached_sc;
			var cs:Object = Global.getInstance().kl_color_scheme;
			var height:Number;
			var bar_bottom:Number
			if( this.bottom == Number.MIN_VALUE )
				bar_bottom = sc.get_y_bottom(this.right_axis);
			else
				bar_bottom = sc.get_y_from_val(this.bottom, this.right_axis);
			if ( this.kl_two_tone_values != null ) {
			var bar_top:Number = sc.get_y_from_val(this.kl_two_tone_values[this.index], this.right_axis);
			}
			height = Math.abs( bar_bottom - bar_top );
    					
			var top_fill_color:uint = is_selected() ? cs["top-fill-selected"] : cs["top-fill-unselected"];
			var top_line_color:uint = is_selected() ? cs["top-border-selected"] : cs["top-border-unselected"];
			var bottom_fill_color:uint = is_selected() ? cs["bottom-fill-selected"] : cs["bottom-fill-unselected"];
			var bottom_line_color:uint = is_selected() ? cs["bottom-border-selected"] : cs["bottom-border-unselected"];
			var background_color:uint = cs["bg-colour"];
			
			this.graphics.lineStyle(1, background_color, 1.0, true, "normal", null, JointStyle.ROUND, 3);
			this.graphics.moveTo( 1, sc.top - sc.bottom + h.height );
			this.graphics.beginFill( background_color, 1.0 );
			this.graphics.lineTo( h.width-1, sc.top - sc.bottom + h.height );
			this.graphics.lineTo( h.width-1, sc.top - sc.bottom + h.height + sc.height );
			this.graphics.lineTo( 1, sc.top - sc.bottom + h.height + sc.height );
			this.graphics.lineTo( 1, sc.top - sc.bottom + h.height );
			this.graphics.endFill();
				
			if ( h.height < height ){
				this.graphics.lineStyle(1, bottom_line_color, 1.0, true, "normal", null, JointStyle.ROUND, 3);
				
				this.graphics.moveTo( 0, 0 );
				this.graphics.beginFill( bottom_fill_color, 1.0 );
				this.graphics.lineTo( h.width, 0 );
				this.graphics.lineTo( h.width, h.height );
				this.graphics.lineTo( 0, h.height );
				this.graphics.lineTo( 0, 0 );
				this.graphics.endFill();
			}else{
				this.graphics.lineStyle(1, top_line_color, 1.0, true, "normal", null, JointStyle.ROUND, 3)
				
				this.graphics.moveTo( 0, 0 );
				this.graphics.beginFill( top_fill_color, 1.0 );
				this.graphics.lineTo( h.width, 0 );
				this.graphics.lineTo( h.width, h.height - height );
				this.graphics.lineTo( 0, h.height - height );
				this.graphics.lineTo( 0, 0 );
				this.graphics.endFill();
				
				this.graphics.lineStyle(1, bottom_line_color, 1.0, true, "normal", null, JointStyle.ROUND, 3);
				
				this.graphics.moveTo( 0, h.height - height );
				this.graphics.beginFill( bottom_fill_color, 1.0 );
				this.graphics.lineTo( h.width, h.height - height );
				this.graphics.lineTo( h.width, h.height );
				this.graphics.lineTo( 0, h.height );
				this.graphics.lineTo( 0, h.height - height );
				this.graphics.endFill();
			}
		}
	}
}