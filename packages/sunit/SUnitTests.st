TestCase subclass: ResumableTestFailureTestCase [
    
    <comment: nil>
    <category: 'SUnit-SUnitTests'>

    errorTest [
	<category: 'Not categorized'>
	1 zork
    ]

    failureLog [
	<category: 'Not categorized'>
	^SUnitNameResolver defaultLogDevice
    ]

    failureTest [
	<category: 'Not categorized'>
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
		resumable: true
    ]

    isLogging [
	<category: 'Not categorized'>
	^false
    ]

    okTest [
	<category: 'Not categorized'>
	self assert: true
    ]

    regularTestFailureTest [
	<category: 'Not categorized'>
	self assert: false description: 'You should see me'
    ]

    resumableTestFailureTest [
	<category: 'Not categorized'>
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
		resumable: true
    ]

    testResumable [
	<category: 'Not categorized'>
	| result suite |
	suite := TestSuite new.
	suite addTest: (self class selector: #errorTest).
	suite addTest: (self class selector: #regularTestFailureTest).
	suite addTest: (self class selector: #resumableTestFailureTest).
	suite addTest: (self class selector: #okTest).
	result := suite run.
	self
	    assert: result failures size = 2;
	    assert: result errors size = 1
    ]
]



TestCase subclass: SUnitTest [
    
    <comment: '
This is both an example of writing tests and a self test for the SUnit. The tests 
run the SUnitClientTests and make sure that things blow up correctly. Your
tests will usually be far more complicated in terms of your own objects- more
assertions, more complicated setup. Kent says: "Never forget, however, that
if the tests are hard to write, something is probably wrong with the design".'>
    <category: 'SUnit-SUnitTests'>

    SUnitTest class >> shouldInheritSelectors [
	"answer true to inherit selectors from superclasses"

	<category: 'Testing'>
	^false
    ]

    testAssert [
	<category: 'Testing'>
	self assert: true.
	self deny: false
    ]

    testDefects [
	<category: 'Testing'>
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
	    errors: 1
    ]

    testDialectLocalizedException [
	<category: 'Testing'>
	self should: [TestResult signalFailureWith: 'Foo']
	    raise: TestResult failure.
	self should: [TestResult signalErrorWith: 'Foo'] raise: TestResult error
    ]

    testDoubleError [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #doubleError.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 1
    ]

    testError [
	<category: 'Testing'>
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
	    errors: 1
    ]

    testException [
	<category: 'Testing'>
	self should: [self error: 'foo'] raise: TestResult error
    ]

    testFail [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #fail.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 1
	    errors: 0
    ]

    testIsNotRerunOnDebug [
	<category: 'Testing'>
	| case |
	case := SUnitClientTest selector: #testRanOnlyOnce.
	case run.
	case debug
    ]

    testRan [
	<category: 'Testing'>
	| case |
	case := SUnitClientTest selector: #setRun.
	self assert: case hasSetup ~= true.
	case run.
	self assert: case hasSetup == true.
	self assert: case hasRun == true
    ]

    testResult [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #noop.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 1
	    failed: 0
	    errors: 0
    ]

    testResumable [
	<category: 'Testing'>
	| result suite |
	(suite := TestSuite new) addTest: (SUnitClientTest selector: #errorTest).
	suite addTest: (SUnitClientTest selector: #regularTestFailureTest).
	suite addTest: (SUnitClientTest selector: #resumableTestFailureTest).
	suite addTest: (SUnitClientTest selector: #okTest).
	result := suite run.
	self
	    assert: result failures size = 2;
	    assert: result errors size = 1
    ]

    testRunning [
	<category: 'Testing'>
	(SUnitDelay forSeconds: 1) wait
    ]

    testShould [
	<category: 'Testing'>
	self should: [true].
	self shouldnt: [false]
    ]

    testSuite [
	<category: 'Testing'>
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
	    errors: 1
    ]

    testExpectedFailures [
        <category: 'Testing'>
        | result suite expected failed error |
	suite := TestSuite new.
	suite addTest: (expected := SUnitClientTest selector: #generateExpectedFailure).
	suite addTest: (failed := SUnitClientTest selector: #generateUnexpectedSuccess).
	result := suite run.
	self assert: (result expectedDefects includes: expected).
	self assert: (result unexpectedPasses includes: failed).

	self
	    assertForTestResult: result
	    runCount: 2
	    passed: 1
	    failed: 1
	    errors: 0
    ]

    assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount [
	<category: 'Private'>
	self
	    assert: aResult runCount = aRunCount;
	    assert: aResult passedCount = aPassedCount;
	    assert: aResult failureCount = aFailureCount;
	    assert: aResult errorCount = anErrorCount
    ]

    isLogging [
	<category: 'Logging'>
	^true
    ]
]



TestResource subclass: SimpleTestResource [
    | runningState hasRun hasSetup hasRanOnce |
    
    <comment: nil>
    <category: 'SUnitTests'>

    hasRun [
	<category: 'testing'>
	^hasRun
    ]

    hasSetup [
	<category: 'testing'>
	^hasSetup
    ]

    isAvailable [
	<category: 'testing'>
	^self runningState == self startedStateSymbol
    ]

    runningState [
	<category: 'accessing'>
	^runningState
    ]

    runningState: aSymbol [
	<category: 'accessing'>
	runningState := aSymbol
    ]

    setRun [
	<category: 'running'>
	hasRun := true
    ]

    setUp [
	<category: 'running'>
	self runningState: self startedStateSymbol.
	hasSetup := true
    ]

    startedStateSymbol [
	<category: 'running'>
	^#started
    ]

    stoppedStateSymbol [
	<category: 'running'>
	^#stopped
    ]

    tearDown [
	<category: 'running'>
	self runningState: self stoppedStateSymbol
    ]
]



TestCase subclass: SUnitClientTest [
    | hasRun hasSetup |
    
    <comment: '
This is an internal class used by the self test for the SUnit. These are
very simple tests but they are pretty strange, since you want to make
sure things blow up. They are separate from SUnitTest both because
you don''t want to log these failures, and because they don''t test
SUnit concepts but rather simulate the real test suites that SUnit
will run.'>
    <category: 'SUnitTests'>

    doubleError [
	<category: 'Private'>
	[3 zork] sunitEnsure: [10 zork]
    ]

    error [
	<category: 'Private'>
	3 zork
    ]

    errorShouldntRaise [
	<category: 'Private'>
	self shouldnt: [self someMessageThatIsntUnderstood]
	    raise: SUnitNameResolver notificationObject
    ]

    errorTest [
	<category: 'Private'>
	1 zork.
	^self
    ]

    fail [
	<category: 'Private'>
	self assert: false
    ]

    isLogging [
	<category: 'Private'>
	^false
    ]

    noop [
	<category: 'Private'>
	
    ]

    okTest [
	<category: 'Private'>
	self assert: true.
	^self
    ]

    regularTestFailureTest [
	<category: 'Private'>
	self assert: false description: 'You should see me'.
	^self
    ]

    resumableTestFailureTest [
	<category: 'Private'>
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
	^self
    ]

    setRun [
	<category: 'Private'>
	hasRun := true
    ]

    testRanOnlyOnce [
	<category: 'Private'>
	self assert: hasRun ~= true.
	hasRun := true
    ]

    hasRun [
	<category: 'Accessing'>
	^hasRun
    ]

    hasSetup [
	<category: 'Accessing'>
	^hasSetup
    ]

    setUp [
	<category: 'Running'>
	hasSetup := true
    ]

    expectedFailures [
	<category: 'Private'>
        ^#(#generateExpectedFailure #generateUnexpectedSuccess)
    ]

    generateExpectedFailure [
	<category: 'Private'>
        self assert: false
    ]

    generateUnexpectedSuccess [
	<category: 'Private'>
        self assert: true
    ]
]



TestCase subclass: ExampleSetTest [
    | full empty |
    
    <comment: nil>
    <category: 'SUnitTests'>

    testAdd [
	<category: 'Testing'>
	empty add: 5.
	self assert: (empty includes: 5)
    ]

    testGrow [
	<category: 'Testing'>
	empty addAll: (1 to: 100).
	self assert: empty size = 100
    ]

    testIllegal [
	<category: 'Testing'>
	self should: [empty at: 5] raise: TestResult error.
	self should: [empty at: 5 put: #abc] raise: TestResult error
    ]

    testIncludes [
	<category: 'Testing'>
	self assert: (full includes: 5).
	self assert: (full includes: #abc)
    ]

    testOccurrences [
	<category: 'Testing'>
	self assert: (empty occurrencesOf: 0) = 0.
	self assert: (full occurrencesOf: 5) = 1.
	full add: 5.
	self assert: (full occurrencesOf: 5) = 1
    ]

    testRemove [
	<category: 'Testing'>
	full remove: 5.
	self assert: (full includes: #abc).
	self deny: (full includes: 5)
    ]

    setUp [
	<category: 'Running'>
	empty := Set new.
	full := Set with: 5 with: #abc
    ]
]



TestCase subclass: SimpleTestResourceTestCase [
    | resource |
    
    <comment: nil>
    <category: 'SUnitTests'>

    SimpleTestResourceTestCase class >> resources [
	<category: 'Not categorized'>
	^(Set new)
	    add: SimpleTestResource;
	    yourself
    ]

    dummy [
	<category: 'Not categorized'>
	self assert: true
    ]

    error [
	<category: 'Not categorized'>
	'foo' odd
    ]

    fail [
	<category: 'Not categorized'>
	self assert: false
    ]

    setRun [
	<category: 'Not categorized'>
	resource setRun
    ]

    setUp [
	<category: 'Not categorized'>
	resource := SimpleTestResource current
    ]

    testRan [
	<category: 'Not categorized'>
	| case |
	case := self class selector: #setRun.
	case run.
	self assert: resource hasSetup.
	self assert: resource hasRun
    ]

    testResourceInitRelease [
	<category: 'Not categorized'>
	| result suite error failure |
	suite := TestSuite new.
	suite addTest: (error := self class selector: #error).
	suite addTest: (failure := self class selector: #fail).
	suite addTest: (self class selector: #dummy).
	result := suite run.
	self assert: resource hasSetup
    ]

    testResourcesCollection [
	<category: 'Not categorized'>
	| collection |
	collection := self resources.
	self assert: collection size = 1
    ]
]

