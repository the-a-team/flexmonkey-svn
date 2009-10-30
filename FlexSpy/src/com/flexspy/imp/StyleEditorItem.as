/**
 * FlexSpy 1.2
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://coderpeon.ovh.org]
 */
package com.flexspy.imp {

	import flash.utils.getQualifiedClassName;
	import flash.events.EventDispatcher;
	import mx.binding.utils.BindingUtils;
	import flash.events.Event;
	import flash.utils.describeType;
	
	public class StyleEditorItem extends PropertyEditorItem {
		private static var COLOR: String = "color";
		private static var COLORS: String = "colors";


		/**
		 * Initializes a new item with the supplied name
		 */
		public function StyleEditorItem(itemName: String) {
			super(itemName);
		}
		
		protected override function getItemDisplayValue(item: *): String {
			if (item == null) { // works for both undefined and null values
				return "";
			}
			
			if (format == "Color") {
				return Utils.toHexColor(Number(item));
			} else if (format == "File") {
				if (type == "String") {
					return String(item);
				} else {
					return Utils.formatClass(item);
				}
			} else if (type == "Class") {
				return Utils.formatClass(item);
			}
			
			// Default behavior
			return (item == null) ? "" : item.toString();
		}
		
		protected override function detectFormat(name: String, type: String): String {
			if (Utils.endsWith(name, "color", false) && (type == "Number" || type == "uint" || type == "int")) {
				return "Color";
			} else if (Utils.endsWith(name, "colors", false) && (type == "Array")) {
				return "Color";
			}
			
			// Unknown
			return super.detectFormat(name, type);
		}
	}
}