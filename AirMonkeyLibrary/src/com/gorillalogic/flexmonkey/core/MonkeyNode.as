/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class MonkeyNode extends MonkeyRunnable
	{
		public function MonkeyNode(target:IEventDispatcher=null)
		{
			super(target);
			children = new ArrayCollection();
		}
		
		private var _children:ArrayCollection;
		/**
		 * The children of this node, an ArrayCollection of MonkeyNode.
		 */	
		public function get children():ArrayCollection{
			return _children;
		}
		public function set children(a:ArrayCollection):void{
			_children = a;
		}
		
		public var empty:Boolean;
		
		/**
		 * Searches the test's children for VerifyMonkeyCommands, and updates this MonkeyTest's
		 * result based on the aggregated results of the children.
		 * 
		 */ 
		override public function updateResult():void{
			for(i = 0; i<children.length; i++){
				MonkeyRunnable(children[i]).updateResult();
			}
			
			// First recalculate the total number of assertions in case this has changed.
			// TODO this may be more often than we really need to recalculate this.
			var total:int = 0;
			var passed:int = 0;
			var failed:int = 0;
			var errors:int = 0;
			var notRuns:int = 0;
			var hasNonEmpties:Boolean = false;
			for(var i:uint = 0; i<children.length; i++){				
				var runnable:MonkeyRunnable = MonkeyRunnable(children[i]);
				if(runnable is MonkeyNode && MonkeyNode(runnable).empty == false){
					hasNonEmpties = true;
				}else if(!(runnable is MonkeyNode)){
					hasNonEmpties = true;	
				}
				if ( runnable.errorCount != 0 ) {
					errors += runnable.errorCount;
				}
				total += runnable.assertionCount;
				passed += runnable.passedAssertionCount;
				failed += runnable.failedAssertionCount;
				if ( ! runnable.hasBeenRun ) {
					notRuns++;
				}
			}
			if(hasNonEmpties == false){
				result = "EMPTY";
			} else if ( errors != 0 ) {
				result = "ERROR";
			} else if ( notRuns != 0 ) {
				result = "NOT_RUN";
			} else if ( failed != 0 ) {
				result = "FAIL";
			} else {
				result = "PASS";
			}
			empty = !hasNonEmpties;
			assertionCount = total;
			passedAssertionCount = passed;
			failedAssertionCount = failed;
			errorCount = errors;
			hasBeenRun = ( notRuns == 0 );
			
//			trace("" + this + ".updateResult(): "
//				+ result + " - " + total + "," + passed + "," + failed + "," + errors + ": " + (hasBeenRun ? "Run" : "Not Run"));
		}
		
		override public function resetResult():void{
			super.resetResult();
			for(var i:uint = 0; i<children.length; i++){	
				MonkeyRunnable(children[i]).resetResult();				
			}
			var hasNonEmpties:Boolean = false;
			for(i = 0; i<children.length; i++){				
				var runnable:MonkeyRunnable = MonkeyRunnable(children[i]);
				if(runnable is MonkeyNode && MonkeyNode(runnable).empty == false){
					hasNonEmpties = true;
				}else if(!(runnable is MonkeyNode)){
					hasNonEmpties = true;	
				}
			}
			if(hasNonEmpties == false){
				result = "EMPTY";
			} else {
				result = "NOT_RUN";
			} 
			empty = !hasNonEmpties;			
		}
	}
}