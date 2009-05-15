package global {
	
	import charts.series.Element;
	
	import elements.axis.XAxisLabels;
	import elements.labels.XLegend;
	
	public class Global {
		private static var instance:Global = null;
		private static var allowInstantiation:Boolean = false;
		
		public var x_labels:XAxisLabels;
		public var x_legend:XLegend;
		private var tooltip:String;
		
		public var kl_color_scheme:Object;
		public var selected_element:Element;
		
		public var kl_selector_labels:Array;
		
		public function Global() {
		}
		
		public static function getInstance() : Global {
			if ( Global.instance == null ) {
				Global.allowInstantiation = true;
				Global.instance = new Global();
				Global.allowInstantiation = false;
			}
			return Global.instance;
		}
		
		public function get_x_label( pos:Number ):String {
			
			// PIE charts don't have X Labels
			
			tr.ace('xxx');
			tr.ace( this.x_labels == null )
			tr.ace(pos);
//			tr.ace( this.x_labels.get(pos))
			
			
			if ( this.x_labels == null )
				return null;
			else
				return this.x_labels.get(pos);
		}
		
		public function get_x_legend(): String {
			
			// PIE charts don't have X Legend
			if( this.x_legend == null )
				return null;
			else
				return this.x_legend.text;
		}
		
		public function set_tooltip_string( s:String ):void {
			tr.ace('@@@@@@@');
			tr.ace(s);
			this.tooltip = s;
		}
		
		public function get_tooltip_string():String {
			return this.tooltip;
		}
	}
}