/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import flash.display.Graphics;
	
	import mx.core.UIComponent;
	public class MonkeyAutomationState
	{

		public static const IDLE:String = "idle";
		public static const NORMAL:String = "normal";
		public static const SNAPSHOT:String = "snapshot";
		
		private static var _monkeyAutomationState:MonkeyAutomationState;

		public static function get monkeyAutomationState():MonkeyAutomationState{
			if(MonkeyAutomationState._monkeyAutomationState == null){
				MonkeyAutomationState._monkeyAutomationState = new MonkeyAutomationState(new SingletonEnforcer());
			}
			return MonkeyAutomationState._monkeyAutomationState;
		}
		
		public function MonkeyAutomationState(singletonEnforcer:SingletonEnforcer)
		{
		}

		private var _state:String = IDLE;
		public function get state():String{
			return _state;
		}
		public function set state(s:String):void{
			_state = s;
		}
		
		private var _graphics:Graphics;
		public function get graphics():Graphics{
			return _graphics;
		}
		public function set graphics(g:Graphics):void{
			_graphics = g;
		}

		private var _conversionPlatform:UIComponent;
		public function get conversionPlatform():UIComponent{
			return _conversionPlatform;
		}	
		public function set conversionPlatform(c:UIComponent):void{
			_conversionPlatform = c;
		}

	}
}
class SingletonEnforcer {}