package net.digitalprimates.fluint.ui
{
   import mx.controls.Image;
   
   public class TestStatusIcon
   {
      [Embed(source="/net/digitalprimates/fluint/assets/tsuite.gif")]
      public static var SUITE_PENDING : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/tsuiteok.gif")]
      public static var SUITE_PASS : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/tsuitefail.gif")]
      public static var SUITE_FAIL : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/tsuiteerror.gif")]
      public static var SUITE_ERROR : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/test.gif")]
      public static var TEST_PENDING : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/testok.gif")]
      public static var TEST_PASS : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/testfail.gif")]
      public static var TEST_FAIL : Class;
      
      [Embed(source="/net/digitalprimates/fluint/assets/testerr.gif")]
      public static var TEST_ERROR : Class;
            
      public function TestStatusIcon()
      {
      }
   }
}