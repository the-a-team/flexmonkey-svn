/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.monkeyAgent.VOs
{
	public class TXVO
	{
		public function TXVO(channel:String, method:String, arguments:Array=null)
		{
			this.channel = channel;
			this.method = method;
			this.arguments = arguments;
			txCount = 0;
		}

		public var channel:String;
		public var method:String;
		public var arguments:Array;
		public var txCount:uint;

	}
}