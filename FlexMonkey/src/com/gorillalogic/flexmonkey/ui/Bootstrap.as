package com.gorillalogic.flexmonkey.ui
{
	import flash.display.DisplayObject;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * Compile with -includes com.gorillalogic.flexmonkey.ui.BootStrap to force the FlexMonkey window to open.
	 * This is only required if you are running FlexMonkey linked into your test app. Do not include this class
	 * if you're using FlexMonkeyLauncher.
	 */
	[Mixin]
	public class Bootstrap
	{
			
		public static function init(root:DisplayObject):void {
			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
				FlexMonkey.showMonkey();
			});			
		}		

	}
}