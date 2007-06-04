"======================================================================
|
|   Lisp continuations for Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Parts Copyright (C) 1992 University of Manchester
| Written by Ian Piumarta and Avi Bryant.
|
 ======================================================================"

PackageLoader fileInPackage: #SUnit!

Object subclass: #Continuation
    instanceVariableNames: 'stack '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Implementation'!


!Continuation class methodsFor: 'instance creation'!

escapeDo: aBlock
    aBlock value: (self new stack: thisContext parentContext).
    SystemExceptions.BadReturn signal.
    Processor activeProcess terminate!

current
    ^self new stack: thisContext parentContext copyStack!

currentDo: aBlock
    ^aBlock value: (self new stack: thisContext parentContext copyStack)! !

!Continuation methodsFor: 'private'!

stack
    ^stack!

stack: s
    stack := s! !

!Continuation methodsFor: 'invocation'!

oneShotValue
    thisContext parentContext: stack.
    ^nil!

oneShotValue: v
    "escape to the original continuation with v as the result, discarding the stack on the way"

    thisContext parentContext: stack.
    ^v!

value
    thisContext parentContext: stack copyStack.
    ^nil!

value: v
    "return to the original continuation, copying the stack to allow another activation"
    thisContext parentContext: stack copyStack.
    ^v!

valueWithArguments: v
    "with one argument, just invoke the usual value mechanism"
    v size == 1 ifFalse: [^self error: 'continuations can only be resumed with one argument'].
    ^self value: (v at: 1)! !


!BlockClosure methodsFor: 'continuations'!

callCC
    ^Continuation currentDo: self! !

Object subclass: #Amb
    instanceVariableNames: 'failureContinuation direction '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside-Seaside-Continuations'!

!Amb class methodsFor: 'new'!

new
	^ super new initialize!

allValues: aBlock
	| amb |
	amb := self new.
	^amb allValues: [ aBlock value: amb ]! !

!Amb methodsFor: 'superpositions'!

withAllValues: aBlock do: serviceBlock
	|kPrev count|
	kPrev := failureContinuation.
	(Continuation currentDo:
		[:kRetry |
		failureContinuation := [:v | kRetry value: false].
		serviceBlock value: aBlock value.
		kRetry value: true])
			ifTrue: [self fail].
	failureContinuation := kPrev!

always: aBlock
	direction := direction not.
	^[ (self hasValue: aBlock) not ]
		ensure: [ direction := direction not ]!

countValues: aBlock
	| count |
	count := ValueHolder with: 0.
	self withAllValues: aBlock do: [ :x | count value: count value + 1 ].
	^count value!

allValues: aBlock
	| results |
	results := OrderedCollection new.
	self withAllValues: aBlock do: [ :x | results add: x ].
	^results asArray!

assert: aBoolean
	aBoolean == direction ifFalse: [self fail]!

deny: aBoolean
	self assert: aBoolean not!

fail
	^ failureContinuation value: nil!

hasValue: aBlock
	|kPrev ok|
	kPrev := failureContinuation.
	ok := Continuation currentDo:
		[:kRetry |
		failureContinuation := [:v | kRetry value: false].
		aBlock value.
		kRetry value: true].
	failureContinuation := kPrev.
	^ ok!

initialize
	failureContinuation := [:v | self error: 'Amb tree exhausted'].
	direction := true!

maybe
	^ self oneOf: { true. false }!

noneOf: aCollection satisfies: aBlock
	^(self oneOf: aCollection satisfies: aBlock) not!

allOf: aCollection satisfying: aBlock
	^self allValues: [ 
		| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x).
		x ]!

allOf: aCollection satisfy: aBlock
	^(self hasValue: [ 
		| x |
		x := self oneOf: aCollection.
		self deny: (aBlock value: x) ]) not!

oneOf: aCollection satisfies: aBlock
	^self hasValue: [ 
		| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x) ]!

oneOf: aCollection
	^ self valueOfOneOf: aCollection through: [:ea | ea ]!

valueOf: blockOne or: blockTwo
	^ self valueOfOneOf: { blockOne. blockTwo }!

valueOf: blockOne or: blockTwo or: blockThree
	^ self valueOfOneOf: { blockOne. blockTwo. blockThree }!

valueOfOneOf: blockCollection
	^self valueOfOneOf: blockCollection through: [ :ea | ea value ]!

valueOfOneOf: blockCollection through: aBlock
	|kPrev|
	kPrev := failureContinuation.
	^ Continuation currentDo:
		[:kEntry |
		blockCollection do:
			[:ea |
			Continuation currentDo:
				[:kNext |
				failureContinuation :=
					[:v | failureContinuation := kPrev. kNext value: v] fixTemps.
				kEntry value: (aBlock value: ea) ]].
		kPrev value: nil]
! !

TestCase subclass: #ContinuationTest
    instanceVariableNames: 'tmp tmp2 '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside-Seaside-Continuations'!

!ContinuationTest methodsFor: 'as yet unclassified'!

callcc: aBlock
	^ Continuation currentDo: aBlock!

testBlockEscape
	|x|
	tmp := 0.
	x := [tmp := tmp + 1. tmp2 value].
	self callcc: [:cc | tmp2 := cc. x value].
	tmp2 := [].
	x value.
	self assert: tmp = 2!

testBlockTemps
	|y|
	#(1 2 3) do:
		[:i ||x|
			x := i.
			tmp ifNil: [tmp2 := (self callcc: [:cc | tmp := cc. [:q]])].
			tmp2 value: x.
			x := 17].
	y := (self callcc: [:cc | tmp value: cc. 42]).
	self assert: y = 1!

testBlockVars
	|continuation|
	tmp := 0.
	tmp := (self callcc: [:cc | continuation := cc. 0]) + tmp.
	tmp2 isNil
		ifFalse: [tmp2 value]
		ifTrue:
			[#(1 2 3) do:
				[:i |
				self callcc: [:cc | tmp2 := cc. continuation value: i]]].
	self assert: tmp = 6!

testMethodTemps
	|i continuation|
	i := 0.
	i := i + (self callcc: [:cc | continuation := cc. 1]).
	self assert: i ~= 3.
	i = 2 ifFalse: [continuation value: 2]!

testSimpleCallCC
	|x continuation|
	x := self callcc: [:cc | continuation := cc. false].
	x ifFalse: [continuation value: true].
	self assert: x!

testSimplestCallCC
	|x|
	x := self callcc: [:cc | cc value: true].
	self assert: x! !

TestCase subclass: #AmbTest
    instanceVariableNames: 'amb '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside-Seaside-Continuations'!

!AmbTest methodsFor: 'as yet unclassified'!

setUp
    amb := Amb new!

testAllValuesAboveFive
    |x results|
    results := amb allValues:
    			[x := amb oneOf: (1 to: 10).
    			amb assert: (x > 5).
    			x].			
    self assert: results = #(6 7 8 9 10).
!

testMaybe
    |x y z|
    x := amb maybe.
    y := amb maybe.
    z := amb maybe not.

    amb deny: x = y.
    amb deny: x = z.
    
    self assert: x.
    self deny: y.
    self deny: z.!

testPickANumber
    self assert: self pickANumber = 1.!

testPickANumberAboveFive
    |x|
    x := self pickANumber.
    amb assert: (x > 5).
    self assert: x = 6.
!

testFactoring
    self assert: (self factors: 7) = #(7).
    self assert: (self factors: 8) = #(2 2 2).
    self assert: (self factors: 84) = #(2 2 3 7)!

testSetIntersection
    | x |
    x := amb allValues: [
	| x y |
	x := amb oneOf: #(#one #two #three #four).
	y := amb oneOf: #(#two #four #six #eight).
        amb assert: x = y.
	x ].
    self assert: x size = 2.
    self assert: (x includes: #two).
    self assert: (x includes: #four).

    x := amb allOf: #(#one #two #three #four) satisfying: [ :x |
	x = (amb oneOf: #(#two #four #six #eight)) ].
    self assert: x size = 2.
    self assert: (x includes: #two).
    self assert: (x includes: #four).

    x := amb allOf: #(#one #two #three #four) satisfying: [ :x |
	amb oneOf: #(#two #four #six #eight) satisfies: [ :y | x = y ] ].
    self assert: x size = 2.
    self assert: (x includes: #two).
    self assert: (x includes: #four)!

testSicpLogicProblem
    "Baker, Cooper, Fletcher, Miller, and Smith live on different floors of an apartment house that contains only five floors. Baker does not live on the top floor. Cooper does not live on the bottom floor. Fletcher does not live on either the top or the bottom floor. Miller lives on a higher floor than does Cooper. Smith does not live on a floor adjacent to Fletcher's. Fletcher does not live on a floor adjacent to Cooper's. Where does everyone live?"

"This implementation is too slow - uncomment to actually run it."
    
    |baker cooper fletcher miller smith|
    baker := amb oneOf: (1 to: 5).
    cooper := amb oneOf: (1 to: 5).
    fletcher := amb oneOf: (1 to: 5).
    miller := amb oneOf: (1 to: 5).
    smith := amb oneOf: (1 to: 5).
    
    amb assert: (Set new add: baker; add: cooper; add: fletcher; add: miller; add: smith; size) = 5.
    
    amb deny: baker = 5.
    amb deny: cooper = 1.
    amb deny: fletcher = 5.
    amb deny: fletcher = 1.
    amb assert: miller > cooper.
    amb deny: (smith - fletcher) abs = 1.
    amb deny: (fletcher - cooper) abs = 1.
    
    self assert: baker = 3.
    self assert: cooper = 2.
    self assert: fletcher = 4.
    self assert: miller = 5.
    self assert: smith = 1.
!

testSicpLogicProblemFaster
    "Baker, Cooper, Fletcher, Miller, and Smith live on different floors
    of an apartment house that contains only five floors. Baker does
    not live on the top floor. Cooper does not live on the bottom
    floor. Fletcher does not live on either the top or the bottom
    floor. Miller lives on a higher floor than does Cooper. Smith does
    not live on a floor adjacent to Fletcher's. Fletcher does not live
    on a floor adjacent to Cooper's. Where does everyone live?"
    
    |baker cooper fletcher miller smith|
    fletcher := amb oneOf: (1 to: 5).
    amb deny: fletcher = 5.
    amb deny: fletcher = 1.

    smith := amb oneOf: (1 to: 5).
    amb deny: (smith - fletcher) abs = 1.

    cooper := amb oneOf: (1 to: 5).
    amb deny: cooper = 1.
    amb deny: (fletcher - cooper) abs = 1.

    miller := amb oneOf: (1 to: 5).
    amb assert: miller > cooper.

    baker := amb oneOf: (1 to: 5).
    amb deny: baker = 5.
    
    amb assert: (Set new add: baker; add: cooper; add: fletcher; add: miller; add: smith; size) = 5.
    self assert: baker = 3.
    self assert: cooper = 2.
    self assert: fletcher = 4.
    self assert: miller = 5.
    self assert: smith = 1.!

testSolveAnEquation
    |x y|
    x := amb oneOf: (1 to: 10).
    y := amb oneOf: (1 to: 10).
    amb assert: (y * x) = 42.
    self assert: x = 6.
    self assert: y = 7.
!

testAlways
    self assert: (amb always: [ | x | x := amb maybe. amb assert: x | x not ]).
    self deny: (amb always: [ | x | x := amb maybe. amb assert: x ])!

testCountValues
    self assert: (amb countValues: [ self queens: 3 ]) = 0.
    self assert: (amb countValues: [ self queens: 4 ]) = 2!

testHasValue
    self deny: (amb hasValue: [ self queens: 3 ]).
    self assert: (amb hasValue: [ self queens: 4 ])!

testNoneOfSatisfies
    self deny: (self primeNoneOf: 8).
    self assert: (self primeNoneOf: 7)!

testAllOfSatisfy
    self deny: (self primeAllOf: 8).
    self assert: (self primeAllOf: 7).
    self assert: (amb allOf: (2 to: 4) satisfy: [ :x |
			amb allOf: (5 to: 7) satisfy: [ :y | x < y ] ])!

testOneOfSatisfies
    self deny: (self primeOneOf: 8).
    self assert: (self primeOneOf: 7).
    self assert: (amb oneOf: (4 to: 6) satisfies: [ :x |
			amb oneOf: (2 to: 4) satisfies: [ :y | x = y ] ])!

testDoubleNegation
    "This fails -- it is clear if you consider that..."
    self deny: (amb noneOf: (5 to: 7) satisfies: [ :x |
			amb noneOf: (2 to: 4) satisfies: [ :y | x < y ] ]).

    "... this passes, and is equivalent to the above."
    self assert: (amb oneOf: (5 to: 7) satisfies: [ :x |
			amb noneOf: (2 to: 4) satisfies: [ :y | x < y ] ]).

    "But what we meant was actually this."
    self assert: (amb noneOf: (5 to: 7) satisfies: [ :x |
			amb oneOf: (2 to: 4) satisfies: [ :y | x < y ] ])!

testQueens
    | results |
    results := amb allValues: [ self queens: 5 ].
    self assert: results size = 10.
    self assert: (results includes: #(1 3 5 2 4)).
    self assert: (results includes: #(5 3 1 4 2)).
    self deny: (results includes: #(1 2 3 4 5)).
    self assert: (results allSatisfy: [ :x | x asSet size = 5 ])
! !

!AmbTest methodsFor: 'problems'!

pickANumber
    ^ self pickANumberGreaterThan: 0!

pickANumberGreaterThan: aNumber
    ^ amb valueOf: [aNumber + 1] or: [self pickANumberGreaterThan: aNumber + 1]!

factors: n
    | lastDivisor check |
    n <= 2 ifTrue: [ ^{ n } ].
    lastDivisor := ValueHolder with: 1.
    ^amb allValues: [
	| divisor factor |
	divisor := amb oneOf: (2 to: n).
	amb assert: n \\ divisor == 0.
	amb assert: divisor \\ lastDivisor value == 0.
	factor := divisor / lastDivisor value.
	lastDivisor value: divisor.
	factor ]!
	
primeOneOf: n
    | limit |
    limit := n sqrt ceiling.
    ^(amb oneOf: (2 to: limit) satisfies: [ :x | (n \\ x) = 0 ]) not!

primeNoneOf: n
    | limit |
    limit := n sqrt ceiling.
    ^(amb noneOf: (2 to: limit) satisfies: [ :x | (n \\ x) = 0 ])!

primeAllOf: n
    | limit |
    limit := n sqrt ceiling.
    ^(amb allOf: (2 to: limit) satisfy: [ :x | (n \\ x) > 0 ])!

queens: size
    | board x y results |
    board := (1 to: size) collect: [ :a | amb oneOf: (1 to: size) ].
    1 to: size do: [ :i |
	x := board at: i.
	1 to: i - 1 do: [ :j |
	    y := board at: j.
	    amb assert: x ~= y.
	    amb assert: (x - y) abs ~= (i - j) abs ] ].
    ^board copy
! !

