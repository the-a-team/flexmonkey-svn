/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.monkeyFluintAirTestRunner
{
	import com.gorillalogic.flexmonkey.context.SnapshotLoader;
	
	import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestContext;
	import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestSuite;
	
	import flash.desktop.NativeApplication;	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import mx.controls.SWFLoader;
	import mx.core.WindowedApplication;
	import mx.logging.ILogger;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import mx.controls.Alert;

	import mx.managers.SystemManager;
	
	import net.digitalprimates.fluint.ui.TestResultDisplay;
	import net.digitalprimates.fluint.ui.TestRunner;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.events.FlexEvent;

	public class MonkeyTestRunnerWindow extends WindowedApplication	
	{
	   private const REPORT_FILE_NAME : String = "TEST-AllTests.xml";
	   private const DEFAULT_REPORT_DIR : String = "app-storage:/";
	   
		private var _logger : ILogger;
		
		private var _workingDir : File;
		
		public var disp : TestResultDisplay;
		public var testRunner : TestRunner; 
		
		private var targetSwf : String = null;
		private var snapshotDir : String = null;
		private var reportDir : String = null;
		
		private var _fileSet : Array;
		private var _fileSetChange : Boolean = false;
		private var _headless : Boolean = false;
		private var _failOnError : Boolean = false;
		private var _headlessChange : Boolean = false;

//---------------------------------------------------------------------------------------

		private var targetSWFReady:Boolean = false;
		
		private var swfLoader:SWFLoader;
		
		private var _localSWFBytes:Object;
		public function get localSWFBytes():Object{
			return _localSWFBytes;
		}
		public function set localSWFBytes(o:Object):void{
			_localSWFBytes = o;
		
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			swfLoader = new SWFLoader();
			swfLoader.addEventListener(Event.COMPLETE, swfLoaderCompleteHandler);
			swfLoader.addEventListener(IOErrorEvent.IO_ERROR, swfLoaderIOErrorHandler,false,0,true);	
			swfLoader.loaderContext = loaderContext;
			swfLoader.percentHeight=100;
			swfLoader.percentWidth=100;
			swfLoader.scaleContent = true;		
			swfLoader.source = o;
			addChild(swfLoader);
		}
			
		
		private function urlLoaderCompleteHandler(event:Event):void{
			var urlLoader:URLLoader = URLLoader(event.target);
			localSWFBytes = urlLoader.data;	
		}
		private function urlLoaderIOErrorHandler(event:IOErrorEvent):void{
			
		}
		
		private function swfLoaderCompleteHandler(event:Event):void{
		      SystemManager(swfLoader.content).addEventListener(FlexEvent.APPLICATION_COMPLETE,swfLoaderApplicationCompleteHandler,false,0,true );
		}
		
		private function swfLoaderApplicationCompleteHandler(event:Event):void{
			targetSWFReady = true;
			if(testModulesReady){
				testRunner.startTests(testSuitesArray);				
			}		
		}
		
		
		private function swfLoaderIOErrorHandler(event:IOErrorEvent):void{
		}


//---------------------------------------------------------------------------------------


		public function MonkeyTestRunnerWindow():void
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,listenToCommandLine);
			_logger = TestRunnerUtils.createLogger(this.className);
		}
		
		[Bindable]
		public function get headless():Boolean
		{
			return _headless;
		}
		
		
		public function set headless(b:Boolean):void
		{
			_headless = b;
			_headlessChange = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get failOnError():Boolean
		{
			return _failOnError;
		}
		
		
		public function set failOnError(b:Boolean):void
		{
			_failOnError = b;
		}

		[Bindable]
		public function get fileSet():Array
		{
			return _fileSet;
		}
		
		public function set fileSet(value:Array):void
		{
			_fileSet = value;
			_fileSetChange = true;
			
			invalidateProperties();
		}
		
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			if ( !headless ) {
				disp = new TestResultDisplay();
				disp.percentHeight=100;
				disp.percentWidth=100;
				disp.creationPolicy="all";
				this.addChild(disp);
			}
			
			testRunner = new TestRunner();
			testRunner.addEventListener(TestRunner.TESTS_COMPLETE, processResults);
			this.addChild(testRunner);

			
		}
		
		
		protected override function commitProperties():void
		{
			if( this._headlessChange )
			{
			   _logger.debug("headless changed to " + headless);
			   
				_headlessChange = false;
				
				if( this.headless )
				{
					// TODO
					// This causes occasional weird display behavior on Windoes with some target apps.
					; // nativeWindow.minimize();
				}else{
					nativeWindow.maximize();
				}
			}
			
			if( _fileSetChange )
			{
			   _logger.debug("fileSet changed to " + fileSet);
			   
				_fileSetChange = false;
				
				parseModules();
			}
		}
		
		protected function listenToCommandLine(event:InvokeEvent):void
		{			
         	_logger.debug("Arguments: " + event.arguments);
         	_workingDir = event.currentDirectory;
			var arguments : Dictionary = TestRunnerUtils.parseArgument(event.arguments);

			
			this.headless = arguments['headless'];
			this.failOnError = arguments['failOnError'];		   	
		   	this.targetSwf = arguments['targetSwf'];
		   	this.fileSet = arguments['fileSet'];		
			this.snapshotDir = arguments['snapshotDir'];
		   	this.reportDir = arguments['reportDir'];

		   	_logger.debug("headless: " + headless);
		   	_logger.debug("failOnError: " + failOnError);
		   	_logger.debug("targetSwf: '" + this.targetSwf + "'");
		   	_logger.debug("fileSet: '" + this.fileSet + "'");
		   	_logger.debug("snapshotDir: '" + this.snapshotDir + "'");
		   	_logger.debug("reportDir: '" + this.reportDir + "'");
		   	
		   	var request:URLRequest = new URLRequest(targetSwf);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,urlLoaderIOErrorHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(request);
		}

		private function parseModules():void
		{

		   try
		   {
   			var fileList : Array = fileSet.map(
   			   function (item:*, index:int, array:Array) : File
   			   {
   			      return _workingDir.resolvePath(item);
   			   }
   			);
   			
   			var swfList : Array = TestRunnerUtils.recurseDirectories(fileList);
   			
   			_logger.debug("FOUND " + swfList.length + " SWF(S)");
   
            if(swfList.length == 0)
            {
               exitWithFailure();
            }
            
   			loadExternalTests( swfList );
   		}
   		catch(e : Error)
   		{
   		   _logger.error("FAILURE MOST LIKELY DUE TO RECURSION LOOP. fileSet = [" + fileSet + "]");
   		}
		}
		
//---------------------------------------------------------------------------------------

		private var testModulesReady:Boolean = false;
		private var testSuitesArray:Array;
		private function testModulesReadyHandler(event:TestModuleEvent):void{
			testSuitesArray = event.suites;
			testModulesReady = true;
			// TODO Use code shared with project manager to get project resources
			_logger.debug("Setting snapshotDir to " + snapshotDir);
			var snapshotLoader:SnapshotLoader = new SnapshotLoader(snapshotDir);
			var testContext:MonkeyFlexUnitTestContext = new MonkeyFlexUnitTestContext(snapshotLoader);
			for each ( var suite : MonkeyFlexUnitTestSuite in testSuitesArray ) {
				suite.context = testContext;
			}
			if(targetSWFReady){
				testRunner.startTests(testSuitesArray);		
			}		
		}
	
//---------------------------------------------------------------------------------------
		
		protected function loadExternalTests(swfList : Array) : void
		{		   
		   var manager : TestModuleManager = new TestModuleManager(_logger);


		   // don't start tests unless the TEST_SWF_READY event has also fired...		   
		   manager.addEventListener(TestModuleEvent.TEST_MODULES_READY, testModulesReadyHandler);
		   
           _logger.debug("ATTEMPTING TO LOAD " + swfList.length + " SWF(S)");
         		   
		   manager.loadModules(swfList);
		}

		protected function processResults(event:Event):void
		{
		   var results : XML = testRunner.xmlResults;
		   var dir : File = new File(DEFAULT_REPORT_DIR);
		   
		   if(reportDir)
		   {
		      dir = _workingDir.resolvePath(reportDir);
		      
		      //Can we actually use the directory?
		      if(!dir.exists)
   		   	  {
   		          dir = new File(DEFAULT_REPORT_DIR);
   		   	  }
		   }

           // patch from http://groups.google.com/group/fluint-discussions/browse_thread/thread/1947b72813e7f62f 
           for each(var testsuite:XML in results.testsuite) 
           { 
	          TestRunnerUtils.writeToFile(testsuite, dir, testsuite.@name + ".xml"); 
           } 
			
           if(headless)
           {
               if(testsFailed(results) && failOnError)
               {
                  exitWithFailure();
               }
               else
               {
                  exitWithSuccess();
               }
           }
		}

		private function testsFailed(testResults : XML) : Boolean
		{
		   if(testResults.@failureCount 
		      && testResults.@errorCount 
		      && testResults.@failureCount == 0 
		      && testResults.@errorCount == 0)
		   {
		      return false;
		   }
		   else
		   {
		      return true;
		   }
		}
		
		private function exitWithFailure() : void
		{
		   _logger.debug("EXITING ON FAILURE!");
			nativeApplication.exit(1);
		}
		
		private function exitWithSuccess() : void
		{
		   _logger.debug("EXITING ON SUCCESS!");
			nativeApplication.exit(0);
		}
	}
}