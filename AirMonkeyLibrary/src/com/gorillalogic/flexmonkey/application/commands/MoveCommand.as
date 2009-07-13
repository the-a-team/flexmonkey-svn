/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.commands {
	import flash.events.IEventDispatcher;
	import mx.collections.ArrayCollection;
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
		
	public class MoveCommand implements IUndoable {
				
		private var _timestamp : Date;
		private var mateDispatcher:IEventDispatcher;
		
		private var dragSourceItems:Object;
		private var dropTarget:Object;
		private var beforeDropTarget:Object;
		private var actualDropTarget:Object;		
		private var dropAtBeforeDropTargetLevel:Boolean;
		private var dropTest:Object;
		private var dropCollection:ArrayCollection;
		private var testCollection:ArrayCollection;
				
		private var dragSourceItemRecords:Array;

		public function get timestamp( ) : Date {
			return _timestamp;
		}
		
		public function get description( ) : String {
			return "Move";
		}
		
		private var _canUndo:Boolean;
		public function get canUndo():Boolean{
			return _canUndo;
		}
		public function set canUndo(s:Boolean):void{
			_canUndo = s;
		}
		
		public function MoveCommand(dragSourceItems:Object,
									dropTarget:Object,
									beforeDropTarget:Object,
									dropAtBeforeDropTargetLevel:Boolean,  
									testCollection:ArrayCollection,
									mateDispatcher:IEventDispatcher,
									canUndo:Boolean = true ) {
			this.dragSourceItems = dragSourceItems;
			this.dropTarget = dropTarget;
			this.beforeDropTarget = beforeDropTarget;
			this.dropAtBeforeDropTargetLevel = dropAtBeforeDropTargetLevel;
			this.testCollection = testCollection;
			this.mateDispatcher = mateDispatcher;
			this.canUndo = canUndo;
			
			var tempArray:Array = [];
			for(var i:uint; i<dragSourceItems.length; i++){
				var r:DragSourceRecordVO = new DragSourceRecordVO();
				r.item = dragSourceItems[i]; 
				r.parent = r.item.parent;
				r.collection = (r.item == r.parent)?testCollection:r.parent.children; 
				r.itemSortOrder = r.collection.getItemIndex(r.item);
				var x:Object = r.item;
				while(x.parent != x){
					x = x.parent;
					if(x.parent != x){
						var y:Object = x.parent;
						r.itemSortOrder += y.children.getItemIndex(x);
					}else{
						r.itemSortOrder += testCollection.getItemIndex(x);
					}				
				}			
				tempArray.push(r);
			}
			dragSourceItemRecords = tempArray.sortOn("itemSortOrder",Array.NUMERIC);			
			if(beforeDropTarget == null){
				// we should drop at the beginning of the testCollection
				dropTest = null;
				dropCollection = testCollection;
			} else if (dropTarget == null){
				// we should drop at the end of the testCollection
				dropTest = null;				
				dropCollection = testCollection;
				actualDropTarget = null;
			}else if(dropTarget.parent == beforeDropTarget.parent || dropTarget.parent == beforeDropTarget){
				// they're both children of the same test, or
				// they're just above the first child of a test, so
				// they're at the same level, so
				// we should drop into the dropTarget level
				dropTest = dropTarget.parent;
				dropCollection = dropTest.children;
				actualDropTarget = dropTarget;
			}else if(dropTarget.parent == dropTarget && beforeDropTarget.parent == beforeDropTarget){
				// they're both top-level tests, so
				// they're at the same level, so
				// we should drop into the testCollection level
				dropTest = null;				
				dropCollection = testCollection;
				actualDropTarget = dropTarget;				
			}else if (dropAtBeforeDropTargetLevel){
				// the drop target and the beforeDropTarget are not siblings and
				// the user wants to drop as a sibling of the beforeDropTarget
				dropTest = beforeDropTarget.parent;
				dropCollection = dropTest.children;
				actualDropTarget = null;				
			}else{
				// the drop target and the beforeDropTarget are not siblings and
				// the user wants to drop as a sibling of the dropTarget
				dropTest = dropTarget.parent;
				dropCollection = dropTest.children;
				actualDropTarget = dropTarget;				
			}
		}
		
		public function execute( ):void {
			var dropIndex:uint; 
			var r:DragSourceRecordVO;		
			for(var i:int=0;i<dragSourceItemRecords.length;i++){
				r = dragSourceItemRecords[i];
				// remove
				r.index = r.collection.getItemIndex(r.item);
				r.collection.removeItemAt(r.index);
				// update test reference
				if(dropTest){
					r.item.parent = dropTest;
				}else{
					r.item.parent = r.item;
				}
				// drop
				if(beforeDropTarget == null){
					dropCollection.addItemAt(r.item,i)
				}else if(actualDropTarget == null){
					dropCollection.addItem(r.item);
				}else{
					dropIndex = dropCollection.getItemIndex(actualDropTarget);
					dropCollection.addItemAt(r.item,dropIndex);
				}
			}
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,dragSourceItemRecords[0].item));		
		}
		
		public function undo( ):void{
			var r:DragSourceRecordVO;
			var index:uint;
			for(var i:int=dragSourceItemRecords.length-1;i>=0;i--){
				r = dragSourceItemRecords[i];
				// remove
				if(r.item.parent == r.item){
					index = testCollection.getItemIndex(r.item);
					testCollection.removeItemAt(index);
				}else{
					index = r.item.test.children.getItemIndex(r.item);
					r.item.test.children.removeItemAt(index);
				}
				// update test reference
				r.item.parent = r.parent;
				// drop back
				r.collection.addItemAt(r.item,r.index);
			}			
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,dragSourceItemRecords[0].item));		
		}
		
		public function redo( ):void{
			execute();
		}
		
	}
}
import mx.collections.ArrayCollection;
class DragSourceRecordVO{
	public var item:Object;
	public var itemSortOrder:uint;
	public var parent:Object;
	public var collection:ArrayCollection;
	public var index:uint;	
}