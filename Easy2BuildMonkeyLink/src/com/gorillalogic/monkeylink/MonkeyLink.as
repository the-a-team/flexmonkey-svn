package com.gorillalogic.monkeylink
{	
	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.application.UI.viewComponents.SnapshotOverlay;
	import com.gorillalogic.flexmonkey.application.VOs.SnapshotVO;
	import com.gorillalogic.flexmonkey.application.VOs.TargetVO;
	import com.gorillalogic.flexmonkey.application.utilities.AttributeFinder;
	import com.gorillalogic.flexmonkey.application.utilities.MonkeyConnection;
	import com.gorillalogic.flexmonkey.core.MonkeyAutomationState;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationRecordEvent;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	
	[Mixin]
	public class MonkeyLink extends MonkeyConnection
	{
		public static const monkeyLink:MonkeyLink = new MonkeyLink();
		
		private static var root:DisplayObject;
		
		public static function init(root:DisplayObject):void {
			MonkeyLink.root = root;
			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, function():void {
				MonkeyLink.monkeyLink.startLink();
			});			
		}				
		
		public function MonkeyLink()
		{
			super();
			txChannelName = "_flexMonkey";
			rxChannelName = "_agent";
			writeConsole = function(message:String):void{trace(message)};
		}
		
		private var targetSWFURL:String;
		[Bindable] private var targetSWFWidth:uint = 600;
		[Bindable] private var targetSWFHeight:uint = 400;		
		
		
// ============================================================================================	

		override public function disconnect():void{
			super.disconnect();
			reloadAgent();
		}

		override public function initializeRXChannel():void{
			initializeRXChannel0();
// This next line will need to change with each new release version...			
			rxConnection.allowInsecureDomain("app#com.gorillalogic.FlexMonkey.FAF8CB444E71DE51EAFD06DD0331CF35731C3B7D.1"); 			
			initializeRXChannel1();
		}
// ============================================================================================		
		private function sendNeedInit():void{
			send(new TXVO("_flexMonkey", "needInit"));
		}
		private var needInit:Boolean;

		private function startLink():void{		
			startConnection();	
			Automation.automationManager.addEventListener(AutomationRecordEvent.RECORD, recordEventHandler, false, 0, true);  	
			pingTXTimer.start();

			try{
//				ExternalInterface.addCallback("sendDisconnect", sendDisconnect);
			}catch(e:Error){
				writeConsole("Could not add disconnect callback to container");
			}	

//			Application(SystemManager(MonkeyLink.root).application).addChild(snapshotOverlay);
			SystemManager(MonkeyLink.root).addChildToSandboxRoot("toolTipChildren",snapshotOverlay);

			MonkeyAutomationState.monkeyAutomationState.graphics = snapshotOverlay.graphics;
			MonkeyAutomationState.monkeyAutomationState.conversionPlatform = snapshotOverlay;
//trace("go link");			
		}
		
		public function reloadAgent():void{
//			if(ExternalInterface.available){
//				ExternalInterface.call("reloadAgent");
//			}else{
//				writeConsole("ExternalInterface not available on reload");
//			}
		}		

		//  receive methods ---------------------------------------------------------------------------	

		public function setFlashVar(parmName:String, parmValue:String, txCount:uint):void{
			sendAck(txCount);
//			Application.application.parameters[parmName] = parmValue;	
		}

		public function setTargetSWFURL(url:String,txCount:uint):void{
			sendAck(txCount);
			if(needInit){
				needInit = false;
			}
			if(url != targetSWFURL){	
				targetSWFURL = url;
//				loadTargetSWF();
			}				
			writeConsole("Received Target SWF URL: " + url);
		}
		public function setTargetSWFWidth(w:uint,txCount:uint):void{
			sendAck(txCount);			
			writeConsole("Received Target SWF Width: " + w);
			targetSWFWidth = w;
		}
		public function setTargetSWFHeight(h:uint,txCount:uint):void{
			sendAck(txCount);			
			writeConsole("Received Target SWF Height: " + h);			
			targetSWFHeight = h;
		}		

		private var snapshotOverlay:SnapshotOverlay = new SnapshotOverlay();
		
		public function startRecording(txCount:uint):void{
			sendAck(txCount);			
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.NORMAL;
			AQAdapter.aqAdapter.beginRecording();	
			writeConsole("Start recording");
		}
		
		public function stopRecording(txCount:uint):void{
			sendAck(txCount);			
			var recordEnd:Object = AQAdapter.aqAdapter.endRecording();
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
			writeConsole("Stop recording");			
		}
		
		public function takeSnapshot(txCount:uint):void{
			sendAck(txCount);			
			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.SNAPSHOT;						
			AQAdapter.aqAdapter.beginRecording();			
		}
			
		private var verifyMonkeyCommandByteArray:ByteArray;
		private var getTargetTXCount:uint=0;

		public function getTarget(ba:ByteArray,status:String,txCount:uint):void{
			sendAck(txCount);
			rxAlive=true;
			if(getTargetTXCount == txCount){
				return
			}			
			getTargetTXCount = txCount;
			switch(status){
				case "single":
					writeConsole("getTarget single");
					returnTarget(ba);
					break;
				case "start":
					writeConsole("getTarget start");				
					verifyMonkeyCommandByteArray = new ByteArray();
					ba.readBytes(verifyMonkeyCommandByteArray);
					break;
				case "body":
					writeConsole("getTarget body");								
					ba.readBytes(verifyMonkeyCommandByteArray,verifyMonkeyCommandByteArray.length);
					break;
				case "end":
					writeConsole("getTarget end");								
					ba.readBytes(verifyMonkeyCommandByteArray,verifyMonkeyCommandByteArray.length);
					returnTarget(ba);
					break;
			}
		}

		private var runCommandTXCount:uint=0;

        public function runCommand(commandByteArray:ByteArray,txCount:uint):void{      	
       	    sendAck(txCount);
       	    rxAlive=true;
       	    if(runCommandTXCount == txCount){
       	    	return;
       	    }     	    
       	    runCommandTXCount = txCount;
  			// deserialize the command
  			try{        	
        		var command:MonkeyRunnable = commandByteArray.readObject() as MonkeyRunnable;	
     		}catch(error:Error){
trace("Now its caught!");     			
     		}
        	
 			writeConsole("runCommand executed command " 
 				+ ((command is UIEventMonkeyCommand)?UIEventMonkeyCommand(command).command:"non-UIEventMonkeyCommand")
 				+ " "
 				+ ((command is UIEventMonkeyCommand)?UIEventMonkeyCommand(command).value:"")
 			);
        	
			// run the command: 
 			if(command is UIEventMonkeyCommand){
 				UIEventMonkeyCommand(command).execute1();
 			}else if(command is VerifyMonkeyCommand){
//				VerifyMonkeyCommand(command).??? 				
 			}else{
 				writeConsole("runCommand could not execute command");
 			}
 				
			// send the completed command back to the monkey here:
     		var returnCommandByteArray:ByteArray = new ByteArray();
     		returnCommandByteArray.writeObject(command);
     		send(new TXVO("_flexMonkey", "agentRunDone", [returnCommandByteArray]));
     		writeConsole("runCommand sent agentRunDone on " 
     			+ ((command is UIEventMonkeyCommand)?UIEventMonkeyCommand(command).command:"non-UIEventMonkeyCommand")
     			+ " "
 				+ ((command is UIEventMonkeyCommand)?UIEventMonkeyCommand(command).value:"")
      		);
        }	
					
		//  send methods ---------------------------------------------------------------------------	

		public function recordEventHandler(event:AutomationRecordEvent):void {
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
			var byteArray:ByteArray = new ByteArray();
			uiEventCommand.value = id;
			uiEventCommand.prop = idProp;
			uiEventCommand.command = event.name;
			uiEventCommand.args = event.args;
			byteArray.writeObject(uiEventCommand);
			switch(MonkeyAutomationState.monkeyAutomationState.state){
				case MonkeyAutomationState.NORMAL:
writeConsole("Sending RecordEvent when AutomationState NORMAL");				
					send(new TXVO("_flexMonkey", "newUIEvent", [byteArray]));
					break;
				case MonkeyAutomationState.SNAPSHOT:
					send(new TXVO("_flexMonkey", "newSnapshot", [byteArray]));					
		  			var snapEnd:Object = AQAdapter.aqAdapter.endRecording();	
		  			MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;				
	 				break;
				default:
					break;
			}
        }  			
 	
		private var attributeFinder:AttributeFinder = new AttributeFinder();        		
        private function returnTarget(verifyMonkeyCommandByteArray:ByteArray):void{
		    writeConsole("returnTarget method invoked");
        	var verifyMonkeyCommand:VerifyMonkeyCommand = verifyMonkeyCommandByteArray.readObject();
		    var target:UIComponent = null;				
			var container:UIComponent = null;
			if (verifyMonkeyCommand.containerValue != null && verifyMonkeyCommand.containerValue != "" && verifyMonkeyCommand.containerValue != "null") {
				container = MonkeyUtils.findComponentWith(verifyMonkeyCommand.containerValue, verifyMonkeyCommand.containerProp); 
			}
			target = MonkeyUtils.findComponentWith(verifyMonkeyCommand.value, verifyMonkeyCommand.prop, container); 
			var propertyArray:Array;
			var styleArray:Array;
			var snapshotVO:SnapshotVO;
			if(target == null){
				writeConsole("returnTarget returned null");
			}else{
				writeConsole("returnTarget returned valid target");	
				propertyArray = attributeFinder.getProperties(target).source;
				styleArray = attributeFinder.getStyles(target).source;			
				var bitmapData:BitmapData = new BitmapData(target.width,target.height);
				bitmapData.draw(target);		
				snapshotVO = new SnapshotVO();	
				snapshotVO.bitmapData = bitmapData;		
			}
			
			var targetVO:TargetVO = new TargetVO(propertyArray, styleArray, snapshotVO);	
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(targetVO);
			writeConsole("TargetVO length: " + ba.length);
			ba.position = 0;
			var bufferSize:uint = 40000;
			
			if(ba.bytesAvailable < bufferSize){
				send(new TXVO("_flexMonkey", "newTarget", [ba, "single"]));
				writeConsole("Sent Single: " + ba.length + " bytes of TargetVO");
			}else{				
				var buffer:ByteArray = new ByteArray();
				ba.readBytes(buffer,0,bufferSize);
				send(new TXVO("_flexMonkey", "newTarget", [buffer, "start"]));
				writeConsole("Sent Start: " + buffer.length + " bytes of TargetVO");				
				while(ba.bytesAvailable >= bufferSize){
					buffer = new ByteArray();
					ba.readBytes(buffer,0,bufferSize);
					send(new TXVO("_flexMonkey", "newTarget", [buffer, "body"]));
					writeConsole("Sent Body: " + buffer.length + " bytes of TargetVO");
				}
				if(ba.bytesAvailable > 0){
					buffer = new ByteArray();
					ba.readBytes(buffer);
					send(new TXVO("_flexMonkey", "newTarget", [buffer, "end"])); 					
					writeConsole("Sent End: " + buffer.length + " bytes of TargetVO");					
				}
			}	
        }
	}
}