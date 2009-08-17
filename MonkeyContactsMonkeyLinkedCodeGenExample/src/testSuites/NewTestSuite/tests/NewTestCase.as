package testSuites.NewTestSuite.tests{
    import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestCase;

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.monkeyCommands.*;
    import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
    import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;

    import mx.collections.ArrayCollection;

    public class NewTestCase extends MonkeyFlexUnitTestCase{
        public function NewTestCase(){
            super();
        }

        private var mtNewTest:MonkeyTest = new MonkeyTest('NewTest', 500,
            new ArrayCollection([
                new UIEventMonkeyCommand('SelectText', 'inName', 'automationName', ['0', '0']),
                new UIEventMonkeyCommand('Input', 'inName', 'automationName', ['Newman']),
                new UIEventMonkeyCommand('ChangeFocus', 'inName', 'automationName', ['false', 'TAB']),
                new UIEventMonkeyCommand('Open', 'inType', 'automationName', [null]),
                new UIEventMonkeyCommand('Select', 'inType', 'automationName', ['Work', '1', '0']),
                new UIEventMonkeyCommand('SelectText', 'inPhone', 'automationName', ['0', '0']),
                new UIEventMonkeyCommand('Input', 'inPhone', 'automationName', ['212-333-9898']),
                new UIEventMonkeyCommand('ChangeFocus', 'inPhone', 'automationName', ['false', 'TAB']),
                //new UIEventMonkeyCommand('Open', 'inDate', 'automationName', [null]),
                //new UIEventMonkeyCommand('Change', 'inDate', 'automationName', ['Mon Aug 24 2009']),
                new UIEventMonkeyCommand('Click', 'Add', 'automationName', ['0']),
                //new UIEventMonkeyCommand('Click', 'Delete', 'automationName', [0]),
                new VerifyMonkeyCommand('New Verify', null, 'Delete', 'automationName', false,
                    new ArrayCollection([
                        new AttributeVO('enabled', null, 'property', 'true')
                    ]))
            ]));

        private var mtNewTestTimeoutTime:int = 24500;

        [Test]
        public function NewTest():void{
            // startTest(<MonkeyTest>, <Complete method>, <Async timeout value>, <Timeout method>);
            startTest(mtNewTest, mtNewTestComplete, mtNewTestTimeoutTime, defaultTimeoutHandler);
        }

        public function mtNewTestComplete(event:MonkeyCommandRunnerEvent, passThroughData:Object):void{
            checkCommandResults(mtNewTest);
        }


    }
}