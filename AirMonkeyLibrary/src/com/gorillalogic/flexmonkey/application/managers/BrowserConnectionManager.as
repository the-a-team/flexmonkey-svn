package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.utilities.MonkeyConnection;
	import flash.events.IEventDispatcher;

	import com.gorillalogic.flexmonkey.application.VOs.FlashVarVO;
	import com.gorillalogic.flexmonkey.application.events.RecorderEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;	
	
	public class BrowserConnectionManager extends MonkeyConnection
	{
		
		public var mateDispatcher : IEventDispatcher;			

		static private var _browserConnection:BrowserConnectionManager;
		static public function get browserConnection():BrowserConnectionManager{
			return _browserConnection;
		}
		static public function setClassReference(b:BrowserConnectionManager):void{
			_browserConnection = b;		
		}	
		public function setSingleton():void{
			BrowserConnectionManager.setClassReference(this);
		}

		private var _useBrowser:Boolean = false;
		public function get useBrowser():Boolean{
			return _useBrowser;
		}
		public function set useBrowser(u:Boolean):void{
			_useBrowser = u;
			if(u && targetSWFURL != "" && targetSWFURL != null){
				pingTXTimer.start();
			}else{
				setConnected(false);
				pingTXTimer.stop();				
			}	
		}
		
		public function needInit(txCount:uint):void{
			sendAck(txCount);
			initAgent();
		}
		
		override public function disconnect():void{
			agentInitialized = false;
			super.disconnect();
		}		
		
		override public function sendDisconnect():void{
			super.sendDisconnect();
			agentInitialized = false;
		}
		
		public function BrowserConnectionManager()
		{
			super();
			transmitToName = "_agent";
			writeConsole = function(message:String):void{
				trace(message);
			}
			agentInitialized = false;
		}

		//  receive methods ---------------------------------------------------------------------------	

		public function targetSWFReady(txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);
			writeConsole("BrowserConnection: Target SWF ready in Browser");
		}
		
		
		private var newUIEventTXCount:uint=0;
		
		public function newUIEvent(ba:ByteArray, txCount:uint):void{						
			sendAck(txCount);
			rxAlive = true;	
			if(newUIEventTXCount == txCount){
				return;
			}
			newUIEventTXCount=txCount;
			sendAck(txCount);
			var uiEventMonkeyCommand:UIEventMonkeyCommand = ba.readObject();
			writeConsole("BrowserConnection: New UI Event");
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_UI_EVENT,uiEventMonkeyCommand));		
		}

		public function newSnapshot(ba:ByteArray, txCount:uint):void{
			rxAlive = true;	
			sendAck(txCount);	
			var uiEventMonkeyCommand:UIEventMonkeyCommand = ba.readObject();
			writeConsole("BrowserConnection: New Snapshot");			
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_SNAPSHOT,uiEventMonkeyCommand));
		}		
		
		private var targetVOByteArray:ByteArray;
		public function newTarget(ba:ByteArray,status:String, txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);
			var o:Object;
			var f:Function;
			switch(status){
				case "single":
					writeConsole("BrowserConnection: got single");				
					o = ba.readObject();
					f = callBackArray.shift();
					f(o);
					break;
				case "start":
					writeConsole("BrowserConnection: got start");
					targetVOByteArray = new ByteArray();
					ba.readBytes(targetVOByteArray);					
					break;
				case "body":
					writeConsole("BrowserConnection: got body");
					ba.readBytes(targetVOByteArray,targetVOByteArray.length);				
					break;
				case "end":
					writeConsole("BrowserConnection: got end");
					ba.readBytes(targetVOByteArray,targetVOByteArray.length);
					o = targetVOByteArray.readObject();
					f = callBackArray.shift();
					f(o); 			
					break;
			}
		}
		 
		public function agentRunDone(ba:ByteArray, txCount:uint):void{
			rxAlive = true;
			sendAck(txCount);			
			writeConsole("BrowserConnection: Agent Done");			
			var monkeyRunnable:MonkeyRunnable = ba.readObject();
			currentRunnerEngine.agentRunDone(monkeyRunnable);
		}		
			
		// send methods ---------------------------------------------------------------------------	

		private var recordingActive:Boolean = false;			

		private var _targetSWFURL:String;
		public function get targetSWFURL():String{
			return _targetSWFURL;
		}
		public function set targetSWFURL(url:String):void{
			_targetSWFURL = url;
			if(useBrowser && targetSWFURL != "" && targetSWFURL != null){
				pingTXTimer.start();				
			}
		}

		private var _targetSWFWidth:uint;
		public function get targetSWFWidth():uint{
			return _targetSWFWidth;
		}
		public function set targetSWFWidth(w:uint):void{
			_targetSWFWidth = w;
			if(agentInitialized){
				send(new TXVO("_agent", "setTargetSWFWidth", [w]));	
			}
		}

		private var _targetSWFHeight:uint;
		public function get targetSWFHeight():uint{
			return _targetSWFHeight;
		}
		public function set targetSWFHeight(h:uint):void{
			_targetSWFHeight = h;
			if(agentInitialized){
				send(new TXVO("_agent", "setTargetSWFHeight", [h]));
			}
		}

		private var _flashVars:ArrayCollection;
		public function get flashVars():ArrayCollection{
			return _flashVars;
		}
		public function set flashVars(fv:ArrayCollection):void{
			_flashVars = fv;
		}

		private var agentInitialized:Boolean = false;
		private function initAgent():void{
			for each(var flashVar:FlashVarVO in flashVars){
				send(new TXVO("_agent", "setFlashVar", [flashVar.name, flashVar.value]));	
			}				
			send(new TXVO("_agent", "setTargetSWFWidth", [targetSWFWidth]));
			send(new TXVO("_agent", "setTargetSWFHeight", [targetSWFHeight]));
			send(new TXVO("_agent", "setTargetSWFURL", [targetSWFURL]));
			agentInitialized = true;				
		}
	
		public function startRecording():void{
			send(new TXVO("_agent", "startRecording"));
			recordingActive = true;		
		}
		public function stopRecording():void{
			send(new TXVO("_agent", "stopRecording"));
			recordingActive = false;		
		}	
		public function takeSnapshot():void{
			send(new TXVO("_agent", "takeSnapshot"));
		}
		
		private var currentRunnerEngine:MonkeyRunnerEngine;
		public function runCommand(c:UIEventMonkeyCommand,e:MonkeyRunnerEngine):void{
			currentRunnerEngine = e;
			var clone:UIEventMonkeyCommand = c.clone();
			clone.parent = null;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(clone);
			writeConsole("BrowserConnection: runCommand length: " + ba.length);			
			send(new TXVO("_agent", "runCommand", [ba]));
		}
				
		private var callBackArray:Array = [];
		public function getTarget(verifyMonkeyCommand:VerifyMonkeyCommand,callBack:Function):void{
			callBackArray.push(callBack);
			var ba:ByteArray = new ByteArray();
			var clone:VerifyMonkeyCommand = verifyMonkeyCommand.clone();
			clone.parent = null;
			ba.writeObject(clone);

			ba.position = 0;
			var bufferSize:uint = 40000;
			
			if(ba.bytesAvailable < bufferSize){
				send(new TXVO("_agent", "getTarget", [ba, "single"]));
				writeConsole("BrowserConnection: sent single");				
			}else{				
				var buffer:ByteArray = new ByteArray();
				ba.readBytes(buffer,0,bufferSize);
				send(new TXVO("_agent", "getTarget", [buffer, "start"]));
				writeConsole("BrowserConnection: sent start");								
				while(ba.bytesAvailable >= bufferSize){
					buffer = new ByteArray();
					ba.readBytes(buffer,0,bufferSize);
					send(new TXVO("_agent", "getTarget", [buffer, "body"]));
					writeConsole("BrowserConnection: sent body");													
				}
				if(ba.bytesAvailable > 0){
					buffer = new ByteArray();
					ba.readBytes(buffer);
					send(new TXVO("_agent", "getTarget", [buffer, "end"]));
					writeConsole("BrowserConnection: sent end");																		
				}
			}			
		}				
	}
}