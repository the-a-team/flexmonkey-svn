/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.managers
{
	import com.gorillalogic.flexmonkey.application.VOs.FlashVarVO;
	import com.gorillalogic.flexmonkey.application.VOs.ProjectPropertiesVO;
	import com.gorillalogic.flexmonkey.application.VOs.SnapshotVO;
	import com.gorillalogic.flexmonkey.application.events.AlertEvent;
	import com.gorillalogic.flexmonkey.application.events.MonkeyFileEvent;
	import com.gorillalogic.flexmonkey.application.events.UserEvent;
	import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
	import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
	import com.gorillalogic.flexmonkey.monkeyCommands.VerifyMonkeyCommand;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import mx.collections.ArrayCollection;
	import mx.controls.SWFLoader;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	import mx.utils.ObjectUtil;
	
	//TODO: use monkey alerts	

	public class ProjectManager extends EventDispatcher
	{
		public var mateDispatcher : IEventDispatcher;
		public var browserConnection:BrowserConnectionManager;
		
		private var newProjectURL:String;		
		private var projectFileURL:String;
		private var snapshotDir:String;

		private var _projectOpen:Boolean;
		[Bindable ("projectOpenChanged")]
		public function get projectOpen():Boolean{
			return _projectOpen;
		}
		private function setProjectOpen(o:Boolean):void{
			_projectOpen = o;
			dispatchEvent(new Event("projectOpenChanged"));
		}
		
		private var _projectURL:String ="";
		public function get projectURL():String{
			return _projectURL;
		}
		public function set projectURL(url:String):void{
			if((isNewProject || _projectURL != url) && url != null && url != ""){
				_projectURL = url;
				projectFileURL = projectURL + "/monkeyTestProject.xml";
				snapshotDir = projectURL + "/snapshots/";	
				setMonkeyTestFileURL(projectURL + "/monkeyTestSuites.xml");				
				if(!isNewProject){	
					readProject();
				}
				setProjectOpen(true);
			}			
		}
				
		private var _monkeyTestFileURL:String;
		[Bindable ("monkeyTestFileURLChanged")]
		public function get monkeyTestFileURL():String{
			return _monkeyTestFileURL;
		}
		private function setMonkeyTestFileURL(url:String):void{
			_monkeyTestFileURL = url;
			dispatchEvent(new Event("monkeyTestFileURLChanged"));
		}

		private var _monkeyTestFileDirty:Boolean = false;
		[Bindable]
		public function get monkeyTestFileDirty():Boolean{
			return _monkeyTestFileDirty;
		}
		public function set monkeyTestFileDirty(d:Boolean):void{
			_monkeyTestFileDirty = d;
		}		

		private var _projectXML:XML;
		public function get projectXML():XML{
			return _projectXML;
		}
		private function setProjectXML(d:XML):void{
			_projectXML = d;	
		}	

		private var _generatedCodeURL:String;
		[Bindable ("generatedCodeURLChanged")]
		public function get generatedCodeURL():String{
			return _generatedCodeURL;
		}
		private function setGeneratedCodeURL(url:String):void{
			_generatedCodeURL = url;
			dispatchEvent(new Event("generatedCodeURLChanged"));			
		}
		
		private var _generatedCodeSuitesPackageName:String;
		[Bindable ("generatedCodeSuitesPackageNameChanged")]
		public function get generatedCodeSuitesPackageName():String{
			return _generatedCodeSuitesPackageName;
		}
		private function setGeneratedCodeSuitesPackageName(n:String):void{
			_generatedCodeSuitesPackageName = n;
			dispatchEvent(new Event("generatedCodeSuitesPackageNameChanged"));
		}
		
		private var _isNewProject:Boolean = false;
		[Bindable ("isNewProjectChanged")]
		public function get isNewProject():Boolean{
			return _isNewProject;
		}
		private function setIsNewProject(n:Boolean):void{
			_isNewProject = n;
			dispatchEvent(new Event("isNewProjectChanged"));
		}
				
		private var browseAfterSave:Boolean = false;
	
		public function ProjectManager()
		{
		}
		
		private function readProject():void{
			var file:File;
			var fileStream:FileStream;
			try{
				file = new File(projectFileURL);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert","ProjectManager: Malformed Project File URL."));
				return;			
			}
			if(file.exists){
				fileStream = new FileStream();
				fileStream.addEventListener(IOErrorEvent.IO_ERROR,fileReadIOErrorHandler,false,0,true);
				fileStream.addEventListener(Event.COMPLETE,fileReadCompleteHandler,false,0,true);
				fileStream.openAsync(file,FileMode.READ);
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Project File does not exist for reading."));
				return;					
			}
		}	
		
		private function fileReadIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Could not open Project File for reading."));
		}

		private function fileReadCompleteHandler(event:Event):void{
			var projectText:String;
			var fileStream:FileStream = event.target as FileStream;
			var bytesAvailable:uint=fileStream.bytesAvailable;
			try{
				projectText = fileStream.readUTFBytes(bytesAvailable);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Could not read Project File."));	
			}catch(error:EOFError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Attempt to read past end of Project File."));
			}finally{
				fileStream.close();
			}
			if(projectText != null){
				try{
					var xml:XML = new XML(projectText);
				}catch(error:Error){
					mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Malformed XML in Project File."));
				}
				if(xml){
					setProjectXML(xml);
					updateProjectPropertiesFromXML();
				}
			}else{
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Project File empty."));	
			}
		}	

		private function updateProjectPropertiesFromXML():void{
			setTargetSWFWidth(projectXML.targetSWF.@width);
			setTargetSWFHeight(projectXML.targetSWF.@height);			
			if(projectXML.targetSWF.@useFlashVars == "true"){
				setUseFlashVars(true);
			}else{
				setUseFlashVars(false);				
			}
			var flashVarNodes:XMLList = projectXML.flashVars.elements("flashVar");
			var flashVars:ArrayCollection = new ArrayCollection();
			for(var i:uint=0;i<flashVarNodes.length();i++){ 
				var flashVarNode:XML = flashVarNodes[i];
				var flashVar:FlashVarVO = new FlashVarVO(flashVarNode.@name,flashVarNode.@value);
				flashVars.addItem(flashVar);
			}				
			setFlashVars(flashVars);
			setCommMode(projectXML.targetSWF.@commMode);
/*			
			if(projectXML.targetSWF.@useTargetSWFWindow == "true"){
				setUseTargetSWFWindow(true);
			}else{
				setUseTargetSWFWindow(false);				
			}			
			if(projectXML.targetSWF.@useMonkeyAgent == "true"){
				setUseMonkeyAgent(true);
			}else{
				setUseMonkeyAgent(false);				
			}	
			if(projectXML.targetSWF.@useMonkeyLink == "true"){
				setUseMonkeyLink(true);
			}else{
				setUseMonkeyLink(false);				
			}
*/			
				
			setTargetSWFURL(projectXML.targetSWF.@url);							
			setGeneratedCodeURL(projectXML.generatedCode.@url);
			setGeneratedCodeSuitesPackageName(projectXML.generatedCode.@suitesPackageName);
				
		}
				
		private function saveProject():void{
			var file:File;
			var fileStream:FileStream;
			var projectText:String;
			try{
				file = new File(projectFileURL);
			}catch(error:ArgumentError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Malformed Project File URL while saving."));	
				return;		
			}
			fileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR,projectFileWriteIOErrorHandler,false,0,true);
			fileStream.openAsync(file,FileMode.WRITE);					
			XML.prettyPrinting = true;
			projectText = projectXML.toXMLString();
			try{	
				fileStream.writeUTFBytes(projectText);
			}catch(error:IOError){
				mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Could not save Project File"));
			}finally{
				fileStream.close();
			}	
		}		

		private function projectFileWriteIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "ProjectManager: Could not open Project File for saving."));
		}	

// ---------------------------------------------------------------------------------

		public function requestForNew():void{
			setIsNewProject(true);			
			if(monkeyTestFileDirty){
				browseAfterSave = true;
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.TEST_FILE_PROMPT_FOR_SAVE));
			}else{
				projectBrowse();
			}			
		}
		
		public function requestForOpen():void{
			if(monkeyTestFileDirty){
				browseAfterSave = true;
				mateDispatcher.dispatchEvent(new MonkeyFileEvent(MonkeyFileEvent.TEST_FILE_PROMPT_FOR_SAVE));
			}else{
				projectBrowse();
			}			
		}

		public function testFileSaveCancelled():void{
			browseAfterSave = false;
			setIsNewProject(false);
		}
				
		public function testFileSaved():void{
			if(browseAfterSave){
				browseAfterSave = false
				projectBrowse();
			}
		}

		private function projectBrowse():void{
			var file:File;
			if(projectURL == "" || projectURL == null){
				file = new File();				
			}else{
				try{
					file = new File(projectURL);
				}catch(error:ArgumentError){
					throw new Error("ProjectManager: Malformed Project URL while browsing for Project Directory.");	
					setIsNewProject(false);
					return;		
				}				
			}
			file.addEventListener(Event.CANCEL,projectBrowseCancelHandler,false,0,true);
			file.addEventListener(Event.SELECT,projectBrowseSelectHandler,false,0,true);
			if(isNewProject){
				file.browseForDirectory("New Project");
			}else{
				file.browseForDirectory("Open Project");
			}	
		}
		
		private function projectBrowseCancelHandler(event:Event):void{
			setIsNewProject(false);	
		}

		private function projectBrowseSelectHandler(event:Event):void{
			newProjectURL = event.target.url;
			var file:File = new File(newProjectURL);
			file.addEventListener(IOErrorEvent.IO_ERROR,directoryListingIOErrorHandler,false,0,true);
			file.addEventListener(FileListEvent.DIRECTORY_LISTING,directoryListingHandler,false,0,true);
			file.getDirectoryListingAsync();
		}
		
		private function directoryListingIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Project Manager: Could not check selected directory for Monkey Project Files"));
			setIsNewProject(false);			
		}
		
		private function directoryListingHandler(event:FileListEvent):void{
			var directoryContents:Array = event.files;
			var hasMonkeyTestProjectFile:Boolean = false;
			monkeyTestProjectLoop: for each(var file:File in directoryContents){
				var slashArray:Array = file.url.split("/");
				if(slashArray[slashArray.length-1] == "monkeyTestProject.xml"){
					hasMonkeyTestProjectFile = true;
					break monkeyTestProjectLoop;
				}	
			}
			if(! isNewProject){
				if(hasMonkeyTestProjectFile){
//TODO					setProjectOpen(false);
					openProject();
				}else{
					mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Project Manager: No Project Files Found!"));
				}
			}else{
				if(hasMonkeyTestProjectFile){
					mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Project Manager: Project Already Exists!"));
					setIsNewProject(false);
				}else{
//TODO					setProjectOpen(false);
					newProject();
				}				
			}						
		}

		public function openProject():void{
			projectURL = newProjectURL;
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.PROJECT_NEW_URL,newProjectURL));	
		}
					
		public function newProject():void{
			projectURL = newProjectURL;		
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.PROJECT_NEW_URL,newProjectURL));					
			setTargetSWFHeight(480);
			setTargetSWFWidth(640); 
			setUseFlashVars(false);
			setFlashVars(new ArrayCollection());
			setCommMode(ProjectPropertiesVO.TARGET_SWF_WINDOW);
/*			
			setUseTargetSWFWindow(true);
			setUseMonkeyAgent(false);
			setUseMonkeyLink(false);
*/			
			setTargetSWFURL("");
			setGeneratedCodeSuitesPackageName("testSuites");
			setGeneratedCodeURL("");				
			setProjectXML(getProjectXML());
			saveProject();
			setIsNewProject(false);			
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.PROJECT_EDIT_PROPERTIES));	
		}
		
		public function updateProjectProperties(properties:ProjectPropertiesVO):void{
			setTargetSWFHeight(properties.targetSWFHeight);
			setTargetSWFWidth(properties.targetSWFWidth);
			setUseFlashVars(properties.useFlashVars);			
			setFlashVars(properties.flashVars);
			setCommMode(properties.commMode);
/*			
			setUseTargetSWFWindow(properties.useTargetSWFWindow);
			setUseMonkeyAgent(properties.useMonkeyAgent);
			setUseMonkeyLink(properties.useMonkeyLink);
*/			
			setTargetSWFURL(properties.targetSWFURL);			
			setGeneratedCodeSuitesPackageName(properties.generatedCodeSuitesPackageName);
			setGeneratedCodeURL(properties.generatedCodeSourceDirectory);
			setProjectXML(getProjectXML());
			saveProject();
		}
		
		private function getProjectXML():XML{
			var xml:XML = <project/>;
			var targetSWFXML:XML = <targetSWF url={targetSWFURL} width={targetSWFWidth} height={targetSWFHeight} commMode={commMode} useFlashVars={useFlashVars}/>
			var generatedCodeXML:XML = <generatedCode url={generatedCodeURL} suitesPackageName={generatedCodeSuitesPackageName}/>
			var flashVarsXML:XML=<flashVars/>;
			for(var i:uint=0;i<flashVars.length;i++){
				var flashVar:XML = FlashVarVO(flashVars[i]).xml;
				flashVarsXML.appendChild(flashVar);
			}			
			xml.appendChild(targetSWFXML);
			xml.appendChild(flashVarsXML);
			xml.appendChild(generatedCodeXML);
			return xml;			
		}	

		
//TODO Refactor snapshot stuff	
		// Snapshots ---------------------------------------------------------------------
	
		public function getSnapshotURL(filename:String):String{
			var url:String = snapshotDir + filename;
			return url;
		}	

		private var _currentVerifyCommand:VerifyMonkeyCommand;
		public function set currentVerifyCommand(c:MonkeyRunnable):void{
			_currentVerifyCommand = c as VerifyMonkeyCommand;
		}
		
		public function updateSnapshot(uiEventCommand:UIEventMonkeyCommand):void{
			_currentVerifyCommand.processExpectedSnapshot(uiEventCommand);
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.UPDATE_ITEM,_currentVerifyCommand));						
		}
		
		public function setExpectedSnapshot(snapshot:SnapshotVO):void{
			_currentVerifyCommand.expectedSnapshot = snapshot;				
		}

		public function retakeExpectedSnapshot():void{
			_currentVerifyCommand.retakeExpectedSnapshot();	
			mateDispatcher.dispatchEvent(new UserEvent(UserEvent.UPDATE_ITEM,_currentVerifyCommand));			
		}			
	
		// Target SWF ------------------------------------------------------------------
		private var _commMode:String;
		[Bindable ("commModeChanged")]
		public function get commMode():String{
			return _commMode;
		}
		private function setCommMode(m:String):void{
			_commMode = m;
			dispatchEvent(new Event("commModeChanged"));
			if(_commMode == ProjectPropertiesVO.TARGET_SWF_WINDOW){
				browserConnection.sendDisconnect();	
			}
		}
		
/*		
		private var _useTargetSWFWindow:Boolean = false;
		[Bindable ("useTargetSWFWindowChanged")]
		public function get useTargetSWFWindow():Boolean{
			return _useTargetSWFWindow;	
		}
		private function setUseTargetSWFWindow(b:Boolean):void{
			_useTargetSWFWindow = b;
			dispatchEvent(new Event("useTargetSWFWindowChanged"));

			if(b){
				browserConnection.sendDisconnect();
			}				


		}

		private var _useMonkeyAgent:Boolean = false;
		[Bindable ("useMonkeyAgentChanged")]
		public function get useMonkeyAgent():Boolean{
			return _useMonkeyAgent;	
		}
		private function setUseMonkeyAgent(b:Boolean):void{
			_useMonkeyAgent = b;
			dispatchEvent(new Event("useMonkeyAgentChanged"));			
		}
		
		private var _useMonkeyLink:Boolean = false;
		[Bindable ("useMonkeyLinkChanged")]
		public function get useMonkeyLink():Boolean{
			return _useMonkeyLink;	
		}
		private function setUseMonkeyLink(b:Boolean):void{
			_useMonkeyLink = b;
			dispatchEvent(new Event("useMonkeyLinkChanged"));			
		}		
*/		
		private var _browserConnected:Boolean = false;
		public function get browserConnected():Boolean{
			return _browserConnected; 
		}
		public function set browserConnected(c:Boolean):void{
			_browserConnected = c;
		}		

		private var _useFlashVars:Boolean = false;
		[Bindable ("useFlashVarsChanged")]
		public function get useFlashVars():Boolean{
			return _useFlashVars;
		}
		private function setUseFlashVars(u:Boolean):void{
			_useFlashVars = u;
			dispatchEvent(new Event("useFlashVarsChanged"));
		}

		private var _flashVars:ArrayCollection;
		[Bindable ("flashVarsChanged")]
		public function get flashVars():ArrayCollection{
			var copy:ArrayCollection = ObjectUtil.copy(_flashVars) as ArrayCollection;
			return copy;
		}	
		private function setFlashVars(f:ArrayCollection):void{
			_flashVars = f;
			for each(var flashVar:FlashVarVO in _flashVars){
				Application.application.parameters[flashVar.name] = flashVar.value;	
			}						
			dispatchEvent(new Event("flashVarsChanged"));
		}
		
		private var _targetSWFURL:String="";
		[Bindable ("targetSWFURLChanged")]
		public function get targetSWFURL():String{
			return _targetSWFURL;
		}
		private function setTargetSWFURL(url:String):void{
			if(url != _targetSWFURL){
				_targetSWFURL = url;
				dispatchEvent(new Event("targetSWFURLChanged"));			
				setTargetSWF(null);
				if(targetSWFURL != null && targetSWFURL != ""){
					if(commMode == ProjectPropertiesVO.TARGET_SWF_WINDOW){
						var urlRequest:URLRequest = new URLRequest(url);
						var urlLoader:URLLoader = new URLLoader();
						urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
						urlLoader.addEventListener(Event.COMPLETE,urlLoaderCompleteHandler,false,0,true);
						urlLoader.addEventListener(IOErrorEvent.IO_ERROR,urlLoaderIOErrorHandler,false,0,true);
						urlLoader.load(urlRequest);
					}
				}
			}			
		}
		
		private function urlLoaderCompleteHandler(event:Event):void{
			setLocalSWFBytes(event.target.data);	
		}
		
		private function urlLoaderIOErrorHandler(event:IOErrorEvent):void{
			mateDispatcher.dispatchEvent(new AlertEvent(AlertEvent.ALERT, "Alert", "Project Manager: Could not URLLoad Target SWF"));
		}		
		
		private var _localSWFBytes:Object;	
		public function get localSWFBytes():Object{
			return _localSWFBytes;
		}
		private function setLocalSWFBytes(o:Object):void{
			_localSWFBytes = o;
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
//			loaderContext.applicationDomain = new ApplicationDomain();
			var swfLoader:SWFLoader = new SWFLoader();
			setTargetSWF(swfLoader);						
			swfLoader.addEventListener(Event.COMPLETE,swfLoaderCompleteHandler,false,0,true);
			swfLoader.loaderContext = loaderContext;
			swfLoader.percentHeight=100;
			swfLoader.percentWidth=100;
			swfLoader.scaleContent = true;		
			swfLoader.source = o;
		}		
		
		private function swfLoaderCompleteHandler(event:Event):void{
			targetSWF.removeEventListener(Event.COMPLETE,swfLoaderCompleteHandler,false);						
			SystemManager(targetSWF.content).addEventListener(FlexEvent.APPLICATION_COMPLETE, targetSWFApplicationCompleteHandler,false,0,true);
		}	
		
		private function targetSWFApplicationCompleteHandler(event:FlexEvent):void{
			var loadedApplication:Application = Application(event.target.application);

		}	
		
		private var _targetSWFWidth:uint;
		[Bindable ("targetSWFWidthChanged")]
		public function get targetSWFWidth():uint{
			return _targetSWFWidth;	
		}
		private function setTargetSWFWidth(w:uint):void{
			_targetSWFWidth = w;
			dispatchEvent(new Event("targetSWFWidthChanged"));
			var app:Application = Application.application as Application;
			app.width = w
		}

		private var _targetSWFHeight:uint;
		[Bindable ("targetSWFHeightChanged")]
		public function get targetSWFHeight():uint{
			return _targetSWFHeight;	
		}
		private function setTargetSWFHeight(h:uint):void{
			_targetSWFHeight = h;
			dispatchEvent(new Event("targetSWFHeightChanged"));			
			var app:Application = Application.application as Application;
			app.height = h;					
		}		

		private var _targetSWF:SWFLoader;
		[Bindable ("targetSWFChanged")]
		public function get targetSWF():SWFLoader{
			return _targetSWF;
		}
		private function setTargetSWF(swf:SWFLoader):void{
			_targetSWF = swf;
			dispatchEvent(new Event("targetSWFChanged"));
		}			
	}
}