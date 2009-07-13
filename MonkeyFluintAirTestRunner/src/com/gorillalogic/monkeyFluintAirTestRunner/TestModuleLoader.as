/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.monkeyFluintAirTestRunner
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   import mx.core.IFlexModuleFactory;
   import mx.events.ModuleEvent;
   import mx.logging.ILogger;
   import mx.managers.ISystemManager;
   
   import net.digitalprimates.fluint.modules.ITestSuiteModule;
   
   public class TestModuleLoader extends EventDispatcher
   {
      private var _logger : ILogger;
      private var _context : LoaderContext;
      private var _loader : Loader;
      
      public var file : File;
      public var suites : Array;
      
      public function TestModuleLoader(logger : ILogger, context : LoaderContext)
      {
         _logger = logger;
         _context = context;
         suites = new Array();
      }

      public function load() : void
      {
         _loader = new Loader();

         _loader.contentLoaderInfo.addEventListener(Event.INIT, moduleInit);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, moduleComplete);
		   _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, moduleProgress);
		   _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, moduleError);
		   _loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, moduleError);
		   
		   _loader.loadBytes(readBytes(this.file), _context);
      }

      private function readBytes(module : File) : ByteArray
      {
         var byteArray :ByteArray = new ByteArray();
         
         var stream : FileStream = new FileStream();
		   stream.open(module, FileMode.READ );
			stream.readBytes(byteArray);
			
			return byteArray;
      }
      
      private function moduleInit(event : Event) : void
      {
         var loaderInfo : LoaderInfo = LoaderInfo(event.currentTarget);
         
         //If SWF contained an Application rather than a Module
         if(loaderInfo.content is ISystemManager)
         {
            var moduleEvent : ModuleEvent = new ModuleEvent(ModuleEvent.ERROR, event.bubbles, event.cancelable);
            moduleEvent.errorText = "Incompatible module definition loaded.  Ignoring SWF.";
            dispatchEvent(moduleEvent);
         }
         else
         {
            //Wait for Module to be ready to process
            loaderInfo.content.addEventListener(ModuleEvent.READY, moduleReady);
         }
      }

      private function moduleReady(event : Event)  : void
      {
         _logger.debug("MODULE READY");
         
         var moduleEvent : ModuleEvent = null;
         
         try
         {
            //Am I going to be able to load this swf as a ITestSUiteModule?
            var factory : IFlexModuleFactory = IFlexModuleFactory(event.currentTarget);
            var tsModule : ITestSuiteModule = ITestSuiteModule(factory.create());
            this.suites = tsModule.getTestSuites();
            
            moduleEvent = new ModuleEvent(ModuleEvent.READY, event.bubbles, event.cancelable);
         }
         catch(e : Error)
         {
            moduleEvent = new ModuleEvent(ModuleEvent.ERROR, event.bubbles, event.cancelable);
            moduleEvent.errorText = e.message;
         }
         
	      dispatchEvent(moduleEvent);
      }
      
      private function moduleProgress(event : ProgressEvent) : void
      {
         var moduleEvent:ModuleEvent = new ModuleEvent(ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = event.bytesLoaded;
         moduleEvent.bytesTotal = event.bytesTotal;
         
         _logger.debug("MODULE LOADING: " + moduleEvent.bytesLoaded + " bytes");
         
         dispatchEvent(moduleEvent);
      }
      
      private function moduleComplete(event : Event) : void
      {
         var loaderInfo:LoaderInfo = LoaderInfo( event.currentTarget );
       
         var moduleEvent : ModuleEvent = new ModuleEvent(ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = loaderInfo.loader.contentLoaderInfo.bytesLoaded;
         moduleEvent.bytesTotal = loaderInfo.loader.contentLoaderInfo.bytesTotal;

         _logger.debug("MODULE COMPLETE: " + moduleEvent.bytesLoaded + " bytes");
         
         dispatchEvent(moduleEvent);
      }
      
      private function moduleError(event : ErrorEvent) : void
      {
         _logger.debug("MODULE ERROR");
         
         var moduleEvent:ModuleEvent = new ModuleEvent(ModuleEvent.ERROR, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = 0;
         moduleEvent.bytesTotal = 0;
         moduleEvent.errorText = event.text;
         dispatchEvent(moduleEvent);
      }
   }
}