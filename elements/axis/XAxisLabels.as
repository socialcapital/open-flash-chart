package elements.axis {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import string.Utils;
	// import DateUtils;
	
	public class XAxisLabels extends Sprite {
		
		public var need_labels:Boolean;
		public var axis_labels:Array;
		// JSON style:
		private var style:Object;
		private var userSpecifiedVisible:Object;
		
		//
		// Ugh, ugly code so we can rotate the text:
		//
		// [Embed(systemFont='Arial', fontName='spArial', mimeType='application/x-font', unicodeRange='U+0020-U+007E')]
		//[Embed(systemFont = 'Arial', fontName = 'spArial', mimeType = 'application/x-font')]
		
		public static var ArialFont__:Class;
		private var offset:Boolean = false;

		function XAxisLabels( json:Object ) {
			
			this.need_labels = true;
			
			// TODO: remove this and the class
			// var style:XLabelStyle = new XLabelStyle( json.x_labels );
			
			this.style = {
				rotate:		0,
				visible:	null,
				labels:		null,
				text:		'#val#',  // default to display the position number or x value
				steps:		null,
				size:		10,
				align:		'auto',
				colour:		'#000000'
			};
			
			// cache the text for tooltips
			this.axis_labels = new Array();
			
			if ( (json.x_axis != null) && (json.x_axis['offset'] is Boolean) ) {
				this.offset = json.x_axis['offset'];
			}
			
			if( ( json.x_axis != null ) && ( json.x_axis.labels != null ) )
				object_helper.merge_2( json.x_axis.labels, this.style );
				
			// save the user specified visible value foe use with auto_labels
			this.userSpecifiedVisible = this.style.visible;
			// for user provided labels, default to visible if not specified
			if (this.style.visible == null) this.style.visible = true; 
			
			// Force rotation value if "rotate" is specified
			if ( this.style.rotate is String )
			{
				if (this.style.rotate == "vertical")
				{
					this.style.rotate = 270;
				}
				else if (this.style.rotate == "diagonal")
				{
					this.style.rotate = -45;
				}
			}
			
			this.style.colour = Utils.get_colour( this.style.colour );
			
			if( ( this.style.labels is Array ) && ( this.style.labels.length > 0 ) )
			{
				//
				// we WERE passed labels
				//
				this.need_labels = false;
				
				var x:Number = 0;
				
				for each( var s:Object in this.style.labels )
				{
					var tmpStyle:Object = {};
					object_helper.merge_2( this.style, tmpStyle );
					tmpStyle.x = x;
					// we need the x position for #x_label# tooltips
					this.add( s, tmpStyle );
					x++;
				}
			}
		}
		
		//
		// we were not passed labels and need to make
		// them from the X Axis range
		//
		public function auto_label( range:Range, steps:Number ):void {
			
			//
			// if the user has passed labels we don't do this
			//
			if ( this.need_labels ) {
				var rev:Boolean = (range.min >= range.max); // min-max reversed?

				// Use the steps specific to labels if provided by user
				var lblSteps:Number = 1;
				if (this.style.steps != null) lblSteps = this.style.steps;

				// force max of 250 labels 
				if (Math.abs(range.count() / lblSteps) > 250) lblSteps = range.count() / 250;

				// guarantee lblSteps is the proper sign
				lblSteps = rev ? -Math.abs(lblSteps) : Math.abs(lblSteps);

				// Allow for only displaying some of the labels 
				var visibleSteps:Number = (this.style["visible-steps"] == null) ? steps : this.style["visible-steps"];

				var tempStyle:Object = {};
				object_helper.merge_2( this.style, tempStyle );
				var lblCount:Number = 0;
				for ( var i:Number = range.min; rev ? i >= range.max : i <= range.max; i += lblSteps ) {
					tempStyle.x = i;
					// restore the user specified visble value
					if (this.userSpecifiedVisible == null)
					{
						tempStyle.visible = ((lblCount % visibleSteps) == 0);
						lblCount++;
					}
					else
					{
						tempStyle.visible = this.userSpecifiedVisible;
					}
					this.add( null, tempStyle );
				}
			}
		}
		
		public function add( label:Object, style:Object ) : void
		{
			
			var label_style:Object = {
				colour:		style.colour,
				text:		style.text,
				rotate:		style.rotate,
				size:		style.size,
				align:		style.align,
				visible:	style.visible,
				x:			style.x,
				offset: 	style.offset
			};

			//
			// inherit some properties from
			// our parents 'globals'
			//
			if( label is String )
				label_style.text = label as String;
			else
				object_helper.merge_2( label, label_style );

			// Replace magic date variables in x label text
			if (label_style.x != null) {
				label_style.text = this.replace_magic_values(label_style.text, label_style.x);
			}
			
			// Map X location to label string
			this.axis_labels[label_style.x] = label_style.text;

			// only create the label if necessary
			if (label_style.visible) {
				// our parent colour is a number, but
				// we may have our own colour:
				if( label_style.colour is String )
					label_style.colour = Utils.get_colour( label_style.colour );

				var l:TextField = this.make_label( label_style );
				
				this.addChild( l );
			}
		}
		
		public function get( i:Number ) : String
		{
			if( i<this.axis_labels.length )
				return this.axis_labels[i];
			else
				return '';
		}
	
		
		public function make_label( label_style:Object ):TextField {
			// we create the text in its own movie clip, so when
			// we rotate it, we can move the regestration point
			
			var title:AxisLabel = new AxisLabel();
            title.x = 0;
			title.y = 0;
			title.offset = label_style.offset;
			
			//this.css.parseCSS(this.style);
			//title.styleSheet = this.css;
			title.text = label_style.text;
			title.htmlText = label_style.text;
			
			var fmt:TextFormat = new TextFormat();
			fmt.color = label_style.colour;
		
			// TODO: != null
			if( label_style.rotate != 0 )
			{
				// so we can rotate the text
				fmt.font = "spArial";
				title.embedFonts = true;
			}
			else
			{
				fmt.font = "Arial";
			}

			fmt.size = label_style.size;
			fmt.align = "center";
			title.setTextFormat(fmt);
			title.autoSize = "center";
			title.rotate_and_align( label_style.rotate, label_style.align, this );
			
			// we don't know the x & y locations yet...
			
			title.visible = label_style.visible;
			if (label_style.x != null)
			{
				// store the x value for use in resize
				title.xVal = label_style.x;
			}
			
			return title;
		}
		
		
		public function count() : Number
		{
			return this.axis_labels.length-1;
		}
		
		public function get_height() : Number
		{
			var height:Number = 0;
			for( var pos:Number=0; pos < this.numChildren; pos++ )
			{
				var child:DisplayObject = this.getChildAt(pos);
				height = Math.max( height, child.height );
			}
			
			return height;
		}
		
		public function resize( sc:ScreenCoords, yPos:Number ) : void//, b:Box )
		{
			
			this.graphics.clear();
			var i:Number = 0;
			
			for( var pos:Number=0; pos < this.numChildren; pos++ )
			{
				var child:AxisLabel = this.getChildAt(pos) as AxisLabel;
				if (isNaN(child.xVal))
				{
					child.x = sc.get_x_tick_pos(pos) + child.xAdj;
				}
				else
				{
					child.x = sc.get_x_from_val(child.xVal) + child.xAdj;
				}
				if ( child.offset ) {
					child.x += sc.get_x_from_val_offset(pos);
				}
				child.y = yPos + child.yAdj;
			}
		}
		
		//
		// to help Box calculate the correct width:
		//
		public function last_label_width() : Number
		{
			// is the last label shown?
//			if( ( (this.labels.length-1) % style.step ) != 0 )
//				return 0;
				
			// get the width of the right most label
			// because it may stick out past the end of the graph
			// and we don't want to truncate it.
//			return this.mcs[(this.mcs.length-1)]._width;
			if ( this.numChildren > 0 )
				// this is a kludge compensating for ScreenCoords dividing the width by 2
				return AxisLabel(this.getChildAt(this.numChildren - 1)).rightOverhang * 2;
			else
				return 0;
		}
		
		// see above comments
		public function first_label_width() : Number
		{
			if( this.numChildren>0 )
				// this is a kludge compensating for ScreenCoords dividing the width by 2
				return AxisLabel(this.getChildAt(0)).leftOverhang * 2;
			else
				return 0;
		}
		
		public function die(): void {
			
			this.axis_labels = null;
			this.style = null;
			this.graphics.clear();
			
			while ( this.numChildren > 0 )
				this.removeChildAt(0);
		}
		
		private function replace_magic_values(labelText:String, xVal:Number):String {
			labelText = labelText.replace('#val#', NumberUtils.formatNumber(xVal));
			// labelText = DateUtils.replace_magic_values(labelText, xVal);
			return labelText;
		}
		
		public function hide_label(index:Number):void{
			this.getChildAt(index).visible = false;
		}
		
		public function show_label(index:Number):void{
			this.getChildAt(index).visible = true;
		}
		
		public function show_all():void{
			for ( var i:Number = 0; i < this.numChildren ; i++ ){
				this.show_label(i);
			}
		}

	}
}
