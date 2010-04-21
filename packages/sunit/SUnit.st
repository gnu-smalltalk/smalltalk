Object subclass: TestSuite [
    | tests resources name |
    
    <category: 'SUnit'>
    <comment: '
This is a Composite of Tests, either TestCases or other TestSuites. The common protocol is #run: aTestResult and the dependencies protocol'>

    TestSuite class >> named: aString [
	<category: 'Creation'>
	^(self new)
	    name: aString;
	    yourself
    ]

    run [
	<category: 'Running'>
	| result |
	result := TestResult new.
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	[self run: result] sunitEnsure: [self resources do: [:each | each reset]].
	^result
    ]

    run: aResult [
	<category: 'Running'>
	self tests do: 
		[:each | 
		self sunitChanged: each.
		each run: aResult]
    ]

    addTest: aTest [
	<category: 'Accessing'>
	self tests add: aTest
    ]

    addTests: aCollection [
	<category: 'Accessing'>
	aCollection do: [:eachTest | self addTest: eachTest]
    ]

    defaultResources [
	<category: 'Accessing'>
	^self tests inject: Set new
	    into: 
		[:coll :testCase | 
		coll
		    addAll: testCase resources;
		    yourself]
    ]

    isLogging [
	<category: 'Accessing'>
	^true
    ]

    logPolicy: aLogPolicy [
	<category: 'Accessing'>
	self tests 
	    do: [:each | each isLogging ifTrue: [each logPolicy: aLogPolicy]]
    ]

    name [
	<category: 'Accessing'>
	^name
    ]

    name: aString [
	<category: 'Accessing'>
	name := aString
    ]

    resources [
	<category: 'Accessing'>
	resources isNil ifTrue: [resources := self defaultResources].
	^resources
    ]

    resources: anObject [
	<category: 'Accessing'>
	resources := anObject
    ]

    tests [
	<category: 'Accessing'>
	tests isNil ifTrue: [tests := OrderedCollection new].
	^tests
    ]

    addDependentToHierachy: anObject [
	<category: 'Dependencies'>
	self sunitAddDependent: anObject.
	self tests do: [:each | each addDependentToHierachy: anObject]
    ]

    removeDependentFromHierachy: anObject [
	<category: 'Dependencies'>
	self sunitRemoveDependent: anObject.
	self tests do: [:each | each removeDependentFromHierachy: anObject]
    ]
]



Object subclass: TestResource [
    | name description |
    
    <category: 'SUnit'>
    <comment: nil>

    TestResource class [
	| current |
	
    ]

    TestResource class >> new [
	<category: 'Creation'>
	^super new initialize
    ]

    TestResource class >> reset [
	<category: 'Creation'>
	current notNil ifTrue: [[current tearDown] ensure: [current := nil]]
    ]

    TestResource class >> signalInitializationError [
	<category: 'Creation'>
	^TestResult 
	    signalErrorWith: 'Resource ' , self name , ' could not be initialized'
    ]

    TestResource class >> isAbstract [
	"Override to true if a TestResource subclass is Abstract and should not have
	 TestCase instances built from it"

	<category: 'Testing'>
	^self name = #TestResource
    ]

    TestResource class >> isAvailable [
	<category: 'Testing'>
	^self current notNil and: [self current isAvailable]
    ]

    TestResource class >> isUnavailable [
	<category: 'Testing'>
	^self isAvailable not
    ]

    TestResource class >> current [
	<category: 'Accessing'>
	current isNil ifTrue: [current := self new].
	^current
    ]

    TestResource class >> current: aTestResource [
	<category: 'Accessing'>
	current := aTestResource
    ]

    TestResource class >> resources [
	<category: 'Accessing'>
	^#()
    ]

    description [
	<category: 'Accessing'>
	description isNil ifTrue: [^''].
	^description
    ]

    description: aString [
	<category: 'Accessing'>
	description := aString
    ]

    name [
	<category: 'Accessing'>
	name isNil ifTrue: [^self printString].
	^name
    ]

    name: aString [
	<category: 'Accessing'>
	name := aString
    ]

    resources [
	<category: 'Accessing'>
	^self class resources
    ]

    setUp [
	"Does nothing. Subclasses should override this
	 to initialize their resource"

	<category: 'Running'>
	
    ]

    signalInitializationError [
	<category: 'Running'>
	^self class signalInitializationError
    ]

    tearDown [
	"Does nothing. Subclasses should override this
	 to tear down their resource"

	<category: 'Running'>
	
    ]

    isAvailable [
	"override to provide information on the
	 readiness of the resource"

	<category: 'Testing'>
	^true
    ]

    isUnavailable [
	"override to provide information on the
	 readiness of the resource"

	<category: 'Testing'>
	^self isAvailable not
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream nextPutAll: self class printString
    ]

    initialize [
	<category: 'Init / Release'>
	self setUp
    ]
]



Object subclass: TestResult [
    | failures errors passed |
    
    <category: 'SUnit'>
    <comment: '
This is a Collecting Parameter for the running of a bunch of tests. TestResult is an interesting object to subclass or substitute. #runCase: is the external protocol you need to reproduce. Kent has seen TestResults that recorded coverage information and that sent email when they were done.'>

    TestResult class >> error [
	<category: 'Exceptions'>
	^SUnitNameResolver errorObject
    ]

    TestResult class >> failure [
	<category: 'Exceptions'>
	^TestFailure
    ]

    TestResult class >> resumableFailure [
	<category: 'Exceptions'>
	^ResumableTestFailure
    ]

    TestResult class >> signalErrorWith: aString [
	<category: 'Exceptions'>
	self error sunitSignalWith: aString
    ]

    TestResult class >> signalFailureWith: aString [
	<category: 'Exceptions'>
	self failure sunitSignalWith: aString
    ]

    TestResult class >> new [
	<category: 'Init / Release'>
	^super new initialize
    ]

    correctCount [
	"depreciated - use #passedCount"

	<category: 'Accessing'>
	^self passedCount
    ]

    defects [
	<category: 'Accessing'>
	^(OrderedCollection new)
	    addAll: self errors;
	    addAll: self failures;
	    yourself
    ]

    errorCount [
	<category: 'Accessing'>
	^self errors size
    ]

    errors [
	<category: 'Accessing'>
	^self unexpectedErrors
    ]

    expectedDefectCount [
	<category: 'Accessing'>
	^self expectedDefects size
    ]

    expectedDefects [
	<category: 'Accessing'>
	^errors , failures asOrderedCollection
	    select: [:each | each shouldPass not]
    ]

    expectedPassCount [
	<category: 'Accessing'>
	^self expectedPasses size
    ]

    expectedPasses [
	<category: 'Accessing'>
	^passed select: [:each | each shouldPass]
    ]

    unexpectedErrorCount [
	<category: 'Accessing'>
	^self unexpectedErrors size
    ]

    unexpectedErrors [
	<category: 'Accessing'>
	^errors select: [:each | each shouldPass]
    ]

    unexpectedFailureCount [
	<category: 'Accessing'>
	^self unexpectedFailures size
    ]

    unexpectedFailures [
	<category: 'Accessing'>
	^failures select: [:each | each shouldPass]
    ]

    unexpectedPassCount [
	<category: 'Accessing'>
	^self unexpectedPasses size
    ]

    unexpectedPasses [
	<category: 'Accessing'>
	^passed select: [:each | each shouldPass not]
    ]

    failureCount [
	<category: 'Accessing'>
	^self failures size
    ]

    failures [
	<category: 'Accessing'>
	^failures
    ]

    passed [
	<category: 'Accessing'>
	^self expectedPasses, self expectedDefects
    ]

    passedCount [
	<category: 'Accessing'>
	^self passed size
    ]

    runCount [
	<category: 'Accessing'>
	^passed size + failures size + errors size
    ]

    tests [
	<category: 'Accessing'>
	^(OrderedCollection new: self runCount)
	    addAll: passed;
	    addAll: errors;
	    addAll: failures;
	    yourself
    ]

    hasErrors [
	<category: 'Testing'>
	^self errors size > 0
    ]

    hasFailures [
	<category: 'Testing'>
	^self failures size > 0
    ]

    hasPassed [
	<category: 'Testing'>
	^self hasErrors not and: [self hasFailures not]
    ]

    isError: aTestCase [
	<category: 'Testing'>
	^self errors includes: aTestCase
    ]

    isFailure: aTestCase [
	<category: 'Testing'>
	^self failures includes: aTestCase
    ]

    isPassed: aTestCase [
	<category: 'Testing'>
	^self passed includes: aTestCase
    ]

    initialize [
	<category: 'Init / Release'>
	errors := Set new.
	failures := Set new.
	passed := OrderedCollection new.
    ]

    runCase: aTestCase [
	<category: 'Running'>
	| testCasePassed |
	aTestCase logPolicy startTestCase: aTestCase.
	testCasePassed := 
		[
		[aTestCase runCase.
		true] sunitOn: self class failure
			do: 
			    [:signal | 
			    failures add: aTestCase.
			    signal sunitExitWith: false]] 
			sunitOn: self class error
			do: 
			    [:signal | 
			    (errors includes: aTestCase) ifFalse: [aTestCase logError: signal].
			    errors add: aTestCase.
			    signal sunitExitWith: false].
	aTestCase logPolicy flush.
	testCasePassed ifTrue: [passed add: aTestCase]
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream
	    nextPutAll: self runCount printString;
	    nextPutAll: ' run'.
        self expectedPassCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self expectedPassCount printString;
	        nextPutAll: ' passes' ].
        self expectedDefectCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self expectedDefectCount printString;
	        nextPutAll: ' expected failures' ].
        self unexpectedFailureCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedFailureCount printString;
	        nextPutAll: ' failures' ].
        self unexpectedErrorCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedErrorCount printString;
	        nextPutAll: ' errors' ].
        self unexpectedPassCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedPassCount printString;
	        nextPutAll: ' unexpected passes' ]
    ]
]



Object subclass: TestLogPolicy [
    | logDevice testCase |
    
    <category: 'SUnit'>
    <comment: '
A TestLogPolicy is a Strategy to log failures and successes within an
SUnit test suite.  Besides providing a null logging policy, this class
provides some common accessors and intention-revealing methdods.

Instance Variables:
    logDevice	<Stream>	the device on which the test results are logged
    testCase	<Object>	the test case that''s being run

'>

    TestLogPolicy class >> null [
	<category: 'Instance Creation'>
	^TestLogPolicy on: (WriteStream on: String new)
    ]

    TestLogPolicy class >> on: aStream [
	<category: 'Instance Creation'>
	^self new initialize: aStream
    ]

    initialize: aStream [
	<category: 'Initializing'>
	logDevice := aStream
    ]

    logDevice [
	<category: 'Accessing'>
	^logDevice
    ]

    testCase [
	<category: 'Accessing'>
	^testCase
    ]

    flush [
	<category: 'logging'>
	logDevice flush
    ]

    logError: exception [
	<category: 'logging'>
	
    ]

    logFailure: failure [
	<category: 'logging'>
	
    ]

    logSuccess [
	<category: 'logging'>
	
    ]

    nextPut: aCharacter [
	<category: 'logging'>
	logDevice nextPut: aCharacter
    ]

    nextPutAll: aString [
	<category: 'logging'>
	logDevice nextPutAll: aString
    ]

    print: anObject [
	<category: 'logging'>
	anObject printOn: logDevice
    ]

    showCr: aString [
	<category: 'logging'>
	logDevice
	    nextPutAll: aString;
	    nl
    ]

    space [
	<category: 'logging'>
	logDevice nextPut: $ 
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	testCase := aTestCase
    ]
]



TestLogPolicy subclass: TestVerboseLog [
    | hadSuccesses |
    
    <category: 'SUnit'>
    <comment: '
TestVerboseLog logs tests in this format

TestCaseName>>#testMethod1 .
TestCaseName>>#testMethod2 ..
TestCaseName>>#testMethod3 ....
FAILURE: failure description 1
...
ERROR
FAILURE: failure description 2
TestCaseName>>#testMethod4 .................

where each dot is a successful assertion.'>

    flush [
	<category: 'logging'>
	hadSuccesses ifTrue: [self showCr: ''].
	hadSuccesses := false.
	super flush
    ]

    logError: exception [
	<category: 'logging'>
	exception messageText displayNl.
	Smalltalk backtrace.
	self flush.
	self showCr: 'ERROR'
    ]

    logFailure: failure [
	<category: 'logging'>
	self flush.
	(failure isNil)
	    ifTrue: [self showCr: 'FAILURE: Assertion failed'];
	    ifFalse: [self showCr: 'FAILURE: ' , failure]
    ]

    logSuccess [
	<category: 'logging'>
	hadSuccesses := true.
	self nextPut: $.
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	super startTestCase: aTestCase.
	hadSuccesses := true.
	self
	    print: aTestCase;
	    space
    ]
]



TestVerboseLog subclass: TestCondensedLog [
    | realLogDevice hadProblems |
    
    <category: 'SUnit'>
    <comment: '
TestCondensedLog logs tests in the same format as TestVerboseLog,
but omits tests that pass.
'>

    flush [
	<category: 'logging'>
	super flush.
	hadProblems 
	    ifTrue: 
		[realLogDevice
		    nextPutAll: self logDevice contents;
		    flush].
	self logDevice reset
    ]

    initialize: aStream [
	<category: 'logging'>
	realLogDevice := aStream.
	super initialize: (WriteStream on: String new)
    ]

    logError: exception [
	<category: 'logging'>
	hadProblems := true.
	super logError: exception
    ]

    logFailure: failure [
	<category: 'logging'>
	hadProblems := true.
	super logFailure: failure
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	hadProblems := false.
	super startTestCase: aTestCase
    ]
]



TestLogPolicy subclass: TestFailureLog [
    
    <category: 'SUnit'>
    <comment: '
TestFailureLog implements logging exactly like SUnit 3.1.
'>

    logFailure: failure [
	<category: 'logging'>
	failure isNil 
	    ifFalse: 
		[self
		    print: self testCase;
		    nextPutAll: ': ';
		    showCr: failure]
    ]
]



Object subclass: TestCase [
    | testSelector logPolicy |
    
    <category: 'SUnit'>
    <comment: '
A TestCase is a Command representing the future running of a test case. Create one with the class method #selector: aSymbol, passing the name of the method to be run when the test case runs.

When you discover a new fixture, subclass TestCase, declare instance variables for the objects in the fixture, override #setUp to initialize the variables, and possibly override# tearDown to deallocate any external resources allocated in #setUp.

When you are writing a test case method, send #assert: aBoolean when you want to check for an expected value. For example, you might say "self assert: socket isOpen" to test whether or not a socket is open at a point in a test.'>

    TestCase class >> debug: aSymbol [
	<category: 'Instance Creation'>
	^(self selector: aSymbol) debug
    ]

    TestCase class >> run: aSymbol [
	<category: 'Instance Creation'>
	^(self selector: aSymbol) run
    ]

    TestCase class >> selector: aSymbol [
	<category: 'Instance Creation'>
	^self new setTestSelector: aSymbol
    ]

    TestCase class >> suite [
	<category: 'Instance Creation'>
	^self buildSuite
    ]

    TestCase class >> buildSuite [
	<category: 'Building Suites'>
	| suite |
	^self isAbstract 
	    ifTrue: 
		[suite := self suiteClass named: self name asString.
		self allSubclasses 
		    do: [:each | each isAbstract ifFalse: [suite addTest: each buildSuiteFromSelectors]].
		suite]
	    ifFalse: [self buildSuiteFromSelectors]
    ]

    TestCase class >> buildSuiteFromAllSelectors [
	<category: 'Building Suites'>
	^self buildSuiteFromMethods: self allTestSelectors
    ]

    TestCase class >> buildSuiteFromLocalSelectors [
	<category: 'Building Suites'>
	^self buildSuiteFromMethods: self testSelectors
    ]

    TestCase class >> buildSuiteFromMethods: testMethods [
	<category: 'Building Suites'>
	^testMethods inject: (self suiteClass named: self name asString)
	    into: 
		[:suite :selector | 
		suite
		    addTest: (self selector: selector);
		    yourself]
    ]

    TestCase class >> buildSuiteFromSelectors [
	<category: 'Building Suites'>
	^self shouldInheritSelectors 
	    ifTrue: [self buildSuiteFromAllSelectors]
	    ifFalse: [self buildSuiteFromLocalSelectors]
    ]

    TestCase class >> suiteClass [
	<category: 'Building Suites'>
	^TestSuite
    ]

    TestCase class >> allTestSelectors [
	<category: 'Accessing'>
	^self sunitAllSelectors select: [:each | 'test*' sunitMatch: each]
    ]

    TestCase class >> resources [
	<category: 'Accessing'>
	^#()
    ]

    TestCase class >> sunitVersion [
	<category: 'Accessing'>
	^'3.1'
    ]

    TestCase class >> testSelectors [
	<category: 'Accessing'>
	^self sunitSelectors select: [:each | 'test*' sunitMatch: each]
    ]

    TestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	 TestCase instances built from it"

	<category: 'Testing'>
	^self name = #TestCase
    ]

    TestCase class >> shouldInheritSelectors [
	"I should inherit from an Abstract superclass but not from a concrete one by default, unless I have no testSelectors in which case I must be expecting to inherit them from my superclass.  If a test case with selectors wants to inherit selectors from a concrete superclass, override this to true in that subclass."

	<category: 'Testing'>
	^self superclass isAbstract or: 
		[self testSelectors isEmpty

		"$QA Ignore:Sends system method(superclass)$"]
    ]

    assert: aBoolean [
	<category: 'Accessing'>
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: nil.
		TestResult failure sunitSignalWith: 'Assertion failed']
    ]

    assert: aBoolean description: aString [
	<category: 'Accessing'>
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: aString.
		TestResult failure sunitSignalWith: aString]
    ]

    assert: aBoolean description: aString resumable: resumableBoolean [
	<category: 'Accessing'>
	| exception |
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: aString.
		exception := resumableBoolean 
			    ifTrue: [TestResult resumableFailure]
			    ifFalse: [TestResult failure].
		exception sunitSignalWith: aString]
    ]

    deny: aBoolean [
	<category: 'Accessing'>
	self assert: aBoolean not
    ]

    deny: aBoolean description: aString [
	<category: 'Accessing'>
	self assert: aBoolean not description: aString
    ]

    deny: aBoolean description: aString resumable: resumableBoolean [
	<category: 'Accessing'>
	self 
	    assert: aBoolean not
	    description: aString
	    resumable: resumableBoolean
    ]

    logError: aSignal [
	<category: 'Accessing'>
	self logPolicy logError: aSignal
    ]

    logFailure: anObject [
	<category: 'Accessing'>
	self logPolicy logFailure: anObject
    ]

    logPolicy [
	<category: 'Accessing'>
	logPolicy isNil ifTrue: [logPolicy := self defaultLogPolicy].
	^logPolicy
    ]

    logPolicy: aLogPolicy [
	<category: 'Accessing'>
	logPolicy := aLogPolicy
    ]

    logSuccess [
	<category: 'Accessing'>
	self logPolicy logSuccess
    ]

    defaultLogPolicy [
	<category: 'Accessing'>
	^self isLogging 
	    ifTrue: [self defaultLogPolicyClass on: self failureLog]
	    ifFalse: [TestLogPolicy null]
    ]

    defaultLogPolicyClass [
	<category: 'Accessing'>
	^TestCondensedLog
    ]

    resources [
	<category: 'Accessing'>
	| allResources resourceQueue |
	allResources := Set new.
	resourceQueue := OrderedCollection new.
	resourceQueue addAll: self class resources.
	[resourceQueue isEmpty] whileFalse: 
		[| next |
		next := resourceQueue removeFirst.
		allResources add: next.
		resourceQueue addAll: next resources].
	^allResources
    ]

    selector [
	<category: 'Accessing'>
	^testSelector
    ]

    should: aBlock [
	<category: 'Accessing'>
	self assert: aBlock value
    ]

    should: aBlock description: aString [
	<category: 'Accessing'>
	self assert: aBlock value description: aString
    ]

    should: aBlock raise: anExceptionalEvent [
	<category: 'Accessing'>
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
    ]

    should: aBlock raise: anExceptionalEvent description: aString [
	<category: 'Accessing'>
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
	    description: aString
    ]

    shouldnt: aBlock [
	<category: 'Accessing'>
	self deny: aBlock value
    ]

    shouldnt: aBlock description: aString [
	<category: 'Accessing'>
	self deny: aBlock value description: aString
    ]

    shouldnt: aBlock raise: anExceptionalEvent [
	<category: 'Accessing'>
	^self 
	    assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not
    ]

    shouldnt: aBlock raise: anExceptionalEvent description: aString [
	<category: 'Accessing'>
	^self 
	    assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not
	    description: aString
    ]

    signalFailure: aString [
	<category: 'Accessing'>
	TestResult failure sunitSignalWith: aString
    ]

    debug [
	<category: 'Running'>
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	[(self class selector: testSelector)
		logPolicy: TestLogPolicy null;
		runCase] 
	    sunitEnsure: [self resources do: [:each | each reset]]
    ]

    debugAsFailure [
	<category: 'Running'>
	| semaphore |
	semaphore := Semaphore new.
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	
	[semaphore wait.
	self resources do: [:each | each reset]] fork.
	(self class selector: testSelector) runCaseAsFailure: semaphore
    ]

    failureLog [
	<category: 'Running'>
	^SUnitNameResolver defaultLogDevice
    ]

    isLogging [
	"By default, we're not logging failures. If you override this in
	 a subclass, make sure that you override #failureLog"

	<category: 'Running'>
	^true
    ]

    openDebuggerOnFailingTestMethod [
	"SUnit has halted one step in front of the failing test method. Step over the 'self halt' and
	 send into 'self perform: testSelector' to see the failure from the beginning"

	<category: 'Running'>
	self
	    halt;
	    performTest
    ]

    run [
	<category: 'Running'>
	| result |
	result := TestResult new.
	self run: result.
	^result
    ]

    run: aResult [
	<category: 'Running'>
	aResult runCase: self
    ]

    runCase [
	<category: 'Running'>
	
	[self setUp.
	self performTest] sunitEnsure: [self tearDown]
    ]

    runCaseAsFailure: aSemaphore [
	<category: 'Running'>
	
	[self setUp.
	self openDebuggerOnFailingTestMethod] sunitEnsure: 
		    [self tearDown.
		    aSemaphore signal]
    ]

    setUp [
	<category: 'Running'>
	
    ]

    tearDown [
	<category: 'Running'>
	
    ]

    expectedFailures [
	<category: 'Testing'>
	^Array new
    ]

    shouldPass [
	"Unless the selector is in the list we get from #expectedFailures, we expect it to pass"

	<category: 'Testing'>
	^(self expectedFailures includes: testSelector) not
    ]

    executeShould: aBlock inScopeOf: anExceptionalEvent [
	<category: 'Private'>
	^
	[aBlock value.
	false] sunitOn: anExceptionalEvent
		do: [:ex | ex sunitExitWith: true]
    ]

    performTest [
	<category: 'Private'>
	self perform: testSelector sunitAsSymbol
    ]

    setTestSelector: aSymbol [
	<category: 'Private'>
	testSelector := aSymbol
    ]

    addDependentToHierachy: anObject [
	"an empty method. for Composite compability with TestSuite"

	<category: 'Dependencies'>
	
    ]

    removeDependentFromHierachy: anObject [
	"an empty method. for Composite compability with TestSuite"

	<category: 'Dependencies'>
	
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream
	    nextPutAll: self class printString;
	    nextPutAll: '>>#';
	    nextPutAll: testSelector
    ]
]

