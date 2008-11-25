The AS class test.FlexUnitTests provides an example of how to test an application (MonkeyContacts.mxml) with FlexMonkey.To run,
open bin-debug/MonkeyContacts.html in your browser. FlexMonkey will start automatically along with the application.

To run the sample FlexUnit test, click on the FlexUnit tab in FlexMonkey and click the "Run" button. The source for the FlexUnit test is in src/test/FlexUnitTests.as.

You can record and play scripts on the "Command List" tab. The source tab will show a FlexUnit test generated from the commands currently selected in the command list.

For more info, see http://code.google.com/p/flexmonkey/wiki/GettingStarted.wiki.

To run from Ant:

1. Replace FlexMonkeyUI.swc with FlexMonkey.wsc in the libs folder. FlexMonkey.swc can be found in the "optional" folder.
2. Change the "init" method in FlexUnitTests to:

      public static function init(root:DisplayObject) : void {
       root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
         var antRunner:JUnitTestRunner = new JUnitTestRunner();
         antRunner.run(new TestSuite(FlexUnitTests));
       });
       
3. type: ant test

  
