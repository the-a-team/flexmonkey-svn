/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
	import com.gorillalogic.flexmonkey.application.utilities.AttributeFinder;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	import com.gorillalogic.flexmonkey.application.VOs.TargetVO;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class AttributeManager extends EventDispatcher
	{
		public var mateDispatcher : IEventDispatcher;
				
		[Bindable] public var propertyCollection:ArrayCollection;
		[Bindable] public var styleCollection:ArrayCollection;

		private var _propertyFilter: String;
		public function get propertyFilter():String{
			return _propertyFilter;
		}
		public function set propertyFilter(s:String):void{
			_propertyFilter = s.toLowerCase();
		}		
		
		private var propertySort: Sort;
		
		private var _styleFilter: String;
		public function get styleFilter():String{
			return _styleFilter;
		}
		public function set styleFilter(s:String):void{
			_styleFilter = s.toLowerCase();
		}	
				
		private var styleSort: Sort;
		
		private var attributeFinder:AttributeFinder = new AttributeFinder();

		private var _selectedItem:MonkeyRunnable;
		public function get selectedItem():MonkeyRunnable{
			return _selectedItem;
		}
		public function set selectedItem(s:MonkeyRunnable):void{
			_selectedItem = s;
//			refreshWindow();
		}
		
		public function refreshWindow():void{
			if(selectedItem is VerifyMonkeyCommand){
				propertyFilter = "";
				styleFilter = "";
				VerifyMonkeyCommand(selectedItem).getTarget(this.finishRefreshWindow);
			}			
		}

		public function finishRefreshWindow(targetVO:TargetVO):void{
			propertyCollection = new ArrayCollection(targetVO.propertyArray);
			propertySort = new Sort();
			propertySort.fields = [new SortField("name",true)];
			propertyCollection.sort = propertySort;
			propertyCollection.filterFunction = filterProperties;
			propertyCollection.refresh();
			
			styleCollection = new ArrayCollection(targetVO.styleArray);
			styleSort = new Sort();
			styleSort.fields = [new SortField("name",true)];
			styleCollection.sort = styleSort;
			styleCollection.filterFunction = filterStyles;
			styleCollection.refresh();		
			var verifyMonkeyCommand:VerifyMonkeyCommand = VerifyMonkeyCommand(selectedItem);
			for(var i:uint = 0;i<verifyMonkeyCommand.attributes.length;i++){
				if(verifyMonkeyCommand.attributes[i].type == AttributeVO.PROPERTY){
					var property:AttributeVO = verifyMonkeyCommand.attributes[i];
					propertyCollectionLoop:for(var j:uint=0;j<propertyCollection.length;j++){
						if(propertyCollection[j].name == property.name){
							propertyCollection[j].selected = true;
							propertyCollection[j].expectedValue = property.expectedValue;
							propertyCollection[j].result = property.result;
							break propertyCollectionLoop;
						}
					}
				}else{
					var style:AttributeVO = verifyMonkeyCommand.attributes[i];
					styleCollectionLoop:for(var k:uint=0;k<styleCollection.length;k++){
						if(styleCollection[k].name == style.name){
							styleCollection[k].selected = true;
							styleCollection[k].expectedValue = style.expectedValue;
							styleCollection[k].result = style.result;
							break styleCollectionLoop;
						}
					}
				}
			}
		}


		private var target:Object;
		      
		public function AttributeManager()
		{
		}
		
		public function filterProperties(item:Object):Boolean{
			if(propertyFilter == null || propertyFilter == ""){	
				return true;
			} else {
				return item.name.toLowerCase().indexOf(propertyFilter) >= 0;
			}
		}

		public function filterStyles(item:Object):Boolean{
			if(styleFilter == null || styleFilter == ""){	
				return true;
			} else {
				return item.name.toLowerCase().indexOf(styleFilter) >= 0;
			}
		}
		
        public function propertySelectAll():void{
        	for(var i:uint=0;i<propertyCollection.length;i++){
        		propertyCollection[i].selected = true;
        	}
        }
        
        public function propertyDeselectAll():void{
        	for(var i:uint=0;i<propertyCollection.length;i++){
        		propertyCollection[i].selected = false;
        	}
        }
       
      	public function propertyInvertSelection():void{
        	for(var i:uint=0;i<propertyCollection.length;i++){
        		propertyCollection[i].selected = !propertyCollection[i].selected;
        	}
        }
        
		public function propertyFilterChange(filterText:Object): void {
			propertyFilter = filterText as String;
			propertyCollection.refresh();
		}	     
		
		public function propertyArrowClick(item:AttributeVO):void{
			item.expectedValue = item.actualValue;
			item.result = "NOT_RUN"
		}   
   
		public function propertySelectClick(item:AttributeVO):void{
			item.selected = !item.selected;
			if(item.selected){
				item.expectedValue = item.actualValue;
			}else{
				item.expectedValue = null;
			}			
		}    
   
//---
   
        public function styleSelectAll():void{
        	for(var i:uint=0;i<styleCollection.length;i++){
        		styleCollection[i].selected = true;
        	}
        }
        
        public function styleDeselectAll():void{
        	for(var i:uint=0;i<styleCollection.length;i++){
        		styleCollection[i].selected = false;
        	}
        }
       
      	public function styleInvertSelection():void{
        	for(var i:uint=0;i<styleCollection.length;i++){
        		styleCollection[i].selected = !styleCollection[i].selected;
        	}
        }
 
		public function styleFilterChange(filterText:Object): void {
			styleFilter = filterText as String;
			styleCollection.refresh();
		}	   
      
		public function styleArrowClick(item:AttributeVO):void{
			item.expectedValue = item.actualValue;
			item.result = "NOT_RUN";
		}   
   
		public function styleSelectClick(item:AttributeVO):void{
			item.selected = !item.selected;	
			if(item.selected){
				item.expectedValue = item.actualValue;
			}else{
				item.expectedValue = null;
			}				
		} 
		
		public function update():void{
        	var i:uint;
        	var attributeVO:AttributeVO;
        	var verifyMonkeyCommand:VerifyMonkeyCommand = VerifyMonkeyCommand(selectedItem).clone();
        	var attributeArray:Array = [];
        	for(i=0;i<propertyCollection.length;i++){
        		if(propertyCollection[i].selected){
        			attributeArray.push(propertyCollection[i]);
        		}
        	}
        	for(i=0;i<styleCollection.length;i++){
        		if(styleCollection[i].selected){
        			attributeArray.push(styleCollection[i]);
        		}
        	}        	
        	verifyMonkeyCommand.attributes = new ArrayCollection(attributeArray);
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.UPDATE_ITEM,verifyMonkeyCommand));			
		}
	}
}