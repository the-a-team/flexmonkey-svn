/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.core
{
	import flash.display.DisplayObject;
	
	import mx.automation.Automation;
	import mx.automation.AutomationID;
	import mx.automation.IAutomationObject;
	import mx.core.Application;
	import mx.core.IChildList;
	import mx.core.UIComponent;
	
	public class MonkeyUtils
	{
		/**
		 * Find the first component with the specified property/value pair. If a container is specified, then
		 * only its children and descendents are searched. The search order is (currently) indeterminate. If no container is specified,
		 * then all components will be searched. If the prop value is "automationID", then the id is resolved directly without searching.
		 */
		public static function findComponentWith(value: String, prop:String="automationName", container:UIComponent=null):UIComponent {
			
			if (prop == "automationID") {
                var rid:AutomationID = AutomationID.parse(value);
	            var obj:IAutomationObject = Automation.automationManager.resolveIDToSingleObject(rid);
	            return UIComponent(obj);
			}
			
			if (container == null) {
				// Check windows whose parent is the SystemManager
				var kids:IChildList = UIComponent(Application.application).systemManager.rawChildren;
				for (i = 0; i < kids.numChildren; i++) {
					var child:DisplayObject = kids.getChildAt(i);
//trace(child);
					if (!(child is UIComponent)) {
						continue;
					}
					if (child.hasOwnProperty(prop) && child[prop] == value) {
						return UIComponent(child); 
					}				
					child = findComponentWith(value, prop, UIComponent(child));
					if (child != null) {
						return UIComponent(child);
					}
				}
				return null;
			}
			var numChildren:int = container.numAutomationChildren;
			if (numChildren == 0) {
				return null;
			}
			
			var component:UIComponent;
			for (var i:int=0; i < numChildren; i++) {
				child = container.getAutomationChildAt(i) as DisplayObject;
//trace(child);

				if (!(child is UIComponent)) {
					continue;
				}
				
				if (child.hasOwnProperty(prop) && child[prop] == value) {
					return UIComponent(child); 
				} else {
					var grandChild:UIComponent = findComponentWith(value, prop, UIComponent(child));
//trace(grandChild);
					if (grandChild != null) {
						return grandChild;
					}
				}
			}
			
			return null;
				
		}
		
		/**
		 * @return the path of FlexMonkey.swf's file location
		 */
		static public function getAppPath():String {
			return Application.application.url.split('/').slice(0,-1).join('/');
		}


	}
}