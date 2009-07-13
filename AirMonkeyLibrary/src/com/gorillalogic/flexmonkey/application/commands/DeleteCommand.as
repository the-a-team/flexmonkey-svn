/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.commands {
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class DeleteCommand implements IUndoable {
				
		private var _timestamp : Date;
		
		private var item:Object;
		private var selectedParent:Object;
		private var selectedItem:MonkeyRunnable;
		private var mateDispatcher:IEventDispatcher;
		private var collection:ArrayCollection;
		
		private var deleteFromCollection:ArrayCollection;
		private var index:uint;
		private var newSelectedItem:Object;
		private var newSelectedItemIndex:uint;
		
		public function get timestamp( ) : Date {
			return _timestamp;
		}
		
		public function get description( ) : String {
			return "Delete";
		}
	
		private var _canUndo:Boolean;
		public function get canUndo():Boolean{
			return _canUndo;
		}
		public function set canUndo(s:Boolean):void{
			_canUndo = s;
		}	
		
		public function DeleteCommand( item:Object, 
									collection:ArrayCollection,
									selectedItem:MonkeyRunnable, 
									mateDispatcher:IEventDispatcher,
									canUndo:Boolean = true ) {
			this.item = item;
			this.collection = collection;
			this.selectedParent = selectedItem.parent;
			this.selectedItem = selectedItem;
			this.mateDispatcher = mateDispatcher;
			this.canUndo = canUndo;
		}
		
		public function execute( ) : void {
        	if(selectedItem == selectedParent){
        		deleteFromCollection = collection;
        	}else{
        		deleteFromCollection = selectedParent.children;
        	}	
        	index = deleteFromCollection.getItemIndex(selectedItem);
        	newSelectedItemIndex = index;	
        	if(deleteFromCollection.length>1){	
        		if(newSelectedItemIndex == deleteFromCollection.length-1){
        			newSelectedItemIndex--;
        		}else{
        			newSelectedItemIndex++;
        		}
        		newSelectedItem = deleteFromCollection.getItemAt(newSelectedItemIndex);
        	}else{
// switch on type to decide what should be selected after the delete        		
        		if(selectedItem is MonkeyTest && MonkeyTest(selectedItem).parent == selectedItem){
        			newSelectedItem = null;
        		}else{
        			newSelectedItem = selectedItem.parent;
        		}
        	}        	
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,newSelectedItem));
			deleteFromCollection.removeItemAt(index);  	
		}
		
		public function undo( ):void{
			if(index == deleteFromCollection.length){
				deleteFromCollection.addItem(selectedItem);
			}else{
				deleteFromCollection.addItemAt(selectedItem,index);
			}
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,selectedItem));
		}
		
		public function redo( ) : void {
			execute();
		}

	}

}