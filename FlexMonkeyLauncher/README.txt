

FlexMonkeyLauncher lets you record and playback FlexMonkey tests for a swf. With FlexMonkeyLauncher, it is no longer necessary to compile your app with the FlexMonkey and automation libraries.

Copy FlexMonkeyLauncher.swf to the directory containing the swf you want to test. Please note: The launcher MUST be run from the same directory as the swf to be tested.

Run FlexMonkeyLauncher.swf. Enter the name of the swf you want to run and click the Load button. Once your swf is loaded, you can record and playback UI interactions. See http://code.google.com/p/flexmonkey/wiki/GettingStarted for more info.

Using FlexMonkey.xml
====================

Instead of using the UI, you can specify the name of the swf to run by creating a file named FlexMonkey.xml with the following format:

<?xml version="1.0" encoding="UTF-8"?>
<FlexMonkey targetSwf="yourTarget" testSwf="yourTests" visible="true" autoStart="true" width="1024" height="768"/>

where yourSwf is the name of the swf file you want to test. You can optionally specify testSwf to run tests packaged separately from the app to be tested. 

The remaining parameters are optional. Setting visible to "false" will run without the FlexMonkey window opening. Use this option when invoking from ant. Setting autoStart to "true" will run immediately upon opening FlexMonkey any tests registered with FlexMonkey's built-in runner. Specify the width and height parameters if you need to set a particular size for the swf to be tested.


For more information on FlexMonkey, see http://flexmonkey.googlecode.com

