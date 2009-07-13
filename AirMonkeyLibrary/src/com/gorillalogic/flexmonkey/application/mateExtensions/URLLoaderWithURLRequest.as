/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.mateExtensions
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class URLLoaderWithURLRequest extends URLLoader
	{
		public var urlRequest:URLRequest;
		public function URLLoaderWithURLRequest(request:URLRequest=null)
		{
			super(request);
		}
		
	}
}