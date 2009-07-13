/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyCommandRunner;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	/**
	 * A MonkeyTest is a child element of a MonkeyTestCase. Its children are executable MonkeyCommands,
	 * including UIEventMonkeyCommands, PauseMonkeyCommands and VerifyMonkeyCommands.
	 * 
	 * 
	 * 
	 */ 
	public class MonkeyTest extends MonkeyNode
	{
		private static var perCommandTimeoutPadding:int = 1000; // Takes Monkey viewer time, etc. into account
		private static var perTestTimeoutPadding:int = 5000; // Additional per test padding

		/**
		 * The event mateDispatcher used by MonkeyTest.
		 * 
		 * @default this
		 */	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
		
		// NOTE: Currently the only place we actually use non-null values for this constructor's parameters is in the generated code.
		//       Also note we set the parent property of any children assigned here.
		/**
		 * Constructor.
		 */ 
		public function MonkeyTest(
			name:String=null, 
			defaultThinkTime:uint=500,
			children:ArrayCollection=null)
		{
			super();
			this.name = name;
			this.defaultThinkTime = defaultThinkTime;
			if ( children != null ) {
				for ( var i:int = 0; i < children.length; i++ ) {
					var child:MonkeyRunnable = MonkeyRunnable(children.getItemAt(i));
					child.parent = this;
				}
			}
			this.children = children;
		}
		
		private var _name:String;
		/**
		 * The name of this MonkeyTest.
		 * 
		 * 
		 */ 		
		public function get name():String{
			return _name;
		}
		public function set name(n:String):void{
			_name = n;
		}

		private var _defaultThinkTime:uint;
		public function get defaultThinkTime():int {
			return _defaultThinkTime;
		}
		public function set defaultThinkTime(thinkTime:int):void {
			_defaultThinkTime = thinkTime;
		}
		

		private var runEngine:MonkeyRunnerEngine;			
		/**
		 * 
		 * . 
		 * 
		 */			
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
			runEngine = new MonkeyRunnerEngine();
			runEngine.addEventListener(MonkeyCommandRunnerEvent.COMPLETE,runEngineComplete,false,0,true);
			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));
			runEngine.runCommands(children,runner);
			return true;
		}
		private function runEngineComplete(event:MonkeyCommandRunnerEvent):void{	

/* 
The event has the last command executed.  Normally, this is the last command of the test.  However, if the user
stopped playing in the middle of a test, this will be the last command executed, but perhaps not the last command of the 
test.  If it is not the last command of the test, update would only return useful results if all the results were set to
not run at the beginning of the run...

*/			
			updateResult();	
			// TODO Write junit XML here?	
			dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE,this));		
		}
		
		
				
		/**
		 * An XML representation of this MonkeyCommand.
		 * 
		 * 
		 */
		override public function get xml():XML{
			var xml:XML = 
			<Test name={name} defaultThinkTime={defaultThinkTime}/>	
			for(var k:int=0;k<children.length;k++){
				xml.appendChild(children[k].xml);
			}			
			return xml;	
		}	
		
		public function get timeoutTime():uint {
			var total:uint = 0;
			for(var i:uint = 0; i<children.length; i++){
				total += MonkeyRunnable(children[i]).thinkTime + perCommandTimeoutPadding;				
			}
			return total += perTestTimeoutPadding;
		}
		
		/**
		 * An AS3 representation of this MonkeyTest.
		 * 
		 */
		public function getAS3():String{
			var monkeyTestName:String = "mt" + name;
			var timeoutName:String = monkeyTestName + "TimeoutTime";
			var completeHandlerName:String = monkeyTestName + "Complete";
			
			var methodString:String = "";
			methodString += "        private var " + monkeyTestName + ":MonkeyTest = new MonkeyTest('" + name + "', " + defaultThinkTime + ",\n";
			methodString += "            new ArrayCollection(["; 
			var separator:String = "\n                ";      
			for(var i:uint=0;i<children.length;i++){
				methodString += separator;
				methodString += children[i].getAS3(monkeyTestName);
				separator = ",\n                ";
			}
			methodString += "\n            ]));\n\n";
			// Set up a var for the timeout name in generated code.  Not needed, but makes the generated code nicer.
			methodString += "        private var " + timeoutName + ":int = " + timeoutTime + ";\n\n";		
			methodString += "        [Test]\n";
			methodString += "        public function " + name + "():void{\n";
			
			methodString += "            // startTest(<MonkeyTest>, <Complete method>, <Async timeout value>, <Timeout method>);\n"
			methodString += "            startTest(" + monkeyTestName + ", " + completeHandlerName + ", " + timeoutName + ", defaultTimeoutHandler);\n"
			methodString += "        }\n\n";

			methodString += "        public function " + completeHandlerName + "(event:MonkeyCommandRunnerEvent, passThroughData:Object):void{\n";
			methodString += "            checkCommandResults(" + monkeyTestName + ");\n"
			methodString += "        }\n\n";
			
			return methodString;
		}

		override public function isEqualTo(item:Object):Boolean{
			if(! item is MonkeyTest){
				return false;
			}else{
				if(
					(item.name == this.name) &&
					(item.result == this.result) &&
					(item.defaultThinkTime == this.defaultThinkTime)		
				){
					return true;
				}else{
					return false;
				}
			}
		}		
		
		/**
		 * Returns a copy of this MonkeyTest.
		 * 
		 * @return A new MonkeyTest with this MonkeyTest's name, children, and result.
		 * 
		 */ 
		public function clone():MonkeyTest{
			var copy:MonkeyTest = new MonkeyTest();
			copy.parent = this.parent;
			copy.children = this.children;
			copy.name = this.name;
			copy.result = this.result;
			copy.defaultThinkTime = this.defaultThinkTime;
			copy.assertionCount = assertionCount;
			copy.passedAssertionCount = passedAssertionCount;
			copy.failedAssertionCount = failedAssertionCount;
			copy.errorCount = errorCount;
			return copy;
		}			
	}
}
