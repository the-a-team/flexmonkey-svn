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
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;	
	
	[Style(name="arrowDirection", type="String", enumeration="toLeft,toRight",inherit="no")]
	public class AttributeMoveArrowItemRenderer extends Label
	{
		[Embed(source="assets/icons/move_left_16/move_left_16.png")]
		public var MoveLeftGridIcon:Class;		
	
		[Embed(source="assets/icons/move_right_16/move_right_16.png")]
		public var MoveRightGridIcon:Class;
		
		public var toRight:Boolean;

		private static var classConstructed:Boolean = classConstruct();
		private static function classConstruct():Boolean {
			var styleDeclaration:CSSStyleDeclaration = StyleManager.getStyleDeclaration("AttributeMoveArrowItemRenderer");
		    if (!styleDeclaration)
		      styleDeclaration = new CSSStyleDeclaration();
		    styleDeclaration.defaultFactory = function ():void {
				this.arrowDirection = "toLeft";		
		    }
		    StyleManager.setStyleDeclaration("AttributeMoveArrowItemRenderer", styleDeclaration, false);
		    return true;
		}		
	
		public function AttributeMoveArrowItemRenderer()
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
			
			var localValue:Object = value;
			
			if(value is AttributeVO){
				var attribute:AttributeVO = value as AttributeVO;
				if (attribute.result != "NOT_RUN" && (attribute.actualValue != attribute.expectedValue)){
					if(attribute.selected){
						if(toRight){
							icon=IFlexDisplayObject(new MoveRightGridIcon());
						}else{	
							icon=IFlexDisplayObject(new MoveLeftGridIcon());			
						}
					}
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
	        measuredWidth = 20;
	    }

   		override protected function updateDisplayList(unscaledWidth:Number,
                                                  	  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        if(icon){
	        	icon.x=4;
	        }
			textField.x = 0;
	    }
	}
}