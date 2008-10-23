package test
{
	import com.gorillalogic.flexmonkey.FlexCommand;
	import com.gorillalogic.flexmonkey.FlexMonkey;
	import com.gorillalogic.flexmonkey.MonkeyEvent;
	import com.gorillalogic.flexmonkey.MonkeyUtils;
	
	import flash.display.DisplayObject;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.events.FlexEvent;


	[Mixin]
	public class FlexUnitTests extends TestCase
	{
      public static function init(root:DisplayObject) : void {
   		
     	FlexMonkey.addTestSuite(FlexUnitTests);
     	// Uncomment the following line to run tests immediately upon app startup
		// FlexMonkey.enableAutoStart();
	}
	// FlexUnit test method
	public function testSomething():void {
		FlexMonkey.theMonkey.addEventListener(MonkeyEvent.READY_FOR_VALIDATION, addAsync(verifySomething, 10000));
		FlexMonkey.runCommands([
			new FlexCommand("inName", "SelectText", ["0", "0"], "automationName"),
			new FlexCommand("inName", "Input", ["Fred"], "automationName"),
			new FlexCommand("inName", "ChangeFocus", [false, "TAB"], "automationName"),
			new FlexCommand("inType", "Open", ["null"], "automationName"),
			new FlexCommand("inType", "Select", ["Work", "1", "0"], "automationName"),
			new FlexCommand("inType", "Type", ["TAB", "0"], "automationName"),
			new FlexCommand("inType", "ChangeFocus", [false, "TAB"], "automationName"),
			new FlexCommand("inPhone", "Input", ["555 555 5555"], "automationName"),
			new FlexCommand("Add", "Click", ["0"], "automationName"),
			new FlexCommand("grid", "Select", ["Fred | *Work* | 555 555 5555", "1", "0"], "automationName"),
			new FlexCommand("className{MonkeyContacts string}automationIndex{index:-1 string}id{MonkeyContacts string}label{ string}automationName{MonkeyContacts string}automationClassName{FlexApplication string}|className{mx.containers.TitleWindow string}label{ string}automationClassName{FlexTitleWindow string}automationIndex{index:0 string}id{null object}automationName{index:0 string}|className{mx.containers.VDividedBox string}label{ string}automationClassName{FlexDividedBox string}automationIndex{index:0 string}id{null object}automationName{index:0 string}|className{mx.controls.DataGrid string}automationIndex{index:6 string}automationName{grid string}automationClassName{FlexDataGrid string}id{grid string}|className{MonkeyContacts_inlineComponent1 string}automationIndex{type:0 string}automationName{Fred%20%7C%20Work%20%7C%20555%20555%205555 string}automationClassName{FlexComboBox string}id{null object}", "Open", ["null"], "automationID"),
			new FlexCommand("className{MonkeyContacts string}automationIndex{index:-1 string}id{MonkeyContacts string}label{ string}automationName{MonkeyContacts string}automationClassName{FlexApplication string}|className{mx.containers.TitleWindow string}label{ string}automationClassName{FlexTitleWindow string}automationIndex{index:0 string}id{null object}automationName{index:0 string}|className{mx.containers.VDividedBox string}label{ string}automationClassName{FlexDividedBox string}automationIndex{index:0 string}id{null object}automationName{index:0 string}|className{mx.controls.DataGrid string}automationIndex{index:6 string}automationName{grid string}automationClassName{FlexDataGrid string}id{grid string}|className{MonkeyContacts_inlineComponent1 string}automationIndex{type:0 string}automationName{Fred%20%7C%20Work%20%7C%20555%20555%205555 string}automationClassName{FlexComboBox string}id{null object}", "Select", ["Mobile", "1", "0"], "automationID"),
			new FlexCommand("grid", "Click", ["0"], "automationName")			]);
   }
		// Called after commands have been run
		private function verifySomething(event:MonkeyEvent):void {
		   var comp:DataGrid = MonkeyUtils.findComponentWith("grid","id") as DataGrid;
		   Assert.assertEquals("Fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
		   Assert.assertEquals("Mobile", ArrayCollection(comp.dataProvider).getItemAt(0).type);		   
		}
 
	}
}
