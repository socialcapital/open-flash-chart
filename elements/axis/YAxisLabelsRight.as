package elements.axis {
	import flash.text.TextField;
	
	public class YAxisLabelsRight extends YAxisLabelsBase {
		
		public function YAxisLabelsRight( parent:YAxisRight, json:Object ) {
			
			var values:Array;
			var ok:Boolean = false;
			var lblText:String = "#val#";
			
			if( json.y_axis_right )
			{
				if( json.y_axis_right.labels is Array )
				{
					values = [];
					
					// use passed in min if provided else zero
					var i:Number = (json.y_axis_right && json.y_axis_right.min) ? json.y_axis_right.min : 0;
					for each( var s:String in json.y_axis_right.labels )
					{
						values.push( { val:s, pos:i } );
						i++;
					}
					
					//
					// alter the MinMax object:
					//
					// use passed in max if provided else the number of values less 1
					i = (json.y_axis_right && json.y_axis_right.max) ? json.y_axis_right.max : values.length - 1;
					parent.set_y_max( i );
					ok = true;
				}
				else if ( json.y_axis_right.labels is Object ) 
				{
					i = (json.y_axis_right && json.y_axis_right.min) ? json.y_axis_right.min : 0;
					if ( json.y_axis_right.labels.text is String ) lblText = json.y_axis_right.labels.text;

					if ( json.y_axis_right.labels.labels is Array )
					{
						values = [];
						for each( var obj:Object in json.y_axis_right.labels.labels )
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
								if (obj.colour != null) lblStyle.colour = obj.colour;
								if (obj.size != null) lblStyle.size = obj.size;
								if (obj.rotate != null) lblStyle.rotate = obj.rotate;
								values.push( lblStyle );
								i = (obj.y > i) ? obj.y : i;
							}
						}
						ok = true;
					}
				}				
			}
			
			if( !ok && parent.style.visible )
				values = make_labels( parent.style.min, parent.style.max, true, 1, lblText );
			
			super( values, 1, json, 'y_label_2_', 'y_axis_right');
		}

		// move y axis labels to the correct x pos
		public override function resize( left:Number, box:ScreenCoords ):void {
			var maxWidth:Number = this.get_width();
			var i:Number;
			var tf:YTextField;
			
			for( i=0; i<this.numChildren; i++ ) {
				// left align
				tf = this.getChildAt(i) as YTextField;
				tf.x = left; // - tf.width + maxWidth;
			}
			
			// now move it to the correct Y, vertical center align
			for ( i=0; i < this.numChildren; i++ ) {
				tf = this.getChildAt(i) as YTextField;
				if (tf.rotation != 0) {
					tf.y = box.get_y_from_val( tf.y_val, true ) + (tf.height / 2);
				}
				else {
					tf.y = box.get_y_from_val( tf.y_val, true ) - (tf.height / 2);
				}
				if (tf.y < 0 && box.top == 0) // Tried setting tf.height but that didnt work 
					tf.y = (tf.rotation != 0) ? tf.height : tf.textHeight - tf.height;
			}
		}
	}
}