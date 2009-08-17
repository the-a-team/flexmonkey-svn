/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.VOs
{
	import mx.collections.ArrayCollection;

	public class ProjectPropertiesVO
	{
		public static const MONKEYAGENT:String = "monkeyAgent";
		public static const TARGET_SWF_WINDOW:String = "targetSWFWindow";
		public static const MONKEYLINK:String = "monkeyLink";		
		
		public function ProjectPropertiesVO()
		{
		}
		public var targetSWFURL:String;
		public var targetSWFWidth:uint;
		public var targetSWFHeight:uint;
		public var commMode:String;	
		public var useFlashVars:Boolean;
		public var flashVars:ArrayCollection;
		public var generatedCodeSourceDirectory:String;
		public var generatedCodeSuitesPackageName:String;
	}
}