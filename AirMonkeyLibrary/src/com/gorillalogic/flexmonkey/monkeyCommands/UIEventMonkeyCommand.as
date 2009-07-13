/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.aqadaptor.AQAdapter;
	import com.gorillalogic.flexmonkey.core.*;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.core.UIComponent;

	[RemoteClass]	
    [Bindable]
	public class UIEventMonkeyCommand extends MonkeyRunnable
	{
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);		
		
		// NOTE: Currently the only place we actually use non-null values for this constructor's parameters is in the generated code.
		public function UIEventMonkeyCommand(command:String=null,
											value:String=null,
											prop:String=null,
											args:Array=null,
											containerValue:String=null,
											containerProp:String=null)
		{
			this.command = command;
			this.value = value;
			this.prop = prop;
			this.containerValue = containerValue;
			this.containerProp = containerProp;
			this.args = args;	
			error = null;		
		}
				
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{	
			execute0(runner,timer);
			execute1();  		
	  		return execute2(runner,timer);						
		}
	
		public function execute0(runner:MonkeyCommandRunner, timer:Timer=null):void{
   			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));			
		}	
		public function execute1():void{
		    var am:IAutomationManager = AQAdapter.aqAdapter.automationManager;
			if (am.isSynchronized(null)) {
				var container:UIComponent = null;
				if ( !isEmpty(containerValue) ) {
					container = MonkeyUtils.findComponentWith(containerValue, containerProp); 
				}
				var target:IAutomationObject = MonkeyUtils.findComponentWith(value, prop, container);
				if (target != null) {
			        if (am.isSynchronized(target)){
			            if (am.isVisible(target as DisplayObject)){
			            	try {
			            		AQAdapter.aqAdapter.run(target, 
						        						command, 
						        						args);
					        	hasBeenRun = true;
			            	} catch ( e:Error ) {
			            		error = "Error: " + e.message + "\n" + e.getStackTrace();
			            	}
			            } else {
							error = "Target " + value + " not visible";
			            }
			        } else {
						error = "AutomationManager not synchronized (with target " + value + ")";
			        }
				} else {
					error = "Could not find target " + value;
				}		        						
	  		}else{
				error = "AutomationManager not synchronized";
	  		}			
		}		
		public function execute2(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
	  		if(!hasBeenRun){
				mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.ERROR,this));
	  			updateResult();
	  		}			
			timer.start();
			return true;
		}
		

		override public function get xml():XML{
			var xml:XML = 
			<UIEvent command={command} value={value} prop={prop} />
			if ( !isEmpty(containerValue) ) { xml.@containerValue = containerValue };
			if ( !isEmpty(containerProp) ) { xml.@containerProp = containerProp };			
			for(var i:uint;i<args.length;i++){
				xml.appendChild(<arg value={args[i]}/>);
			}
			return xml;
		}
		
		
		override public function get shortDescription():String {
			return "UIEventMonkeyCommand " + command + " " + value;
		}	
				
		override public function get thinkTime():uint {
			return MonkeyTest(parent).defaultThinkTime;
		}			

		private function quote(arg:Object):String {
			if (arg is String) {
				if ( isEmpty(String(arg)) ) {
					return "null";
				} else {
					return "'" + String(arg) + "'";
				}
			} else {
				return String(arg);
			}
		}
		
		private function isEmpty(arg:String):Boolean {
			return ( arg == null || arg == "" || arg == "null" ); // Check for "null" only needed for backwards XML compatibility
		}

		public function getAS3(testName:String):String{
			var argsString:String = quote(args[0]);			
	 		for each (var arg:String in args.slice(1)) {
	 			argsString += ", " + quote(arg); 
	 		}						
			var commandString:String = "new UIEventMonkeyCommand("
				+ quote(command) + ", "
				+ quote(value) + ", "
				+ quote(prop) +  ", "
				+ "[" 
				+ argsString 
				+ "]";
			 if ( !isEmpty(containerValue) || !isEmpty(containerProp) ) {
			 	commandString += 
			 		", " + quote(containerValue)
					 + ", " + quote(containerProp);
			 }
			 commandString += ")";
			 return commandString;
		}
		
		private var _command:String;
		public function get command():String{
			return _command;
		}
		public function set command(t:String):void{
			_command = t;
		}
		
		private var _value:String;
		public function get value():String{
			return _value;
		}
		public function set value(v:String):void{
			_value = v;
		}
		
		private var _prop:String;
		public function get prop():String{
			return _prop;
		}
		public function set prop(p:String):void{
			_prop = p;
		}
		
		private var _containerValue:String;
		public function get containerValue():String{
			return _containerValue;
		}
		public function set containerValue(v:String):void{
			_containerValue = v;
		}
		
		private var _containerProp:String;
		public function get containerProp():String{
			return _containerProp;
		}
		public function set containerProp(p:String):void{
			_containerProp = p;
		}		
		
		private var _args:Array;
		public function get args():Array{
			return _args;
		}
		public function set args(a:Array):void{
			_args = a;
		}
			
		override public function isEqualTo(item:Object):Boolean{
			if(! item is UIEventMonkeyCommand){
				return false;
			}else{
				if(
					(item.command == this.command) &&
					(item.value == this.value) &&
					(item.prop == this.prop) &&
					(item.containerValue == this.containerValue) &&
					(item.containerProp == this.containerProp)				
				){
					for(var i:uint=0;i<args.length;i++){
						if(item.args[i] != this.args[i]){
							return false;
						}
					}
					return true;
				}else{
					return false;
				}
			}
		}
		
		public override function updateResult():void {
			if ( error != null ) {
				result = "ERROR";
			} else if ( ! hasBeenRun ) {
				result = "NOT_RUN";
			} else { 
				result = "PASS";
			}
			errorCount = error == null ? 0 : 1;
		}

		override public function resetResult():void{
			super.resetResult();
			error = null;
		}			
			
		public function clone():UIEventMonkeyCommand{
			var copy:UIEventMonkeyCommand = new UIEventMonkeyCommand();
			copy.mateDispatcher = mateDispatcher;
			copy.parent = this.parent;
			copy.command = this.command;
			copy.value = this.value;
			copy.prop = this.prop;
			copy.containerValue = this.containerValue;
			copy.containerProp = this.containerProp;
			copy.args = this.args.concat();	
			copy.result = result;	
			copy.error = this.error;		
			copy.errorCount = this.errorCount;
			return copy;
		}			
				
	}
}