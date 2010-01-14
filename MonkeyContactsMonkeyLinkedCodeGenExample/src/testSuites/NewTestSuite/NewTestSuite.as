package testSuites.NewTestSuite{
    import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestSuite;

    import testSuites.NewTestSuite.tests.NewTestCase;

    public class NewTestSuite extends MonkeyFlexUnitTestSuite{
        public function NewTestSuite(){
            addTestCase(new NewTestCase());
        }
    }
}