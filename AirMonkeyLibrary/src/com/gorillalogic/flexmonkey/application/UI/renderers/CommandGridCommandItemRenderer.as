/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.renderers
{
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Label;
	import mx.core.IFlexDisplayObject;
        	
	public class CommandGridCommandItemRenderer extends Label
	{
		
		[Embed(source="assets/icons/mouse_16/mouse.png")]
		public var MouseGridIcon:Class;		
	
		[Embed(source="assets/icons/keyboard_16/keyboard.png")]
		public var KeyboardGridIcon:Class;			

		[Embed(source="assets/icons/lightning_16/lightning.png")]
		public var LightningGridIcon:Class;		
	
		[Embed(source="assets/icons/photocamera_16/photocamera_16.png")]
		public var VerifyGridIcon:Class;
		
		[Embed(source="assets/icons/sandclock_16/sandclock_16.png")]
		public var PauseGridIcon:Class;		
		
		public function CommandGridCommandItemRenderer()
		{
			super();	
		}
		
		private var icon:IFlexDisplayObject;
		private var indentMultiple:uint;
		private var indentWidth:uint = 0;

		override public function set data(value:Object):void{
			super.data = value;	
			if(icon != null){
				removeChild(DisplayObject(icon));
			}
			icon=null;
			
			indentMultiple = 0;
			var localValue:Object = value;
			while(localValue && (localValue != localValue.parent)){
				indentMultiple++;
				localValue = localValue.parent;
			} 
			indentMultiple--;
			
			if(value is UIEventMonkeyCommand){
				switch(UIEventMonkeyCommand(value).command){
					case "Click":
						icon=IFlexDisplayObject(new MouseGridIcon());
						break;
					case "Type":
						icon=IFlexDisplayObject(new KeyboardGridIcon());
						break;
					case "Input":
						icon=IFlexDisplayObject(new KeyboardGridIcon());
						break;						
					default:
						icon=IFlexDisplayObject(new LightningGridIcon());					
				}
			}else if(value is PauseMonkeyCommand){
				icon=IFlexDisplayObject(new PauseGridIcon());					
			}else if(value is VerifyMonkeyCommand){
				icon=IFlexDisplayObject(new VerifyGridIcon());					
			}	
			if(icon != null){				
				addChild(DisplayObject(icon));	
			}
		}

		override protected function measure():void
	    {
	        super.measure();
//magic numbers!!!
	        measuredWidth += (20 + indentMultiple*indentWidth) ;
	    }

   		override protected function updateDisplayList(unscaledWidth:Number,
                                                  	  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        if(icon){
	        	icon.x=4 + indentMultiple*indentWidth;
	        }
			textField.x += (20 + (indentMultiple*indentWidth));
	    }
		
		
	}
}