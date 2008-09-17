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
	
	[Mixin]
	public class FlexUnitTests extends TestCase
	{
      public static function init(root:DisplayObject) : void {
      	FlexMonkey.addTestSuite(FlexUnitTests);
      }

		// FlexUnit test method
		public function testSomething():void {
		  FlexMonkey.theMonkey.addEventListener(MonkeyEvent.READY_FOR_VALIDATION, addAsync(verifySomething, 10000));
		  FlexMonkey.runCommands([
		      new FlexCommand("inName", "SelectText", [0, "0"], "automationName"),
		      new FlexCommand("inName", "Input", ["fred"], "automationName"),
		      new FlexCommand("inName", "ChangeFocus", [false, "TAB"], "automationName"),
		      new FlexCommand("inPhone", "Input", ["555 555 5555"], "automationName"),
		      new FlexCommand("inPhone", "ChangeFocus", [false, "TAB"], "automationName"),
		      new FlexCommand("inEmail", "Input", ["fred@email.com"], "automationName"),
		      new FlexCommand("Add", "Click", [0], "automationName")   ]);
		  }
		
		// Called after commands have been run
		private function verifySomething(event:MonkeyEvent):void {
		   var comp:DataGrid = MonkeyUtils.findComponentWith("grid","id") as DataGrid;
		   Assert.assertEquals("fred", ArrayCollection(comp.dataProvider).getItemAt(0).name);
		}
	}
}