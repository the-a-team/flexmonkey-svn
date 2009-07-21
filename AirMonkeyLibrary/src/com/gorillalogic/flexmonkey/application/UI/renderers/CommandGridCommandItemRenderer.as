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
	import mx.core.ClassFactory;
	import mx.core.IFlexDisplayObject;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;		

	[Style(name="MouseGridIcon", type="Class", inherit="no")]
	[Style(name="KeyboardGridIcon", type="Class", inherit="no")]
	[Style(name="LightningGridIcon", type="Class", inherit="no")]
	[Style(name="VerifyGridIcon", type="Class", inherit="no")]
	[Style(name="PauseGridIcon", type="Class", inherit="no")]
        	
	public class CommandGridCommandItemRenderer extends Label
	{
		
		[Embed(source='assets/icons/asterisk_orange_16/asterisk_orange.png')]
		public static var defaultIcon:Class;		

		private static var classConstructed:Boolean = classConstruct();
		private static function classConstruct():Boolean{
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("CommandGridCommandItemRenderer");
		    if (!styleDeclaration)
		    	styleDeclaration = new CSSStyleDeclaration();
		    styleDeclaration.defaultFactory = function ():void {
				this.MouseGridIcon = defaultIcon;
				this.KeyboardGridIcon = defaultIcon;
				this.LightningGridIcon = defaultIcon;
				this.VerifyGridIcon = defaultIcon;
				this.PauseGridIcon = defaultIcon;
		    }
		    StyleManager.setStyleDeclaration("CommandGridCommandItemRenderer", styleDeclaration, false);				
			return true;
		}	
		
//		[Embed(source="assets/icons/mouse_16/mouse.png")]
//		public var MouseGridIcon:Class;// = defaultIcon;		
	
//		[Embed(source="assets/icons/keyboard_16/keyboard.png")]
//		public var KeyboardGridIcon:Class;// = defaultIcon;			

//		[Embed(source="assets/icons/lightning_16/lightning.png")]
//		public var LightningGridIcon:Class;// = defaultIcon;		
	
//		[Embed(source="assets/icons/photocamera_16/photocamera_16.png")]
//		public var VerifyGridIcon:Class;// = defaultIcon;
		
//		[Embed(source="assets/icons/sandclock_16/sandclock_16.png")]
//		public var PauseGridIcon:Class;// = defaultIcon;		
		
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
						icon=IFlexDisplayObject((new ClassFactory(getStyle("MouseGridIcon"))).newInstance());
						break;
					case "Type":
						icon=IFlexDisplayObject((new ClassFactory(getStyle("KeyboardGridIcon"))).newInstance());
						break;
					case "Input":
						icon=IFlexDisplayObject((new ClassFactory(getStyle("KeyboardGridIcon"))).newInstance());
						break;						
					default:
						icon=IFlexDisplayObject((new ClassFactory(getStyle("LightningGridIcon"))).newInstance());					
				}
			}else if(value is PauseMonkeyCommand){
				icon=IFlexDisplayObject((new ClassFactory(getStyle("PauseGridIcon"))).newInstance());					
			}else if(value is VerifyMonkeyCommand){
				icon=IFlexDisplayObject((new ClassFactory(getStyle("VerifyGridIcon"))).newInstance());					
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