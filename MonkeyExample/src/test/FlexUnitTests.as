package test
{
	import com.gorillalogic.flexmonkey.commands.CallCommand;
	import com.gorillalogic.flexmonkey.commands.CommandRunner;
	import com.gorillalogic.flexmonkey.commands.FlexCommand;
	import com.gorillalogic.flexmonkey.core.MonkeyEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.ui.FlexMonkey;
	
	import flash.display.DisplayObject;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.DateField;
	import mx.events.FlexEvent;


	[Mixin]
	public class FlexUnitTests extends TestCase
	{
      public static function init(root:DisplayObject) : void {
       root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
        // To run with the FlexMonkey UI
     	 FlexMonkey.addTestSuite(FlexUnitTests);


        // Uncomment the following line to start tests immediately upon opening the FlexMonkey window (not needed for Ant)
        // FlexMonkey.enableAutoStart();

        // To run without the FlexMonkeyUI, use the lines below instead of the ones obove (and link FlexMonkey.swc instead of FlexMonkeyUI.swc)
        // var	antRunner:JUnitTestRunner = new JUnitTestRunner();
        // antRunner.run(new TestSuite(FlexUnitTests));
       });        
	}
	// Test method
	public function testSomething():void {
		var cmdRunner:CommandRunner = new CommandRunner();
		cmdRunner.addEventListener(MonkeyEvent.READY_FOR_VALIDATION, addAsync(verifySomething, 10000));
		cmdRunner.runCommands([
			new FlexCommand("inName", "SelectText", ["0", "0"], "automationName"),
			new FlexCommand("inName", "Input", ["Fred"], "automationName"),
			new FlexCommand("inType", "Open", ["null"], "automationName"),
			new FlexCommand("inType", "Select", ["Work", "1", "0"], "automationName"),
			new FlexCommand("inPhone", "SelectText", ["0", "0"], "automationName"),
			new FlexCommand("inPhone", "Input", ["555 555 5555"], "automationName"),
			// The following command was inserted manually to demonstrate a workaround for DateField bug
			// See http://groups.google.com/group/flexmonkey/browse_thread/thread/bf4af5e1d8164608# for more info
			new CallCommand(function():void {DateField(MonkeyUtils.findComponentWith("inDate")).open()}),
			new FlexCommand("inDate", "Open", [null], "automationName"),
			new FlexCommand("inDate", "Change", ["Wed Oct 8 2008"], "automationName"),
			new FlexCommand("Add", "Click", ["0"], "automationName"),
			new FlexCommand("grid", "Select", ["  | Fred | *Work* | 555 555 5555 | Wed Oct 8 00:00:00 GMT-0600 2008", "1", "0"], "automationName"),
			new FlexCommand("automationName{MonkeyContacts string}automationClassName{FlexApplication string}className{MonkeyContacts string}label{ string}id{MonkeyContacts string}automationIndex{index:-1 string}|automationName{index:0 string}className{mx.containers.TitleWindow string}id{null object}automationClassName{FlexTitleWindow string}automationIndex{index:0 string}label{ string}|automationName{index:0 string}className{mx.containers.VDividedBox string}id{null object}automationClassName{FlexDividedBox string}automationIndex{index:0 string}label{ string}|automationName{grid string}automationClassName{FlexDataGrid string}className{mx.controls.DataGrid string}id{grid string}automationIndex{index:6 string}|automationName{%20%20%7C%20Fred%20%7C%20Work%20%7C%20555%20555%205555%20%7C%20Wed%20Oct%208%2000:00:00%20GMT-0600%202008 string}automationClassName{FlexComboBox string}className{MonkeyContacts_inlineComponent1 string}id{null object}automationIndex{type:0 string}", "Open", ["null"], "automationID"),
			new FlexCommand("automationName{MonkeyContacts string}automationClassName{FlexApplication string}className{MonkeyContacts string}label{ string}id{MonkeyContacts string}automationIndex{index:-1 string}|automationName{index:0 string}className{mx.containers.TitleWindow string}id{null object}automationClassName{FlexTitleWindow string}automationIndex{index:0 string}label{ string}|automationName{index:0 string}className{mx.containers.VDividedBox string}id{null object}automationClassName{FlexDividedBox string}automationIndex{index:0 string}label{ string}|automationName{grid string}automationClassName{FlexDataGrid string}className{mx.controls.DataGrid string}id{grid string}automationIndex{index:6 string}|automationName{%20%20%7C%20Fred%20%7C%20Work%20%7C%20555%20555%205555%20%7C%20Wed%20Oct%208%2000:00:00%20GMT-0600%202008 string}automationClassName{FlexComboBox string}className{MonkeyContacts_inlineComponent1 string}id{null object}automationIndex{type:0 string}", "Select", ["Mobile", "1", "0"], "automationID"),
			new FlexCommand("grid", "Click", ["0"], "automationName")			]);


   }

	// Called after commands have been run
	private function verifySomething(event:MonkeyEvent):void {
		   var comp:DataGrid = MonkeyUtils.findComponentWith("grid","id") as DataGrid;
		   Assert.assertEquals("Fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
		   Assert.assertEquals("Mobile", ArrayCollection(comp.dataProvider).getItemAt(0).type);		   

	}   }
}