/**
 * FlexSpy 1.2
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://coderpeon.ovh.org]
 */
package com.flexspy.imp {

	import mx.controls.DataGrid;
	import mx.controls.listClasses.IListItemRenderer;
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import mx.events.DataGridEvent;
	import mx.core.EventPriority;
	import mx.events.DataGridEventReason;

	/**
	 * DataGrid that does not try to restore the edited item when it re-gains the focus
	 */
	public class EditableDataGrid extends DataGrid {
		
		public function EditableDataGrid() {
			super();

			editable = true;
			addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, disableEditing);
			addEventListener(DataGridEvent.ITEM_EDIT_END, onItemEditEnd, false, EventPriority.DEFAULT);
		}

	    /**
	     *  @private
	     *  when the grid gets focus, does not focus an item renderer
	     */
	    override protected function focusInHandler(event:FocusEvent):void {
			editable = false;
			super.focusInHandler(event);
			editable = true;    	
	    }

		private function onItemEditEnd(event: DataGridEvent): void {
			// Modify the event.
			if (event.reason == DataGridEventReason.NEW_ROW) {
				event.reason = DataGridEventReason.OTHER;
			}
		}

		private function disableEditing(event: DataGridEvent): void {
			// Only the above method can trigger an edition.
			event.preventDefault(); 
		}
	}
}