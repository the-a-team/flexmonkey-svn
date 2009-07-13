/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers {
	
	import com.gorillalogic.flexmonkey.application.commands.IUndoable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class UndoManager extends EventDispatcher {
				
		private var undoStack:Array;
		private var redoStack:Array;

		private var dirtyUndoCount:uint;
		private var dirtyRedoCount:uint;
		private var permaDirty:Boolean;

		[Bindable(event="undoChanged")]
		public function get undoPossible( ) : Boolean {
			return undoStack.length > 0;
		}

		[Bindable(event="undoChanged")]
		public function get redoPossible( ) : Boolean {
			return redoStack.length > 0;
		}

		[Bindable(event="undoChanged")]
		public function get dataDirty():Boolean{
			return (dirtyUndoCount > 0 || dirtyRedoCount > 0 || permaDirty);
		}
			
		public function UndoManager( ) {
			undoStack = [ ];
			redoStack = [ ];
			dirtyUndoCount = 0;
			dirtyRedoCount = 0;
			permaDirty = false;
		}
		
		public function save():void{
			dirtyUndoCount = 0;
			dirtyRedoCount = 0;
			permaDirty = false;
			dispatchUndoChanged();			
		}		
		
		private function dispatchUndoChanged( ) : void {
			dispatchEvent(new Event("undoChanged"));
		}
		
		public function addUndoable( undoable : IUndoable ) : void {
			undoStack.push(undoable);
			redoStack = [ ];
			if(dirtyRedoCount > 0){
				permaDirty = true;
			}
			dirtyRedoCount = 0;
			dirtyUndoCount += 1;
			dispatchUndoChanged();
		}
				
		public function reset():void{
			undoStack = [];
			redoStack = [];
			dirtyUndoCount = 0;
			dirtyRedoCount = 0;	
			permaDirty = false;		
			dispatchUndoChanged();
		}
		
		public function undo( ) : void {
			if ( undoPossible ) {				
				var command : IUndoable = undoStack.pop();
				command.undo();
				redoStack.push(command);
				if(dirtyUndoCount>0){
					dirtyUndoCount -= 1;
				}else{
					dirtyRedoCount += 1;
				}
				dispatchUndoChanged();
			}
		}

		public function redo( ) : void {
			if ( redoPossible ) {
				var command : IUndoable = redoStack.pop();
				command.redo();
				undoStack.push(command);
				if(dirtyRedoCount>0){
					dirtyRedoCount -= 1;
				}else{
					dirtyUndoCount += 1;
				}
				dispatchUndoChanged();
			}
		}

	}

}