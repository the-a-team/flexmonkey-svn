The AS class test.FlexUnitTests provides an example of how to test an application (MonkeyContacts.mxml) with FlexMonkey.

RUNNING
======

open build/MonkeyContactsTest.html. 

To run the sample FlexUnit test:

1. Click on the FlexUnit tab in FlexMonkey
2. Click the "Run" button. 

The source for the FlexUnit test is in src/test/FlexUnitTests.as.

For more info, see http://code.google.com/p/flexmonkey/wiki/GettingStarted.wiki.

RECORDING A TEST
===============

1. Click the record button.
2. Interact with the application. Notice that commands are recorded in the command list. You can replay selected commands by highlighting them and hitting Run.

Generating Test Code Source
===========================

1. Click on the Test Source Code tab.
2. Source code will be displayed for the recorded commands.

Running from Ant
================

To run from Ant:

1. Create the file build.properties by copying build.properties.template
2. Customize build.properties for your environment
3. Change the "create" method in MonkeyContactsTest to:

			public function create():void {
		            var	antRunner:JUnitTestRunner = new JUnitTestRunner();
		            antRunner.run(new TestSuite(FlexUnitTests), function():void {
                  	       fscommand("quit");
         		    }); 
			}
       
4. type: ant


  
