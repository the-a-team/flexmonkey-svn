/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package net.digitalprimates.fluint.ui {
   import mx.controls.Image;
   import mx.controls.Tree;
   import mx.controls.treeClasses.TreeItemRenderer;
   import mx.controls.treeClasses.TreeListData;
   import mx.events.FlexEvent;
   import mx.events.TreeEvent;
   
   import net.digitalprimates.fluint.monitor.ITestResult;
   import net.digitalprimates.fluint.monitor.ITestResultContainer;
   import net.digitalprimates.fluint.monitor.TestMethodResult;

   /** 
    * A TreeItemRenderer that shows TestSuites, TestCases and TestMethods with 
    * failures in bold and in red.
    */
   public class ErrorTreeItemRenderer extends TreeItemRenderer {

      private var _status : Image;
      private var _tree : Tree;
      
      override protected function createChildren() : void {
         _tree = Tree(this.parent.parent);
         _tree.setStyle("folderClosedIcon", null);
         _tree.setStyle("folderOpenIcon", null);
         _tree.setStyle("defaultLeafIcon", null);
         
         _status = new Image();
         _status.width = 16;
         _status.height = 16;
         _status.setStyle("verticalAlign", "middle");
         
         addChild(_status);
         
         super.createChildren(); 
      }

      override public function set data(value:Object):void {
         super.data = value;
      }
      
      override protected function commitProperties() : void {
         super.commitProperties();
         
         if(super.data) {
            var result : ITestResult = ITestResult(TreeListData(super.listData).item);
            
            if(!result.status) {
               setStyle("color", 0xff0000);
               setStyle("fontWeight", 'bold');
            }
            else {
               setStyle("color", 0x000000);
               setStyle("fontWeight", 'normal');
            }
            
            //node is a suite
            if(TreeListData(super.listData).hasChildren)
            {
               var container : ITestResultContainer = ITestResultContainer(result);

               //no pass
               if(!container.status)
               {
                  var failureInfo : String;

                  //did this suite have no pass tests            
                  if(container.numberOfErrors > 0 || container.numberOfFailures > 0) {
                     //show number of no pass tests
                     failureInfo = ' ( ' + (container.numberOfFailures + container.numberOfErrors) + ' )';
                  }
                  
                  //choose icon to show
                  //errors but no failures 
                  if(container.numberOfFailures == 0 && container.numberOfErrors > 0) {
                     //set image to SUITE_ERROR
                     _status.source = TestStatusIcon.SUITE_ERROR;
                  }
                  //failures and errors or just failures
                  else
                  {
                     //set image to SUITE_FAIL 
                    _status.source = TestStatusIcon.SUITE_FAIL;
                  }
                  
                  label.text =  TreeListData(listData).label + failureInfo;
               }
               //pass
               else {
                  //set image to SUITE_PASS
                  _status.source = TestStatusIcon.SUITE_PASS;
               }
               
            }
            
            //node is a test
            else
            {
               var testResult : TestMethodResult = TestMethodResult(result);
               
               //choose icon to show
               if(testResult.failed) {
                  //set image to TEST_FAIL
                  _status.source = TestStatusIcon.TEST_FAIL;
               }
               else if(testResult.errored) {
                  //set image to TEST_ERROR
                  _status.source = TestStatusIcon.TEST_ERROR;
               }
               else {
                  //set image to TEST_PASS
                  _status.source = TestStatusIcon.TEST_PASS;
               }
            }
         }
      }
      
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {          
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         
         resetIconPosition();
      }
      
      private function resetIconPosition() : void {
         // reset the position of the image to be before the label
         _status.x = super.label.x;
               
        // reset the position of the label to be after the image, plus give it a margin
        super.label.x = _status.x + _status.width + 10;

      }
   }
}