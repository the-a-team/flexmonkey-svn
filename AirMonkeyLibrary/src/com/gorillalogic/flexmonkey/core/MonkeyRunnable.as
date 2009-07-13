/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{	
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyCommandRunner;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	[Bindable]
	public class MonkeyRunnable extends EventDispatcher
	{
		public function MonkeyRunnable(target:IEventDispatcher=null)
		{
			super(target);
		}

		private var _parent:Object;
		public function get parent():Object{
			return _parent;
		}
		public function set parent(p:Object):void{
			_parent = p;
		}
		
		public function isEqualTo(item:Object):Boolean{
			return false;
		}
		
		private var _result:String;
		/**
		 * The result of this subgraph of the test tree.
		 */	
		public function get result():String{
			return _result;
		}
		public function set result(result:String):void{
			_result = result;
		}
		
		private var _assertionCount:int;
		/**
		 * The total number of assertions of this subgraph of the test tree.
		 */	
		public function get assertionCount():int{
			return _assertionCount;
		}
		public function set assertionCount(assertionCount:int):void{
			_assertionCount = assertionCount;
			updateNotRunAssertionCount();			
		}
		
		private var _passedAssertionCount:int;
		/**
		 * The total number of passed assertions of this subgraph of the test tree.
		 */	
		public function get passedAssertionCount():int{
			return _passedAssertionCount;
		}
		public function set passedAssertionCount(passedAssertionCount:int):void{
			_passedAssertionCount = passedAssertionCount;
			updateNotRunAssertionCount();			
		}
		
		private var _failedAssertionCount:int;
		/**
		 * The total number of failed assertions of this subgraph of the test tree.
		 */	
		public function get failedAssertionCount():int{
			return _failedAssertionCount;
		}
		public function set failedAssertionCount(failedAssertionCount:int):void{
			_failedAssertionCount = failedAssertionCount;
			updateNotRunAssertionCount();
		}
		
		private var _notRunAssertionCount:int;
		[Bindable ("notRunAssertionCount")]
		public function get notRunAssertionCount():int{
			return _notRunAssertionCount;
		}
		private function updateNotRunAssertionCount():void{
			_notRunAssertionCount = assertionCount - passedAssertionCount - failedAssertionCount;
			dispatchEvent(new Event("notRunAssertionCount"));
		}
		
		private var _errorCount:int;
		/**
		 * The total number of errors of this subgraph of the test tree.
		 */	
		public function get errorCount():int{
			return _errorCount;
		}
		public function set errorCount(errorCount:int):void{
			_errorCount = errorCount;
		}
		
		/**
		 * Has this entire subgraph been run since the last reset.
		 */	
		private var _hasBeenRun:Boolean;
		public function get hasBeenRun():Boolean{
			return _hasBeenRun;
		}
		public function set hasBeenRun(hasBeenRun:Boolean):void{
			_hasBeenRun = hasBeenRun;
		}
			
		
		/**
		 * Error associated with this node.
		 */	
		// TODO This could be moved to a MonkeyCommand class if one existed.
		private var _error:String;
		public function get error():String {
			return _error;
		}
		public function set error(error:String):void {
			_error = error;
		}	

		public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
			return false;
		}		

		public function	get xml():XML{
			return null;
		}
			
		public function get thinkTime():uint {
			return 0;
		}
		
		public function get shortDescription():String {
			return this.toString();
		}
		
		public function updateResult():void{
		}
		
		public function assimilateEvilTwin(evilTwin:MonkeyRunnable):void{
			this.hasBeenRun = evilTwin.hasBeenRun;
			this.error = evilTwin.error;
		}
	
		public function resetResult():void{
			result = "NOT_RUN";
			passedAssertionCount = 0;
			failedAssertionCount = 0;
			errorCount = 0;
			hasBeenRun = false;
		}
		
		public function updateParentResult():void{
			if ( parent != null ) {
				parent.updateParentResult();
			}
		}
		 
	}
}