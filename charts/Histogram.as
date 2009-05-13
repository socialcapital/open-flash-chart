package charts {
	import charts.series.Element;
	import charts.series.histogram.Bar;

	public class Histogram extends BarBase {


		public function Histogram( json:Object, group:Number ) {

			super( json, group );
		}

		//
		// called from the base object
		//
		protected override function get_element( index:Number, value:Object ): Element {

			return new charts.series.histogram.Bar( index, this.get_element_helper( value ), this.group );
		}

	}
}