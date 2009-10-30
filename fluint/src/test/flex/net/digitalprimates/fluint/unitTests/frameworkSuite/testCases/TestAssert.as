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
package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
	import net.digitalprimates.fluint.assertion.AssertionFailedError;
	import net.digitalprimates.fluint.tests.TestCase;

    /**
     * @private
     */
	public class TestAssert extends TestCase
	{
		[Test(description="Test is supposed to Fail",issueID="0012443")]
	    public function fails2():void
	    {
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("fail uncaught");
	    }

	    public function testFail():void
	    {
	        try 
	        {
	            fail();
	        } 
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        throw new AssertionFailedError("fail uncaught");
	    }
	
	//------------------------------------------------------------------------------
	    public function testAssertEquals():void
	    {
	        var  o : Object = new Object();
	        assertEquals( o, o );
	        assertEquals( "5", 5 );
	        try 
	        {
	            assertEquals( new Object(), new Object() );
	        } 
	        catch ( e : AssertionFailedError )  
	        {
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertEqualsNull():void 
	    {
	        assertEquals( null, null );
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertNullNotEqualsString():void 
	    {
	        try 
	        {
	            assertEquals( null, "foo" );
	            fail();
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	        }
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertStringNotEqualsNull():void 
	    {
	        try 
	        {
	            assertEquals( "foo", null );
	            fail();
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            assertEquals( "expected:<foo> but was:<null>", e.message );
	        }
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertNullNotEqualsNull():void 
	    {
	        try 
	        {
	            assertEquals( null, new Object() );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            assertEquals( "expected:<null> but was:<[object Object]>", e.message );
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertNull():void 
	    {
	        try 
	        {
	            assertNull( new Object() );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertNotNull():void 
	    {
	        try 
	        {
	            assertNotNull( null );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertTrue():void
	    {
	        try 
	        {
	            assertTrue( false );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertFalse():void
	    {
	        try 
	        {
	            assertFalse( true );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            return;
	        }
	        fail();
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertStictlyEquals():void 
	    {
	        var  o : Object = new Object();
	        assertStrictlyEquals( o, o );
	        try 
	        {
	            assertStrictlyEquals( "5", 5 );
	        } 
	        catch ( e : AssertionFailedError )  
	        {
	            return;
	        }
	        fail();
	    }
	    
	//------------------------------------------------------------------------------
	
	    public function testAssertStrictlyEqualsNull():void 
	    {
	        assertStrictlyEquals( null, null );
	    }
	    
	//------------------------------------------------------------------------------
	
	    public function testAssertNullNotStrictlyEqualsString():void 
	    {
	        try 
	        {
	            assertStrictlyEquals( null, "foo" );
	            fail();
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	        }
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertStringNotStrictlyEqualsNull():void 
	    {
	        try 
	        {
	            assertStrictlyEquals( "foo", null );
	            fail();
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            assertEquals( "expected:<foo> but was:<null>", e.message );
	        }
	    }
	
	//------------------------------------------------------------------------------
	
	    public function testAssertNullNotStrictlyEqualsNull():void 
	    {
	        try 
	        {
	            assertStrictlyEquals( null, new Object() );
	        }
	        catch ( e : AssertionFailedError ) 
	        {
	            assertEquals( "expected:<null> but was:<[object Object]>", e.message );
	            return;
	        }
	        fail();
	    }
	}
}