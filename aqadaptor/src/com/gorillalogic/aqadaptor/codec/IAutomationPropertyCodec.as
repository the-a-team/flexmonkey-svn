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

/**
 * Defines the interface for codecs, which translate between internal Flex properties 
 * and automation-friendly ones.
 */
public interface IAutomationPropertyCodec
{
	/**
	 * Encodes the value into a form readable by the user.
	 * 
	 * @param automationManager The automationManager object
	 * 
	 * @param obj The object having the property which requires encoding.
	 * 
	 * @param propertyDescriptor The property descriptor object describing the 
	 * 							 property which needs to be encoded.
	 * 
	 * @param relativeParent The parent or automationParent of the component
	 * 					    recording the event.
	 */
    function encode(automationManager:IAutomationManager,
                    obj:Object, 
                    propertyDescriptor:IAQPropertyDescriptor,
                    relativeParent:IAutomationObject):Object;

	/**
	 * Decodes the value into a form required for the framework to do operations.
	 *  This may involve searching for some data in the dataProvider or a particualr
	 *  child of the container.
	 * 
	 * @param automationManager The automationManager object
	 * 
	 * @param obj The object having the property which needs to be 
	 * 						updated with the new value.
	 * 
	 * @param value The input value for the decoding process.
	 * 
	 * @param propertyDescriptor The property descriptor object describing the 
	 * 							 property which needs to be decoded.
	 * 
	 * @param relativeParent The parent or automationParent of the component
	 * 					    recording the event.
	 */
    function decode(automationManager:IAutomationManager,
                    obj:Object, 
                    value:Object,
                    propertyDescriptor:IAQPropertyDescriptor,
                    relativeParent:IAutomationObject):void;

}

}
