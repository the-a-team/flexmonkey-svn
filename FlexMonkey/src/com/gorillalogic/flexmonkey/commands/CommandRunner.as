package com.gorillalogic.flexmonkey.commands
{
	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.core.MonkeyEvent;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	
	[Event(name="readyForValidation", type="com.gorillalogic.MonkeyEvent")]
	[Event(name="error", type="com.gorillalogic.MonkeyEvent")]	
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
			
			if (target == null) {
				dispatchEvent(new MonkeyEvent(MonkeyEvent.ERROR, false, false, "Unable to find component having " + prop + " = " + value));
			}
			
	        if (!target || !am.isSynchronized(target))
				return false;

            if (!am.isVisible(target as DisplayObject))
				return false;

    	
        	AQAdapter.aqAdapter.run(target, 
	        						command, 
	        						args);
			return true;
		}



	}	

}