/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.VOs
{
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	

	[RemoteClass]
	/**
	 * SnapshotVO holds the BitmapData for a Snapshot.  
	 * 
	 * <p>To serialize the bitmap when saving to persistent storage, 
	 * Snapshot also contains a ByteArray version of the BitmapData.</p>
	 * 
	 */ 		
	public class SnapshotVO
	{
		/**
		 * Constructor.
		 * 
		 */ 
		public function SnapshotVO()
		{
		}
		
		/**
		 * The ByteArray version of the Snapshot.
		 */ 
		public var byteArray:ByteArray;
		
		/**
		 * The width of the BitmapData.
		 */ 
		public var width:uint;
		
		/**
		 * The height of the BitmapData.
		 */ 
		public var height:uint;
		

		private var _bitmapData:BitmapData;		
		/**
		 * The BitmapData version of the Snapshot.
		 * 
		 */ 
		public function set bitmapData(b:BitmapData):void{
			_bitmapData = b;
			if(b){
				width = b.width;
				height = b.height;
				var rect:Rectangle = new Rectangle(0,0,width,height);
				byteArray = b.getPixels(rect);
			}
		}				
		public function get bitmapData():BitmapData{
			if(_bitmapData == null && byteArray != null){
				_bitmapData = new BitmapData(width,height);
				var rect:Rectangle = new Rectangle(0,0,width,height);				
				byteArray.position = 0;
				_bitmapData.setPixels(rect,byteArray);
			}	
			return _bitmapData;
		}				
	}
}