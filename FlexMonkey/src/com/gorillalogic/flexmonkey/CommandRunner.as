package com.gorillalogic.flexmonkey
{
	import com.gorillalogic.aqadaptor.AQAdapter;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	public class CommandRunner extends EventDispatcher
	{
		public function CommandRunner()
		{
		}
		
		public function runCommands(cmds:Array, validator:Function=null, thinkTime:int=500):void {	
				

			var runTimer:Timer = new Timer(thinkTime, 1);		
			var nextCmdIndex:int = 0;	

			runTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				runTimer.delay = thinkTime;
				if (nextCmdIndex == cmds.length) {
					dispatchEvent(new MonkeyEvent(MonkeyEvent.READY_FOR_VALIDATION));
					return;
				}
				
				var c:Object = cmds[nextCmdIndex];
				if (c is PauseCommand) {
					runTimer.delay = PauseCommand(c).delay;
					runTimer.start();
					nextCmdIndex++;
					return;
				}
				
				if (c is CallCommand) {
					CallCommand(c).func();
					nextCmdIndex++;
					runTimer.start();
					return;
				}
				
				var cmd:FlexCommand = c as FlexCommand;
				
				try {
					if (runCommand(cmd.value, cmd.command, cmd.args, cmd.prop, cmd.containerValue, cmd.containerProp)) {
						nextCmdIndex++;
					}
				} catch (error:Error) {
					Alert.show(error.message);
					nextCmdIndex++
				}
				runTimer.start();
				
			});
			runTimer.start();
		}

	
		public function runCommand(value:String, command:String, args:Array, prop:String=null, containerValue:String=null, containerProp:String=null):Boolean {
		    var am:IAutomationManager = AQAdapter.aqAdapter.automationManager;
    	
			if (!am.isSynchronized(null)) {
				return false;
			}

			var container:UIComponent = null;
			if (containerValue != null) {
				container = MonkeyUtils.findComponentWith(containerValue, containerProp); 
			}

			var target:IAutomationObject = MonkeyUtils.findComponentWith(value, prop, container);
			
			Assert.assertNotNull(target,"Unable to find component having " + prop + " = " + value);

	        if (!target || !am.isSynchronized(target))
				return false;

            if (!am.isVisible(target as DisplayObject))
				return false;

    	
        	AQAdapter.aqAdapter.run(target, 
	        						command, 
	        						args);
			return true;
		}
		
		/**
		 * Registers a verification function for a TestCase. Function will be called after commands have been run.
		 * @param test the TestCase 	
		 * @param func the function to call after commands have been run
		 * @param timeOut Maximum time to wait for the commands to run
		 */ 
		public function addVerifier(test:TestCase, func:Function, timeOut:int=10000):void {
			addEventListener(MonkeyEvent.READY_FOR_VALIDATION, test.addAsync(func, timeOut));
		}


	}	

}