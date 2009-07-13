/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.utilities
{
	import com.gorillalogic.flexmonkey.application.VOs.AS3FileVO;
	
	import mx.collections.ArrayCollection;
	
	public class AS3FileCollector
	{
		public function AS3FileCollector(packageName:String)
		{
			_packageName = packageName;
		}
		private var _AS3Files:ArrayCollection = new ArrayCollection();
		public function get AS3Files():ArrayCollection{
			return _AS3Files;
		}

		private var _packageName:String;
		public function get packageName():String{
			return _packageName;	
		}
		
		public function addItem(fr:AS3FileVO):void{
			_AS3Files.addItem(fr);
		}		
	}
}