/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import com.gorillalogic.flexmonkey.application.VOs.AS3FileVO;
	import com.gorillalogic.flexmonkey.application.utilities.AS3FileCollector;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyCommandRunner;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.core.*;
	
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	[Bindable]
	/**
	 * A MonkeyTestSuite is a top-level test containter.  It contains other MonkeyTestSuites, as well as
	 * MonkeyTestCases.
	 * 
	 * 
	 */ 
	public class MonkeyTestSuite extends MonkeyNode
	{

		/**
		 * The event mateDispatcher used by MonkeyTestSuite.
		 * 
		 * @default this
		 */	
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
		
		
		/**
		 * Constructor.
		 * 
		 * 
		 */ 
		public function MonkeyTestSuite(parent:Object=null,
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
			if(! item is MonkeyTestSuite){
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
				currentCaseIndex=0;
				mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));
				children[currentCaseIndex].addEventListener(MonkeyCommandRunnerEvent.COMPLETE,caseCompleteHandler,false,0,true);	
				children[currentCaseIndex].execute(runner,timer);								
			}
			return true;
		}
		private var runner:MonkeyCommandRunner;
		private var timer:Timer;
		private var currentCaseIndex:uint;
		private	function caseCompleteHandler(event:MonkeyCommandRunnerEvent):void{	
			children[currentCaseIndex].removeEventListener(MonkeyCommandRunnerEvent.COMPLETE,caseCompleteHandler);
			currentCaseIndex++;
			if(currentCaseIndex == children.length){
				updateResult();
				dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.COMPLETE,this));
// remove any remaining event listeners							
			}else{
				children[currentCaseIndex].addEventListener(MonkeyCommandRunnerEvent.COMPLETE,caseCompleteHandler,false,0,true);
				children[currentCaseIndex].execute(runner,timer);	
			}	
		}
		
		/**
		 * An XML representation of this MonkeyCommand.
		 * 
		 * 
		 */
		override public function get xml():XML{
			var xml:XML = 
			<TestSuite name={name}/>	
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
// loop over kids to get their vitals, create the fileRecord and add it to the collector,
//  then pass the collector to each of the kids in turn...
			var i:uint;
			var fileName:String = this.name;
			var suitePackageName:String = collector.packageName + "." + fileName;
			var fileContents:String = "package ";
			var imports:Array = [];
			var addTestCases:Array = [];

			for(i=0;i<children.length;i++){
				var testCaseName:String = children[i].name;
				var importLine:String = "    import " + suitePackageName + ".tests." + testCaseName + ";\n";
				var addTestCaseLine:String = "            addTestCase(new " + testCaseName + "());\n";
				imports.push(importLine);
				addTestCases.push(addTestCaseLine);
			}
			
			fileContents += (collector.packageName +"." + fileName + "{\n");
			fileContents += "    import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestSuite;\n\n";			
			for(i=0;i<imports.length;i++){
				fileContents += imports[i];
			}
			fileContents += ("\n    public class " + this.name + " extends MonkeyFlexUnitTestSuite{\n");
			fileContents += ("        public function " + this.name + "(){\n");
			for(i=0;i<addTestCases.length;i++){
				fileContents += addTestCases[i];
			}
			fileContents += ("        }\n    }\n}");

			var fileRecord:AS3FileVO = new AS3FileVO(fileName,fileContents);
			collector.addItem(fileRecord);
	
			if(children.length > 0){
				fileRecord.children = new AS3FileCollector(suitePackageName + ".tests");			
				for(i=0;i<children.length;i++){
					children[i].getAS3(fileRecord.children);
				}		
			}
			
		}

		
		private var _name:String;
		/**
		 * The name of this MonkeyTestSuite.
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
		 * Returns a copy of this MonkeyTestSuite.
		 * 
		 * @return A new MonkeyTestSuite with this MonkeyTestSuite's name, children, and result.
		 * 
		 */ 
		public function clone():MonkeyTestSuite{
			var copy:MonkeyTestSuite = new MonkeyTestSuite();
			if(this.parent == this){
				copy.parent = copy;
			}else{
				copy.parent = this.parent;
			}	
			copy.children = this.children;
			copy.name = this.name;
			copy.result = this.result;
			copy.assertionCount = assertionCount;
			copy.passedAssertionCount = passedAssertionCount;
			copy.failedAssertionCount = failedAssertionCount;
			copy.errorCount = errorCount;
			return copy;
		}	
		
		public override function updateParentResult():void {
			updateResult();
		}		
	}
}
