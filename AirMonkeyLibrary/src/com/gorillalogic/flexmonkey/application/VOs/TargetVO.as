/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.application.VOs
{
	[RemoteClass]
	public class TargetVO
	{
		public function TargetVO(propertyArray:Array=null, styleArray:Array=null, snapshotVO:SnapshotVO=null)
		{
			this.propertyArray = propertyArray;
			this.styleArray = styleArray;
			this.snapshotVO = snapshotVO;
		}
		public var propertyArray:Array;
		public var styleArray:Array;
		public var snapshotVO:SnapshotVO;		
		
	}
}