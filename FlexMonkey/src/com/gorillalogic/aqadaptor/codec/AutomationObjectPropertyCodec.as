////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.gorillalogic.aqadaptor.codec
{
import com.gorillalogic.aqadaptor.IAQPropertyDescriptor;

import mx.automation.AutomationIDPart;
import mx.automation.IAutomationManager;
import mx.automation.IAutomationObject;

/**
 * Translates between internal Flex component and automation-friendly version
 */
public class AutomationObjectPropertyCodec extends DefaultPropertyCodec
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    public function AutomationObjectPropertyCodec()
	{
		super();
	}
   
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
     * @private
     */
    override public function encode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    pd:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):Object
    {
        var val:Object = getMemberFromObject(automationManager, obj, pd);

		var delegate:IAutomationObject = val as IAutomationObject;
        if (delegate)
        {
            //only use automationName
            val = automationManager.createIDPart(delegate).automationName;
        }

        if (!val && !(val is int))
        	val = "";

        return val;
    }

    /**
     * @private
     */
    override public function decode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    value:Object,
                                    pd:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):void
    {
		if (value == null || value.length == 0)
		{
	        obj[pd.name] = null;
		}
		else
		{
	        var aoc:IAutomationObject = 
	        		(relativeParent != null ? relativeParent : obj as IAutomationObject);

	        var part:AutomationIDPart = new AutomationIDPart();
	        // If we have any descriptive programming element
            // in the value string use that property.
            // If it is a normal string assume it to be automationName
	        var text:String = String(value);
	        var separatorPos:int = text.indexOf(":=");
	        var items:Array = [];
	        if(separatorPos != -1)
	        	items = text.split(":=");

        	if(items.length == 2)
	        	part[items[0]] = items[1]; 
	        else
	        	part.automationName = text;
	            
			var ao:Array = automationManager.resolveIDPart(aoc, part);
			var delegate:IAutomationObject = (ao[0] as IAutomationObject);
			if (delegate)
		    	obj[pd.name] = delegate;
		    else
		    	obj[pd.name] = ao[0];
		    	
	    	if (ao.length > 1)
	    	{
	    		trace("Multiple matches found");
	    	}
		}
    }
}

}
