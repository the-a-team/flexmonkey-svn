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
	

import com.gorillalogic.aqadaptor.codec.ArrayPropertyCodec;
import com.gorillalogic.aqadaptor.codec.AssetPropertyCodec;
import com.gorillalogic.aqadaptor.codec.AutomationObjectPropertyCodec;
import com.gorillalogic.aqadaptor.codec.ColorPropertyCodec;
import com.gorillalogic.aqadaptor.codec.DatePropertyCodec;
import com.gorillalogic.aqadaptor.codec.DateRangePropertyCodec;
import com.gorillalogic.aqadaptor.codec.DateScrollDetailPropertyCodec;
import com.gorillalogic.aqadaptor.codec.DefaultPropertyCodec;
import com.gorillalogic.aqadaptor.codec.IAutomationPropertyCodec;
import com.gorillalogic.aqadaptor.codec.KeyCodePropertyCodec;
import com.gorillalogic.aqadaptor.codec.KeyModifierPropertyCodec;
import com.gorillalogic.aqadaptor.codec.ListDataObjectCodec;
import com.gorillalogic.aqadaptor.codec.ScrollDetailPropertyCodec;
import com.gorillalogic.aqadaptor.codec.ScrollDirectionPropertyCodec;
import com.gorillalogic.aqadaptor.codec.TabObjectCodec;
import com.gorillalogic.aqadaptor.codec.TriggerEventPropertyCodec;
import com.gorillalogic.aqadaptor.custom.CustomAutomationClass;
import com.gorillalogic.flexmonkey.FlexMonkey;

import flash.display.DisplayObject;
import flash.events.*;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;

import mx.automation.Automation;
import mx.automation.AutomationError;
import mx.automation.AutomationID;
import mx.automation.IAutomationClass;
import mx.automation.IAutomationEventDescriptor;
import mx.automation.IAutomationManager;
import mx.automation.IAutomationMethodDescriptor;
import mx.automation.IAutomationObject;
import mx.automation.IAutomationPropertyDescriptor;
import mx.automation.IAutomationTabularData;
import mx.automation.events.AutomationRecordEvent;
import mx.controls.Alert;
import mx.core.Application;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

use namespace mx_internal;

[Mixin]

/**
 *  @private
 */
public class AQAdapter implements IAQCodecHelper
{
	
	[Embed(source="FlexMonkeyEnv.xml", mimeType="application/octet-stream")]  
	protected const FlexMonkeyEnv:Class;
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
     */	
    private static var isInitailized:Boolean = false;
    
    /**
	 *  @private
     */	
    private static var AQCodecHelper:IAQCodecHelper;
    
    public var unhacked:Boolean;
    
    
   
    private var records:XML = <Records></Records>;  

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	private static var _root:DisplayObject;
	
	public static var aqAdapter:AQAdapter;
	
    /**
	 *  @private    
	 */
	public static function init(root:DisplayObject):void
    {
    	if(!aqAdapter)
	    {
	    	_root = root;

			root.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
    	}
     }
	
    /**
	 *  @private    
	 */
	private static function applicationCompleteHandler(event:FlexEvent):void
	{
		_root.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);

		aqAdapter = new AQAdapter();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor
	 */
	public function AQAdapter()
    {
		super();
		
		if (!isInitailized)
		{
		    isInitailized = true;

            AQCodecHelper = this;

            // Add the default serializers.
            addPropertyCodec(
				"object", new DefaultPropertyCodec());

            addPropertyCodec(
				"keyCode", new KeyCodePropertyCodec());

            addPropertyCodec(
				"keyModifier", new KeyModifierPropertyCodec());

            addPropertyCodec(
				"object[]", new ArrayPropertyCodec(new DefaultPropertyCodec()));

            addPropertyCodec(
				"color", new ColorPropertyCodec());

            addPropertyCodec(
				"color[]", new ArrayPropertyCodec(new ColorPropertyCodec()));

            addPropertyCodec(
				"automationObject", new AutomationObjectPropertyCodec());

            addPropertyCodec(
				"automationObject[]",
				new ArrayPropertyCodec(new AutomationObjectPropertyCodec()));

            addPropertyCodec(
				"asset", new AssetPropertyCodec());

            addPropertyCodec(
				"asset[]", new ArrayPropertyCodec(new AssetPropertyCodec()));

            addPropertyCodec(
				"listDataObject", new ListDataObjectCodec());

            addPropertyCodec(
				"listDataObject[]",
				new ArrayPropertyCodec(new ListDataObjectCodec()));

            addPropertyCodec(
				"dateRange", new DateRangePropertyCodec());

			addPropertyCodec(
				"dateObject", new DatePropertyCodec());

            addPropertyCodec(
				"dateRange[]",
				new ArrayPropertyCodec(new DateRangePropertyCodec()));

            addPropertyCodec(
				"event", new TriggerEventPropertyCodec());
			
			addPropertyCodec(
				"tab", new TabObjectCodec());
				
			addPropertyCodec(
				"scrollDetail", new ScrollDetailPropertyCodec());

			addPropertyCodec(
				"dateScrollDetail", new DateScrollDetailPropertyCodec());

			addPropertyCodec(
				"scrollDirection", new ScrollDirectionPropertyCodec());

	    	try
	    	{
	    		// check for availability of chart codec.
	    		// it may not be available if user has not included chart delegates
				var codec:Object = getDefinitionByName("codec.HitDataCodec");
				
				addPropertyCodec(
					"hitDataCodec[]", new ArrayPropertyCodec(new codec()));
	    	}
	    	catch(e:Error)
			{
			}

            /** 
            * If the plugin DLL is ActiveX based this check can be enabled.
            */
            /* if (Capabilities.playerType != "ActiveX")
            {
                trace("No ActiveX support"]);
                return;
            } */

            
/*          If the agent is supporting only Windows platform   
            if (! Capabilities.os.match(/^Windows/))
            {
                trace("Agent supports only Windows");
                return;
            }
 */
            /** 
            *  If the plugin DLL requries ExternalInterface support playerID is a must to 
            *  identfiy the player instance in JavaScript.
            */
            /* if (!playerID || playerID.length == 0)
            {
                trace("No PlayerID is provided");
                return;
            } 

            if (playerID.match(/[\.-]/))
            {
                trace("Invalid PlayerID");
                return;
            }*/
            
            

			var byteArray:ByteArray = new FlexMonkeyEnv() as ByteArray;
			var env:String = new String(byteArray.readUTFBytes(byteArray.length));
			setTestingEnvironment(env);
			PopUpManager.addPopUp(FlexMonkey.theMonkey, DisplayObject(Application.application));
			PopUpManager.centerPopUp(FlexMonkey.theMonkey);			

        }
    }
    
 	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
	private var lastError:Error;

    /**
     *  @private
     */
	private var propertyCodecMap:Object = [];
	
  	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  automationManager
	//----------------------------------

    /**
     *  @private
	 */
    public function get automationManager():IAutomationManager
    {
        return Automation.automationManager ;
    }

	//----------------------------------
	//  playerID
	//----------------------------------

    /**
     *  @private
     */
    private function get playerID():String 
    { 
        return Application.application.id;
    }

    private var lastRecord:String;

  	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  Registers a custom codec to encoding an decoding of object properties and
     *  event properties to and from a testing tool.  For example, ColorPicker
     *  events can contain the selected color.  A special color codec is provided
     *  to encode and decode colors from their native number format to hex.
     *
     *  Predefined codecs include:
     *      "" - The default codec that supports basic types such as String, Number, int and uint.
     *      "color" - Converts a number to hex.
     *      "keyCode" - Converts a keyCode number to a human readable string
     *      "keyState" - Converts ctrlKey, shiftKey and altKey booleans to a human 
     *                   readable bitfield string.
     *      "skin" - Converts a skin asset class name to closely resemble it's 
     *               original asset name.  Path separators and periods in the orignal
     *               path name will be converted to underscores.  This is only available
     *               on readonly properties.
     *      "automationObject" - Converts an object to it's automationName.
     *
     *  @param codecName the name of the codec.
     * 
     *  @param codec the implementation of the codec.
     */
    private function addPropertyCodec(codecName:String, codec:IAutomationPropertyCodec):void
    {
        propertyCodecMap[codecName] = codec;
    }

    /**
	 *  @private
	 */
    public function setTestingEnvironment(te:String):void
    {
    	if (automationManager == null) {
    		Alert.show("Automation Manager does not appear to be loaded. Be sure you are including the automation libraries.");
    		return;
    	}
        automationManager.automationEnvironment = new AQEnvironment(new XML(te));
    }

    /**
     *  Encodes a single value to a testing tool value.  Unlike encodeProperties which
     *  takes an object which contains all the properties to encode, this method
     *  takes the actual value to encode.  This is useful for encoding return values.
     *
     *  @param obj the value to be encoded.
     * 
     *  @param propertyDescriptor the property descriptor that describes this value.
     * 
     *  @param relativeParent the IAutomationObject that is related to this value.
     */
    public function encodeValue(value:Object, 
                                testingToolType:String,
                                codecName:String,
                                relativeParent:IAutomationObject):Object
    {
        //setup a fake descriptor and object to send to the codec
        var pd:AQPropertyDescriptor = 
            new AQPropertyDescriptor("value",
                                             false, 
                                             false, 
                                             testingToolType, 
                                             codecName);
        var obj:Object = {value:value};
        return getPropertyValue(obj, pd, relativeParent);
    }
    
    
    public function getPropertyValue(obj:Object, 
                                     pd:AQPropertyDescriptor,
                                     relativeParent:IAutomationObject = null):Object
    {
        var coder:IAutomationPropertyCodec = propertyCodecMap[pd.codecName];
        
        if (coder == null)
            coder = propertyCodecMap["object"];

	    if (relativeParent == null)
		    relativeParent = obj as IAutomationObject;
		    
        return coder.encode(automationManager, obj, pd, relativeParent);
    }
    
    /**
     *  Encodes properties in an AS object to an array of values for a testing tool
     *  using the codecs.  Since the object being passed in may not be an IAutomationObject 
     *  (it could be an event class) and some of the properties require the
     *  IAutomationObject to be transcoded (such as the item renderers in
     *  a list event), relativeParent should always be set to the relevant
     *  IAutomationObject.
     *
     *  @param obj the object that contains the properties to be encoded.
     * 
     *  @param propertyDescriptors the property descriptors that describes the properties for this object.
     * 
     *  @param relativeParent the IAutomationObject that is related to this object.
     *
     *  @return the encoded property value.
     */
    public function encodeProperties(obj:Object,
                                     propertyDescriptors:Array,
                                     interactionReplayer:IAutomationObject):Array
    {
        var result:Array = [];
        var consecutiveDefaultValueCount:Number = 0;
        for (var i:int = 0; i < propertyDescriptors.length; i++)
        {
            var val:Object = getPropertyValue(obj, 
                                              propertyDescriptors[i],
                                              interactionReplayer);

			var isDefaultValueNull:Boolean = propertyDescriptors[i].defaultValue == "null";

            consecutiveDefaultValueCount = (!(val == null && isDefaultValueNull) &&
            								(propertyDescriptors[i].defaultValue == null || 
                                             val == null ||
                                             propertyDescriptors[i].defaultValue != val.toString())
                                            ? 0
                                            : consecutiveDefaultValueCount + 1);

            result.push(val);
        }

        result.splice(result.length - consecutiveDefaultValueCount, 
                      consecutiveDefaultValueCount);

        return result;
    }
    

    /**
	 *  @private
	 */
    private function recordHandler(event:AutomationRecordEvent):void
    {
        automationManager.incrementCacheCounter();

        try
        {
            var obj:IAutomationObject = event.automationObject ;
            
            // Skip clicks on the toolbar itself
            if (event.automationObject is FlexMonkey) {
            	automationManager.decrementCacheCounter();
           		return;
            }
            
            var rid:AutomationID = automationManager.createID(obj);

			var rec:XML;
			if (unhacked) {
			 	rec = (<Step id={rid.toString()} method={event.name} ></Step>); 
			} else {
			 	rec = (<Step id={obj.automationName} method={event.name} ></Step>); 
			}

            XML.prettyPrinting = false;
            
            rec.appendChild(<Args value={event.args.join("_ARG_SEP_")} />);
			
			records.appendChild(rec);
            
        }
        catch (e:Error)
        {
            lastError = e;
            trace(e.message);
        }

        automationManager.decrementCacheCounter();
    }

    /**
	 *  @private
	 */
    public function beginRecording():Object
    {
        return useErrorHandler(function():Object
        {
            var o:Object = { result:null, error:0 };
            automationManager.addEventListener(AutomationRecordEvent.RECORD,
                                               recordHandler, false, 0, true);
            automationManager.beginRecording();
            
            return o;
        });
    }

    /**
	 *  @private
	 */
    public function endRecording():Object
    {
        return useErrorHandler(function():Object
        {
            var o:Object = { result:null, error:0 };
            automationManager.endRecording();
            automationManager.removeEventListener(AutomationRecordEvent.RECORD,
                                                  recordHandler);
            return o;
        });
    }

    private function replayEvent(target:IAutomationObject, eventName:String, args:Array):Object
    {
        var automationClass:IAutomationClass = 
            automationManager.automationEnvironment.getAutomationClassByInstance(target);
        // try to find the automation class
        if (! automationClass)
            throw new Error(CustomAutomationClass.getClassName(target) + "class not found");
    
        var eventDescriptor:IAutomationEventDescriptor =
            automationClass.getDescriptorForEventByName(eventName);

        if (!eventDescriptor)
            throw new Error(eventName + " event description not found for " + automationClass);
    
		var retValue:Object = eventDescriptor.replay(target, args);
        return {value:retValue, type:null};
    }

    private function replayMethod(target:IAutomationObject, method:String, args:Array):Object
    {
        var automationClass:IAutomationClass = 
            automationManager.automationEnvironment.getAutomationClassByInstance(target);
        // try to find the automation class
        if (! automationClass)
            throw new Error(CustomAutomationClass.getClassName(target) + "class not found");
    
        var methodDescriptor:IAutomationMethodDescriptor =
            automationClass.getDescriptorForMethodByName(method);

        if (!methodDescriptor) {
        	trace(method + " method not found for "+ automationClass);
            throw new Error(method + " method not found for "+ automationClass);
        }
    
        var retValue:Object = methodDescriptor.replay(target, args);
        
        if(retValue is IAutomationObject)
	        retValue = automationManager.createID(IAutomationObject(retValue)).toString();
        
        return {value:retValue, type:methodDescriptor.returnType};
    }
    
    /**
     *  @private
     */
    public function replay(target:IAutomationObject, method:String, args:Array):Object
    {   
        automationManager.incrementCacheCounter();
        var o:Object = { result:null, error:0 };
        try
        {
			 o.result = replayMethod(target, method, args);        	
        }
        catch(e:Error)
        {
	        try
	        {
			     o.result = replayEvent(target, method, args);        	
	        }
	        catch(e:Error)
    	    {
		        automationManager.decrementCacheCounter();
    	    	throw e;
    	    }
        }

		//force clear;
        automationManager.decrementCacheCounter(true);
        
        return o;
    }
    

    /**
	 *  @param target If target is a string, it will be used to lookup a component by autoname. Otherwise, target
	 * 		must be a component.
	 */
    public function run(target:Object, method:String, args:Array):Object
    {

        return useErrorHandler(function():Object
        {


            if (!target)
            	return { result:null, error:0 };
            	
            
			return  replay(IAutomationObject(target), method, args);
        });
    }
    

    /**
	 *  @private
	 */
    public function getPropertyDescriptors(obj:IAutomationObject, 
                                  names:Array = null, 
                                  forVerification:Boolean = true, 
                                  forDescription:Boolean = true):Array
    {
        if (!obj)
            return null;

        try
        {
            automationManager.incrementCacheCounter();

            var automationClass:IAutomationClass =
                automationManager.automationEnvironment.getAutomationClassByInstance(obj) as IAutomationClass;
            var i:int;
			var propertyNameMap:Object = automationClass.propertyNameMap;

            var result:Array = [];
            if (!names)
            {
	            var propertyDescriptors:Array = 
    		            automationClass.getPropertyDescriptors(obj, 
            	                                        forVerification, 
                	                                    forDescription);
                names = [];
                for (i = 0; i < propertyDescriptors.length; i++)
                {
                    names[i] = propertyDescriptors[i].name;
                }
            }
            for (i = 0; i < names.length; i++)
            {
                var propertyDescriptor:AQPropertyDescriptor = propertyNameMap[ names[i] ];
                result.push(propertyDescriptor);
            }
            
            automationManager.decrementCacheCounter();
        }
        catch(e:Error)
        {
            automationManager.decrementCacheCounter();
            
            throw e;
        }

        return result;
    }

	private function encodeValues(obj:IAutomationObject, values:Array, descriptors:Array):Array
	{
        var result:Array = [];
        for (var i:int = 0; i < values.length; ++i)
        {
        	var descriptor:AQPropertyDescriptor = descriptors[i];
	        var coder:IAutomationPropertyCodec = propertyCodecMap[descriptor.codecName];
	        
	        if (coder == null)
	            coder = propertyCodecMap["object"];
	
		    var relativeParent:IAutomationObject = obj;
	            
	        var retValue:Object = coder.encode(automationManager, obj, descriptor, relativeParent);
            result.push({value:retValue, descriptor:descriptor});
        }
        
        return result;
	}

    /**
	 *  Returns the property values of an AutomationObject.
	 *
	 *  If names are given
	 */
    public function getProperties(objID:String, names:String):Object
    {
        return useErrorHandler(function():Object
        {
            var o:Object = { result:null, error:0 };
            var rid:AutomationID = AutomationID.parse(objID);
            var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
            var asNames:Array = names;
            var descriptors:Array = [];
			if(asNames && asNames.length)
            {
	            var automationClass:IAutomationClass =
            	    automationManager.automationEnvironment.getAutomationClassByInstance(obj) as IAutomationClass;;
				var propertyNameMap:Object = automationClass.propertyNameMap;
	            for (var i:int = 0; i < asNames.length; i++)
	            {
		            var propertyDescriptor:IAutomationPropertyDescriptor = 
	    	            propertyNameMap[ asNames[i] ];
	    	        if(propertyDescriptor)
	                {
						asNames[i] = propertyDescriptor.name;
	                    descriptors.push(propertyDescriptor);
	                }
	                else
	                	// descriptor was not found delete the entry.
	                	asNames.splice(i, 1);

	    	    }
            
            }
            
            var values:Array = automationManager.getProperties(obj, asNames);
			var x:Array = encodeValues(obj, values, descriptors);
            for (var no:int = 0; no < x.length; ++no)
	        {
    	        x[no] = x[no].value;
        	}

            o.result = x;
            return o;
        });
    }

    /**
	 *  @private
	 */
    public function getParent(objID:String):Object
    {
        return useErrorHandler(function():Object
        {
            var o:Object = { result:null, error:0 };
            var rid:AutomationID = AutomationID.parse(objID);
            var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
            obj = automationManager.getParent(obj);
            o.result = (obj 
                        ? automationManager.createID(obj).toString() 
                        : null);
            return o;
        });
    }


    /**
	 *  @private
	 */
    public function getTabularData(objID:String, begin:uint = 0, end:uint = 0):Object
    {
        return useErrorHandler(function():Object
        {
            var o:Object = { result:null, error:0 };
            var rid:AutomationID = AutomationID.parse(objID);
            var obj:IAutomationObject = automationManager.resolveIDToSingleObject(rid);
            var td:IAutomationTabularData = automationManager.getTabularData(obj);
            o.result = {
                columnTitles: td ? td.columnNames : [],
                tableData: (td 
                            ? td.getValues(begin, end) 
                            : [[]])
            };
            return o;
        });
    }

    /**
     *  @private
     */
    private function useErrorHandler(f:Function):Object
    {
        var o:Object = { result:null, error:0 };
        try
        {
        	automationManager.incrementCacheCounter();
            o = f();
        	automationManager.decrementCacheCounter();
        }
        catch (e:Error)
        {
        	automationManager.decrementCacheCounter();
            lastError = e;
            o.error = (e is AutomationError 
                       ? AutomationError(e).code 
                       : AutomationError.ILLEGAL_OPERATION);
            trace(e.message + ": " + e.getStackTrace());
        }
        return o;
    }


    /**
     *  @private
     *  Converts AQ specific strings to proper values.
     */
    private function convertArrayFromStringToAs(a:String):Array
    {
        var result:Array = a.split("_ARG_SEP_");
        return result;
    }

    /**
     *  Decodes an array of properties from a testing tool into an AS object.
     *  using the codecs.
     *
     *  @param obj the object that contains the properties to be encoded.
     * 
     *  @param args the property values to transcode.
     * 
     *  @param propertyDescriptors the property descriptors that describes the properties for this object.
     * 
     *  @param relativeParent the IAutomationObject that is related to this object.
     *
     *  @return the decoded property value.
     */
    public function decodeProperties(obj:Object,
                                     args:Array,
                                     propertyDescriptors:Array,
                                     interactionReplayer:IAutomationObject):void
    {	
        for (var i:int = 0; i < propertyDescriptors.length; i++)
        {
            var value:String = null;
            if (args != null && 
                i < args.length && 
                args[i] == "null" && 
                propertyDescriptors[i].defaultValue == "null")
                args[i] = null;
            if (args != null && 
                i < args.length && 
                ((args[i] != null  && args[i] != "")  || propertyDescriptors[i].defaultValue == null))
                setPropertyValue(obj, 
                                 args[i],
                                 propertyDescriptors[i],
                                 interactionReplayer);
            else if (propertyDescriptors[i].defaultValue != null)
                setPropertyValue(obj, 
                                 (propertyDescriptors[i].defaultValue == "null" 
                                      ? null 
                                      : propertyDescriptors[i].defaultValue), 
                                 propertyDescriptors[i], 
                                 interactionReplayer);
            else
                throw new Error("Missing Argument " + propertyDescriptors[i].name);
        }
    }
    

    /**
     *  @private
     */
    public function setPropertyValue(obj:Object, 
                                     value:Object,
                                     pd:AQPropertyDescriptor,
                                     relativeParent:IAutomationObject = null):void
    {
        var coder:IAutomationPropertyCodec = propertyCodecMap[pd.codecName];
        
        if (coder == null)
            coder = propertyCodecMap["object"];
            
	    if (relativeParent == null)
		    relativeParent = obj as IAutomationObject;

        coder.decode(automationManager, obj, value, pd, relativeParent);
	}
	
	/**
	 *  @private
	 */
	public static function getCodecHelper():IAQCodecHelper
	{
		return AQCodecHelper;
	}
	
//        private function configureListeners(dispatcher:IEventDispatcher):void 
//        {
//            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
//            dispatcher.addEventListener(Event.OPEN, openHandler);
//            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
//            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
//            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
//            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
//        }
//
//        private function completeHandler(event:Event):void {
//            
//            var loader:URLLoader = URLLoader(event.target);
//            //trace("completeHandler: " + loader.data);
//       
//            setTestingEnvironment(loader.data);
//
//			PopUpManager.createPopUp(DisplayObject(Application.application), FlexMonkey);
//        }
//
//        private function openHandler(event:Event):void {
//            //trace("openHandler: " + event);
//        }
//
//        private function progressHandler(event:ProgressEvent):void {
//            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
//        }
//
//        private function securityErrorHandler(event:SecurityErrorEvent):void {
//            Alert.show("securityErrorHandler: " + event);
//        }
//
//        private function httpStatusHandler(event:HTTPStatusEvent):void {
//            //trace("httpStatusHandler: " + event);
//        }
//
//        private function ioErrorHandler(event:IOErrorEvent):void {
//            Alert.show("ioErrorHandler: " + event);
//        }
//    
//	public function getRecords():String
//	{
//		return records.toXMLString();
//	}

}

}
