/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.renderers
{
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Label;
	import mx.core.IFlexDisplayObject;

	public class CommandGridResultItemRenderer extends Label
	{
			
		[Embed(source="assets/icons/ok_16/ok_16.png")]
		public var passGridIcon:Class;
	
		[Embed(source='assets/icons/close_b_16/close_b_16.png')]
		public var failGridIcon:Class;	

		[Embed(source='assets/icons/asterisk_orange_16/asterisk_orange.png')]
		public var notRunGridIcon:Class;	
		
		[Embed(source="assets/icons/warning_16/warning.png")]
		public var warningGridIcon:Class;	
		
		[Embed(source="assets/icons/error_16/error_16.png")]
		public var errorGridIcon:Class;
	
		public function CommandGridResultItemRenderer()
		{
			super();	
		}
		
		private var icon:IFlexDisplayObject;

		override public function set data(value:Object):void{
			super.data = value;
			if((value is MonkeyTestSuite) || 
			   (value is MonkeyTestCase) ||
			   (value is MonkeyTest) ||
			   (value is VerifyMonkeyCommand)){
			   	text = value.result;
				setIcon(value.result);
			} else if (value is UIEventMonkeyCommand) {
				// Here ERROR is the only result we want to see the graphical display for
				if ( value.result == "ERROR" ) {
					text = value.result;
					setIcon(value.result);
				} else {
					text = "";
					setIcon(null);
				}
			} else if (value is AttributeVO) {
				text = value.result;
				setIcon(value.result);
			} else if (value is String) {
				text = String(value);
				setIcon(String(value));
			} else {
				text = "";
				setIcon(null);
			}
		}
		
		private function setIcon(result:String):void{	
			if(icon != null){
				removeChild(DisplayObject(icon));
			}
			icon=null;
			switch(result){
				case "NOT_RUN":
					icon=IFlexDisplayObject(new notRunGridIcon());
					break;
				case "FAIL":
					icon=IFlexDisplayObject(new failGridIcon());
					break;
				case "PASS":
					icon=IFlexDisplayObject(new passGridIcon());
					break;
				case "EMPTY":
					icon=IFlexDisplayObject(new warningGridIcon());
					break;	
				case "ERROR":
					icon=IFlexDisplayObject(new errorGridIcon());
					break;				
			}
			if(icon != null){				
				addChild(DisplayObject(icon));	
			}
		}

		override protected function measure():void
	    {
	        super.measure();
	        measuredWidth += 20;
	    }

   		override protected function updateDisplayList(unscaledWidth:Number,
                                                  	  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        if(icon){
	        	icon.x=2;
	        }
			textField.x += 20;
	    }
		
		
	}
}