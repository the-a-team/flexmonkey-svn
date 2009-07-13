/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.mateExtensions
{
	import com.asfusion.mate.actionLists.IScope;
	import com.asfusion.mate.actions.AbstractServiceInvoker;
	import com.asfusion.mate.actions.IAction;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	import com.gorillalogic.flexmonkey.application.mateExtensions.URLLoaderWithURLRequest;
	
	public class URLLoaderInvoker extends AbstractServiceInvoker implements IAction
	{
		private var urlLoader:URLLoaderWithURLRequest;
				
		public function URLLoaderInvoker()
		{
			super();
			urlLoader = new URLLoaderWithURLRequest();
			currentInstance = this.urlLoader;
		}
		
		override protected function run(scope:IScope):void{
			innerHandlersDispatcher = urlLoader;
			if(resultHandlers && resultHandlers.length>0){
				createInnerHandlers(scope,Event.COMPLETE,resultHandlers);				
			}
			if(faultHandlers && faultHandlers.length>0){
				createInnerHandlers(scope,IOErrorEvent.IO_ERROR,faultHandlers);
			}
			urlLoader.load(urlLoader.urlRequest);
		}
		
		
	}
}