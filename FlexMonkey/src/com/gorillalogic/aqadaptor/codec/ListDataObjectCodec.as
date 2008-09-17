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

import mx.automation.IAutomationManager;
import mx.automation.IAutomationObject;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * Translates between internal Flex List item and automation-friendly version
 */
public class ListDataObjectCodec extends DefaultPropertyCodec
{
		
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    public function ListDataObjectCodec()
	{
		super();
	}
   
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override public function encode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    propertyDescriptor:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):Object
    {
        var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);

		if (val != null)
		{
		    val = relativeParent.automationTabularData.getAutomationValueForData(val).join(" | ");
		}
        
        return val;
    }

    /**
     *  @private
     */ 
    override public function decode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    value:Object,
                                    propertyDescriptor:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):void
    {
        trace("ILLEGAL OPERATION");
    }
}

}
