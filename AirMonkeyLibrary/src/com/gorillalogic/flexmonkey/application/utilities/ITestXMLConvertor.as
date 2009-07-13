/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.utilities
{
	import mx.collections.ArrayCollection;
	
	public interface ITestXMLConvertor
	{
		function parseXML(input:XML):ArrayCollection;
		function generateXML(input:ArrayCollection):String;
	}
}