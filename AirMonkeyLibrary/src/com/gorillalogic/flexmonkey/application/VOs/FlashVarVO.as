/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.VOs
{
	[RemoteClass]
	public class FlashVarVO
	{
		public function FlashVarVO(name:String=null, value:String=null)
		{
			this.name = name;
			this.value = value;
		}
		public var name:String;
		public var value:String;
		
		public function get xml():XML{
			var xml:XML = 
				<flashVar name={name} value={value}/>	
			return xml;				
		}
	}
}