/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.viewComponents
{
	import mx.controls.MenuBar;
	import mx.controls.menuClasses.IMenuBarItemRenderer;
	import flash.geom.Rectangle;

	public class IconMenuBar extends MenuBar
	{
		public function IconMenuBar()
		{
			super();
		}
	    override protected function updateDisplayList(unscaledWidth:Number,
	                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        var lastX:Number = 0;
	        var lastW:Number = 0;
	        var len:int = menuBarItems.length;
	
	        var clipContent:Boolean = false;
	        var hideItems:Boolean = (unscaledWidth == 0 || unscaledHeight == 0);
	
	        for (var i:int = 0; i < len; i++)
	        {
	            var item:IMenuBarItemRenderer = menuBarItems[i];
	
	            item.setActualSize(unscaledWidth, unscaledHeight);
	            item.visible = !hideItems;
	
	            lastX = item.x = lastX+lastW;
	            lastW = item.width;
	            
	            if (!hideItems && (lastX + lastW) > unscaledWidth)
	            {
	                clipContent = true;
	            }	                      
	        }

	        // Set a scroll rect to handle clipping.
	        scrollRect = clipContent ? new Rectangle(0, 0,
	                unscaledWidth, unscaledHeight) : null;
	    }		
	}
}