/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	
import com.gorillalogic.flexmonkey.application.UI.views.AlertView;
import com.gorillalogic.flexmonkey.application.UI.views.ProjectPropertiesWindowView;
import com.gorillalogic.flexmonkey.application.UI.views.SnapshotWindowView;
import com.gorillalogic.flexmonkey.application.UI.views.SpyWindowView;
import com.gorillalogic.flexmonkey.application.events.UserEvent;
import com.gorillalogic.flexmonkey.core.MonkeyAutomationState;
import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
import com.gorillalogic.flexmonkey.registration.MonkeyRegistrationWindow;
import com.gorillalogic.flexmonkey.registration.MonkeyRegistrationStore;

import flash.desktop.NativeApplication;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.Window;
import mx.managers.PopUpManager;
import mx.core.IFlexDisplayObject;
		
/*
	import mx.core.IFlexDisplayObject;
	
*/		
	public class WindowManager extends EventDispatcher
	{
		public var mateDispatcher : IEventDispatcher;
		private var _targetSWFWindow: Application;
		public function get targetSWFWindow():Application{
			return _targetSWFWindow;
		}
		public function set targetSWFWindow(w:Application):void{
			_targetSWFWindow = w;
		}
		
		private var _airMonkeyWindow: Window;
		public function get airMonkeyWindow():Window{
			return _airMonkeyWindow;
		}
		public function set airMonkeyWindow(w:Window):void{
			_airMonkeyWindow = w;
		}
				
		private var alertWindowStack:Array = [];

		public var selectedItem:MonkeyRunnable;

		
		//-- constructor --------------------------------------------------------------------------
		public function WindowManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function closeAlertWindow():void{
			var av:AlertView = alertWindowStack.pop();
			av.close();
		}
		
		public function displayAlert(alertWindow:Object):void{
			alertWindowStack.push(alertWindow);
			airMonkeyWindow.orderToFront();
			PopUpManager.addPopUp(IFlexDisplayObject(alertWindow),airMonkeyWindow,true);
		}
		
		
		public function displayAbout():void{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appDescriptor.namespace();
			var appCopyright:String = appDescriptor.ns::copyright;
			var appVersion:String = appDescriptor.ns::version;

			Alert.show("FlexMonkey " + appVersion);
		}
		
		public function alertWindowClick():void{
			var av:AlertView = alertWindowStack.pop();
			if(av.titleText == "Take Snapshot"){
				mateDispatcher.dispatchEvent(new UserEvent(UserEvent.STOP_RECORDING));
			}
//MonkeyAutomationState.monkeyAutomationState.state = MonkeyAutomationState.IDLE;
		}
		
		private var regWindow:MonkeyRegistrationWindow;
		public function displayRegistration():void{
			//check if registration key is valid, if invalid display registration popup
			if (!MonkeyRegistrationStore.checkValidKey()) {
			    regWindow = new MonkeyRegistrationWindow();
			    regWindow.onCompleteCallback = displayRegistration;
			    
			    PopUpManager.addPopUp(regWindow, airMonkeyWindow, true);
			    PopUpManager.centerPopUp(regWindow);
			}else{			
				regWindow = null;
				if(introWindow != null){
					displayIntro(introWindow);
				}
			}
		}
		
		private var introWindow:Object;
		public function displayIntro(introWindow:Object):void{
			this.introWindow = introWindow;
			if(MonkeyRegistrationStore.checkValidKey()){
				alertWindowStack.push(introWindow);
				airMonkeyWindow.orderToFront();
				PopUpManager.addPopUp(IFlexDisplayObject(introWindow),airMonkeyWindow,true);
			}						
		}
		
		public function openSnapshotWindow(verifyCommand:VerifyMonkeyCommand = null):void{
			if(verifyCommand == null){			
				verifyCommand = VerifyMonkeyCommand(this.selectedItem);
			}
			var snapshotWindow:SnapshotWindowView = new SnapshotWindowView();
			snapshotWindow.verifyCommand = verifyCommand;
			snapshotWindow.open();
			snapshotWindow.nativeWindow.x = airMonkeyWindow.nativeWindow.x + airMonkeyWindow.nativeWindow.width/2;
			snapshotWindow.nativeWindow.y = airMonkeyWindow.nativeWindow.y + airMonkeyWindow.nativeWindow.height/2;
								
		}
		
		public function openSpyWindow():void{			
			var spyWindow:SpyWindowView = new SpyWindowView();
			spyWindow.open();
			spyWindow.nativeWindow.x = airMonkeyWindow.nativeWindow.x + 10;
			spyWindow.nativeWindow.y = airMonkeyWindow.nativeWindow.y + 100;	
		}
		
		public function openProjectPropertiesWindow():void{			
			var projectPropertiesWindow:ProjectPropertiesWindowView = new ProjectPropertiesWindowView();
			projectPropertiesWindow.open();
			projectPropertiesWindow.nativeWindow.x = airMonkeyWindow.nativeWindow.x + 10;
			projectPropertiesWindow.nativeWindow.y = airMonkeyWindow.nativeWindow.y + 100; 
		}		
		
	}
}