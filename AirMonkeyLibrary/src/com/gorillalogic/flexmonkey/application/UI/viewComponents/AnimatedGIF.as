package com.gorillalogic.flexmonkey.application.UI.viewComponents
{
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	import org.gif.player.GIFPlayer;

	public class AnimatedGIF extends UIComponent
	{
		private var _GIFStream:Class;
		public function get GIFStream():Class{
			return _GIFStream;
		}
		public function set GIFStream(c:Class):void{
			_GIFStream = c;
			invalidateProperties();
		}
		
		private var player:GIFPlayer = new GIFPlayer();
		
		public function AnimatedGIF(GIFStream:Class)
		{
			super();
			this.GIFStream = GIFStream;
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			var gifBytes:ByteArray = new GIFStream();
			player.loadBytes(gifBytes);
		}
		
		override protected function measure():void{
			super.measure();
			this.minWidth = this.measuredWidth = player.width;
			this.minHeight = this.measuredHeight = player.height;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			addChild(player);
		}
		
	}
}