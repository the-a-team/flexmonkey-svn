/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.monkeyCommands
{
	import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
	import com.gorillalogic.flexmonkey.application.VOs.SnapshotVO;
	import com.gorillalogic.flexmonkey.application.VOs.TargetVO;
	import com.gorillalogic.flexmonkey.application.events.MonkeyFileEvent;
	import com.gorillalogic.flexmonkey.application.managers.BrowserConnectionManager2;
	import com.gorillalogic.flexmonkey.application.utilities.AttributeFinder;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.core.MonkeyTest;
	import com.gorillalogic.flexmonkey.core.MonkeyUtils;
	import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import com.gorillalogic.flexmonkey.application.events.AlertEvent;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	[RemoteClass]		
	[Bindable]
	public class VerifyMonkeyCommand extends MonkeyRunnable
	{
		public var mateDispatcher:IEventDispatcher = IEventDispatcher(this);
		
		// NOTE: Currently the only place we actually use non-null values for this constructor's parameters is in the generated code.		
		public function VerifyMonkeyCommand(description:String=null,
											snapshotURL:String=null,
											value:String=null,
											prop:String=null,
											verifyBitmap:Boolean=false,	
											attributes:ArrayCollection=null,
											containerValue:String=null,
											containerProp:String=null)
		{
			super(null);
			this.description = description;
			this.snapshotURL = snapshotURL;
			this.value = value;
			this.prop = prop;
			this.containerValue = containerValue;
			this.containerProp = containerProp;
			this.verifyBitmap = verifyBitmap;
			this.error = null;
			if(attributes != null){
				this.attributes = attributes;
			}else{
				this.attributes = new ArrayCollection();
			}

		}
				
		private var runTimer:Timer;		
				
		override public function execute(runner:MonkeyCommandRunner, timer:Timer=null):Boolean{
		    runTimer = timer;
			mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.EXECUTE,this));			
		    if(value != null && value != ""){	// ignore verify execution if user hasn't specified a target
				takeActualSnapshot();
		    }
			return true;	
		}								

		override public function get xml():XML{
			var xml:XML = 
			<Verify description={description} 
				snapshotURL={snapshotURL} value={value} prop={prop}
				verifyBitmap={verifyBitmap} />
			if ( !isEmpty(containerValue) ) { xml.@containerValue = containerValue };
			if ( !isEmpty(containerProp) ) { xml.@containerProp = containerProp };
			for ( var i:uint = 0; i < attributes.length; i++ ) {
				var attribute:AttributeVO = AttributeVO(attributes[i]);
				var attributeXML:XML = attribute.xml;
				xml.appendChild(attributeXML);
			}
			return xml;	
		}	

		private function quote(arg:Object):String {
			if (arg is String) {
				if ( isEmpty(String(arg)) ) {
					return "null";
				} else {
					return "'" + String(arg) + "'";
				}
			} else {
				return String(arg);
			}
		}
		
		private function isEmpty(arg:String):Boolean {
			return ( arg == null || arg == "" || arg == "null" ); // Check for "null" only needed for backwards XML compatibility
		}

		public function getAS3(testName:String):String {
			var as3:String;
			
			as3 = "new VerifyMonkeyCommand(";
			as3 += quote(description) + ", ";
			as3 += ( verifyBitmap ? quote(snapshotURL) : "null" ) + ", ";
			as3 += quote(value) + ", ";
			as3 += quote(prop) + ", ";
			as3 += quote(verifyBitmap);
			
			if ( attributes.length != 0 ) {
				as3 += ",\n                    new ArrayCollection([";				
				var separator:String = "";
				for each ( var attribute:AttributeVO in attributes ) {
					as3 += separator + "\n";
					as3 += "                        new AttributeVO("
						+ quote(attribute.name) + ", "
						+ quote(attribute.namespaceURI) + ", "
						+ quote(attribute.type) + ", "
						+ quote(attribute.expectedValue)
					    + ")";
					separator = ",";
				}			
				as3	+= "\n                    ])";
			}
			
			if ( !isEmpty(containerValue) || !isEmpty(containerProp) ) {
				if ( attributes.length == 0 ) {
					// Tricky. Need the placeholder null value for the attributes array here 
					as3 += ", null";
				}
				as3 += ", " + quote(containerValue);
				as3 += ", " + quote(containerProp);
			}
			as3 += ")";
			
			return as3;
		}
		
		private var _description:String;
		public function get description():String{
			return _description;
		}
		public function set description(d:String):void{
			_description = d;
		}
		
		private var _snapshotURL:String;
		public function get snapshotURL():String{
			return _snapshotURL;
		}
		public function set snapshotURL(url:String):void{
			_snapshotURL = url;
		}
		
		private var _snapshotResult:String;
		public function get snapshotResult():String{
			return _snapshotResult;
		}
		public function set snapshotResult(r:String):void{
			_snapshotResult = r;
		}
				
		private var _value:String;
		public function get value():String{
			return _value;
		}
		public function set value(v:String):void{
			_value = v;
		}
		
		private var _prop:String;
		public function get prop():String{
			return _prop;
		}
		public function set prop(p:String):void{
			_prop = p;
		}
		
		private var _containerValue:String;
		public function get containerValue():String{
			return _containerValue;
		}
		public function set containerValue(v:String):void{
			_containerValue = v;
		}
		
		private var _containerProp:String;
		public function get containerProp():String{			
			return _containerProp;
		}
		public function set containerProp(p:String):void{
			_containerProp = p;
		}	
		
		private var _verifyBitmap:Boolean;
		public function get verifyBitmap():Boolean{			
			return _verifyBitmap;
		}
		public function set verifyBitmap(p:Boolean):void{
			_verifyBitmap = p;
		}		
		
		private var _expectedSnapshot:SnapshotVO;
		[Bindable ("expectedSnapshotSet")]
		public function get expectedSnapshot():SnapshotVO{			
			return _expectedSnapshot;	
		}
		public function set expectedSnapshot(s:SnapshotVO):void{
			_expectedSnapshot = s;
			dispatchEvent(new Event("expectedSnapshotSet"));
			compareSnapshots();			
		}

		private var _actualSnapshot:SnapshotVO;
		[Bindable ("actualSnapshotSet")]
		public function get actualSnapshot():SnapshotVO{
			return _actualSnapshot;	
		}
		public function set actualSnapshot(s:SnapshotVO):void{
			_actualSnapshot = s;
			dispatchEvent(new Event("actualSnapshotSet"));	
			compareSnapshots();		
		}

		private function getURL():String{
			return UIDUtil.createUID() + ".snp";					
		}
		
		private var _attributes:ArrayCollection;
		public function get attributes():ArrayCollection{			
			return _attributes;
		}
		public function set attributes(p:ArrayCollection):void{
			_attributes = p;
			
		}
		
		override public function get shortDescription():String {
			return "VerifyMonkeyCommand " + value;
		}
				
		override public function get thinkTime():uint {
			return MonkeyTest(parent).defaultThinkTime;
		}	
		
		// this function is needed so that dragging does not load the bitmap...
		public function loadSnapshot():void{
			if(!_expectedSnapshot && snapshotURL){
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.LOAD_SNAPSHOT,snapshotURL,this));
			}				
		}		
		
		private var attributeFinder:AttributeFinder = new AttributeFinder();
		public function getTarget(callBack:Function):void{
		    if(BrowserConnectionManager2.browserConnection != null && BrowserConnectionManager2.browserConnection.useBrowser){ 
		       	if(BrowserConnectionManager2.browserConnection.connected){
		       		BrowserConnectionManager2.browserConnection.getTarget(this,callBack);
		       	}
		    }else{
			    var target:UIComponent = null;				
				var container:UIComponent = null;
				if (!isEmpty(containerValue)) {
					container = MonkeyUtils.findComponentWith(containerValue, containerProp); 
				}
				target = MonkeyUtils.findComponentWith(value, prop, container);
				var propertyArray:Array;
				var styleArray:Array;
				var snapshotVO:SnapshotVO;
				if(target != null){
					propertyArray = attributeFinder.getProperties(target).source;
					styleArray = attributeFinder.getStyles(target).source;			
					var bitmapData:BitmapData = new BitmapData(target.width,target.height);
					bitmapData.draw(target);		
					snapshotVO = new SnapshotVO();	
					snapshotVO.bitmapData = bitmapData;		
				}
				
				var targetVO:TargetVO = new TargetVO(propertyArray, styleArray, snapshotVO);				
				callBack(targetVO);
		    }
/*		    
			if ( target == null ) {
				throw new MonkeyAutomationError(
					"VerifyMonkeyCommand " + this.description + ": Could not find target " + value,
					"Could not find target " + value);
			}
*/			
		}
		
		public function processExpectedSnapshot(uiCommand:UIEventMonkeyCommand):void{
			var target:UIComponent;
			value = uiCommand.value;
			prop = uiCommand.prop;
			containerValue = uiCommand.containerValue;
			containerProp = uiCommand.containerProp;			
			getTarget(this.finishProcessExpectedSnapshot);
		}		
		
		public function finishProcessExpectedSnapshot(targetVO:TargetVO):void{
			if ( targetVO.snapshotVO == null ) {
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","VerifyMonkeyCommand " + this.description, "Could not find target " + value));
			}else{
				if(!snapshotURL || snapshotURL == ""){
					snapshotURL = getURL();	
				} 			
				expectedSnapshot = targetVO.snapshotVO;	
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.SAVE_SNAPSHOT,snapshotURL,expectedSnapshot));
			}			
		}
		
		public function retakeExpectedSnapshot():void{
			getTarget(this.finishRetakeExpectedSnapshot);
		}
		
		public function finishRetakeExpectedSnapshot(targetVO:TargetVO):void{
			if(targetVO.snapshotVO == null){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","VerifyMonkeyCommand " + this.description, "Could not find target " + value));
			}else{
				expectedSnapshot = targetVO.snapshotVO;	
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.SAVE_SNAPSHOT,snapshotURL,expectedSnapshot));				
			}					
		}
	
		public function takeActualSnapshot():void{
			getTarget(this.finishTakeActualSnapshot);	
		}	
		
		public function finishTakeActualSnapshot(targetVO:TargetVO):void{
			if(targetVO.snapshotVO == null){
				error = "Could not find target " + value;
				mateDispatcher.dispatchEvent(new MonkeyCommandRunnerEvent(MonkeyCommandRunnerEvent.ERROR,this));
			}else{
				compareAttributes(targetVO);
				actualSnapshot = targetVO.snapshotVO;
				if(verifyBitmap){
					compareSnapshots();	
				}
			}
			updateResult();
			runTimer.start();			
		}
			
		private function compareSnapshots():void{
			if(expectedSnapshot && expectedSnapshot.bitmapData && actualSnapshot && actualSnapshot.bitmapData){
				var compareResult:* = expectedSnapshot.bitmapData.compare(actualSnapshot.bitmapData);
				if(compareResult == 0){
					snapshotResult = "PASS";
				}else{
					snapshotResult = "FAIL";
				}
			}else if(actualSnapshot && actualSnapshot.bitmapData && snapshotURL && snapshotURL != ""){
				loadSnapshot();
			}
		}
		
		private function compareAttributes(targetVO:TargetVO):void {
			for each ( var attribute:AttributeVO in attributes ) {
				var attributeName:String = attribute.name;
				var expectedValue:String = attribute.expectedValue;
				attribute.setActualValueForTargetVO(targetVO);
				var actualValue:String = attribute.actualValue;
				attribute.actualValue = actualValue;
				if ( actualValue == expectedValue ) {
					attribute.result = "PASS";
				} else {
					attribute.result = "FAIL";
				}
			}
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,this.attributes,null,this.attributes));			
		}
		
		public override function updateResult():void {
			var total:int = 0;
			var passed:int = 0;
			var failed:int = 0;
			var errors:int = ( error == null ? 0 : 1 );
			
			if ( verifyBitmap ) {
				if ( snapshotResult == "FAIL" ) {
					failed++;
				} else if ( snapshotResult == "PASS" ) {
					passed++;
				}
				total++;
			} else {
				snapshotResult = "";
			}
			for each ( var attribute:AttributeVO in attributes ) {
				var attributeResult:String = attribute.result;
				if ( attributeResult == "FAIL" ) {
					failed++;
				} else if ( attributeResult == "PASS" ) {
					passed++;
				}
				total++;
			}
			if ( errors != 0 ) {
				result = "ERROR";
			} else if ( total == 0 ) {
				result = "EMPTY";
			} else if ( passed + failed != total ) {
				result = "NOT_RUN";
			} else if ( failed != 0 ) {
				result = "FAIL";
			} else {
				result = "PASS";
			}
			assertionCount = total;
			passedAssertionCount = passed;
			failedAssertionCount = failed;
			errorCount = errors;
			hasBeenRun = passed + failed == total;
		}

		override public function resetResult():void{
			super.resetResult();
			if ( verifyBitmap ) {
				snapshotResult = "NOT_RUN";
			} else {
				snapshotResult = "";
			}
			for each ( var attribute:AttributeVO in attributes ) {
				attribute.result = "NOT_RUN";
			}
			error = null;
		}
		
		/**
		 * Get the full set of subtest results thqat can be used to run a series of asserts in a FlexUnit test
		 */
		public function get subtestResults():Array {
			var results:Array = new Array();
			
			// Snapshot result
			if ( verifyBitmap ) {
				var snapshotSubtestResult:SubtestResult = new SubtestResult();
				snapshotSubtestResult.description = description + " Snapshot";
				snapshotSubtestResult.expectedValue = "PASS";
				snapshotSubtestResult.actualValue = this.snapshotResult;
				results.push(snapshotSubtestResult);
			}
			
			// Attribute results 
			for each ( var attribute:AttributeVO in attributes ) {
				var attributeSubtestResult:SubtestResult = new SubtestResult();
				if ( attribute.type == AttributeVO.PROPERTY ) {
					attributeSubtestResult.description = description + " Property " + attribute.name;
				} else if ( attribute.type == AttributeVO.STYLE ) {
					attributeSubtestResult.description = description + " Style " + attribute.name;
				} else {
					throw new Error("Unknown value " + attributeSubtestResult.description + " in AttributeVO type");
				}
				attributeSubtestResult.expectedValue = attribute.expectedValue;
				attributeSubtestResult.actualValue = attribute.actualValue;
				results.push(attributeSubtestResult);
			}
			return results;
		}

		override public function isEqualTo(item:Object):Boolean{
			if(! item is VerifyMonkeyCommand){
				return false;
			}else{
				if(
					(item.description == this.description) &&
					(item.value == this.value) &&
					(item.prop == this.prop) &&
					(item.containerValue == this.containerValue) &&
					(item.containerProp == this.containerProp) &&
					(item.result == this.result) &&
					(item.snapshotResult == this.snapshotResult) &&
					(item.verifyBitmap == this.verifyBitmap)		
				){
					for(var i:uint=0;i<attributes.length;i++){
						if(!item.attributes[i].isEqualTo(this.attributes[i])){
							return false;
						}
					}
					return true;
				}else{
					return false;
				}
			}
		}

		public function clone():VerifyMonkeyCommand{			
			var copy:VerifyMonkeyCommand = new VerifyMonkeyCommand();
			copy.mateDispatcher = mateDispatcher;
			copy.parent = parent;
			copy.description = description;
			copy.snapshotURL = snapshotURL;
			copy.snapshotResult = snapshotResult;
			copy.result = result;
			copy.value = value;
			copy.prop = prop;
			copy.containerValue = containerValue;
			copy.containerProp = containerProp;
			copy.verifyBitmap = verifyBitmap;
			copy.attributes = ObjectUtil.copy(attributes) as ArrayCollection;
			copy.assertionCount = assertionCount;
			copy.hasBeenRun = hasBeenRun;
			copy.passedAssertionCount = passedAssertionCount;
			copy.failedAssertionCount = failedAssertionCount;
			copy.errorCount = errorCount;
			copy.error = error;
			return copy;
		}			
	}
}