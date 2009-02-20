package com.gorillalogic.flexmonkey.controls
{
	import mx.automation.IAutomationObject;
	import mx.containers.VBox;
	/**
	 * Special VBox that is immune to automation
	 */
	public class IgnoreAutomationVBox extends VBox
	{
		public function IgnoreAutomationVBox()
		{
			super();
		}
	
		override public function get numAutomationChildren():int {
			return 0;
		}
		
		override public function getAutomationChildAt(index:int):IAutomationObject{
			return null;
		}
	
	}
}