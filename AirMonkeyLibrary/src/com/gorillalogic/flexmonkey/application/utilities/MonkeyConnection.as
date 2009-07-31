package com.gorillalogic.flexmonkey.application.utilities
{
	import com.gorillalogic.monkeyAgent.VOs.TXVO;
	
	import flash.display.DisplayObject;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.utils.Timer;
	
	public class MonkeyConnection extends EventDispatcher
	{
		public function MonkeyConnection(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		protected function startConnection():void{
			// set up RX Channel listen 
			initializeRXChannel();
			// set up TX channel and announce
			initializeTXChannel();

			pingRXTimer = new Timer(1000,0);
			pingRXTimer.addEventListener(TimerEvent.TIMER, pingRXHandler, false, 0, true);	
			
			pingTXTimer = new Timer(500,0);
			pingTXTimer.addEventListener(TimerEvent.TIMER, pingTXHandler, false, 0, true);			
		}

		protected var txChannelName:String;
		protected var rxChannelName:String;
		protected var writeConsole:Function;		

		protected var pingTXTimer:Timer;
		protected var txConnection:LocalConnection;
		private var txCount:uint = 1;

		protected var pingRXTimer:Timer;
		protected var rxConnection:LocalConnection;
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
				writeConsole("Connected and timing");
				pingRXTimer.start();
				rxAlive = true;					
			}else{
				writeConsole("Disconnected");				
				pingRXTimer.stop();
				rxAlive = false;	
				try{
					rxConnection.close();
				}catch(error:ArgumentError){
					writeConsole("Error closing rxConnection");					
				}
				initializeRXChannel();			
			}
		}
		
		public function ack(count:uint):void{
			if(!connected){
				setConnected(true);
			}	
			rxAlive = true;
			if(txQueue.length>0 && txQueue[0].txCount==count){
				txQueue.shift();
				pingCount=0;
				if(txQueue.length>0){	
					coreSend(txQueue[0]);
				}	
			}		
			writeConsole(txChannelName + " ack'd w txQueue.length=" + txQueue.length + " and txCount=" + count);			
		}	
				
		public function disconnect():void{
			writeConsole(txChannelName + ":Disconnected"); 
			txQueue = [];			
			setConnected(false);
		}
		
		private var _rxAlive:Boolean = false;
		protected function get rxAlive():Boolean{
			return _rxAlive;
		}
		protected function set rxAlive(a:Boolean):void{
			_rxAlive = a;
			if(_rxAlive){
				if(!connected){
					setConnected(true);
				}
			}
		}
		
		public function ping():void{
			if(!connected){
				setConnected(true);
			}else{
				rxAlive = true;  
			}	
		}
		public function initializeRXChannel():void{
			initializeRXChannel0();
			initializeRXChannel1();
		}
		
		protected function initializeRXChannel0():void{
			// Channels are named for their listener			
			rxConnection = new LocalConnection();
			rxConnection.allowDomain('*')
			rxConnection.client = this;			
		}
		protected function initializeRXChannel1():void{
			try{
				rxConnection.connect(rxChannelName);
			}catch(error:ArgumentError){
				writeConsole("Could not connect to RX channel");
			}				
		}
		
		public function initializeTXChannel():void{
			txConnection = new LocalConnection();
			txConnection.addEventListener(StatusEvent.STATUS, txStatusEventHandler);
			txConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);			
			txConnection.addEventListener(IOErrorEvent.IO_ERROR,IOErrorHandler);								
		}
		
		protected function pingRXHandler(event:TimerEvent):void{
			if(rxAlive){
				rxAlive = false;
			}else{
				writeConsole("RX Disconnected (ping timeout)"); 
				setConnected(false);
			}
		}

		protected function pingTXHandler(event:TimerEvent):void{
     		send(new TXVO(txChannelName, "ping"));
		}

		private function txStatusEventHandler(event:StatusEvent):void{
			switch(event.level){
				case "status":
					break;
				case "error":
					if(connected){
						setConnected(false);
					}
					break;
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void{
			writeConsole("AsyncErrorEvent");
		}

		private function IOErrorHandler(event:IOErrorEvent):void{
			writeConsole("IOErrorEvent");
		}

		private var txQueue:Array = [];

		private var pingCount:uint = 0;
		private var resendPingCount:uint = 2;
		
		protected function send(txVO:TXVO):void{
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
		
		public function sendDisconnect():void{
			send(new TXVO(txChannelName, "disconnect"));	
			txQueue = [];						
		}						
		protected function sendAck(count:uint):void{
			send(new TXVO(txChannelName, "ack", [count]));
		}
		
		
			
	}
}