"======================================================================
|
|   Lisp continuations for Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1992 University of Manchester
| Written by Ian Piumarta.
|
 ======================================================================"

PackageLoader fileInPackage: #SUnit!

Object subclass: #Continuation
    instanceVariableNames: 'stack '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Kernel-Methods'!


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


!Continuation class methodsFor: 'instance creation'!

current
    ^self fromContext: thisContext sender!

currentDo: aBlock
    ^aBlock value: (self fromContext: thisContext sender)!

fromContext: aStack
    ^self new stack: aStack copyStack! !

!Continuation class methodsFor: 'examples'!

factorialExample: x 
    "Modified from the example given in Dybvig p. 81 (the example is 
    explained adequately there). Evaluate each of the following expressions 
    in turn.
    Undeclared is used to hold a `global' temporary to avoid cluttering your
    namespace."

    "Transcript cr; show: (self factorialExample: 4) printString; cr" 
    "(Undeclared at: #RetryCC) value: 2"
    "(Undeclared at: #RetryCC) value: 5"
    "Undeclared removeKey: #RetryCC"

    ^x == 0
    	ifTrue: [
	    [ :continuation | 
		Undeclared at: #RetryCC put: continuation.
		1] callCC]
	ifFalse: [x * (self factorialExample: x - 1) printNl]! !

!BlockClosure methodsFor: 'copying'!

copyStack
    outerContext := outerContext copyStack! !

!BlockClosure methodsFor: 'continuations'!

callCC
    ^self value: (Continuation fromContext: thisContext parentContext)! !

!ContextPart methodsFor: 'copying'!

copyStack
    self parentContext isNil
	ifTrue:[^self copy]
	ifFalse: [^self copy parentContext: self parentContext copyStack]! !

"(Continuation factorialExample: 4) printNl!"
"(Undeclared.RetryCC value: 10) printNl!"
"Undeclared removeKey: #RetryCC!"


Object subclass: #Amb
    instanceVariableNames: 'failureContinuation '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside-Seaside-Continuations'!

!Amb class methodsFor: 'new'!

new
	^ super new initialize! !

!Amb methodsFor: 'superpositions'!

allValues: aBlock
	|kPrev results|
	kPrev := failureContinuation.
	results := OrderedCollection new.
	(Continuation currentDo:
		[:kRetry |
		failureContinuation := [:v | kRetry value: false].
		results add: aBlock value.
		kRetry value: true])
			ifTrue: [self fail].
	failureContinuation := kPrev.
	^ results asArray!

assert: aBoolean
	aBoolean ifFalse: [self fail]!

deny: aBoolean
	self assert: aBoolean not!

fail
	^ failureContinuation value: nil!

initialize
	failureContinuation := [:v | self error: 'Amb tree exhausted'].!

maybe
	^ self oneOf: { true. false }!

oneOf: aCollection
	^ self valueOfOneOf: (aCollection collect: [:ea | [ea] ])!

valueOf: blockOne or: blockTwo
	^ self valueOfOneOf: { blockOne. blockTwo }!

valueOf: blockOne or: blockTwo or: blockThree
	^ self valueOfOneOf: { blockOne. blockTwo. blockThree }!

valueOfOneOf: blockCollection
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
				kEntry value: ea value]].
		kPrev value: nil]
! !

TestCase subclass: #AmbTest
    instanceVariableNames: 'amb '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside-Seaside-Continuations'!

!AmbTest methodsFor: 'as yet unclassified'!

pickANumber
    ^ self pickANumberGreaterThan: 0!

pickANumberGreaterThan: aNumber
    ^ amb valueOf: [aNumber + 1] or: [self pickANumberGreaterThan: aNumber + 1]!

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
! !

