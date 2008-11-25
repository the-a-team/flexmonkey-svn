package com.gorillalogic.flexmonkey.commands
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
		
		/**
		 * Generate a flex event for the component identified by the specified 
		 * property-value pair.
		 * 
		 * @param value the value to search for
		 * @param name the name of the event to generate
		 * @param args the event args
		 * @param prop the property to search for the specified value. Defaults to automationName.
		 * @param containerValue if specified, only children/descendants of the container having this property value will be searched.
		 * @param containerProp The property to search for the specified containerValue. If no containerProperty-containerValue pair is specified, all components will be searched.
		 */ 	
		public function FlexCommand(value:String, name:String, args:Array = null, prop:String = "automationName", containerValue:String = null, containerProp:String = null)
		{
			this.value = value;
			this.command = name;
			this.args = args;
			this.prop = prop
			this.containerValue = containerValue;
			this.containerProp = containerProp;
		}

	}
}