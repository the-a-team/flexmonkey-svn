package com.gorillalogic.monkeylink
{
	import com.gorillalogic.flexmonkey.context.SnapshotLoader;
	import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestContext;
	import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestSuite;
	
	import flash.display.DisplayObject;
	import flash.events.DataEvent;
	import flash.net.XMLSocket;
	import flash.system.fscommand;
	
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleLoader;
	
	import net.digitalprimates.fluint.ui.TestRunner;
	
	[Mixin]
	public class MonkeyLinkTestLauncher
	{
		
		public static const monkeyLinkTestLauncher:MonkeyLinkTestLauncher = new MonkeyLinkTestLauncher();
		
		private static var root:DisplayObject;
		
		public static function init(root:DisplayObject):void {
			MonkeyLinkTestLauncher.root = root;
			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
				MonkeyLinkTestLauncher.monkeyLinkTestLauncher.startTestLauncher();
			});			
		}		
		
		private function startTestLauncher():void{
writeConsole("Starting Test Launcher");			
			connectSocket();	
//			handleResponse();
		}
		
		private static const REQUEST_PARAMS : String = "<requestParams/>";
		private static const END_OF_TEST_RUN : String = "<endOfTestRun/>";
		private static const END_OF_TEST_ACK_NAME : String = "endOfTestRunAck";
		private static const PARAMETERS_RESPONSE_NAME : String = "parameters";
		
		[Inspectable]
		public var port : uint = 1024;
		
		[Inspectable]
		public var server : String = "localhost";
		
		[Bindable]
		public var status : String = "";
		
		private var reports : Object = new Object();
		private var testsComplete : Function;
		private var totalTestCount : int;
    	private var numTestsRun : int = 0;
    	private var socket : XMLSocket;
				
		private var snapshotDirURL:String;		
		private var testModuleSWFURL:String;
						
		private var testModuleLoader:ModuleLoader; 
		private var testRunner:TestRunner;
		
		public function MonkeyLinkTestLauncher()
		{
			testModuleLoader = new ModuleLoader();
			testModuleLoader.addEventListener(ModuleEvent.READY,testModuleLoaderReadyHandler);
			
			testRunner = new TestRunner();
			testRunner.addEventListener(TestRunner.TESTS_COMPLETE, processResults);		
		}
						
		public function writeConsole(m:String):void{
//			Alert.show(m);
//			trace(m);
		}

		//--------------------------------------------------------------------------
		
		/*
		 * Open a socket to talk back to the Ant task.
		 */
		private function connectSocket() : void {
			writeConsole("Connecting to " + server + ":" + port + "...");
			socket = new XMLSocket();
			socket.addEventListener( Event.CONNECT, handleConnect );
			socket.addEventListener( DataEvent.DATA, handleResponse );
   	   		socket.connect( server, port );
		}
		
		/*
		 * 
		 */
		private function handleConnect( event : Event ) : void {				
			writeConsole("Sending requestParams");
			socket.send( REQUEST_PARAMS );
		}
		
		/*
		 * Event listener to handle data received on the socket.
		 */
		private function handleResponse( event : DataEvent = null ) : void
		{
			var data : String = event.data;
			
			var xml:XML = new XML(data);
   			if ( xml.name() == END_OF_TEST_ACK_NAME ) {
				exit();
   			} else if ( xml.name() == PARAMETERS_RESPONSE_NAME ) {   			
   				testModuleSWFURL = xml.@testModuleSwf;
   				snapshotDirURL = xml.@snapshotDir;
   				writeConsole("Received parameters: testModuleSWF=" + testModuleSWFURL + ", snapshotDir=" + snapshotDirURL);
   				testModuleLoader.loadModule(testModuleSWFURL);	
   			}

/*
			testModuleSWFURL = "MonkeyContactsCodeGenExampleTestModule.swf";
   			snapshotDirURL = "../snapshots";
   			writeConsole("Received parameters: testModuleSWF=" + testModuleSWFURL + ", snapshotDir=" + snapshotDirURL);
   			testModuleLoader.loadModule(testModuleSWFURL);
*/
		}
		
		private function testModuleLoaderReadyHandler(event:ModuleEvent):void{
			writeConsole("Test module SWF ready, running tests...");
			
			var testSuites:Array = Object(testModuleLoader.child).getTestSuites();
			
			// TODO Use code shared with project manager to get project resources
			var snapshotLoader:SnapshotLoader = new SnapshotLoader(snapshotDirURL);
			var testContext:MonkeyFlexUnitTestContext = new MonkeyFlexUnitTestContext(snapshotLoader);
			for each ( var suite : MonkeyFlexUnitTestSuite in testSuites ) {
				suite.context = testContext;
			}
			
			testRunner.startTests( testSuites );
		}
		
		protected function processResults(event:Event):void{
		   sendResults();
		}		

		/*
		 * Sends the results. This sends the reports back to the controlling Ant
		 * task using an XMLSocket.
		 */
		private function sendResults() : void
		{
			var testSuitesXml : XML = testRunner.xmlResults;
			
			writeConsole("Sending test results");
			for each(var testSuiteXml:XML in testSuitesXml.testsuite) { 
				socket.send( testSuiteXml.toXMLString() );
			}
			// Send the end of reports terminator.
			writeConsole("Sending endOfTestRun");
			socket.send( END_OF_TEST_RUN );
		}
				
		/*
		 * Exit the test runner.
		 */
		private function exit() : void
		{
			writeConsole("Done.");
			
			// Close the socket.
			socket.close();  
			
			// TODO Has no effect in browser...
			fscommand( "quit" );
		}
	}
}