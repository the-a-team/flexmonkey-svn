package com.gorillalogic.flexmonkey.ui
{
	import flash.display.DisplayObject;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	[Mixin]
	public class Bootstrap
	{
			
		public static function init(root:DisplayObject):void {
			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
				PopUpManager.addPopUp(FlexMonkey.theMonkey, DisplayObject(Application.application));
				PopUpManager.centerPopUp(FlexMonkey.theMonkey);	
			});			
		}		

	}
}