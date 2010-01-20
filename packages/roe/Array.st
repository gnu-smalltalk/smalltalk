"=====================================================================
|
|   ROE bridge to standard collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RAConcreteRelation subclass: RAArrayRelation [
    | tuples |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>

    RAArrayRelation class >> name: aString attributes: anArray [
	^self basicNew initializeWithName: aString attributes: anArray
    ]

    addValues: anArray [
	<category: 'adding'>
	tuples add: (anArray collect: [:ea | Array with: ea])
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	(RAEvaluator evaluate: aRelation) do: 
		[:array | 
		aBlock value: (RASimpleTuple relation: aRelation
			    values: (array collect: [:ea | ea first]))]
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	(RAEvaluator evaluate: aRelation) 
	    do: [:ea | aBlock value: (RABoxedTuple relation: aRelation values: ea)]
    ]

    initializeWithName: aString [
	<category: 'initializing'>
	self initializeWithName: aString attributes: #()
    ]

    initializeWithName: aString attributes: anArray [
	<category: 'initializing'>
	super initializeWithName: aString.
	attributes := anArray 
		    collect: [:ea | RASimpleAttribute named: ea relation: self].
	tuples := OrderedCollection new
    ]

    tuples [
	<category: 'accessing'>
	^tuples
    ]

    update: aBlock [
	<category: 'updating'>
	tuples do: [:ea | aBlock value: (RABoxedTuple relation: self values: ea)]
    ]
]



RAVisitor subclass: RAEvaluator [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    RAEvaluator class >> evaluate: aRelation [
	^self new visit: aRelation
    ]

    visitCartesianProduct: aRelation [
	| right left |
	right := self visit: aRelation right.
	left := self visit: aRelation left.
	^Array 
	    streamContents: [:s | left do: [:l | right do: [:r | s nextPut: l , r]]]
    ]

    visitClone: aClone [
	^self visitTransformation: aClone
    ]

    visitDifference: aRelation [
	| right |
	right := self visit: aRelation right.
	^Array streamContents: 
		[:stream | 
		(self visit: aRelation left) 
		    do: [:row | (right includes: row) ifFalse: [stream nextPut: row]]]
    ]

    visitDistinct: aRelation [
	^(self visit: aRelation source) asSet asArray
    ]

    visitIntersection: aRelation [
	^(self visit: aRelation left) intersection: (self visit: aRelation right)
    ]

    visitInterval: aRelation [
	^(self visitTransformation: aRelation) copyFrom: aRelation start
	    to: aRelation stop
    ]

    visitOrder: aRelation [
	| result ascending order pos block |
	result := self visitTransformation: aRelation.
	aRelation order size to: 1
	    by: -1
	    do: 
		[:index | 
		ascending := aRelation ascending at: index.
		order := aRelation order at: index.
		pos := aRelation attributes indexOf: order.
		block := 
			[:x :y | 
			ascending 
			    ifTrue: [(x at: pos) first < (y at: pos) first]
			    ifFalse: [(x at: pos) first > (y at: pos) first]].
		result := result sort: block].
	^result
    ]

    visitProjection: aRelation [
	| projectedAttributes sourceAttributes |
	projectedAttributes := aRelation attributes.
	sourceAttributes := aRelation source attributes.
	^(self visitTransformation: aRelation) collect: 
		[:tuple | 
		Array streamContents: 
			[:s | 
			tuple with: sourceAttributes
			    do: [:val :attr | (projectedAttributes includes: attr) ifTrue: [s nextPut: val]]]]
    ]

    visitRelation: aRelation [
	^aRelation tuples
    ]

    visitSelection: aRelation [
	| arrays tuples |
	arrays := self visitTransformation: aRelation.
	tuples := arrays 
		    collect: [:ea | RABoxedTuple relation: aRelation values: ea].
	tuples := tuples select: [:ea | aRelation evaluateTuple: ea].
	^tuples collect: [:ea | ea values]
    ]

    visitUnion: aRelation [
	^(self visit: aRelation left) , (self visit: aRelation right)
    ]
]



RASimpleTuple subclass: RABoxedTuple [
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    isMutable [
	^relation isMutable
    ]

    takeValue: anObject forAttribute: anAttribute [
	(values at: (relation attributes indexOf: anAttribute)) at: 1 put: anObject
    ]

    valueForAttribute: anAttribute [
	^(super valueForAttribute: anAttribute) first
    ]
]



