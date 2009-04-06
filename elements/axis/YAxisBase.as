package elements.axis {
	import flash.display.Sprite;
	import string.Utils;
	
	public class YAxisBase extends Sprite {
		
		protected var stroke:Number;
		protected var tick_length:Number;
		protected var colour:Number;
		protected var grid_colour:Number;
		
		public var style:Object;
		
		protected var labels:YAxisLabelsBase;
		private var user_labels:Array;
		private var user_ticks:Boolean;
		
		function YAxisBase( json:Object, name:String )
		{
	
			//
			// If we set this.style in the parent, then
			// access it here it is null, but if we do
			// this hack then it is OK:
			//
			this.style = this.get_style();
			
			if( json[name] )
				object_helper.merge_2( json[name], this.style );
				
			
			this.colour = Utils.get_colour( style.colour );
			this.grid_colour = Utils.get_colour( style['grid-colour'] );
			this.stroke = style.stroke;
			this.tick_length = style['tick-length'];
			
			// try to avoid infinate loops...
			if ( this.style.steps == 0 )
				this.style.steps = 1;
				
			if ( this.style.steps < 0 )
				this.style.steps *= -1;
			
			if ((this.style.labels != null) &&
				(this.style.labels.labels != null) &&
				(this.style.labels.labels is Array) &&
				(this.style.labels.labels.length > 0))
			{
				this.user_labels = new Array();
				for each( var lbl:Object in this.style.labels.labels )
				{
					if (!(lbl is String)) {
						if (lbl.y != null) 
						{
							var tmpObj:Object = { y: lbl.y };
							if (lbl["grid-colour"])
							{
								tmpObj["grid-colour"] = Utils.get_colour(lbl["grid-colour"]);
							}
							else
							{
								tmpObj["grid-colour"] = this.grid_colour;
							}
							
							this.user_ticks = true;
							this.user_labels.push(tmpObj);
						}
					}
				}
			}

			
		}
		
		public function get_style():Object { return null;  }
		
		//
		// may be called by the labels
		//
		public function set_y_max( m:Number ):void {
			this.style.max = m;
		}
		
		public function get_range():Range {
			return new Range( this.style.min, this.style.max, this.style.steps, this.style.offset );
		}
		
		public function get_width():Number {
			return this.stroke + this.tick_length + this.labels.width;
		}
		
		public function die(): void {
			
			//this.offset = null;
			this.style = null;
			if (this.labels != null) this.labels.die();
			this.labels = null;
			
			this.graphics.clear();
			while ( this.numChildren > 0 )
				this.removeChildAt(0);
		}
		
		public function resize(label_pos:Number, sc:ScreenCoords):void { }
		
		protected function resize_helper(label_pos:Number, sc:ScreenCoords, right:Boolean):void {
			
			if( !right )
				this.labels.resize( label_pos, sc );
			else
				this.labels.resize( sc.right + this.stroke + this.tick_length, sc );
			
			if ( !this.style.visible )
				return;
			
			this.graphics.clear();
			this.graphics.lineStyle( 0, 0, 0 );
			
			// y axel grid lines
			//var every:Number = (this.minmax.y_max - this.minmax.y_min) / this.steps;
			
			// Set opacity for the first line to 0 (otherwise it overlaps the x-axel line)
			//
			// Bug? Does this work on graphs with minus values?
			//
			var i2:Number = 0;
			var i:Number;
			var y:Number;
			
			var min:Number = Math.min(this.style.min, this.style.max);
			var max:Number = Math.max(this.style.min, this.style.max);
			
			if ( this.style['grid-visible'] ) {
				//
				// draw GRID lines
				//
				if (this.user_ticks) 
				{
					for each( var lbl:Object in this.user_labels )
					{
						y = sc.get_y_from_val(lbl.y, right);
						this.graphics.beginFill(lbl["grid-colour"], 1);
						this.graphics.drawRect( sc.left, y, sc.width, 1 );
						this.graphics.endFill();
					}
				}
				else
				{
					//
					// hack: http://kb.adobe.com/selfservice/viewContent.do?externalId=tn_13989&sliceId=1
					//
					max += 0.000004;
					
					for( i = min; i <= max; i+=this.style.steps ) {
						
						y = sc.get_y_from_val(i, right);
						this.graphics.beginFill( this.grid_colour, 1 );
						this.graphics.drawRect( sc.left, y, sc.width, 1 );
						this.graphics.endFill();
					}
				}
			}
			
			var pos:Number;
			
			if (!right)
				pos = sc.left - this.stroke;
			else
				pos = sc.right;
			
			// Axis line:
			this.graphics.beginFill( this.colour, 1 );
			this.graphics.drawRect( pos, sc.top, this.stroke, sc.height );
			this.graphics.endFill();
			
			// ticks..
			var width:Number;
			if (this.user_ticks) 
			{
				for each( lbl in this.user_labels )
				{
					y = sc.get_y_from_val(lbl.y, right);
					
					if ( !right )
						tick_pos = sc.left - this.stroke - this.tick_length;
					else
						tick_pos = sc.right + this.stroke;
					
					this.graphics.beginFill( this.colour, 1 );
					this.graphics.drawRect( tick_pos, y - (this.stroke / 2), this.tick_length, this.stroke );
					//this.graphics.drawRect( pos - this.tick_length, y - (this.stroke / 2), this.tick_length, this.stroke );
					//this.graphics.drawRect( left, y-(this.stroke/2), this.tick_length, this.stroke );
					this.graphics.endFill();
				}
			}
			else
			{
				for( i = min; i <= max; i+=this.style.steps ) {
					
					// start at the bottom and work up:
					y = sc.get_y_from_val(i, right);
					
					var tick_pos:Number;
					if ( !right )
						tick_pos = sc.left - this.stroke - this.tick_length;
					else
						tick_pos = sc.right + this.stroke;
					
					this.graphics.beginFill( this.colour, 1 );
					this.graphics.drawRect( tick_pos, y - (this.stroke / 2), this.tick_length, this.stroke );
					//this.graphics.drawRect( pos - this.tick_length, y - (this.stroke / 2), this.tick_length, this.stroke );
					//this.graphics.drawRect( left, y-(this.stroke/2), this.tick_length, this.stroke );
					this.graphics.endFill();
						
				}
			}
		}
		
	}
}