/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.monkeyFluintAirTestRunner
{
   import flash.events.Event;

   public class TestModuleEvent extends Event
   {
      public static const TEST_MODULES_READY : String = "testModulesReady";
      
      public var suites : Array;
      
      public function TestModuleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(type, bubbles, cancelable);
      }
      
   }
}