package com.gorillalogic.flexmonkey
{
	/**
	 * Call the specified function during playback
	 */ 
	public class CallCommand
	{
		public var func:Function;
		/**
		 * Call a function during playback
		 * @param func the function to call
		 */ 
		public function CallCommand(func:Function)
		{
			this.func = func;
		}

	}
}