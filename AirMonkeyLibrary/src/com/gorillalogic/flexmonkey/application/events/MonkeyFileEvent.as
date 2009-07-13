/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.events
{
	import flash.events.Event;

	/**
	 * The MonkeyFileEvent is the event object passed to the event listener 
	 * for MonkeyFile events.
	 * 
	 * 
	 */
	public class MonkeyFileEvent extends Event
	{
	    /**
	     *  The <code>MonkeyFileEvent.PREFERENCES_FILE_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>configFileOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType configFileOpen
	     */				
		public static const PREFERENCES_FILE_OPEN:String = "preferencesFileOpen";		
		public static const PREFERENCES_FILE_SAVE:String = "preferencesFileSave";

public static const APPLICATION_PROMPT_FOR_NEW:String = "applicationPromptForNew";

public static const PROJECT_BROWSE_FOR_NEW:String = "projectBrowseForNew";
public static const PROJECT_BROWSE_FOR_OPEN:String = "projectBrowseForOpen";
public static const PROJECT_FILE_OPEN:String = "projectFileOpen";
public static const PROJECT_FILE_SAVE:String = "projectFileSave";
public static const PROJECT_CHECK_FOR_MONKEY_FILES:String = "projectCheckForMonkeyFiles";

public static const GENERATED_CODE_SAVE:String = "generatedCodeSave";
		
	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_REQUEST_FOR_NEW</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileRequestForNew</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileRequestForNew
	     */	
		public static const TEST_FILE_REQUEST_FOR_NEW:String = "testFileRequestForNew";

	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_NEW</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileNew</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileNew
	     */			
	    public static const TEST_FILE_NEW:String = "testFileNew";

	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_REQUEST_FOR_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileRequestForOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileRequestForOpen
	     */	
		public static const TEST_FILE_REQUEST_FOR_OPEN:String = "testFileRequestForOpen";

	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileOpen
	     */
		public static const TEST_FILE_OPEN:String = "testFileOpen";		
		
	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_PROMPT_FOR_SAVE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFilePromptForSave</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFilePromptForSave
	     */
		public static const TEST_FILE_PROMPT_FOR_SAVE:String = "testFilePromptForSave";	
		
	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_PROMPT_SAVE_CANCELLED</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileSaveCancelled</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileSaveCancelled
	     */			
		public static const TEST_FILE_SAVE_CANCELLED:String = "testfileSaveCancelled";
		
	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_DONT_SAVE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileDontSave</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileDontSave
	     */		
		public static const TEST_FILE_DONT_SAVE:String = "testFileDontSave";

	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_REQUEST_FOR_SAVE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileRequestForSave</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileRequestForSave
	     */		
		public static const TEST_FILE_REQUEST_FOR_SAVE:String = "testFileRequestForSave";
				
	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_SAVE</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileSave</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileSave
	     */				
		public static const TEST_FILE_SAVE:String = "testFileSave";

	    /**
	     *  The <code>MonkeyFileEvent.TEST_FILE_SAVE_AS3</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>testFileSaveAS3</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType testFileSave
	     */				
		public static const TEST_FILE_SAVE_AS3:String = "testFileSaveAS3";

	    /**
	     *  The <code>MonkeyFileEvent.TARGET_SWF_REQUEST_FOR_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>targetSWFRequestForOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType targetSWFRequestForOpen
	     */		
		public static const TARGET_SWF_REQUEST_FOR_OPEN:String = "targetSWFRequestForOpen";

	    /**
	     *  The <code>MonkeyFileEvent.TARGET_SWF_BROWSE_FOR_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>targetSWFBrowseForOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType targetSWFBrowseForOpen
	     */	
		public static const TARGET_SWF_BROWSE_FOR_OPEN:String = "targetSWFBrowseForOpen";

	    /**
	     *  The <code>MonkeyFileEvent.TARGET_SWF_OPEN</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>targetSWFOpen</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType targetSWFOpen
	     */	
		public static const TARGET_SWF_OPEN:String = "targetSWFOpen";
		
	    /**
	     *  The <code>MonkeyFileEvent.SAVE_SNAPSHOT</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>saveSnapshot</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType saveSnapshot
	     */			
	    public static const SAVE_SNAPSHOT:String = "saveSnapshot";
	
		
	    /**
	     *  The <code>MonkeyFileEvent.LOAD_SNAPSHOT</code> constant defines the value of the
	     *  <code>type</code> property of the event object for an <code>loadSnapshot</code> event.
	     *
	     *  <p>The properties of the event object have the following values:</p>
	     *  <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
	     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
	     *       event listener that handles the event.</td></tr>
	     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
	     *       it is not always the Object listening for the event.
	     *       Use the <code>currentTarget</code> property to always access the
	     *       Object listening for the event.</td></tr>
		 * 	   <tr><td><code>url</code></td><td>--</td></tr>
		 * 	   <tr><td><code>data</code></td><td>--</td></tr>
  		 * 	   <tr><td><code>oldURL</code></td><td>--</td></tr>
  	     * 
	     *  </table>
	     *
	     *  @eventType loadSnapshot
	     */			
		public static const LOAD_SNAPSHOT:String = "loadSnapshot";
					
		/**
		 * Can contain a file URL for reading or writing.
		 * 
		 */ 
		public var url:String;
		
		/**
		 * Can contain data to be written to a file, or data read from a file.
		 * 
		 */
		public var data:Object;
		
		/**
		 * For a file move operation, contains the original URL of the file.
		 * 
		 */
		public var oldURL:String;

	    /**
	     *  Constructor.
	     *
	     *  @param type The event type; indicates the action that caused the event.
	     *
	     *  @param url Can contain a file URL for reading or writing.
	     * 
	     *  @param data Can contain data to be written to a file, or data read from a file.
	     * 
	     *  @param oldUrl For a file move operation, contains the original URL of the file.
	     * 
	     *  @param bubbles Specifies whether the event can bubble up
	     *  the display list hierarchy.
	     *
	     *  @param cancelable Specifies whether the behavior
	     *  associated with the event can be prevented.
	     */						
		public function MonkeyFileEvent(type:String, url:String="", data:Object = null, oldURL:String="",
			bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.url = url;
			this.oldURL = oldURL;
			this.data = data;
		}
	}
}