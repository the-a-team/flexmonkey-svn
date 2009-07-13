/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	public class MonkeyAutomationError extends Error
	{
		public var briefMessage:String;
		
		public function MonkeyAutomationError(message:String, briefMessage:String)
		{
			super(message);
			this.briefMessage = briefMessage;
		}
	}
}