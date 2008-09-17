package com.gorillalogic.flexmonkey
{
	public class AssertionFailed extends Error
	{
		public function AssertionFailed(message:String="", id:int=0)
		{
			super(message, id);
		}
		
	}
}