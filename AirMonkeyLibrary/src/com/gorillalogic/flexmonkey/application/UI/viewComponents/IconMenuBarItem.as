/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.viewComponents
{
	import mx.controls.menuClasses.MenuBarItem;
	import mx.core.IFlexDisplayObject;

	public class IconMenuBarItem extends MenuBarItem
	{
		
		public function IconMenuBarItem()
		{
			super();
		}
	    override protected function updateDisplayList(unscaledWidth:Number,
	                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        var lMargin:int = 0;
	        if (icon)
	        {
	            icon.x = (lMargin - icon.measuredWidth) / 2;
	            icon.setActualSize(icon.measuredWidth, icon.measuredHeight);
	            label.x = lMargin;
	        }
	        else
	            label.x = lMargin / 2;
	            
	        label.setActualSize(unscaledWidth - lMargin, 
	            label.getExplicitOrMeasuredHeight());
	            
	        label.y = (unscaledHeight - label.height) / 2;
	        
	        if (icon)
	            icon.y = (unscaledHeight - icon.height) / 2;
	         

		    menuBarItemState = "itemUpSkin";
	    }		
	}
}