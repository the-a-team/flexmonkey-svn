/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.events.MonkeyFileEvent;
	
	import flash.desktop.NativeApplication;
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Timer;
	
	import com.gorillalogic.flexmonkey.application.events.AlertEvent;
	
	//TODO: use monkey alerts
	
	public class ApplicationManager extends EventDispatcher
	{
		public var mateDispatcher : IEventDispatcher;		
		public var browserConnection: BrowserConnectionManager2;
		
		public var monkeyTestFileDirty:Boolean = false;		

		//-- preferences ---------------------------------------------------------------------------
		private var _preferencesURL:String;
		public function get preferencesURL():String{
			return _preferencesURL;
		}
		public function set preferencesURL(url:String):void{
			_preferencesURL=url;
		}

		public function updateProjectURL(url:String):void{
			setProjectURL(url);

			preferencesXML.project.@url = url;
			savePreferences()
		}
		
		private var _preferencesXML:XML = <preferences/>;
		public function get preferencesXML():XML{
			return _preferencesXML;
		}
		public function setPreferencesXML(x:XML):void{
			_preferencesXML = x;
			var url:String = x.project.@url;
			if(url){
				setProjectURL(url);
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","Application Manager: Preferences File does not contain Project URL"));
			}
		}
		
		//-- project preferences -------------------------------------------------------------------
		private var _projectURL:String = "";
		[Bindable ("projectURLChanged")]
		public function get projectURL():String{
			return _projectURL;
		}
		private function setProjectURL(url:String):void{
			_projectURL = url;
			dispatchEvent(new Event("projectURLChanged"));			
		}
			
		//-- constructor ---------------------------------------------------------------------------
		public function ApplicationManager(target:IEventDispatcher=null)
		{
			super(target);
		}	
		
		public function readUserPreferences():void{
			if(preferencesURL == null || preferencesURL == ""){
				preferencesURL = File.userDirectory.url + "/flexMonkeyPreferences.xml"
			}
			
			var file:File;
			var fileStream:FileStream;
			try{
				file = new File(preferencesURL);
			}catch(error:ArgumentError){
				// this should never happen...;)
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Application Manager: Malformed Preferences File URL."));			
			}
			if(file.exists){
				fileStream = new FileStream();
				fileStream.addEventListener(IOErrorEvent.IO_ERROR,userPreferencesFileReadIOErrorHandler,false,0,true);
				fileStream.addEventListener(Event.COMPLETE,fileReadCompleteHandler,false,0,true);
				fileStream.openAsync(file,FileMode.READ);
			}else{
				//Alert.show("Application Manager: Preferences File does not exist for reading.");
				userPreferencesFileMissing();
			}
		}	
		
		private function userPreferencesFileReadIOErrorHandler(event:IOErrorEvent):void{
//			Alert.show("Application Manager: Could not open Preferences File for reading.");
			userPreferencesFileMissing();
		}

		private function userPreferencesFileMissing():void{
			mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.APPLICATION_PROMPT_FOR_NEW));
		}


		private function fileReadCompleteHandler(event:Event):void{
			var preferencesText:String;
			var fileStream:FileStream = event.target as FileStream;
			var bytesAvailable:uint=fileStream.bytesAvailable;
			try{
				preferencesText = fileStream.readUTFBytes(bytesAvailable);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","Application Manager: Could not read Preferences File."));	
			}catch(error:EOFError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","Application Manager: Attempt to read past end of Preferences File."));
			}finally{
				fileStream.close();
			}
			if(preferencesText != null){
				try{
					var xml:XML = new XML(preferencesText);
				}catch(error:Error){
					mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","Application Manager: Malformed XML in Preferences File."));
				}
				if(xml){
					setPreferencesXML(xml);
				}
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Application Manager: Preferences File empty."));	
			}
		}		
			
		private function savePreferences():void{
			var file:File;
			var fileStream:FileStream;
			var preferencesText:String;
			try{
				file = new File(preferencesURL);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","Application Manager: Malformed Preferences File URL."));	
				return;		
			}
			fileStream = new FileStream();
			try{
				fileStream.open(file,FileMode.WRITE);
			}catch(error:Error){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Application Manager: Could not open Preferences File for updating."));
				return; 
			}			
			XML.prettyPrinting = true;
			preferencesText = preferencesXML.toXMLString();
			try{	
				fileStream.writeUTFBytes(preferencesText);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","ApplicationManager: Could not update Preferences File"));
			}finally{
				fileStream.close();
			}				
		}
				
		private var exitImminent:Boolean = false;
		public function monkeyExit():void{
			exitImminent = true;
			if(monkeyTestFileDirty){
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.TEST_FILE_PROMPT_FOR_SAVE));
			}else{
				// calling exit immediately here does not seem to work, perhaps because default is still prevented?
				var timer:Timer = new Timer(10,1);
				timer.addEventListener("timer",testFileSaved,false,0,true);
				timer.start();
			}
		}
		
		public function testFileSaveCancelled():void{
			exitImminent = false;
		}
		
		public function testFileSaved(event:TimerEvent = null):void{
			if(exitImminent){
				if(browserConnection.useBrowser && browserConnection.connected){
					browserConnection.sendDisconnect();	
				}
				NativeApplication.nativeApplication.exit();
			}			
		}
		
		
		
	}
}
