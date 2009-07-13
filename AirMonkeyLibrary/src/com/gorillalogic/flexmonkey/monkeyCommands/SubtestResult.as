/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	public class SubtestResult
	{
		public function SubtestResult()
		{
		}
		
		/**
		 * The description of the subtest.
		 */ 
		public var description:String;
		
		/**
		 * The expected value of the property.
		 */ 
		public var expectedValue:String;
		
		/**
		 * The actual value of the property.
		 */ 
		public var actualValue:String;
	}
}