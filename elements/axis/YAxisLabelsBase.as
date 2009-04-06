package elements.axis {
	import flash.display.Sprite;
	import elements.axis.YTextField;
	import flash.text.TextFormat;
	import org.flashdevelop.utils.FlashConnect;
	import br.com.stimuli.string.printf;
	import string.Utils;
	
	public class YAxisLabelsBase extends Sprite {
		private var steps:Number;
		private var right:Boolean;
		protected var style:Object;
		
		public function YAxisLabelsBase( values:Array, steps:Number, json:Object, name:String, axis_name:String ) {

			this.steps = steps;
			
			var lblStyle:YLabelStyle = new YLabelStyle( json, name );
			this.style = lblStyle.style;
			
			// Default to using "rotate" from the y_axis level
			if ( json[axis_name] && json[axis_name].rotate ) {
				this.style.rotate = json[axis_name].rotate;
			}

			// Next override with any values at the y_axis.labels level
			if (( json[axis_name] != null ) && 
				( json[axis_name].labels != null ) ) {
				object_helper.merge_2( json[axis_name].labels, this.style );
			}
			
			// are the Y Labels visible?
			if( !this.style.show_labels )
				return;
			
			// labels
			var pos:Number = 0;
			
			for each ( var v:Object in values )
			{
				var tmp:YTextField = this.make_label( v );
				tmp.y_val = v.pos;
				this.addChild(tmp);
				
				pos++;
			}
		}

		//
		// use Y Min, Y Max and Y Steps to create an array of
		// Y labels:
		//
		protected function make_labels( min:Number, max:Number, right:Boolean, steps:Number, lblText:String ):Array {
			var values:Array = [];
			
			var min_:Number = Math.min( min, max );
			var max_:Number = Math.max( min, max );
			
			// hack: hack: http://kb.adobe.com/selfservice/viewContent.do?externalId=tn_13989&sliceId=1
			max_ += 0.000004;
			
			var eek:Number = 0;
			for( var i:Number = min_; i <= max_; i+=steps ) {
				values.push( { val:lblText, pos:i } );
				
				// make sure we don't generate too many labels:
				if( eek++ > 250 ) break;
			}
			return values;
		}
		
		private function make_label( json:Object ):YTextField
		{
			
			
			// does _root already have this textFiled defined?
			// this happens when we do an AJAX reload()
			// these have to be deleted by hand or else flash goes wonky.
			// In an ideal world we would put this code in the object
			// distructor method, but I don't think actionscript has these :-(
			
			var lblStyle:Object = { };
			object_helper.merge_2( this.style, lblStyle );
			object_helper.merge_2( json, lblStyle );
			lblStyle.colour = string.Utils.get_colour(lblStyle.colour);
			
			var tf:YTextField = new YTextField();
			//tf.border = true;
			tf.text = this.replace_magic_values(lblStyle.val, lblStyle.pos);
			var fmt:TextFormat = new TextFormat();
			fmt.color = lblStyle.colour;
			fmt.font = lblStyle.rotate == "vertical" ? "spArial" : "Verdana";
			fmt.size = lblStyle.size;
			fmt.align = "right";
			tf.setTextFormat(fmt);
			tf.autoSize = "right";
			if (lblStyle.rotate == "vertical")
			{
				tf.rotation = 270;
				tf.embedFonts = true;
				tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			} 
			return tf;
		}

		// move y axis labels to the correct x pos
		public function resize( left:Number, sc:ScreenCoords ):void
		{
		}


		public function get_width():Number{
			var max:Number = 0;
			for( var i:Number=0; i<this.numChildren; i++ )
			{
				var tf:YTextField = this.getChildAt(i) as YTextField;
				max = Math.max( max, tf.width );
			}
			return max;
		}
		
		public function die(): void {
			
			while ( this.numChildren > 0 )
				this.removeChildAt(0);
		}

		private function replace_magic_values(labelText:String, yVal:Number):String {
			labelText = labelText.replace('#val#', NumberUtils.formatNumber(yVal));
			return labelText;
		}
	}
}