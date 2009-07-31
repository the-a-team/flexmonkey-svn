/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.VOs
{
	import mx.collections.ArrayCollection;
	
	public class ProjectPropertiesVO
	{
		public function ProjectPropertiesVO()
		{
		}
		public var targetSWFURL:String;
		public var targetSWFWidth:uint;
		public var targetSWFHeight:uint;
		public var useTargetSWFWindow:Boolean;
		public var useMonkeyAgent:Boolean;
		public var useMonkeyLink:Boolean;		
		public var useFlashVars:Boolean;
		public var flashVars:ArrayCollection;
		public var generatedCodeSourceDirectory:String;
		public var generatedCodeSuitesPackageName:String;
	}
}