package elements.axis {
	import flash.text.TextField;
	
	public class YAxisLabelsLeft extends YAxisLabelsBase {

		public function YAxisLabelsLeft( parent:YAxisLeft, json:Object ) {
			
			var values:Array;
			var ok:Boolean = false;
			var lblText:String = "#val#";
			
			if( json.y_axis )
			{
				if( json.y_axis.labels is Array )
				{
					values = [];
					
					// use passed in min if provided else zero
					var i:Number = (json.y_axis && json.y_axis.min) ? json.y_axis.min : 0;
					for each( var s:String in json.y_axis.labels )
					{
						values.push( { val:s, pos:i } );
						i++;
					}
					
					//
					// alter the MinMax object:
					//
					// use passed in max if provided else the number of values less 1
					i = (json.y_axis && json.y_axis.max) ? json.y_axis.max : values.length - 1;
					parent.set_y_max( i );
					ok = true;
				}
				else if ( json.y_axis.labels is Object ) 
				{
					if ( json.y_axis.labels.text is String ) lblText = json.y_axis.labels.text;

					if ( json.y_axis.labels.labels is Array )
					{
						values = [];
						for each( var obj:Object in json.y_axis.labels.labels )
						{
							if (obj is Number) 
							{
								values.push( { val:lblText, pos:obj } );
								i = (obj > i) ? obj as Number : i;
							}
							else if (obj.y is Number)
							{
								s = (obj.text is String) ? obj.text : lblText;
								var lblStyle:Object = { val:s, pos:obj.y }
								if (obj.colour != null)
									lblStyle.colour = obj.colour;
									
								if (obj.size != null)
									lblStyle.size = obj.size;
									
								if (obj.rotate != null)
									lblStyle.rotate = obj.rotate;
									
								values.push( lblStyle );
								i = (obj.y > i) ? obj.y : i;
							}
						}
						ok = true;
					}
				}				
			}
			
			if( !ok )
			{
				values = this.make_labels( parent.style.min, parent.style.max, false, parent.style.steps, lblText );
			}
			
			
			super(values,1,json,'y_label_','y_axis');
		}

		// move y axis labels to the correct x pos
		public override function resize( left:Number, sc:ScreenCoords ):void {
			var maxWidth:Number = this.get_width();
			var i:Number;
			var tf:YTextField;
			
			for( i=0; i<this.numChildren; i++ ) {
				// right align
				tf = this.getChildAt(i) as YTextField;
				tf.x = left - tf.width + maxWidth;
			}
			
			// now move it to the correct Y, vertical center align
			for ( i=0; i < this.numChildren; i++ ) {
				tf = this.getChildAt(i) as YTextField;
				if (tf.rotation != 0) {
					tf.y = sc.get_y_from_val( tf.y_val, false ) + (tf.height / 2);
				}
				else {
					tf.y = sc.get_y_from_val( tf.y_val, false ) - (tf.height / 2);
				}
				
				//
				// this is a hack so if the top
				// label is off the screen (no chart title or key set)
				// then move it down a little.
				//
				if (tf.y < 0 && sc.top == 0) // Tried setting tf.height but that didnt work 
					tf.y = (tf.rotation != 0) ? tf.height : tf.textHeight - tf.height;
			}
		}
	}
}