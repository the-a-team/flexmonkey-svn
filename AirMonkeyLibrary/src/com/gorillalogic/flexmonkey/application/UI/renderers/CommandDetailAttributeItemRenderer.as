/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.renderers
{
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Label;
	import mx.core.IFlexDisplayObject;
	
	public class CommandDetailAttributeItemRenderer extends Label
	{
		[Embed(source="assets/icons/property_16/property_16.png")]
		public var PropertyGridIcon:Class;		
	
		[Embed(source="assets/icons/style_16/style_16.png")]
		public var StyleGridIcon:Class;
		
		public function CommandDetailAttributeItemRenderer()
		{
			super();	
		}
		
		private var icon:IFlexDisplayObject;

		override public function set data(value:Object):void{
			super.data = value;	
			if(icon != null){
				removeChild(DisplayObject(icon));
			}
			icon=null;
			
			if(value is AttributeVO){
				switch(AttributeVO(value).type){
					case AttributeVO.PROPERTY:
						icon=IFlexDisplayObject(new PropertyGridIcon());
						break;
					case AttributeVO.STYLE:
						icon=IFlexDisplayObject(new StyleGridIcon());
						break;
					default:
						//throw new ;					
				}
			}	
			if(icon != null){				
				addChild(DisplayObject(icon));	
			}
		}
		
		override protected function measure():void
	    {
	        super.measure();
//magic numbers!!!
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