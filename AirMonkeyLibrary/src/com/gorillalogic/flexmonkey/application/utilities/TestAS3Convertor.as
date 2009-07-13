/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.utilities
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import com.gorillalogic.flexmonkey.application.utilities.AS3FileCollector;
		
	public class TestAS3Convertor
	{
		public function TestAS3Convertor()
		{
		}

		public var mateDispatcher:IEventDispatcher; 

		public function generateAS3(input:ArrayCollection,collector:AS3FileCollector):void{
			for(var j:int=0;j<input.length;j++){
				input[j].getAS3(collector);						
			}	
		}
	}
}