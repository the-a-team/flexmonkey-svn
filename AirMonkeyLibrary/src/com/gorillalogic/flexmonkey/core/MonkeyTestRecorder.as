/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.application.events.RecorderEvent;
	import com.gorillalogic.flexmonkey.application.managers.BrowserConnectionManager;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationRecordEvent;
	import mx.core.UIComponent;
	
	public class MonkeyTestRecorder extends EventDispatcher
	{
		public var mateDispatcher:IEventDispatcher;
		
		public var browserConnection:BrowserConnectionManager;
						
		public function MonkeyTestRecorder()
		{
			Automation.automationManager.addEventListener(AutomationRecordEvent.RECORD, recordEventHandler, false, 0, true);  
		}
		
		public function startRecording():void{
			if(browserConnection.useBrowser && browserConnection.connected){
				browserConnection.startRecording();
			}else{
				MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.NORMAL;
				AQAdapter.aqAdapter.beginRecording();
			}
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.RECORDER_STARTED));
		}
		
		public function stopRecording():void{
			if(browserConnection.useBrowser && browserConnection.connected){
				browserConnection.stopRecording();
			}else{			
				var recordEnd:Object = AQAdapter.aqAdapter.endRecording();
			}
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
			takingSnapshot = false;
		}
		
		[Bindable] public var takingSnapshot:Boolean = false;
		public function takeSnapshot():void{
			takingSnapshot = true;
			if(browserConnection.useBrowser && browserConnection.connected){
				browserConnection.takeSnapshot();
			}else{
				MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.SNAPSHOT;
				AQAdapter.aqAdapter.beginRecording();
			}		
		}		
		
		public function snapshotTaken():void{
			takingSnapshot = false;
		}
		
		public function recordEventHandler(event:AutomationRecordEvent):void {
trace("AirMonkey recordEventHandler");
			var id:String;
			var idProp:String;
			var obj:IAutomationObject = event.automationObject;
				var container:UIComponent = null;	

			if (obj.automationName != null && obj.automationName != "") {
				idProp = "automationName"
				id = obj.automationName;
			} else if (obj is UIComponent && UIComponent(obj).id != null && UIComponent(obj).id != "") {
				idProp = "id";
				id = UIComponent(obj).id;
			} else {
				idProp = "automationID";
				id = Automation.automationManager.createID(obj).toString();
			}
			var uiEventCommand:UIEventMonkeyCommand = new UIEventMonkeyCommand();
			uiEventCommand.value = id;
			uiEventCommand.prop = idProp;
			uiEventCommand.command = event.name;
			uiEventCommand.args = event.args;
			switch(MonkeyAutomationState.monkeyAutomationState.state){
				case MonkeyAutomationState.NORMAL:
					mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_UI_EVENT,uiEventCommand));
					break;
				case MonkeyAutomationState.SNAPSHOT:
					mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_SNAPSHOT,uiEventCommand));
		  			var snapEnd:Object = AQAdapter.aqAdapter.endRecording();	
		  			takingSnapshot = false;
		  			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;				
	 				break;
				default:
					break;
			}
        }  		
	}
}