"======================================================================
|
|   Lisp continuations for Smalltalk: the Amb evaluator
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2004-2009 Avi Bryant.
|
| Permission is hereby granted, free of charge, to any person obtaining a
| copy of this software and associated documentation files (the `Software'),
| to deal in the Software without restriction, including without limitation
| the rights to use, copy, modify, merge, publish, distribute, sublicense,
| and/or sell copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following conditions:
| 
| The above copyright notice and this permission notice shall be included
| in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS
| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
| FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
| THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
| OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
| ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
 ======================================================================"



Object subclass: Amb [
    | failureContinuation direction |
    
    <category: 'Seaside-Seaside-Continuations'>
    <comment: nil>

    Amb class >> new [
	<category: 'new'>
	^super new initialize
    ]

    Amb class >> allValues: aBlock [
	<category: 'new'>
	| amb |
	amb := self new.
	^amb allValues: [aBlock value: amb]
    ]

    withAllValues: aBlock do: serviceBlock [
	<category: 'superpositions'>
	| kPrev count |
	kPrev := failureContinuation.
	(Continuation currentDo: 
		[:kRetry | 
		failureContinuation := [:v | kRetry value: false].
		serviceBlock value: aBlock value.
		kRetry value: true]) 
	    ifTrue: [self fail].
	failureContinuation := kPrev
    ]

    always: aBlock [
	<category: 'superpositions'>
	direction := direction not.
	^[(self hasValue: aBlock) not] ensure: [direction := direction not]
    ]

    countValues: aBlock [
	<category: 'superpositions'>
	| count |
	count := ValueHolder with: 0.
	self withAllValues: aBlock do: [:x | count value: count value + 1].
	^count value
    ]

    allValues: aBlock [
	<category: 'superpositions'>
	| results |
	results := OrderedCollection new.
	self withAllValues: aBlock do: [:x | results add: x].
	^results asArray
    ]

    assert: aBoolean [
	<category: 'superpositions'>
	aBoolean == direction ifFalse: [self fail]
    ]

    deny: aBoolean [
	<category: 'superpositions'>
	self assert: aBoolean not
    ]

    fail [
	<category: 'superpositions'>
	^failureContinuation value: nil
    ]

    hasValue: aBlock [
	<category: 'superpositions'>
	| kPrev ok |
	kPrev := failureContinuation.
	ok := Continuation currentDo: 
			[:kRetry | 
			failureContinuation := [:v | kRetry value: false].
			aBlock value.
			kRetry value: true].
	failureContinuation := kPrev.
	^ok
    ]

    initialize [
	<category: 'superpositions'>
	failureContinuation := [:v | self error: 'Amb tree exhausted'].
	direction := true
    ]

    maybe [
	<category: 'superpositions'>
	^self oneOf: 
		{true.
		false}
    ]

    noneOf: aCollection satisfies: aBlock [
	<category: 'superpositions'>
	^(self oneOf: aCollection satisfies: aBlock) not
    ]

    allOf: aCollection satisfying: aBlock [
	<category: 'superpositions'>
	^self allValues: 
		[| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x).
		x]
    ]

    allOf: aCollection satisfy: aBlock [
	<category: 'superpositions'>
	^(self hasValue: 
		[| x |
		x := self oneOf: aCollection.
		self deny: (aBlock value: x)]) 
	    not
    ]

    oneOf: aCollection satisfies: aBlock [
	<category: 'superpositions'>
	^self hasValue: 
		[| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x)]
    ]

    oneOf: aCollection [
	<category: 'superpositions'>
	^self valueOfOneOf: aCollection through: [:ea | ea]
    ]

    valueOf: blockOne or: blockTwo [
	<category: 'superpositions'>
	^self valueOfOneOf: 
		{blockOne.
		blockTwo}
    ]

    valueOf: blockOne or: blockTwo or: blockThree [
	<category: 'superpositions'>
	^self valueOfOneOf: 
		{blockOne.
		blockTwo.
		blockThree}
    ]

    valueOfOneOf: blockCollection [
	<category: 'superpositions'>
	^self valueOfOneOf: blockCollection through: [:ea | ea value]
    ]

    valueOfOneOf: blockCollection through: aBlock [
	<category: 'superpositions'>
	| kPrev |
	kPrev := failureContinuation.
	^Continuation currentDo: 
		[:kEntry | 
		blockCollection do: 
			[:ea | 
			Continuation currentDo: 
				[:kNext | 
				failureContinuation := 
					[:v | 
					failureContinuation := kPrev.
					kNext value: v] fixTemps.
				kEntry value: (aBlock value: ea)]].
		kPrev value: nil]
    ]
]
