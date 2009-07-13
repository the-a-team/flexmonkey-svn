/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.commands {

	public interface IUndoable extends ICommand {

		function get timestamp( ) : Date ;

		function get description( ) : String ;
	
		function get canUndo():Boolean;
		function set canUndo(s:Boolean):void;
	
		function undo( ) : void ;
		
		function redo( ) : void ;
		
	}
	 
}
