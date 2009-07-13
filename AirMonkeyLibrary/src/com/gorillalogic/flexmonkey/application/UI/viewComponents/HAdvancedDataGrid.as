/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.UI.viewComponents
{
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.collections.HierarchicalCollectionView;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.listClasses.ListRowInfo;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.events.ScrollEventDirection;
	import mx.managers.DragManager;
	
	use namespace mx_internal;

[Style(name="testSuiteOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="testSuiteClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="testCaseOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="testCaseClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="testOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="testClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="defaultOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]
[Style(name="defaultClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]
	
	public class HAdvancedDataGrid extends AdvancedDataGrid
	{

		private var myDragScrollingInterval:int = 0;
		private var myMouseY:Number;
		
		public function HAdvancedDataGrid()
		{
			super();
		}
	
	
override public function itemToIcon(item:Object):Class
{
    if (item == null)
    {
        return null;
    }

    var icon:*;
    var open:Boolean = isItemOpen(item);
    var branch:Boolean = isBranch(item);
    var uid:String = itemToUID(item);

    //first lets check the component
    var iconClass:Class =
        itemIcons && itemIcons[uid] ?
        itemIcons[uid][open ? "iconID2" : "iconID"] :
        null;

    if (iconClass)
    {
        return iconClass;
    }
    else if (iconFunction != null)
    {
        return iconFunction(item)
            }
    else if (branch)
    {
//        return getStyle(open ? "folderOpenIcon" : "folderClosedIcon");
		if(item is MonkeyTestSuite){
			return getStyle(open ? "testSuiteOpenIcon" : "testSuiteClosedIcon");	
		}else if(item is MonkeyTestCase){
			return getStyle(open ? "testCaseOpenIcon" : "testCaseClosedIcon");
		}else if(item is MonkeyTest){
			return getStyle(open ? "testOpenIcon" : "testClosedIcon");			
		}else{
			return getStyle(open ? "defaultOpenIcon" : "defaultClosedIcon");						
		}
    }
    else
        //let's check the item itself
    {
        if (item is XML)
        {
            try
            {
                if (item[iconField].length() != 0)
                    icon = String(item[iconField]);
            }
            catch(e:Error)
            {
            }
        }
        else if (item is Object)
        {
            try
            {
                if (iconField && item[iconField])
                    icon = item[iconField];
                else if (item.icon)
                    icon = item.icon;
            }
            catch (e:Error)
            {
            }
        }
    }

    //set default leaf icon if nothing else was found
    if (icon == null)
        icon = getStyle("defaultLeafIcon");

    //convert to the correct type and class
    if (icon is Class)
    {
        return icon;
    }
    else if (icon is String)
    {
        iconClass = Class(systemManager.getDefinitionByName(String(icon)));
        if (iconClass)
            return iconClass;

        return document[icon];
    }
    else
    {
        return Class(icon);
    }

}	
	
	
		
		
	    override public function scrollToIndex(index:int):Boolean
	    {
	        var newVPos:int;
	
	        if (index >= verticalScrollPosition + listItems.length - lockedRowCount - offscreenExtraRowsBottom || index < verticalScrollPosition)
	        {
	        	var rc:int = rowCount;			
				var viewLength:int = HierarchicalCollectionView(dataProvider).length;	
				var maxPos:int;
				if(viewLength > rc){
					maxPos = viewLength - rc;
				}else{
					maxPos = 0;
				}				
	        	newVPos = Math.min(index, maxPos);
//	            newVPos = Math.min(index, maxVerticalScrollPosition);
	            verticalScrollPosition = newVPos;
	            return true;
	        }
	        return false;
	    }		
		
		
		public function dropInRowTopHalf(event:DragEvent):Boolean{	        
	        var rowCount:int = rowInfo.length;
	        var rowNum:int = 0;
	        // we need to take care of headerHeight
	        var yy:int = rowInfo[rowNum].height + (headerVisible ? headerHeight :0);
	        var pt:Point = globalToLocal(new Point(event.stageX, event.stageY));
	        while (rowInfo[rowNum] && pt.y > yy)
	        {
	            if (rowNum != rowInfo.length-1)
	                rowNum++;
	            yy += rowInfo[rowNum].height;
	        }
	        var yOffset:Number = pt.y - rowInfo[rowNum].y;
	        var rowHeight:Number = rowInfo[rowNum].height;
	        rowNum += verticalScrollPosition;			
			return(yOffset < (rowHeight * 0.5));			
		}

/*
SDK-13227
AIR: dragDrop event is sent too early when using the NativeDragManagerImpl
 (this bug, where AIR does not properly update mouseY etc., clobbers dragScrolling)

*/

		public function updateMyMouseY(event:DragEvent):void{
			var pt:Point = globalToLocal(new Point(event.stageX, event.stageY));
			myMouseY = pt.y;
		}
		
		public function setMyDragScrolling():void{
			myDragScrollingInterval = setInterval(myDragScroll, 15);
			myMouseY = mouseY;
		}		
		
		private function myDragScroll():void
	    {
	        var slop:Number = 0;
	        var scrollInterval:Number;
	        var oldPosition:Number;
	        var d:Number;
	        var scrollEvent:ScrollEvent;

	        if (myDragScrollingInterval == 0)
	            return;
	
	        const minScrollInterval:Number = 30;
	
	        if (DragManager.isDragging)
	        {
	            slop = viewMetrics.top
	                + (variableRowHeight ? getStyle("fontSize") / 4 : rowHeight);
	        }
	
	        clearInterval(myDragScrollingInterval);
	        if (myMouseY < slop)
	        {
	            oldPosition = verticalScrollPosition;
	            verticalScrollPosition = Math.max(0, oldPosition - 1);
	            if (DragManager.isDragging)
	            {
	                scrollInterval = 100;
	            }
	            else
	            {
	                d = Math.min(0 - myMouseY - 30, 0);
	                scrollInterval = 0.593 * d * d + 1 + minScrollInterval;
	            }
	
	            myDragScrollingInterval = setInterval(myDragScroll, scrollInterval);
	
	            if (oldPosition != verticalScrollPosition)
	            {
	                scrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
	                scrollEvent.detail = ScrollEventDetail.THUMB_POSITION;
	                scrollEvent.direction = ScrollEventDirection.VERTICAL;
	                scrollEvent.position = verticalScrollPosition;
	                scrollEvent.delta = verticalScrollPosition - oldPosition;
	                dispatchEvent(scrollEvent);
	            }
	        }
	        else if (myMouseY > (unscaledHeight - slop))
	        {	  
	        	var maxScroll:int;     	
	        	var view:HierarchicalCollectionView = HierarchicalCollectionView(dataProvider);	
	        	var rowInfoItem:ListRowInfo = rowInfo[0];
	        	var rowsShowing:int = (Math.floor(unscaledHeight/rowInfoItem.height));
	        	if(rowsShowing>view.length){
	        		maxScroll = 0;
	        	}else{
	        		maxScroll = view.length - rowsShowing + 1;
	        	} 
	            oldPosition = verticalScrollPosition;
	            verticalScrollPosition = Math.min(maxScroll, verticalScrollPosition + 1);
	            if (DragManager.isDragging)
	            {
	                scrollInterval = 100;
	            }
	            else
	            {
	                d = Math.min(myMouseY - unscaledHeight - 30, 0);
	                scrollInterval = 0.593 * d * d + 1 + minScrollInterval;
	            }	
	            myDragScrollingInterval = setInterval(myDragScroll, scrollInterval);
	
	            if (oldPosition != verticalScrollPosition)
	            {
	                scrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
	                scrollEvent.detail = ScrollEventDetail.THUMB_POSITION;
	                scrollEvent.direction = ScrollEventDirection.VERTICAL;
	                scrollEvent.position = verticalScrollPosition;
	                scrollEvent.delta = verticalScrollPosition - oldPosition;
	                dispatchEvent(scrollEvent);
	            }
	        }
	        else
	        {
	            myDragScrollingInterval = setInterval(myDragScroll, 15);
	        }
	    }
		
	    public function resetMyDragScrolling():void
	    {
	        if (myDragScrollingInterval != 0)
	        {
	            clearInterval(myDragScrollingInterval);
	            myDragScrollingInterval = 0;
	        }
	    }		
	}
}