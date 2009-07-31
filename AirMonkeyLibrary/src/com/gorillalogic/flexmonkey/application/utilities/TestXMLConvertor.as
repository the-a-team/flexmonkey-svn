/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.utilities
{
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
		
	public class TestXMLConvertor implements ITestXMLConvertor
	{
		public function TestXMLConvertor()
		{
		}

		public var mateDispatcher:IEventDispatcher;

		public function generateXML(input:ArrayCollection):String{
			var tsXML:XML = 
				<TopNode></TopNode>;
			for(var j:int=0;j<input.length;j++){
				var t:Object = input[j];
				var tXML:XML = t.xml;
				tsXML.appendChild(tXML); 									
			}	
			XML.prettyPrinting = true;
			return tsXML.toXMLString();				
		}

		private function parseChildren(testContainer:Object, testNodes:XMLList, testCollection:ArrayCollection):void{
			for each (var x:XML in testNodes){
				switch(x.localName()){
					case "TestSuite":
						var testSuiteName:String = x.@name;
						var testSuiteDescription:String = x.@description;
						var newTestSuite:MonkeyTestSuite = new MonkeyTestSuite();
						newTestSuite.mateDispatcher = this.mateDispatcher;
						newTestSuite.name = testSuiteName;
						newTestSuite.description = testSuiteDescription;
						if(testContainer != null){
							newTestSuite.parent = testContainer;
						}else{
							newTestSuite.parent = newTestSuite;
						}
						newTestSuite.children = new ArrayCollection();			
						var newTestSuiteNodes:XMLList = x.elements();
						parseChildren(newTestSuite,newTestSuiteNodes,newTestSuite.children);
						testCollection.addItem(newTestSuite);
						newTestSuite.resetResult();
						newTestSuite.updateResult();
						break;					
					case "TestCase":
						var testCaseName:String = x.@name;
						var testCaseDescription:String = x.@description;
						var newTestCase:MonkeyTestCase = new MonkeyTestCase();
						newTestCase.mateDispatcher = this.mateDispatcher;
						newTestCase.name = testCaseName;
						newTestCase.description = testCaseDescription;
						newTestCase.parent = testContainer;
						newTestCase.children = new ArrayCollection();			
						var newTestCaseNodes:XMLList = x.elements();
						parseChildren(newTestCase,newTestCaseNodes,newTestCase.children);
						testCollection.addItem(newTestCase);					
						break;					
					case "Test":
						var testName:String = x.@name;
						var testDescription:String = x.@description;
						var newTest:MonkeyTest = new MonkeyTest();
						newTest.mateDispatcher = this.mateDispatcher;
						newTest.name = testName;
						newTest.description = testDescription;
						// This XML may have been generated internally via new project creation code.
						// In this case make sure default defaultThinkTime from MonkeyTest class gets used.
						var rawDefaultThinkTime:String = x.@defaultThinkTime;
						if ( rawDefaultThinkTime != "" ) {
							newTest.defaultThinkTime = parseInt(rawDefaultThinkTime);
						}
						newTest.parent = testContainer;
						newTest.children = new ArrayCollection();			
						var nodes:XMLList = x.elements();
						parseChildren(newTest,nodes,newTest.children);
						testCollection.addItem(newTest);					
						break;
					case "UIEvent":
						var uiEventCmd:String=x.@command;
						var uiEventValue:String=x.@value;
						var uiEventProp:String=x.@prop;
						var uiEventContainerValue:String=x.@containerValue;
						var uiEventContainerProp:String=x.@containerProp;								
						var uiEventArgs:Array = new Array();
						var argNodes:XMLList = x.elements();
						for(var i:int=0;i<argNodes.length();i++){ 
// why is toString needed here?								
							uiEventArgs[i]=argNodes[i].@value.toString();
						}
						var uiEventCommand:UIEventMonkeyCommand = new UIEventMonkeyCommand;
						uiEventCommand.mateDispatcher = this.mateDispatcher;
						uiEventCommand.parent = testContainer;
						uiEventCommand.command = uiEventCmd;
						uiEventCommand.value = uiEventValue;
						uiEventCommand.prop = uiEventProp;
						uiEventCommand.containerValue = uiEventContainerValue;
						uiEventCommand.containerProp = uiEventContainerProp;								
						uiEventCommand.args = uiEventArgs;								
						testContainer.children.addItem(uiEventCommand);
						break;
					case "Pause":
						var pauseDuration:uint = x.@duration;
						var pauseCommand:PauseMonkeyCommand = new PauseMonkeyCommand();
						pauseCommand.mateDispatcher = this.mateDispatcher;
						pauseCommand.duration = pauseDuration;
						pauseCommand.parent = testContainer;
						testContainer.children.addItem(pauseCommand);
						break;
					case "Verify":
						var verifyDescription:String = x.@description;
						var verifySnapshotURL:String = x.@snapshotURL;	
						var verifyValue:String = x.@value;
						var verifyProp:String = x.@prop;
						var verifyContainerValue:String = x.@containerValue;
						var verifyContainerProp:String = x.@containerProp;
						var verifyBitmap:Boolean = (x.@verifyBitmap == "true");
						var verifyCommand:VerifyMonkeyCommand = new VerifyMonkeyCommand();
						verifyCommand.mateDispatcher = this.mateDispatcher;							
						verifyCommand.description = verifyDescription;
						verifyCommand.value = verifyValue;
						verifyCommand.prop = verifyProp;
						verifyCommand.containerValue = verifyContainerValue;
						verifyCommand.containerProp = verifyContainerProp;	
						verifyCommand.verifyBitmap = verifyBitmap;	
						verifyCommand.snapshotURL = verifySnapshotURL;
						var attributeNodes:XMLList = x.elements("Attribute");
						var attributes:ArrayCollection = new ArrayCollection();
						for(i=0;i<attributeNodes.length();i++){ 
							var attributeNode:XML = attributeNodes[i];
							var attribute:AttributeVO = new AttributeVO();
							attribute.name = attributeNode.@name;
							attribute.expectedValue = attributeNode.@expectedValue;
							attribute.type = attributeNode.@type;
							attribute.selected = true;
							attributes.addItem(attribute);
						}	
						verifyCommand.attributes = attributes;	
						verifyCommand.parent = testContainer;						
						testContainer.children.addItem(verifyCommand);
						break;
					default:
						throw new Error("TestXMLConvertor: Local name not found:" + x.localName());	
				}						
			}			
		}

		public function parseXML(input:XML):ArrayCollection{
			var testXMLList:XMLList = input.elements();	
			var testHierarchicalArrayCollection:ArrayCollection = new ArrayCollection();
			parseChildren(null,testXMLList,testHierarchicalArrayCollection);									
			return testHierarchicalArrayCollection;			
		}
	}
}