Object subclass: #TestSuite
    instanceVariableNames: 'tests resources name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestSuite comment: '
This is a Composite of Tests, either TestCases or other TestSuites. The common protocol is #run: aTestResult and the dependencies protocol'!


Object subclass: #TestResource
    instanceVariableNames: 'name description '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestResource class instanceVariableNames: 'current '!

Object subclass: #TestResult
    instanceVariableNames: 'failures errors passed '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestResult comment: '
This is a Collecting Parameter for the running of a bunch of tests. TestResult is an interesting object to subclass or substitute. #runCase: is the external protocol you need to reproduce. Kent has seen TestResults that recorded coverage information and that sent email when they were done.'!


Object subclass: #TestLogPolicy
    instanceVariableNames: 'logDevice testCase '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestLogPolicy comment: '
A TestLogPolicy is a Strategy to log failures and successes within an
SUnit test suite.  Besides providing a null logging policy, this class
provides some common accessors and intention-revealing methdods.

Instance Variables:
    logDevice	<Stream>	the device on which the test results are logged
    testCase	<Object>	the test case that''s being run

'!


TestLogPolicy subclass: #TestVerboseLog
    instanceVariableNames: 'hadSuccesses '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestVerboseLog comment: '
TestVerboseLog logs tests in this format

TestCaseName>>#testMethod1 .
TestCaseName>>#testMethod2 ..
TestCaseName>>#testMethod3 ....
FAILURE: failure description 1
...
ERROR
FAILURE: failure description 2
TestCaseName>>#testMethod4 .................

where each dot is a successful assertion.'!


TestVerboseLog subclass: #TestCondensedLog
    instanceVariableNames: 'realLogDevice hadProblems '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestCondensedLog comment: '
TestCondensedLog logs tests in the same format as TestVerboseLog,
but omits tests that pass.
'!


TestLogPolicy subclass: #TestFailureLog
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestFailureLog comment: '
TestFailureLog implements logging exactly like SUnit 3.1.
'!


Object subclass: #TestCase
    instanceVariableNames: 'testSelector logPolicy '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'!

TestCase comment: '
A TestCase is a Command representing the future running of a test case. Create one with the class method #selector: aSymbol, passing the name of the method to be run when the test case runs.

When you discover a new fixture, subclass TestCase, declare instance variables for the objects in the fixture, override #setUp to initialize the variables, and possibly override# tearDown to deallocate any external resources allocated in #setUp.

When you are writing a test case method, send #assert: aBoolean when you want to check for an expected value. For example, you might say "self assert: socket isOpen" to test whether or not a socket is open at a point in a test.'!


!TestSuite class methodsFor: 'Creation'!

named: aString
    ^self new
    	name: aString;
    	yourself! !

!TestSuite methodsFor: 'Running'!

run
    | result |
 	result := TestResult new.
    self resources do: [ :res |
    	res isAvailable ifFalse: [^res signalInitializationError]].
    [self run: result] sunitEnsure: [self resources do: [:each | each reset]].
    ^result!

run: aResult 
    self tests do: [:each | 
    	self sunitChanged: each.
    	each run: aResult]! !

!TestSuite methodsFor: 'Accessing'!

addTest: aTest
    self tests add: aTest!

addTests: aCollection 
    aCollection do: [:eachTest | self addTest: eachTest]!

defaultResources
    ^self tests 
    	inject: Set new
    	into: [:coll :testCase | 
    		coll
    			addAll: testCase resources;
    			yourself]!

name
    ^name!

name: aString
    name := aString!

resources
    resources isNil ifTrue: [resources := self defaultResources].
    ^resources!

resources: anObject
    resources := anObject!

tests
    tests isNil ifTrue: [tests := OrderedCollection new].
    ^tests! !

!TestSuite methodsFor: 'Dependencies'!

addDependentToHierachy: anObject
    self sunitAddDependent: anObject.
    self tests do: [ :each | each addDependentToHierachy: anObject]!

removeDependentFromHierachy: anObject
    self sunitRemoveDependent: anObject.
    self tests do: [ :each | each removeDependentFromHierachy: anObject]! !

!TestResource class methodsFor: 'Creation'!

new
    ^super new initialize!

reset
    current notNil ifTrue: [
    	[current tearDown] ensure: [
    		current := nil]]!

signalInitializationError
    ^TestResult signalErrorWith: 'Resource ' , self name , ' could not be initialized'! !

!TestResource class methodsFor: 'Testing'!

isAbstract
    "Override to true if a TestResource subclass is Abstract and should not have
    TestCase instances built from it"

    ^self name = #TestResource!

isAvailable
    ^self current notNil and: [self current isAvailable]!

isUnavailable
    ^self isAvailable not! !

!TestResource class methodsFor: 'Accessing'!

current
    current isNil
    	ifTrue: [current := self new].

    ^current!

current: aTestResource
    current := aTestResource!

resources
    ^#()! !

!TestResource methodsFor: 'Accessing'!

description
    description isNil
    	ifTrue: [^''].

    ^description!

description: aString
    description := aString!

name
    name isNil
    	ifTrue: [^self printString].

    ^name!

name: aString
    name := aString!

resources
    ^self class resources! !

!TestResource methodsFor: 'Running'!

setUp
    "Does nothing. Subclasses should override this
    to initialize their resource"!

signalInitializationError
    ^self class signalInitializationError!

tearDown
    "Does nothing. Subclasses should override this
    to tear down their resource"! !

!TestResource methodsFor: 'Testing'!

isAvailable
    "override to provide information on the
    readiness of the resource"
    
    ^true!

isUnavailable
    "override to provide information on the
    readiness of the resource"
    
    ^self isAvailable not! !

!TestResource methodsFor: 'Printing'!

printOn: aStream
    aStream nextPutAll: self class printString! !

!TestResource methodsFor: 'Init / Release'!

initialize
    self setUp! !

!TestResult class methodsFor: 'Exceptions'!

error
    ^SUnitNameResolver errorObject!

failure
    ^TestFailure!

resumableFailure
    ^ResumableTestFailure!

signalErrorWith: aString 
    self error sunitSignalWith: aString!

signalFailureWith: aString 
    self failure sunitSignalWith: aString! !

!TestResult class methodsFor: 'Init / Release'!

new
    ^super new initialize! !

!TestResult methodsFor: 'Accessing'!

correctCount
    "depreciated - use #passedCount"

    ^self passedCount!

defects
    ^OrderedCollection new
    	addAll: self errors;
    	addAll: self failures; yourself!

errorCount
    ^self errors size!

errors
    errors isNil
    	ifTrue: [errors := Set new].
    ^errors!

failureCount
    ^self failures size!

failures
    failures isNil
    	ifTrue: [failures := Set new].
    ^failures!

passed
    passed isNil
    	ifTrue: [passed := OrderedCollection new].

    ^passed!

passedCount
    ^self passed size!

runCount
    ^self passedCount + self failureCount + self errorCount!

tests
    ^(OrderedCollection new: self runCount)
    	addAll: self passed;
    	addAll: self errors;
    	addAll: self failures;
    	yourself! !

!TestResult methodsFor: 'Testing'!

hasErrors
    ^self errors size > 0!

hasFailures
    ^self failures size > 0!

hasPassed
    ^self hasErrors not and: [self hasFailures not]!

isError: aTestCase
    ^self errors includes: aTestCase!

isFailure: aTestCase
    ^self failures includes: aTestCase!

isPassed: aTestCase
    ^self passed includes: aTestCase! !

!TestResult methodsFor: 'Init / Release'!

initialize! !

!TestResult methodsFor: 'Running'!

runCase: aTestCase
    | testCasePassed |
    aTestCase logPolicy startTestCase: aTestCase.
    testCasePassed :=
    	[
    		[
    			aTestCase runCase.
    			true]
    				sunitOn: self class failure
    				do: [:signal |
    					self failures add: aTestCase.
    					signal sunitExitWith: false]]
    						sunitOn: self class error
    						do: [:signal |
							(self errors includes: aTestCase)
								ifFalse: [ aTestCase logError: signal ].
							self errors add: aTestCase.
    							signal sunitExitWith: false].

    aTestCase logPolicy flush.
    testCasePassed
    	ifTrue: [self passed add: aTestCase]! !

!TestResult methodsFor: 'Printing'!

printOn: aStream
    aStream
    	nextPutAll: self runCount printString;
    	nextPutAll: ' run, ';
    	nextPutAll: self passedCount printString;
    	nextPutAll: ' passed, ';
    	nextPutAll: self failureCount printString;
    	nextPutAll: ' failed, ';
    	nextPutAll: self errorCount printString;
    	nextPutAll: ' error'.

    self errorCount ~= 1
    	ifTrue: [aStream nextPut: $s]! !

!TestLogPolicy class methodsFor: 'Instance Creation'!

null
    ^TestLogPolicy on: (WriteStream on: String new)!

on: aStream
    ^self new initialize: aStream! !

!TestLogPolicy methodsFor: 'Initializing'!

initialize: aStream
    logDevice := aStream! !

!TestLogPolicy methodsFor: 'Accessing'!

logDevice
    ^logDevice!

testCase
    ^testCase! !

!TestLogPolicy methodsFor: 'logging'!

flush
    logDevice flush!

logError: exception!
logFailure: failure!
logSuccess!
nextPut: aCharacter
    logDevice nextPut: aCharacter!

nextPutAll: aString
    logDevice nextPutAll: aString!

print: anObject
    anObject printOn: logDevice!

showCr: aString
    logDevice nextPutAll: aString; nl!

space
    logDevice nextPut: ($ )!

startTestCase: aTestCase
    testCase := aTestCase! !

!TestVerboseLog methodsFor: 'logging'!

flush
    hadSuccesses ifTrue: [ self showCr: '' ].
    hadSuccesses := false.
    super flush!

logError: exception
    self flush.
    self showCr: 'ERROR'!

logFailure: failure
    self flush.
    failure isNil
    	ifTrue: [ self showCr: 'FAILURE: Assertion failed' ];
    	ifFalse: [ self showCr: 'FAILURE: ', failure ]!

logSuccess
    hadSuccesses := true.
    self nextPut: $.!

startTestCase: aTestCase
    super startTestCase: aTestCase.
    hadSuccesses := true.
    self print: aTestCase; space! !

!TestCondensedLog methodsFor: 'logging'!

flush
    super flush.
    hadProblems ifTrue: [
    	realLogDevice nextPutAll: self logDevice contents; flush ].

    self logDevice reset!

initialize: aStream
    realLogDevice := aStream.
    super initialize: (WriteStream on: String new)!

logError: exception
    hadProblems := true.
    super logError: exception!

logFailure: failure
    hadProblems := true.
    super logFailure: failure!

startTestCase: aTestCase
    hadProblems := false.
    super startTestCase: aTestCase! !

!TestFailureLog methodsFor: 'logging'!

logFailure: failure
    failure isNil ifFalse: [
    	self
    		print: self testCase;
    		nextPutAll: ': ';
    		showCr: failure ]! !

!TestCase class methodsFor: 'Instance Creation'!

debug: aSymbol
    ^(self selector: aSymbol) debug!

run: aSymbol
    ^(self selector: aSymbol) run!

selector: aSymbol
    ^self new setTestSelector: aSymbol!

suite
    ^self buildSuite! !

!TestCase class methodsFor: 'Building Suites'!

buildSuite
    | suite |
    ^self isAbstract
    	ifTrue: 
    		[suite := self suiteClass named: self name asString.
    		self allSubclasses 
    			do: [:each | each isAbstract ifFalse: [suite addTest: each buildSuiteFromSelectors]].
    		suite]
    	ifFalse: [self buildSuiteFromSelectors]!

buildSuiteFromAllSelectors
    ^self buildSuiteFromMethods: self allTestSelectors!

buildSuiteFromLocalSelectors
    ^self buildSuiteFromMethods: self testSelectors!

buildSuiteFromMethods: testMethods
    ^testMethods
    	inject: (self suiteClass named: self name asString)
    	into: [:suite :selector |
    		suite
    			addTest: (self selector: selector);
    			yourself]!

buildSuiteFromSelectors
    ^self shouldInheritSelectors
    	ifTrue: [self buildSuiteFromAllSelectors]
    	ifFalse: [self buildSuiteFromLocalSelectors]!

suiteClass
    ^TestSuite! !

!TestCase class methodsFor: 'Accessing'!

allTestSelectors
    ^self sunitAllSelectors select: [:each | 'test*' sunitMatch: each]!

resources
    ^#()!

sunitVersion
    ^'3.1'!

testSelectors
    ^self sunitSelectors select: [:each | 'test*' sunitMatch: each]! !

!TestCase class methodsFor: 'Testing'!

isAbstract
    "Override to true if a TestCase subclass is Abstract and should not have
    TestCase instances built from it"

    ^self name = #TestCase!

shouldInheritSelectors
    "I should inherit from an Abstract superclass but not from a concrete one by default, unless I have no testSelectors in which case I must be expecting to inherit them from my superclass.  If a test case with selectors wants to inherit selectors from a concrete superclass, override this to true in that subclass."

    ^self superclass isAbstract
    	or: [self testSelectors isEmpty]

"$QA Ignore:Sends system method(superclass)$"! !

!TestCase methodsFor: 'Accessing'!

assert: aBoolean
    aBoolean
        ifTrue: [ self logSuccess ]
        ifFalse: [
    	    self logFailure: nil. 
    	    TestResult failure sunitSignalWith: 'Assertion failed']!

assert: aBoolean description: aString
    aBoolean
        ifTrue: [ self logSuccess ]
        ifFalse: [
    	    self logFailure: aString. 
    	    TestResult failure sunitSignalWith: aString]!

assert: aBoolean description: aString resumable: resumableBoolean 
    | exception |
    aBoolean
        ifTrue: [ self logSuccess ]
        ifFalse:
            [self logFailure: aString.
            exception := resumableBoolean
               ifTrue: [TestResult resumableFailure]
               ifFalse: [TestResult failure].
            exception sunitSignalWith: aString]!

deny: aBoolean
    self assert: aBoolean not!

deny: aBoolean description: aString
    self assert: aBoolean not description: aString!

deny: aBoolean description: aString resumable: resumableBoolean 
    self
    	assert: aBoolean not
    	description: aString
    	resumable: resumableBoolean!

logError: aSignal
    self logPolicy logError: aSignal!

logFailure: anObject
    self logPolicy logFailure: anObject!

logPolicy
    logPolicy isNil ifTrue: [ logPolicy := self defaultLogPolicy ].
    ^logPolicy!

logPolicy: aLogPolicy
    logPolicy := aLogPolicy!

logSuccess
    self logPolicy logSuccess!

defaultLogPolicy
    ^self isLogging
    	ifTrue: [ self defaultLogPolicyClass on: self failureLog ]
    	ifFalse: [ TestLogPolicy null ]!

defaultLogPolicyClass
    ^TestCondensedLog!

resources
    | allResources resourceQueue |
    allResources := Set new.
    resourceQueue := OrderedCollection new.
    resourceQueue addAll: self class resources.
    [resourceQueue isEmpty] whileFalse: [
    	| next |
    	next := resourceQueue removeFirst.
    	allResources add: next.
    	resourceQueue addAll: next resources].
    ^allResources!

selector
    ^testSelector!

should: aBlock
    self assert: aBlock value!

should: aBlock description: aString
    self assert: aBlock value description: aString!

should: aBlock raise: anExceptionalEvent 
    ^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)!

should: aBlock raise: anExceptionalEvent description: aString 
    ^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
    	description: aString!

shouldnt: aBlock
    self deny: aBlock value!

shouldnt: aBlock description: aString
    self deny: aBlock value description: aString!

shouldnt: aBlock raise: anExceptionalEvent 
    ^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not!

shouldnt: aBlock raise: anExceptionalEvent description: aString 
    ^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not 		description: aString!

signalFailure: aString
    TestResult failure sunitSignalWith: aString! !

!TestCase methodsFor: 'Running'!

debug
    self resources do: [:res | 
    	res isAvailable ifFalse: [^res signalInitializationError]].
    [(self class selector: testSelector) runCase] 
    	sunitEnsure: [self resources do: [:each | each reset]]!

debugAsFailure
    | semaphore |
    semaphore := Semaphore new.
    self resources do: [:res | 
    	res isAvailable ifFalse: [^res signalInitializationError]].
    [semaphore wait. self resources do: [:each | each reset]] fork.
    (self class selector: testSelector) runCaseAsFailure: semaphore.!

failureLog
    ^SUnitNameResolver defaultLogDevice!

isLogging
    "By default, we're not logging failures. If you override this in 
    a subclass, make sure that you override #failureLog"
    ^true!

openDebuggerOnFailingTestMethod
    "SUnit has halted one step in front of the failing test method. Step over the 'self halt' and 
     send into 'self perform: testSelector' to see the failure from the beginning"

    self
    	halt;
    	performTest!

run
    | result |
    result := TestResult new.
    self run: result.
    ^result!

run: aResult
    aResult runCase: self!

runCase
    [self setUp.
    self performTest] sunitEnsure: [self tearDown]!

runCaseAsFailure: aSemaphore
    [self setUp.
    self openDebuggerOnFailingTestMethod] sunitEnsure: [
    	self tearDown.
    	aSemaphore signal]!

setUp!
tearDown! !

!TestCase methodsFor: 'Private'!

executeShould: aBlock inScopeOf: anExceptionalEvent 
    ^[aBlock value.
 	false] sunitOn: anExceptionalEvent
    	do: [:ex | ex sunitExitWith: true]!

performTest
    self perform: testSelector sunitAsSymbol!

setTestSelector: aSymbol
    testSelector := aSymbol! !

!TestCase methodsFor: 'Dependencies'!

addDependentToHierachy: anObject 
    "an empty method. for Composite compability with TestSuite"!

removeDependentFromHierachy: anObject 
    "an empty method. for Composite compability with TestSuite"! !

!TestCase methodsFor: 'Printing'!

printOn: aStream
    aStream
    	nextPutAll: self class printString;
    	nextPutAll: '>>#';
    	nextPutAll: testSelector! !
