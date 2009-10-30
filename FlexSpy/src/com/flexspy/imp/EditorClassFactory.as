/**
 * FlexSpy 1.2
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://coderpeon.ovh.org]
 */
package com.flexspy.imp {

	import mx.core.IFactory;

	/**
	 * Factory that always return the same instance
	 */
	public class EditorClassFactory implements IFactory {
		private var _instance: *;
		
		public function newInstance(): * {
			return _instance;
		}
		public function get activeInstance(): * {
			return _instance;
		}

		public function set activeInstance(instance: *): void {
			_instance = instance;
		}
	}
}