package com.gorillalogic.flexmonkey
{
	
	/**
	 * Pause command playback.
	 */ 
	public class PauseCommand
	{
		public var delay:int;
		/**
		 * Pause for the specified delay time
		 * @param delay in milliseconds
		 */ 
		public function PauseCommand(delay:int)
		{
			this.delay = delay;
		}

	}
}