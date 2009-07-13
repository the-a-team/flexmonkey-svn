/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.commands {
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class AddCommand implements IUndoable {
				
		private var _timestamp : Date;
		
		private var item:Object;
		private var selectedItem:Object;
		private var mateDispatcher:IEventDispatcher;		
		private var addToCollection:ArrayCollection;
		private var index:uint;

		public function get timestamp( ) : Date {
			return _timestamp;
		}
		
		public function get description( ) : String {
			return "Add";
		}
		
		private var _canUndo:Boolean;
		public function get canUndo():Boolean{
			return _canUndo;
		}
		public function set canUndo(s:Boolean):void{
			_canUndo = s;
		}
		
		public function AddCommand( item:Object, 
									addToCollection:ArrayCollection,
									selectedItem:Object, 
									mateDispatcher:IEventDispatcher,
									canUndo:Boolean = true ) {
			this.item = item;
			this.addToCollection = addToCollection;
			this.selectedItem = selectedItem;
			this.mateDispatcher = mateDispatcher;
			this.canUndo = canUndo;
		}
		
		public function execute( ) : void {	
			if(selectedItem == null || item.parent==selectedItem){
				index = 0;				
			}else{
				index = addToCollection.getItemIndex(selectedItem)+1;
			}			
				
			if(addToCollection.length == index){
				addToCollection.addItem(item);
			}else{
				addToCollection.addItemAt(item,index);
			}

			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,item));
			if ( _timestamp == null ) {
				// don't overwrite the timestamp on redo
				_timestamp = new Date();
			}
		}
		
		public function undo( ) : void {
			addToCollection.removeItemAt(index);
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.SELECT_ITEM,selectedItem));
		}
		
		public function redo( ) : void {
			execute();
		}

	}

}