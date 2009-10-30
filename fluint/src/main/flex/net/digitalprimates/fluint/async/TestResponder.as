package net.digitalprimates.fluint.async {
	public class TestResponder extends Object implements ITestResponder {
		private var resultFunction:Function;
		private var faultFunction:Function;
		
		public function fault( info:Object, passThroughData:Object ):void {
			faultFunction( info, passThroughData );
		}

		public function result( data:Object, passThroughData:Object ):void {
			resultFunction( data, passThroughData );
		}

		public function TestResponder( result:Function, fault:Function ) {
			resultFunction = result;
			faultFunction = fault;
		}
	}
}