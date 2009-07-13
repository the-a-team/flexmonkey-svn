/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.VOs.AS3FileVO;
	import com.gorillalogic.flexmonkey.application.commands.AddCommand;
	import com.gorillalogic.flexmonkey.application.commands.DeleteCommand;
	import com.gorillalogic.flexmonkey.application.commands.IUndoable;
	import com.gorillalogic.flexmonkey.application.commands.MoveCommand;
	import com.gorillalogic.flexmonkey.application.commands.UpdateCommand;
	import com.gorillalogic.flexmonkey.application.events.UndoEvent;
	import com.gorillalogic.flexmonkey.application.utilities.AS3FileCollector;
	import com.gorillalogic.flexmonkey.application.utilities.ITestXMLConvertor;
	import com.gorillalogic.flexmonkey.application.utilities.TestAS3Convertor;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyTestCase;
	import com.gorillalogic.flexmonkey.core.MonkeyTestSuite;
	import com.gorillalogic.flexmonkey.monkeyCommands.PauseMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.collections.HierarchicalData;
	import com.gorillalogic.flexmonkey.application.events.AlertEvent;

// ---------------------------------------------------------------------------------

	public class TestManager extends EventDispatcher
	{
		public var mateDispatcher:IEventDispatcher;

		public var testXMLConvertor:ITestXMLConvertor;
		public var testAS3Convertor:TestAS3Convertor;
		public var generatedCodeURL:String;
		public var generatedCodeSuitesPackageName:String;
		public var isNewProject:Boolean;
		
		private var _monkeyTestFileURL:String;
		public function get monkeyTestFileURL():String{
			return _monkeyTestFileURL;
		}
		public function set monkeyTestFileURL(url:String):void{
			if((isNewProject || _monkeyTestFileURL != url) && url != null){
				_monkeyTestFileURL = url;
				if(isNewProject){
					newTestFile();
				}else{
					readTestFile()
				}
			}
		}	
		
		private function readTestFile():void{
			var file:File;
			var fileStream:FileStream;
			try{
				file = new File(monkeyTestFileURL);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Malformed monkeyTestSuites.xml URL."));
				return;			
			}
			if(file.exists){
				fileStream = new FileStream();
				fileStream.addEventListener(IOErrorEvent.IO_ERROR,fileReadIOErrorHandler,false,0,true);
				fileStream.addEventListener(Event.COMPLETE,fileReadCompleteHandler,false,0,true);
				fileStream.openAsync(file,FileMode.READ);
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: monkeyTestSuites.xml does not exist for reading."));
				return;					
			}		
		}

		private function fileReadIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not open monkeyTestSuites.xml for reading."));
		}

		private function fileReadCompleteHandler(event:Event):void{
			var testText:String;
			var fileStream:FileStream = event.target as FileStream;
			var bytesAvailable:uint=fileStream.bytesAvailable;
			try{
				testText = fileStream.readUTFBytes(bytesAvailable);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not read monkeyTestSuites.xml."));	
			}catch(error:EOFError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Attempt to read past end of monkeyTestSuites.xml."));
			}finally{
				fileStream.close();
			}
			if(testText != null){
				try{
					var xml:XML = new XML(testText);
				}catch(error:Error){
					mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Malformed XML in monkeyTestSuites.xml"));
				}
				if(xml){
					testXML = xml;
				}
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: monkeyTestSuites.xml empty."));	
			}
		}	
		
		public function saveTestFile():void{
			var file:File;
			var fileStream:FileStream;
			var testText:String;
			try{
				file = new File(monkeyTestFileURL);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Malformed monkeyTestSuites.xml URL while saving."));	
				return;		
			}
			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR,testFileWriteIOErrorHandler,false,0,true);
			fileStream.openAsync(file,FileMode.WRITE);					
			testText = getTestAsXML();
			try{	
				fileStream.writeUTFBytes(testText);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not save monkeyTestSuites.xml"));
			}finally{
				fileStream.close();
			}				
		}	
	
		private function testFileWriteIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not open monkeyTestSuites.xml for saving."));
		}		
		
		public function newTestFile():void{
			testXML = newTestFileXML;
			saveTestFile();
		}

		private var newTestFileXML:XML = 
			<TopNode>
				<TestSuite name="NewTestSuite" result="NOT_RUN">
					<TestCase name="NewTestCase" result="NOT_RUN">
						<Test name="NewTest" result="NOT_RUN"/> 
					</TestCase>						
				</TestSuite>			
			</TopNode>;		

		//-- test ---------------------------------------------------------------------------------		
        private var testHierarchicalArrayCollection:ArrayCollection;	

		private var _testXML:XML;
		private function set testXML(d:XML):void{
			_testXML = d;
			testHierarchicalArrayCollection = testXMLConvertor.parseXML(_testXML);							
			testData = new HierarchicalData(testHierarchicalArrayCollection);
			mateDispatcher.dispatchEvent(new UndoEvent(UndoEvent.RESET));
			if(testHierarchicalArrayCollection.length!=0){
				selectedItem = testHierarchicalArrayCollection[0];
			}			
		}

		private var _testData:HierarchicalData;
        [Bindable] 
        public function get testData():HierarchicalData{
        	return _testData;
        }
        private function set testData(d:HierarchicalData):void{
        	_testData = d;       	
        }
        		
		private var _selectedItem:MonkeyRunnable = null;
		[Bindable]
		public function get selectedItem():MonkeyRunnable{
			return _selectedItem;
		}
		private function set selectedItem(o:MonkeyRunnable):void{
			_selectedItem = o;
		}
				
		private var _selectedItems:Array = null;
		private function get selectedItems():Array{				
			return _selectedItems;
		}
		private function set selectedItems(a:Array):void{
			_selectedItems = a;
		}

		//-- constructor --------------------------------------------------------------------------
		public function TestManager(target:IEventDispatcher=null)
		{
			super(target);
		}

		//-- methods ------------------------------------------------------------------------------		
		public function changeSelectedItem(o:Object):void{
			selectedItem = MonkeyRunnable(o);
		}

		public function changeSelectedItems(a:Array):void{
			selectedItems = a;
		}
				
// these add commands should take a nullified item to manipulate
		public function addTestSuite(canUndo:Boolean=true):void{
			var testSuite:MonkeyTestSuite = new MonkeyTestSuite();
        	testSuite.name = "NewTestSuite";
			testSuite.result = "NOT_RUN";
			if(selectedItem == null || selectedItem is MonkeyTestSuite){
				testSuite.parent = testSuite;	
			}else{
//throw error				
			}
			testSuite.children = new ArrayCollection();	
			executeCommand( new AddCommand(testSuite,testHierarchicalArrayCollection,selectedItem,mateDispatcher,canUndo));
		}

		public function addTestCase(canUndo:Boolean=true):void{
			var testCase:MonkeyTestCase = new MonkeyTestCase();
        	testCase.name = "NewTestCase";
			testCase.result = "NOT_RUN";
			if(selectedItem is MonkeyTestSuite){
				testCase.parent = selectedItem;
			}else if(selectedItem is MonkeyTestCase){				
				testCase.parent = selectedItem.parent;
			}else{
//throw error				
			}
			testCase.children = new ArrayCollection();	
			executeCommand( new AddCommand(testCase,testCase.parent.children,selectedItem,mateDispatcher,canUndo));
		}

		public function addTest(canUndo:Boolean=true):void{
			var test:MonkeyTest = new MonkeyTest();
        	test.name = "NewTest";
			test.result = "NOT_RUN";
			if(selectedItem is MonkeyTestCase){
				test.parent = selectedItem;
			}else if(selectedItem is MonkeyTest){
				test.parent = selectedItem.parent;
			}else{				
//throw error
			}
			test.children = new ArrayCollection();
			executeCommand( new AddCommand(test,test.parent.children,selectedItem,mateDispatcher,canUndo));
		}	
		
		public function addUIEvent(uiEventCommand:UIEventMonkeyCommand,canUndo:Boolean=true):void{
			uiEventCommand.mateDispatcher = this.mateDispatcher;
			if(selectedItem){			
				if(selectedItem is MonkeyTest){
					uiEventCommand.parent = selectedItem;
				}else{
					uiEventCommand.parent = selectedItem.parent;
				}
// improve checking for ok place to insert here		
				executeCommand( new AddCommand(uiEventCommand,uiEventCommand.parent.children,selectedItem,mateDispatcher,canUndo));			
			}
		}			
		
		public function addVerify(canUndo:Boolean=true):void{
			if(selectedItem){
	        	var verify:VerifyMonkeyCommand = new VerifyMonkeyCommand();
	        	verify.mateDispatcher =	this.mateDispatcher;
	        	if(selectedItem is MonkeyTest){
	        		verify.parent = selectedItem;
	        	}else{
	        		verify.parent = selectedItem.parent;
	        	}
// improve checking for ok place to insert here					        	
	        	verify.description = "New Verify";
	        	verify.result = "NOT_RUN";
				executeCommand( new AddCommand(verify,verify.parent.children,selectedItem,mateDispatcher,canUndo));
			}		
		}	

		public function addPause(canUndo:Boolean=true):void{
			if(selectedItem){
	        	var pause:PauseMonkeyCommand = new PauseMonkeyCommand();
	        	pause.mateDispatcher = this.mateDispatcher;
				pause.duration = 500;
				if(selectedItem is MonkeyTest){
					pause.parent = selectedItem;
				}else{	
					pause.parent = selectedItem.parent;
				}
// improve checking for ok place to insert here					        	
				executeCommand( new AddCommand(pause,pause.parent.children,selectedItem,mateDispatcher,canUndo));
			}
		}			
		
		public function updateItem(c:MonkeyRunnable,canUndo:Boolean=true):void{
			if(selectedItem){
				executeCommand( new UpdateCommand(c,testHierarchicalArrayCollection,selectedItem,mateDispatcher,canUndo));
			}
		}		
		
		public function deleteItem(canUndo:Boolean=true):void{
        	if(selectedItem != null){
				executeCommand( new DeleteCommand(selectedItem,testHierarchicalArrayCollection,selectedItem,mateDispatcher,canUndo));
            }				
		}
		
		public function dragMoveItem(dragSourceItems:Object, dropTarget:Object, beforeDropTarget:Object, dropAtBeforeDropTargetLevel:Boolean, canUndo:Boolean=true):void{
			executeCommand( new MoveCommand(dragSourceItems,dropTarget,beforeDropTarget,dropAtBeforeDropTargetLevel,testHierarchicalArrayCollection,mateDispatcher,canUndo));
		}		
						
		public function executeCommand(command:IUndoable):void{
			command.execute();
			if(command.canUndo){
				mateDispatcher.dispatchEvent(new UndoEvent(UndoEvent.ADD_UNDOABLE, command));
			}
		}

		public function getTestAsXML():String{
			return testXMLConvertor.generateXML(testHierarchicalArrayCollection);	
		}
		
		public function saveTestFilesAsAS3():void{
			var AS3Files:AS3FileCollector = new AS3FileCollector(generatedCodeSuitesPackageName);
			testAS3Convertor.generateAS3(testHierarchicalArrayCollection,AS3Files);
			var package2DirPattern:RegExp = /\./g;
			var packageDir:String = generatedCodeURL + "/" + AS3Files.packageName.replace(package2DirPattern,"/");
	 		for each (var testSuite:AS3FileVO in AS3Files.AS3Files) {
	 			var testSuiteFilePath:String = packageDir + "/" + testSuite.fileName + "/" + testSuite.fileName + ".as";
	 			var testCaseDirPath:String = packageDir + "/" + testSuite.fileName + "/tests/";
	 			saveGeneratedCode(testSuiteFilePath,testSuite.fileContents);
	 			for each(var testCase:AS3FileVO in testSuite.children.AS3Files){
	 				var testCaseFilePath:String = testCaseDirPath + testCase.fileName + ".as";
	 				saveGeneratedCode(testCaseFilePath,testCase.fileContents);
	 			}	 			
	 		}				
		}			
		
		private function saveGeneratedCode(url:String, contents:String):void{
			var file:File;
			var fileStream:FileStream;
			try{
				file = new File(url);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Malformed URL while saving AS3:" + url));	
				return;		
			}
			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR,as3FileWriteIOErrorHandler,false,0,true);
			fileStream.openAsync(file,FileMode.WRITE);					
			try{	
				fileStream.writeUTFBytes(contents);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not save AS3:" + url));
			}finally{
				fileStream.close();
			}							
		}		
		
		private function as3FileWriteIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","TestManager: Could not open AS3 file for saving."));
		}			
		
		public function updateResults():void{
			for(var i:uint=0;i<testHierarchicalArrayCollection.length;i++){
				MonkeyTestSuite(testHierarchicalArrayCollection[i]).updateResult();
			}	
		}
		
	}
}