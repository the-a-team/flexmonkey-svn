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
	import flash.filesystem.File;

	public class FileDialogInvoker extends AbstractServiceInvoker implements IAction
	{
		public var file:File;
		public var filter:Array = null;
		public var mode:String = "browseForOpen";
		public var title:String = "Open File";
		
		public static const BROWSE_FOR_OPEN:String = "browseForOpen";
		public static const BROWSE_FOR_DIR:String = "browseForDir";
		public static const BROWSE_FOR_SAVE:String = "browseForSave";
		
		public function FileDialogInvoker()
		{
			super();
			file = new File();
			currentInstance = this;			
		}
			
		override protected function run(scope:IScope):void{
			innerHandlersDispatcher = file;
			if(resultHandlers && resultHandlers.length>0){
				createInnerHandlers(scope,Event.SELECT,resultHandlers);
			}	
			if(faultHandlers && faultHandlers.length>0){
				createInnerHandlers(scope,Event.CANCEL,faultHandlers);
			}		
			switch(mode){
				case FileDialogInvoker.BROWSE_FOR_OPEN:
					file.browseForOpen(title, filter);
					break;
				case FileDialogInvoker.BROWSE_FOR_DIR:
					file.browseForDirectory(title);
					break;
				case FileDialogInvoker.BROWSE_FOR_SAVE:
					file.browseForSave(title);
				default:				
			}
		}			
	}
}