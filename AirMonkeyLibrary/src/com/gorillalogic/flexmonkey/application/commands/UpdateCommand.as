/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.commands {
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyNode;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class UpdateCommand implements IUndoable {
				
		private var _timestamp : Date;
		
		private var item:MonkeyRunnable;
		private var selectedParent:Object;
		private var selectedItem:MonkeyRunnable;
		private var mateDispatcher:IEventDispatcher;
		private var collection:ArrayCollection;
		
		private var updateCollection:ArrayCollection;
		private var index:uint;

		public function get timestamp( ) : Date {
			return _timestamp;
		}
		
		public function get description( ) : String {
			return "Update";
		}

		private var _canUndo:Boolean;
		public function get canUndo():Boolean{
			return _canUndo;
		}
		public function set canUndo(s:Boolean):void{
			_canUndo = s;
		}
		
		public function UpdateCommand( item:MonkeyRunnable, 
									collection:ArrayCollection,
									selectedItem:MonkeyRunnable, 
									mateDispatcher:IEventDispatcher, 
									canUndo:Boolean = true) {
			this.item = item;
			this.collection = collection;
			this.selectedParent = selectedItem.parent;
			this.selectedItem = selectedItem;
			this.mateDispatcher = mateDispatcher;
			this.canUndo = canUndo;
		}
		
		public function execute( ):void{			
			if(item is MonkeyTestSuite && item.parent == item){
				updateCollection = collection;	
			}else{
				updateCollection = selectedParent.children;
			}
			index = updateCollection.getItemIndex(selectedItem);
			
//				updateCollection.setItemAt(item,index);  DOES NOT WORK ON TOP LEVEL NODE IF IT'S OPEN
			updateCollection.addItemAt(item,index);
			
			// Update the children of the existing object to point to the new object
			if ( item is MonkeyNode ) {
				var children:ArrayCollection = MonkeyNode(item).children;
				for ( var i:uint = 0; i < children.length; i++ ) {
					children[i].parent = item;
				}
			}
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,item));
			updateCollection.removeItemAt(index+1);
			
			
			
			if ( _timestamp == null ) {
				// don't overwrite the timestamp on redo
				_timestamp = new Date();
			}
		}
		
		public function undo( ) : void {
			updateCollection.addItemAt(selectedItem,index);
			
			// Update the children of the existing object to point to the new object
			if ( selectedItem is MonkeyNode ) {
				var children:ArrayCollection = MonkeyNode(selectedItem).children;
				for ( var i:uint = 0; i < children.length; i++ ) {
					children[i].parent = selectedItem;
				}
			}
			
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,selectedItem));	
			updateCollection.removeItemAt(index+1);					
		}
		
		public function redo( ) : void {
			execute();
		}

	}

}