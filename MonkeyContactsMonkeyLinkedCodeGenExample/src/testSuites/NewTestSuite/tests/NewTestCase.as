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
                new UIEventMonkeyCommand('Input', 'inName', 'automationName', ['Fricasee']),
                new UIEventMonkeyCommand('Open', 'inType', 'automationName', ['1']),
                new UIEventMonkeyCommand('Select', 'inType', 'automationName', ['Mobile', '1', '0']),
                new UIEventMonkeyCommand('SelectText', 'inPhone', 'automationName', ['0', '0']),
                new UIEventMonkeyCommand('Input', 'inPhone', 'automationName', ['212-555-1212']),
                new UIEventMonkeyCommand('Open', 'inDate', 'automationName', ['1']),
                new UIEventMonkeyCommand('Change', 'inDate', 'automationName', ['Thu Jan 14 2010']),
                new UIEventMonkeyCommand('Click', 'Add', 'automationName', ['0']),
                new UIEventMonkeyCommand('Select', 'grid', 'automationName', ['  | *Fricasee* | Mobile | 212-555-1212 | Thu Jan 14 00:00:00 GMT-0700 2010', '1', '0']),
                new UIEventMonkeyCommand('Select', 'grid', 'automationName', ['  | *Fricasee* | Mobile | 212-555-1212 | Thu Jan 14 00:00:00 GMT-0700 2010', '1', '0']),
                new VerifyMonkeyCommand('New Verify', null, 'label{ string}id{MonkeyContacts string}automationIndex{index:-1 string}automationName{MonkeyContacts string}automationClassName{FlexApplication string}className{MonkeyContacts string}|id{null object}automationIndex{index:0 string}automationClassName{FlexTitleWindow string}className{mx.containers.TitleWindow string}label{ string}automationName{index:0 string}|id{null object}automationIndex{index:0 string}automationClassName{FlexDividedBox string}className{mx.containers.VDividedBox string}label{ string}automationName{index:0 string}|id{grid string}automationIndex{index:6 string}automationName{grid string}automationClassName{FlexDataGrid string}className{mx.controls.DataGrid string}|id{null object}automationClassName{FlexTextArea string}className{mx.controls.TextInput string}automationName{%20%20%7C%20Fricasee%20%7C%20Mobile%20%7C%20212-555-1212%20%7C%20Thu%20Jan%2014%2000:00:00%20GMT-0700%202010 string}automationIndex{name:0 string}editable{true boolean}displayAsPassword{false boolean}', 'automationID', false,
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Fricasee')
                    ])),
                new UIEventMonkeyCommand('Click', 'Delete', 'automationName', ['0']),
                new VerifyMonkeyCommand('New Verify', null, 'Delete', 'automationName', false,
                    new ArrayCollection([
                        new AttributeVO('enabled', null, 'property', 'true')
                    ]))
            ]));

        private var mtNewTestTimeoutTime:int = 26000;

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