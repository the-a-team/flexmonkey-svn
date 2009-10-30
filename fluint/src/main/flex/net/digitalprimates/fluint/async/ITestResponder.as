package net.digitalprimates.fluint.async {
	public interface ITestResponder {
		/**
		 * This method is called by TestCase when an error has been received.
		 **/
		function fault( info:Object, passThroughData:Object ):void 

		/**
		 * This method is called by TestCase when the return value has been received.
		 **/
		function result( data:Object, passThroughData:Object ):void 
	}
}