/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.utilities
{
	
	import com.flexspy.imp.metadata.FrameworkMetadata;
	import com.flexspy.imp.metadata.StyleMetadata;
	
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	
	import flash.display.DisplayObject;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.styles.IStyleClient;
	
	public class AttributeFinder
	{	
		private static var FILTERED_PROPERTIES: Array = 
        	["textSnapshot", 
        	"accessibilityImplementation", 
        	"accessibilityProperties", 
        	"automationDelegate", 
        	"automationValue", 
        	"automationTabularData", 
        	"numAutomationChildren", 
        	"contextMenu", 
        	"focusManager", 
        	"styleDeclaration", 
        	"systemManager", 
        	"descriptor", 
        	"rawChildren", 
        	"verticalScrollBar", 
        	"horizontalScrollBar", 
        	"stage", 
        	"graphics", 
        	"focusPane", 
        	"loaderInfo", 
        	"moduleFactory", 
        	"transform", 
        	"soundTransform", 
        	"inheritingStyles", 
        	"nonInheritingStyles" ];
        	
		public function AttributeFinder()
		{
			
		}
		
		//
		// Properties
		//

		public function getProperties(targetDisplayObject: Object): ArrayCollection {
			var description: XML = describeType(targetDisplayObject);
			
			var property: AttributeVO;
			var properties:ArrayCollection = new ArrayCollection();
			var propertyNames:Array = new Array();
			
			for each (var accessor: XML in description.accessor) {
				property = inspectPropertyXML(accessor, targetDisplayObject, propertyNames);
				if (property != null) {
					property.setActualValueForTarget(targetDisplayObject);
					properties.addItem(property);
					propertyNames.push(property.fullyQualifiedName);
				}
			}
			for each (var variable: XML in description.variable) {
				property = inspectPropertyXML(variable, targetDisplayObject, propertyNames);
				if (property != null) {
					property.setActualValueForTarget(targetDisplayObject);
					properties.addItem(property);
					propertyNames.push(property.fullyQualifiedName);
				}
			}
			for(var name:String in targetDisplayObject) {
				property = inspectProperty(name, null, getQualifiedClassName(targetDisplayObject[name]), targetDisplayObject, propertyNames, "readonly");
				if (property != null) {
					property.setActualValueForTarget(targetDisplayObject);
					properties.addItem(property);
					propertyNames.push(property.fullyQualifiedName);
				}					
			}
			
			return properties;
		}

		
		private function inspectPropertyXML(propertyXML: XML, displayObject: Object, propertyNames: Array): AttributeVO {
			//trace("inspecting property " + property.@name);
			if (propertyXML.@access == "writeonly") {
				return null;
			}
			return inspectProperty(propertyXML.@name, propertyXML.@uri, propertyXML.@type, displayObject, propertyNames, propertyXML.@access);
		}
		
		private function inspectProperty(name: String, namespaceURI:String, type: String, displayObject: Object, propertyNames: Array, access: String): AttributeVO {
			if (name == null || name.length == 0 || name.charAt(0) == '$' || FILTERED_PROPERTIES.indexOf(name) >= 0) {
				// Invalid or private property, or already present (describeType method might return several times the same properties)
				return null;
			}
		
			var attribute: AttributeVO = new AttributeVO(name, namespaceURI, AttributeVO.PROPERTY);
			if ( propertyNames.indexOf(attribute.fullyQualifiedName) != -1 ) {
				return null;
			}
			return attribute;
		}
		
		//
		// Styles
		//
        
        public function getStyles(target: DisplayObject): ArrayCollection {       	
        	var targetStyleClient:IStyleClient = target as IStyleClient;
			var style:AttributeVO;
			var styles:ArrayCollection = new ArrayCollection();
			var styleNames:Array = new Array();
			var name:String;
			
			var stylesMetadata: Array = FrameworkMetadata.getClassStyles(targetStyleClient);
			if (stylesMetadata.length > 0) {
				for each (var styleMetadata: StyleMetadata in stylesMetadata) {
					style = createStyle(targetStyleClient, styleMetadata);
					if (style != null) {
						style.setActualValueForTarget(targetStyleClient);
						styles.addItem(style);
						styleNames.push(style.name);
					}
				}
			} else {
				// Metadata not found for this component. Show all possible styles (non editable)
				var nonInheritingStyles: Object = targetStyleClient.nonInheritingStyles;
				if (nonInheritingStyles != null) {
					for (name in nonInheritingStyles) {
						style = inspectStyle(targetStyleClient, name, nonInheritingStyles, styleNames, false);
						if (style != null) {
							style.setActualValueForTarget(targetStyleClient);
							styles.addItem(style);
							styleNames.push(style.name);
						}
					}
				}
	
				var inheritingStyles: Object = targetStyleClient.inheritingStyles;
				if (inheritingStyles != null) {
					for (name in inheritingStyles) {
						style = inspectStyle(targetStyleClient, name, inheritingStyles, styleNames, true);
						if (style != null) {
							style.setActualValueForTarget(targetStyleClient);
							styles.addItem(style);
							styleNames.push(style.name);
						}
					}
				}
			}
			return styles;
        }
        
       	private function createStyle(stylableObject: IStyleClient, styleMetadata: StyleMetadata): AttributeVO {
			var style:AttributeVO = new AttributeVO(styleMetadata.name, null, AttributeVO.STYLE);
			return style;
        }

        private function inspectStyle(stylableObject: IStyleClient, name: String, styles: Object, styleNames: Array, inherited: Boolean): AttributeVO {
			if (name == null || name.length == 0 || name.charAt(0) == '$' || styleNames.indexOf(name) != -1) {
				// Invalid or private style, or already present (method might return several times the same properties)
				return null;
			}

			var style: AttributeVO = new AttributeVO(name, null, AttributeVO.STYLE);
			return style;
        }
	}
}