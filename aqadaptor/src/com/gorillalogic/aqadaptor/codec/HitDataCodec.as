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
import mx.charts.ChartItem;
import mx.charts.HitData;
import mx.charts.chartClasses.Series;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * translates between internal Flex HitData and automation-friendly version
 */
public class HitDataCodec extends DefaultPropertyCodec
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    public function HitDataCodec()
	{
		super();
	}
   
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    override public function encode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    propertyDescriptor:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):Object
    {
        var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
		var encodedID:int;

        if (val != null)
        {
        	if (val is HitData)
        	{
        		encodedID = (val as HitData).chartItem.index;
        	}
        }
        
        return encodedID;
    }

    override public function decode(automationManager:IAutomationManager,
                                    obj:Object, 
                                    value:Object,
                                    propertyDescriptor:IAQPropertyDescriptor,
                                    relativeParent:IAutomationObject):void
    {
    	if (relativeParent is Series)
    	{
    		var series:Object = relativeParent;
    		var items:Array = series.items;
    		for(var i:int = 0; i < items.length; ++i)
    		{
    			if (items[i] is ChartItem)
    			{
    				var chartItem:ChartItem = items[i] as ChartItem;
    				if ( chartItem.index == value)
    				{
   						obj[propertyDescriptor.name] = 
   									new HitData(0, 0, 0, 0, chartItem);
    					break;
    				}
    			}
    		}
    	}
}
}

}
