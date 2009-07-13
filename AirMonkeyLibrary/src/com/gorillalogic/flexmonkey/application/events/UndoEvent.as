/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.events {
	
	import com.gorillalogic.flexmonkey.application.commands.IUndoable;
	
	import flash.events.Event;
	
	
	/**
	 * Events of this type are used to request undo-related actions.
	 */
	public class UndoEvent extends Event {
		
		public static const         UNDO : String = "undo";
		public static const         REDO : String = "redo";
		public static const      RESTORE : String = "restore";
		public static const ADD_UNDOABLE : String = "addUndoable";
		public static const        RESET : String = "reset";
		
		/**
		 * Events that refer to a specific undoable (RESTORE, ADD_UNDOABLE) use 
		 * this property to pass that object.
		 */
		public var undoable : IUndoable;
		
		
		public function UndoEvent( type : String, undoable : IUndoable = null ) {
			super(type, true);
			
			this.undoable = undoable;
		}
		
	}
	
}