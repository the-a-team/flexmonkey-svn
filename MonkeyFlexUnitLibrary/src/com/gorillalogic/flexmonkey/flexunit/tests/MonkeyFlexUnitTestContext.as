/*
 * FlexMonkey 1.0, Copyright 2008, 2009 by Gorilla Logic, Inc.
 * FlexMonkey 1.0 is distributed under the GNU General Public License, v2. 
 */
package com.gorillalogic.flexmonkey.flexunit.tests
{
	import com.gorillalogic.flexmonkey.context.ISnapshotLoader;
	public class MonkeyFlexUnitTestContext
	{ 
		public var snapshotLoader:ISnapshotLoader;
		
		public function MonkeyFlexUnitTestContext(snapshotLoader:ISnapshotLoader)
		{
			this.snapshotLoader = snapshotLoader;			
		}

	}
}