package charts {
	import charts.series.Element;
	import charts.series.bars.Outline;
	import string.Utils;
	
	public class BarOutline extends BarBase {
		private var outline_colour:Number;
		
		public function BarOutline( json:Object, group:Number ) {
			
			//
			// specific value for outline
			//
			var style:Object = {
				'outline-colour':	"#000000"
			};
			
			object_helper.merge_2( json, style );
			
			super( json, group );
		}
		
		//
		// called from the base object
		//
		protected override function get_element( index:Number, value:Object ): Element {
			
			var default_style:Object = this.get_element_helper( value );
			
			if ( !default_style['outline-colour'] )
				default_style['outline-colour'] = this.style['outline-colour'];
			
			if( default_style['outline-colour'] is String )
				default_style['outline-colour'] = Utils.get_colour( default_style['outline-colour'] );
				
			return new Outline( index, default_style, this.group );
		}
	}
}