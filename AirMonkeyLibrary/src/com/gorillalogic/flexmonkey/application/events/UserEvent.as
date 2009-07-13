/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.events
{
	import flash.events.Event;

	public class UserEvent extends Event
	{
		public static const REGISTRATION_PROMPT:String = "registrationPrompt";
		
		public static const START_RECORDING:String = "recordStart";
		public static const STOP_RECORDING:String = "recordEnd";
		public static const START_PLAYING:String = "startPlaying";
		public static const STOP_PLAYING:String = "stopPlaying";		
		public static const START_PAUSING:String = "startPausing";
		public static const STOP_PAUSING:String = "stopPausing";
		
		public static const ADD_TEST_SUITE:String = "addTestSuite";
		public static const ADD_TEST_CASE:String = "addTestCase";
		public static const ADD_TEST:String = "addTest";
		public static const ADD_VERIFY:String = "addVerify";
		public static const ADD_PAUSE:String = "addPause";
		public static const DELETE_ITEM:String = "deleteItem";
		public static const UPDATE_ITEM:String = "updateItem";
		public static const SELECT_ITEM:String = "selectItem";
		public static const SELECT_ITEMS:String = "selectItems";
		
		public static const DRAG_MOVE:String = "dragMove";
		
		public static const TAKE_EXPECTED_SNAPSHOT:String = "takeExpectedSnapshot";
		public static const RETAKE_EXPECTED_SNAPSHOT:String = "retakeExpectedSnapshot";
		public static const SHOW_SNAPSHOT_WINDOW:String = "showSnapshotWindow";
		public static const SHOW_SPY_WINDOW:String = "showSpyWindow";
		
		public static const ALERT_CLICK:String = "alertClick";

		public static const PROPERTY_SELECT_ALL:String = "propertySelectAll";
		public static const PROPERTY_DESELECT_ALL:String = "propertyDeselectAll";
		public static const PROPERTY_INVERT_SELECTION:String = "propertyInvertSelection";
		public static const PROPERTY_UPDATE:String = "propertyUpdate";
		public static const PROPERTY_FILTER_CHANGE:String = "propertyFilterChange";
		public static const PROPERTY_ARROW_CLICK:String = "propertyArrowClick";
		public static const PROPERTY_SELECT_CLICK:String = "propertySelectClick";

		public static const STYLE_SELECT_ALL:String = "styleSelectAll";
		public static const STYLE_DESELECT_ALL:String = "styleDeselectAll";
		public static const STYLE_INVERT_SELECTION:String = "styleInvertSelection";
		public static const STYLE_UPDATE:String = "styleUpdate";
		public static const STYLE_FILTER_CHANGE:String = "styleFilterChange";
		public static const STYLE_ARROW_CLICK:String = "styleArrowClick";
		public static const STYLE_SELECT_CLICK:String = "styleSelectClick";

		public static const PROJECT_REQUEST_FOR_NEW:String = "projectRequestForNew";
		public static const PROJECT_REQUEST_FOR_OPEN:String = "projectRequestForOpen";
		public static const PROJECT_EDIT_PROPERTIES:String = "projectEditProperties";
		public static const PROJECT_PROPERTIES_UPDATE:String = "projectPropertiesUpdate";
		public static const PROJECT_NEW_URL:String = "projectNewURL";
		
		public static const HELP_ABOUT:String = "helpAbout";

		public static const MONKEY_EXIT:String = "monkeyExit";

		public var item:Object;
		public var dropTargetItem:Object;
		public var beforeDropTargetItem:Object;
		public var dropAtBeforeDropTargetLevel:Boolean
		
		public function UserEvent(type:String, 
										item:Object = null,
										dropTargetItem:Object = null,
										beforeDropTargetItem:Object = null,
										dropAtBeforeDropTargetLevel:Boolean = false,
										bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
			this.dropTargetItem = dropTargetItem;
			this.beforeDropTargetItem = beforeDropTargetItem;
			this.dropAtBeforeDropTargetLevel = dropAtBeforeDropTargetLevel;
		}
	}
}