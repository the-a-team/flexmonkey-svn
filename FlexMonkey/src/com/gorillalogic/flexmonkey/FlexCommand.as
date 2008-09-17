package com.gorillalogic.flexmonkey
{
	public class FlexCommand	
	{
			/**
			 * The id of the target component to which to send the command. By default, it's the automationName
			 */ 
			public var value:String;
			/**
			 * The property containing the specified id value. If not specified, first automationName's and id's will be searched until the first match.
			 */
			public var prop:String = null;
			/**
			 * The command to execute, eg, Click or Select
			 */  
			public var command:String;
			/**
			 * Arguments concatenated as a string
			 */
			  
			public var args:Array;  
			 /**
			 * Optional. An ID of a component that contains the target. Used to further qualify the search for the target.
			 */ 
			public var containerValue:String = null;
			/**
			* The property containing the specified containingId value.
			*/
			public var containerProp:String = null;		
			
		public function FlexCommand(value:String, command:String, args:Array = null, prop:String = null, containerValue:String = null, containerProp:String = null)
		{
			this.value = value;
			this.command = command;
			this.args = args;
			this.prop = prop
			this.containerValue = containerValue;
			this.containerProp = containerProp;
		}

	}
}