package charts.series.bars {
	
	import flash.display.Sprite;
	import charts.series.bars.Base;
	
	public class Outline extends Base {
		private var outline:Number;
		
		public function Outline( index:Number, style:Object, group:Number )	{
			
			super( index, style, style.colour, style.tip, style.alpha, group );
			this.outline = style['outline-colour'];
		}
		
		public override function resize( sc:ScreenCoordsBase ):void {
			
			var h:Object = this.resize_helper( sc as ScreenCoords );
			
			this.graphics.clear();
			this.graphics.lineStyle(1, this.outline, 1);
			this.graphics.beginFill( this.colour, 1.0 );
			this.graphics.moveTo( 0, 0 );
			this.graphics.lineTo( h.width, 0 );
			this.graphics.lineTo( h.width, h.height );
			this.graphics.lineTo( 0, h.height );
			this.graphics.lineTo( 0, 0 );
			this.graphics.endFill();
			
		}
	}
}