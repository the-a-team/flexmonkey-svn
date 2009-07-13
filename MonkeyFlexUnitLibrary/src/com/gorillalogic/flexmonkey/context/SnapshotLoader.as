/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.context
{
	import com.gorillalogic.flexmonkey.application.VOs.SnapshotVO;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import mx.controls.Alert;
	

	public class SnapshotLoader implements ISnapshotLoader
	{
		private var verifyCommand:VerifyMonkeyCommand;
		private var snapshotDirURL:String;
		private var snapshotFileURL:String;
		private var snapshotUrlStream:URLStream;
		
		private var snapshotLoader:URLLoader;
				
		public function SnapshotLoader(snapshotDirURL:String)
		{
			this.snapshotDirURL = snapshotDirURL;
		}				
		public function getSnapshot(name:String,verifyCommand:VerifyMonkeyCommand):void{
			this.verifyCommand = verifyCommand;
			snapshotFileURL = snapshotDirURL + "/" + name;
			
			var urlRequest:URLRequest = new URLRequest(snapshotFileURL);
			snapshotLoader = new URLLoader();
			snapshotLoader.dataFormat = URLLoaderDataFormat.BINARY;
			snapshotLoader.addEventListener(Event.COMPLETE,urlStreamCompleteHandler,false,0,true);
			snapshotLoader.addEventListener(IOErrorEvent.IO_ERROR,urlStreamIOErrorHandler,false,0,true);
			snapshotLoader.load(urlRequest);
		}
		
		
		private function urlStreamCompleteHandler(event:Event):void{
			var snap:SnapshotVO = event.target.data.readObject();
			
			verifyCommand.expectedSnapshot = snap;	
		}
		
		
		private function urlStreamIOErrorHandler(event:IOErrorEvent):void{
			Alert.show("Could not load snapshot " + snapshotFileURL);
		}
	}
}