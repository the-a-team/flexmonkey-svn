/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.VOs.FlashVarVO;
	import com.gorillalogic.flexmonkey.application.events.RecorderEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.monkeyCommands.MonkeyRunnerEngine;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	public class BrowserConnectionManager extends EventDispatcher
	{
		import flash.net.LocalConnection;
		import flash.events.StatusEvent;


import flash.net.Socket;
import flash.events.*;
import flash.errors.*;


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
		

// ============================================================================================	

		private var pingRXTimer:Timer;
		private var pingTXTimer:Timer;
		private var rxConnection:LocalConnection;
		private var txConnection:LocalConnection;
		private var txCount:uint = 1;
		private var rxCount:uint = 1;
		
		private var _connected:Boolean = false;
		[Bindable ("connectedChanged")] 
		public function get connected():Boolean{
			return _connected;
		}
		public function setConnected(c:Boolean):void{
			_connected = c;
			this.dispatchEvent(new Event("connectedChanged"));
			if(_connected){
				writeConsole("BrowserConnection: Connected and timing");
				pingRXTimer.start();
				agentAlive = true;					
			}else{
				writeConsole("BrowserConnection: Disconnected");				
				pingRXTimer.stop();
				if(recordingActive){
					stopRecording();
				}
				agentAlive = false;	
				try{
					rxConnection.close();
				}catch(error:ArgumentError){
					writeConsole("BrowserConnection: Error closing rxConnection");					
				}
				initializeRXChannel();			
			}
		}
		
		public function needInit(txCount:uint):void{
			sendAck(txCount);
			initAgent();
		}
/*
		public function connectUp():void{
			writeConsole("BrowserConnection: agent connected");
			sendAck();
			setConnected(true);
			agentAlive = true;
		}	
*/
		public function ack(count:uint):void{
			if(!connected){
				setConnected(true);
			}	
			agentAlive = true;
			if(txQueue.length>0 && txQueue[0].txCount==count){
				txQueue.shift();
				pingCount=0;
				if(txQueue.length>0){	
					coreSend(txQueue[0]);
				}	
			}		
			writeConsole("BrowserConnection: agent ack'd w txQueue.length=" + txQueue.length + " and txCount=" + count);			
		}	
				
		public function disconnect():void{
			writeConsole("BrowserConnection: agent Disconnected"); 
			agentInitialized = false;	
			txQueue = [];			
			setConnected(false);
		}
		
		private var _agentAlive:Boolean = false;
		private function get agentAlive():Boolean{
			return _agentAlive;
		}
		private function set agentAlive(a:Boolean):void{
			_agentAlive = a;
			if(_agentAlive){
				if(!connected){
					setConnected(true);
				}
			}
		}
		
		public function ping():void{
			if(!connected){
				setConnected(true);
			}else{
				agentAlive = true;
			}	
		}
		public function initializeRXChannel():void{
			// Channels are named for their listener			
			rxConnection = new LocalConnection();
			rxConnection.allowDomain('*')
			rxConnection.client = this;
			try{
				rxConnection.connect("_FlexMonkey");
			}catch(error:ArgumentError){
				writeConsole("BrowserConnection: could not connect to RX channel");
			}			
		}
		
		public function initializeTXChannel():void{
			txConnection = new LocalConnection();
			txConnection.addEventListener(StatusEvent.STATUS, txStatusEventHandler);
			txConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);			
			txConnection.addEventListener(IOErrorEvent.IO_ERROR,IOErrorHandler);								
		}
		
		private function pingRXHandler(event:TimerEvent):void{
			if(agentAlive){
				agentAlive = false;
			}else{
				writeConsole("BrowserConnection: agent Disconnected (ping timeout)"); 
				setConnected(false);
			}
		}

		private function pingTXHandler(event:TimerEvent):void{
     		send(new TXVO("_agent", "ping"));
		}

		private function txStatusEventHandler(event:StatusEvent):void{
			switch(event.level){
				case "status":
					break;
				case "error":
//					writeConsole("BrowserConnection: Send failed");
					if(connected){
						setConnected(false);
					}
					break;
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void{
			writeConsole("BrowserConnection: AsyncErrorEvent");
		}

		private function IOErrorHandler(event:IOErrorEvent):void{
			writeConsole("BrowserConnection: IOErrorEvent");
		}

		private var txQueue:Array = [];

		private var pingCount:uint = 0;
		private var resendPingCount:uint = 2;
		
		private function send(txVO:TXVO):void{
			if( txVO.method == "ping" ||
			    txVO.method == "ack"  ||
			    txVO.method == "disconnect"){
				if(txVO.method == "ping" || txVO.method == "disconnect"){
					txConnection.send(txVO.channel, txVO.method);
				}else{
					txConnection.send(txVO.channel, txVO.method, txVO.arguments[0]);
				}
				if(txVO.method == "ping"){
					if(txQueue.length != 0){
						pingCount++;
						if(!(pingCount<resendPingCount)){
							coreSend(txQueue[0]);
							pingCount=0;	
						}	
					}else{
						pingCount = 0;
					}
				}
				return;
			}
			txQueue.push(txVO);
			if(txQueue.length < 2){
				coreSend(txVO);
			}
		}
		
		private function coreSend(txVO:TXVO):void{
			if(connected){
				if(txVO.txCount == 0){
					txCount++;
					txVO.txCount = txCount;	
				}	
				try{
					if(txVO.arguments != null){
						switch(txVO.arguments.length){
							case 0:
								writeConsole("send method received empty arguments");
							case 1:
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[0], txVO.txCount);
								break;
							case 2:
								txConnection.send(txVO.channel, txVO.method, txVO.arguments[0], txVO.arguments[1], txVO.txCount);
								break;
							default:
								writeConsole("send method received too many arguments");
						}					
					}else{
						txConnection.send(txVO.channel, txVO.method, txVO.txCount);
					}
				}catch(e:Error){
					writeConsole("Could not send " + txVO.method);	
					return;											
				}
				writeConsole("Sending " + txVO.method + " to " + txVO.channel + " w/TXCount=" + txVO.txCount);			
			}			
		}				
		
//		private function sendConnect():void{
//			send(new TXVO("_agent", "connectUp"));
//		}	
		public function sendDisconnect():void{
			send(new TXVO("_agent", "disconnect"));	
			txQueue = [];						
			agentInitialized = false;							
		}						
		private function sendAck(count:uint):void{
			send(new TXVO("_agent", "ack", [count]));
		}
		
		private function writeConsole(m:String):void{
			trace(m);			
		}		
		
// ============================================================================================	
private var socket:Socket;		
		public function BrowserConnectionManager(target:IEventDispatcher=null)
		{
			super(target);
			// set up RX Channel listen 
			initializeRXChannel();
			// set up TX channel and announce
			initializeTXChannel();

			pingRXTimer = new Timer(1000,0);
			pingRXTimer.addEventListener(TimerEvent.TIMER, pingRXHandler, false, 0, true);	
			
			pingTXTimer = new Timer(500,0);
			pingTXTimer.addEventListener(TimerEvent.TIMER, pingTXHandler, false, 0, true);
			
			agentInitialized = false;	
/*			
socket = new Socket();
configureSocketListeners();	
socket.timeout = 2000;
socket.connect("localhost",843);
*/	
		}		

/*
private function configureSocketListeners():void{
    socket.addEventListener(Event.CLOSE, socketCloseHandler);
    socket.addEventListener(Event.CONNECT, socketConnectHandler);
    socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler);
    socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
    socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);	
}
private function socketCloseHandler(event:Event):void {
	trace("close");
}

private function socketConnectHandler(event:Event):void {
	trace("connect");
}

private function socketIOErrorHandler(event:IOErrorEvent):void {
	trace("ioerror");
}

private function socketSecurityErrorHandler(event:SecurityErrorEvent):void {
	trace("yikes");
}

private function socketDataHandler(event:ProgressEvent):void {
	trace("data");
}
*/

		//  receive methods ---------------------------------------------------------------------------	

		public function targetSWFReady(txCount:uint):void{
			agentAlive = true;
			sendAck(txCount);
			writeConsole("BrowserConnection: Target SWF ready in Browser");
		}
		
		
		private var newUIEventTXCount:uint=0;
		
		public function newUIEvent(ba:ByteArray, txCount:uint):void{						
			sendAck(txCount);
			agentAlive = true;	
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
			agentAlive = true;	
			sendAck(txCount);	
			var uiEventMonkeyCommand:UIEventMonkeyCommand = ba.readObject();
			writeConsole("BrowserConnection: New Snapshot");			
			mateDispatcher.dispatchEvent(new RecorderEvent(RecorderEvent.NEW_SNAPSHOT,uiEventMonkeyCommand));
		}		
		
		private var targetVOByteArray:ByteArray;
		public function newTarget(ba:ByteArray,status:String, txCount:uint):void{
			agentAlive = true;
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
			agentAlive = true;
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