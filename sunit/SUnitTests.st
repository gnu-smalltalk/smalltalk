TestCase subclass: #ResumableTestFailureTestCase
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit-SUnitTests'!

TestCase subclass: #SUnitTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit-SUnitTests'!

SUnitTest comment: '
This is both an example of writing tests and a self test for the SUnit. The tests 
run the SUnitClientTests and make sure that things blow up correctly. Your
tests will usually be far more complicated in terms of your own objects- more
assertions, more complicated setup. Kent says: "Never forget, however, that
if the tests are hard to write, something is probably wrong with the design".'!


TestResource subclass: #SimpleTestResource
    instanceVariableNames: 'runningState hasRun hasSetup hasRanOnce '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'!

TestCase subclass: #SUnitClientTest
    instanceVariableNames: 'hasRun hasSetup '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'!

SUnitClientTest comment: '
This is an internal class used by the self test for the SUnit. These are
very simple tests but they are pretty strange, since you want to make
sure things blow up. They are separate from SUnitTest both because
you don''t want to log these failures, and because they don''t test
SUnit concepts but rather simulate the real test suites that SUnit
will run.'!


TestCase subclass: #ExampleSetTest
    instanceVariableNames: 'full empty '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'!

TestCase subclass: #SimpleTestResourceTestCase
    instanceVariableNames: 'resource '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'!

!ResumableTestFailureTestCase methodsFor: 'Not categorized'!

errorTest
    1 zork!

failureLog
    ^SUnitNameResolver defaultLogDevice!

failureTest
    self
    	assert: false description: 'You should see me' resumable: true; 
    	assert: false description: 'You should see me too' resumable: true; 
    	assert: false description: 'You should see me last' resumable: false; 
    	assert: false description: 'You should not see me' resumable: true!

isLogging
    ^false!

okTest
    self assert: true!

regularTestFailureTest
    self assert: false description: 'You should see me'!

resumableTestFailureTest
    self
    	assert: false description: 'You should see me' resumable: true; 
    	assert: false description: 'You should see me too' resumable: true; 
    	assert: false description: 'You should see me last' resumable: false; 
    	assert: false description: 'You should not see me' resumable: true!

testResumable
    | result suite |
    suite := TestSuite new.
    suite addTest: (self class selector: #errorTest).
    suite addTest: (self class selector: #regularTestFailureTest).
    suite addTest: (self class selector: #resumableTestFailureTest).
    suite addTest: (self class selector: #okTest).
    result := suite run.
    self assert: result failures size = 2;
    	assert: result errors size = 1! !

!SUnitTest class methodsFor: 'Testing'!

shouldInheritSelectors
    "answer true to inherit selectors from superclasses"

    ^false! !

!SUnitTest methodsFor: 'Testing'!

testAssert
    self assert: true.
    self deny: false!

testDefects
    | result suite error failure |
    suite := TestSuite new.
    suite addTest: (error := SUnitClientTest selector: #error).
    suite addTest: (failure := SUnitClientTest selector: #fail).
    result := suite run.
    self assert: (result defects includes: error).
    self assert: (result defects includes: failure).
    self
    	assertForTestResult: result
    	runCount: 2
    	passed: 0
    	failed: 1
    	errors: 1!

testDialectLocalizedException
    self
    	should: [TestResult signalFailureWith: 'Foo']
    	raise: TestResult failure.
    self
    	should: [TestResult signalErrorWith: 'Foo']
    	raise: TestResult error!

testDoubleError
    | case result |
    case := SUnitClientTest selector: #doubleError.
    result := case run.
    self
    	assertForTestResult: result
    	runCount: 1
    	passed: 0
    	failed: 0
    	errors: 1!

testError
    | case result |
    case := SUnitClientTest selector: #error.
    result := case run.
    self
    	assertForTestResult: result
    	runCount: 1
    	passed: 0
    	failed: 0
    	errors: 1.

    case := SUnitClientTest selector: #errorShouldntRaise.
    result := case run.
    self 
    	assertForTestResult: result
    	runCount: 1
    	passed: 0
    	failed: 0
    	errors: 1!

testException
    self should: [self error: 'foo'] raise: TestResult error!

testFail
    | case result |
    case := SUnitClientTest selector: #fail.
    result := case run.
    self
    	assertForTestResult: result
    	runCount: 1
    	passed: 0
    	failed: 1
    	errors: 0!

testIsNotRerunOnDebug
    | case |
    case := SUnitClientTest selector: #testRanOnlyOnce.
    case run.
    case debug!

testRan
    | case |
    case := SUnitClientTest selector: #setRun.
    self assert: case hasSetup ~= true.
    case run.
    self assert: case hasSetup == true.
    self assert: case hasRun == true!

testResult
    | case result |
    case := SUnitClientTest selector: #noop.
    result := case run.
    self
    	assertForTestResult: result
    	runCount: 1
    	passed: 1
    	failed: 0
    	errors: 0!

testResumable
    | result suite |
    (suite := TestSuite new) addTest: (SUnitClientTest selector: #errorTest).
    suite addTest: (SUnitClientTest selector: #regularTestFailureTest).
    suite addTest: (SUnitClientTest selector: #resumableTestFailureTest).
    suite addTest: (SUnitClientTest selector: #okTest).
    result := suite run.
    self
    	assert: result failures size = 2;
    	assert: result errors size = 1!

testRunning
    (SUnitDelay forSeconds: 1) wait!

testShould
    self should: [true].
    self shouldnt: [false]!

testSuite
    | suite result |
    suite := TestSuite new.
    suite addTest: (SUnitClientTest selector: #noop).
    suite addTest: (SUnitClientTest selector: #fail).
    suite addTest: (SUnitClientTest selector: #error).
    result := suite run.
    self
    	assertForTestResult: result
    	runCount: 3
    	passed: 1
    	failed: 1
    	errors: 1! !

!SUnitTest methodsFor: 'Private'!

assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount
    self
    	assert: aResult runCount = aRunCount;
    	assert: aResult passedCount = aPassedCount;
    	assert: aResult failureCount = aFailureCount;
    	assert: aResult errorCount = anErrorCount! !

!SUnitTest methodsFor: 'Logging'!

isLogging
    ^true! !

!SimpleTestResource methodsFor: 'testing'!

hasRun
    ^hasRun!

hasSetup
    ^hasSetup!

isAvailable
    
    ^self runningState == self startedStateSymbol! !

!SimpleTestResource methodsFor: 'accessing'!

runningState
    ^runningState!

runningState: aSymbol
    runningState := aSymbol! !

!SimpleTestResource methodsFor: 'running'!

setRun
    hasRun := true!

setUp
    
    self runningState: self startedStateSymbol.
    hasSetup := true!

startedStateSymbol
    ^#started!

stoppedStateSymbol
    ^#stopped!

tearDown
    self runningState: self stoppedStateSymbol! !

!SUnitClientTest methodsFor: 'Private'!

doubleError
    [ 3 zork ] sunitEnsure: [ 10 zork ]!

error
    3 zork!

errorShouldntRaise
    self 
    	shouldnt: [self someMessageThatIsntUnderstood] 
    	raise: SUnitNameResolver notificationObject!

errorTest
    1 zork.
    ^self!

fail
    self assert: false!

isLogging
    ^false!

noop!
okTest
    self assert: true.
    ^self!

regularTestFailureTest
    self assert: false description: 'You should see me'.
    ^self!

resumableTestFailureTest
    self
    assert: false
    description: 'You should see me'
    resumable: true;
    assert: false
    description: 'You should see me too'
    resumable: true;
    assert: false
    description: 'You should see me last'
    resumable: false;
    assert: false
    description: 'You should not see me'
    resumable: true.
    ^self!

setRun
    hasRun := true!

testRanOnlyOnce
    self assert: hasRun ~= true.
    hasRun := true! !

!SUnitClientTest methodsFor: 'Accessing'!

hasRun
    ^hasRun!

hasSetup
    ^hasSetup! !

!SUnitClientTest methodsFor: 'Running'!

setUp
    hasSetup := true! !

!ExampleSetTest methodsFor: 'Testing'!

testAdd
    empty add: 5.
    self assert: (empty includes: 5)!

testGrow
    empty addAll: (1 to: 100).
    self assert: empty size = 100!

testIllegal
    self 
    	should: [empty at: 5] 
    	raise: TestResult error.
    self 
    	should: [empty at: 5 put: #abc] 
    	raise: TestResult error!

testIncludes
    self assert: (full includes: 5).
    self assert: (full includes: #abc)!

testOccurrences
    self assert: (empty occurrencesOf: 0) = 0.
    self assert: (full occurrencesOf: 5) = 1.
    full add: 5.
    self assert: (full occurrencesOf: 5) = 1!

testRemove
    full remove: 5.
    self assert: (full includes: #abc).
    self deny: (full includes: 5)! !

!ExampleSetTest methodsFor: 'Running'!

setUp
    empty := Set new.
    full := Set with: 5 with: #abc! !

!SimpleTestResourceTestCase class methodsFor: 'Not categorized'!

resources
    ^Set new add: SimpleTestResource; yourself! !

!SimpleTestResourceTestCase methodsFor: 'Not categorized'!

dummy
    self assert: true!

error
    'foo' odd!

fail
    self assert: false!

setRun
    resource setRun!

setUp
    resource := SimpleTestResource current!

testRan
    | case |
    case := self class selector: #setRun.
    case run.
    self assert: resource hasSetup.
    self assert: resource hasRun!

testResourceInitRelease
    | result suite error failure |
    suite := TestSuite new.
    suite addTest: (error := self class selector: #error).
    suite addTest: (failure := self class selector: #fail).
    suite addTest: (self class selector: #dummy).
    result := suite run.
    self assert: resource hasSetup!

testResourcesCollection
    | collection |
    collection := self resources.
    self assert: collection size = 1! !

(SUnitTest -> SUnitTest buildSuite run) printNl!

