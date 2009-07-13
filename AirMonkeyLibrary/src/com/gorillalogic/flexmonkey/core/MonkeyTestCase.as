/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import com.gorillalogic.flexmonkey.application.VOs.AS3FileVO;
	import com.gorillalogic.flexmonkey.application.utilities.AS3FileCollector;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyCommandRunner;
	import com.gorillalogic.flexmonkey.core.*;
	
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	[Bindable]
	/**
	 * A MonkeyTestCase is a child element of a MonkeyTestCaseCase. Its children are executable MonkeyCommands,
	 * including UIEventMonkeyCommands, PauseMonkeyCommands and VerifyMonkeyCommands.
	 * 
	 * 
	 * 
	 */ 
	public class MonkeyTestCase extends MonkeyNode
	{

		/**
		 * The event mateDispatcher used by MonkeyTestCase.
		 * 
		 * @default this
		 */	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
		
		/**
		 * Constructor.
		 * 
		 * 
		 */ 
		public function MonkeyTestCase(parent:Object=null,
									name:String=null, 
									result:String=null, 
									children:ArrayCollection=null)
		{
			super();
			this.parent = parent;
			this.name = name;
			this.result = result;
			this.children = children;
		}


		override public function isEqualTo(item:Object):Boolean{
			if(! item is MonkeyTestCase){
				return false;
			}else{
				if(
					(item.name == this.name) &&
					(item.result == this.result) 		
				){
					return true;
				}else{
					return false;
				}
			}
		}	
			
		/**
		 * 
		 * 
		 * 
		 */			
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
			if(children.length>0){
				this.runner = runner;
				this.timer = timer;
				currentTestIndex=0;
				mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));
				children[currentTestIndex].addEventListener(MonkeyCommandRunnerEvent.COMPLETE,testCompleteHandler,false,0,true);	
				children[currentTestIndex].execute(runner,timer);								
			}
			return true;
		}
		private var runner:MonkeyCommandRunner;
		private var timer:Timer;
		private var currentTestIndex:uint;
		private	function testCompleteHandler(event:MonkeyCommandRunnerEvent):void{	
			children[currentTestIndex].removeEventListener(MonkeyCommandRunnerEvent.COMPLETE,testCompleteHandler);
			currentTestIndex++;
			if(currentTestIndex == children.length){
				updateResult();
				dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE,this));
			}else{
				children[currentTestIndex].addEventListener(MonkeyCommandRunnerEvent.COMPLETE,testCompleteHandler,false,0,true);
				children[currentTestIndex].execute(runner,timer);	
			}	
		}
				
		/**
		 * An XML representation of this MonkeyCommand.
		 * 
		 * 
		 */
		override public function get xml():XML{
			var xml:XML = 
			<TestCase name={name}/>	
			for(var k:int=0;k<children.length;k++){
				xml.appendChild(children[k].xml);
			}			
			return xml;	
		}			
		
		/**
		 * An AS3 representation of this MonkeyCommand.
		 * 
		 * 
		 */
		public function getAS3(collector:AS3FileCollector):void{
			var i:uint;
			var j:uint;
			var fileName:String = this.name;
			var fileContents:String = "package ";
			var monkeyCommandVar:String;
			
			fileContents += (collector.packageName + "{\n");		
			fileContents += "    import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestCase;\n\n";				

			fileContents += "    import com.gorillalogic.flexmonkey.core.MonkeyTest;\n";				
			fileContents += "    import com.gorillalogic.flexmonkey.monkeyCommands.*;\n";
			fileContents += "    import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;\n";				
			fileContents += "    import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;\n\n";								
			
			fileContents += "    import mx.collections.ArrayCollection;\n\n";				

			fileContents += ("    public class " + this.name + " extends MonkeyFlexUnitTestCase{\n");
			
			fileContents += ("        public function " + this.name + "(){\n");
			fileContents += ("            super();\n");
			fileContents += ("        }\n\n");		
			
			for(i=0;i<children.length;i++){
				fileContents += children[i].getAS3();	
			}

			fileContents += ("\n    }\n}");			

			var fileRecord:AS3FileVO = new AS3FileVO(fileName, fileContents);
			collector.addItem(fileRecord);						
		}
			
		private var _name:String;
		/**
		 * The name of this MonkeyTestCase.
		 * 
		 * 
		 */ 		
		public function get name():String{
			return _name;
		}
		public function set name(n:String):void{
			_name = n;
		}		
		
		/**
		 * Returns a copy of this MonkeyTestCase.
		 * 
		 * @return A new MonkeyTestCase with this MonkeyTestCase's name, children, and result.
		 * 
		 */ 
		public function clone():MonkeyTestCase{
			var copy:MonkeyTestCase = new MonkeyTestCase();
			copy.parent = this.parent;
			copy.children = this.children;
			copy.name = this.name;
			copy.result = this.result;
			copy.assertionCount = assertionCount;
			copy.passedAssertionCount = passedAssertionCount;
			copy.failedAssertionCount = failedAssertionCount;
			copy.errorCount = errorCount;
			return copy;
		}			
	}
}
