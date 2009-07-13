////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.gorillalogic.aqadaptor
{

import com.gorillalogic.aqadaptor.custom.CustomAutomationEventDescriptor;

import flash.events.Event;

import mx.automation.Automation;
import mx.automation.IAutomationObject;
import mx.automation.events.AutomationReplayEvent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * Method descriptor class.
 */
public class AQEventDescriptor extends CustomAutomationEventDescriptor
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor
     */
    public function AQEventDescriptor(name:String,
                                               eventClassName:String,
                                               eventType:String,
                                               args:Array)
    {
        super(name, eventClassName, eventType, args);
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
    
    /**
     *  @private
     */
	private var _eventArgASTypesInitialized:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
    override public function record(target:IAutomationObject, event:Event):Array
    {
        var args:Array = getArgDescriptors(target);

		var helper:IAQCodecHelper = AQAdapter.getCodecHelper();
        return helper.encodeProperties(event, args, target);
    }

    /**
     * @private
     */
    override public function replay(target:IAutomationObject, args:Array):Object
    {
        var event:Event = createEvent(target);
        var argDescriptors:Array = getArgDescriptors(target);
		var helper:IAQCodecHelper = AQAdapter.getCodecHelper();
        helper.decodeProperties(event, args, argDescriptors,
							IAutomationObject(target));
							
        var riEvent:AutomationReplayEvent = new AutomationReplayEvent();
		riEvent.automationObject = target;
		riEvent.replayableEvent = event;
        Automation.automationManager.replayAutomatableEvent(riEvent);

        return null;
    }

}

}
