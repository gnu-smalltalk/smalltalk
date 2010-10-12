"======================================================================
|
|   Numerical methods - Basic objects and concepts
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbIterativeProcess [
    | precision desiredPrecision maximumIterations result iterations |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIterativeProcess class >> new [
	"Create an instance of the class.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbIterativeProcess class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^50
    ]

    DhbIterativeProcess class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    hasConverged [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	^precision <= desiredPrecision
    ]

    iterations [
	"Answers the number of iterations performed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^iterations
    ]

    limitedSmallValue: aNumber [
	"Private - prevent aNumber from being smaller in absolute value than a small number.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	^aNumber abs < DhbFloatingPointMachine new smallNumber 
	    ifTrue: [DhbFloatingPointMachine new smallNumber]
	    ifFalse: [aNumber]
    ]

    precision [
	"Answer the attained precision for the result.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'information'>
	^precision
    ]

    precisionOf: aNumber1 relativeTo: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/5/99"

	<category: 'information'>
	^aNumber2 > DhbFloatingPointMachine new defaultNumericalPrecision 
	    ifTrue: [aNumber1 / aNumber2]
	    ifFalse: [aNumber1]
    ]

    result [
	"Answer the result of the iterations (if any)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^result
    ]

    desiredPrecision: aNumber [
	"Defines the desired precision for the result.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	aNumber > 0 
	    ifFalse: [^self error: 'Illegal precision: ' , aNumber printString].
	desiredPrecision := aNumber
    ]

    initialize [
	"Private - initialize the parameters of the receiver with default values.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	desiredPrecision := self class defaultPrecision.
	maximumIterations := self class defaultMaximumIterations.
	^self
    ]

    maximumIterations: anInteger [
	"Defines the maximum number of iterations.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	(anInteger isInteger and: [anInteger > 1]) 
	    ifFalse: 
		[^self 
		    error: 'Invalid maximum number of iteration: ' , anInteger printString].
	maximumIterations := anInteger
    ]

    evaluate [
	"Perform the iteration until either the desired precision is attained or the number of iterations exceeds the maximum.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	iterations := 0.
	self initializeIterations.
	
	[iterations := iterations + 1.
	precision := self evaluateIteration.
	self hasConverged or: [iterations >= maximumIterations]] 
		whileFalse: [].
	self finalizeIterations.
	^self result
    ]

    evaluateIteration [
	"Dummy method (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    finalizeIterations [
	"Perform cleanup operation if needed (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	
    ]

    initializeIterations [
	"Initialize the iterations (must be implemented by subclass when needed).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	
    ]
]



DhbIterativeProcess subclass: DhbFunctionalIterator [
    | functionBlock relativePrecision |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFunctionalIterator class >> function: aBlock [
	"Convenience method to create a instance with given function block.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^(self new)
	    setFunction: aBlock;
	    yourself
    ]

    relativePrecision: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/4/99"

	<category: 'information'>
	^self precisionOf: aNumber relativeTo: result abs
    ]

    setFunction: aBlock [
	"Defines the function for which zeroes will be found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	(aBlock respondsTo: #value:) 
	    ifFalse: [self error: 'Function block must implement the method value:'].
	functionBlock := aBlock
    ]

    computeInitialValues [
	<category: 'operation'>
	self subclassResponsibility
    ]

    initializeIterations [
	"If no initial value has been defined, take 0 as the starting point (for lack of anything better).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	functionBlock isNil ifTrue: [self error: 'No function supplied'].
	self computeInitialValues
    ]
]



Object subclass: DhbPolynomial [
    | coefficients |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbPolynomial class >> coefficients: anArray [
	"Creates a new instance with given coefficients
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	^self new initialize: anArray reverse
    ]

    = aNumberOrPolynomial [
	<category: 'comparing'>
	aNumberOrPolynomial isNil ifTrue: [^false].
	aNumberOrPolynomial isNumber 
	    ifTrue: 
		[^coefficients size = 1 and: [coefficients first = aNumberOrPolynomial]].
	aNumberOrPolynomial class = self class ifFalse: [^false].
	^self coefficients = aNumberOrPolynomial coefficients
    ]

    hash [
	<category: 'comparing'>
	^coefficients hash
    ]

    deflatedAt: aNumber [
	"Answers a new polynomial quotient of the receiver with polynomial (X-aNumber)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'creation'>
	| remainder next newCoefficients |
	remainder := 0.
	newCoefficients := coefficients collect: 
			[:each | 
			next := remainder.
			remainder := remainder * aNumber + each.
			next].
	^self class 
	    coefficients: (newCoefficients copyFrom: 2 to: newCoefficients size) 
		    reverse
    ]

    derivative [
	"Answer a new polynomial, derivative of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	| n |
	n := coefficients size.
	^self class 
	    coefficients: ((coefficients collect: 
			[:each | 
			n := n - 1.
			each * n]) 
		    reverse copyFrom: 2 to: coefficients size)
    ]

    integral [
	"Answer a new polynomial, integral of the receiver with value 0 at x=0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	^self integral: 0
    ]

    integral: aValue [
	"Answer a new polynomial, integral of the receiver with given value at x=0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	| n |
	n := coefficients size + 1.
	^self class 
	    coefficients: ((coefficients collect: 
			[:each | 
			n := n - 1.
			each / n]) 
		    copyWith: aValue) reverse
    ]

    printOn: aStream [
	"Append to aStream a written representation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'display'>
	| n firstNonZeroCoefficientPrinted |
	n := 0.
	firstNonZeroCoefficientPrinted := false.
	coefficients reverseDo: 
		[:each | 
		each = 0 
		    ifFalse: 
			[firstNonZeroCoefficientPrinted 
			    ifTrue: 
				[aStream space.
				each < 0 ifFalse: [aStream nextPut: $+].
				aStream space]
			    ifFalse: [firstNonZeroCoefficientPrinted := true].
			(each = 1 and: [n > 0]) ifFalse: [each printOn: aStream].
			n > 0 
			    ifTrue: 
				[aStream nextPutAll: ' X'.
				n > 1 
				    ifTrue: 
					[aStream nextPut: $^.
					n printOn: aStream]]].
		n := n + 1]
    ]

    addNumber: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	| newCoefficients |
	newCoefficients := coefficients reverse.
	newCoefficients at: 1 put: newCoefficients first + aNumber.
	^self class coefficients: newCoefficients
    ]

    addPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		    collect: [:n | (aPolynomial at: n) + (self at: n)])
    ]

    differenceFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self subtractFrom: aFloatD
    ]

    dividingPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	^(self dividingPolynomialWithRemainder: aPolynomial) first
    ]

    dividingPolynomialWithRemainder: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	| remainderCoefficients quotientCoefficients n m norm quotientDegree |
	n := self degree.
	m := aPolynomial degree.
	quotientDegree := m - n.
	quotientDegree < 0 
	    ifTrue: [^Array with: (self class new: #(0)) with: aPolynomial].
	quotientCoefficients := Array new: quotientDegree + 1.
	remainderCoefficients := (0 to: m) collect: [:k | aPolynomial at: k].
	norm := 1 / coefficients first.
	quotientDegree to: 0
	    by: -1
	    do: 
		[:k | 
		| x |
		x := (remainderCoefficients at: n + k + 1) * norm.
		quotientCoefficients at: quotientDegree + 1 - k put: x.
		n + k - 1 to: k
		    by: -1
		    do: 
			[:j | 
			remainderCoefficients at: j + 1
			    put: (remainderCoefficients at: j + 1) - (x * (self at: j - k))]].
	^Array with: (self class coefficients: quotientCoefficients reverse)
	    with: (self class coefficients: (remainderCoefficients copyFrom: 1 to: n))
    ]

    productFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self * aFloatD
    ]

    subtractFrom: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	| newCoefficients |
	newCoefficients := (coefficients collect: [:c | c negated]) reverse.
	newCoefficients at: 1 put: newCoefficients first + aNumber.
	^self class coefficients: newCoefficients
    ]

    subtractToPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		    collect: [:n | (aPolynomial at: n) - (self at: n)])
    ]

    sumFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self + aFloatD
    ]

    timesNumber: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	^self class 
	    coefficients: (coefficients collect: [:each | each * aNumber]) reverse
    ]

    timesPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	| productCoefficients degree |
	degree := aPolynomial degree + self degree.
	productCoefficients := (degree to: 0 by: -1) collect: 
			[:n | 
			| sum |
			sum := 0.
			0 to: degree - n
			    do: [:k | sum := (self at: k) * (aPolynomial at: degree - n - k) + sum].
			sum].
	^self class coefficients: productCoefficients
    ]

    at: anInteger [
	"Answers the coefficient of order anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'information'>
	^anInteger < coefficients size 
	    ifTrue: [coefficients at: coefficients size - anInteger]
	    ifFalse: [0]
    ]

    coefficients [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^coefficients reverse
    ]

    degree [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'information'>
	^coefficients size - 1
    ]

    roots [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	^self roots: DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    roots: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	| pol roots x rootFinder |
	rootFinder := DhbNewtonZeroFinder new.
	rootFinder desiredPrecision: aNumber.
	pol := self class 
		    coefficients: (coefficients reverse collect: [:each | each asFloatD]).
	roots := OrderedCollection new: self degree.
	
	[rootFinder
	    setFunction: pol;
	    setDerivative: pol derivative.
	x := rootFinder evaluate.
	rootFinder hasConverged] 
		whileTrue: 
		    [roots add: x.
		    pol := pol deflatedAt: x.
		    pol degree > 0 ifFalse: [^roots]].
	^roots
    ]

    value: aNumber [
	"Answer the value of the polynomial for the specified variable value.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'information'>
	^coefficients inject: 0 into: [:sum :each | sum * aNumber + each]
    ]

    initialize: anArray [
	"Private - Initialize the coefficients of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'initialization'>
	coefficients := anArray.
	^self
    ]

    generality [
	<category: 'numerics'>
	^nil
    ]

    * aNumberOrPolynomial [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial timesPolynomial: self
    ]

    + aNumberOrPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial addPolynomial: self
    ]

    - aNumberOrPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial subtractToPolynomial: self
    ]

    / aNumberOrPolynomial [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial dividingPolynomial: self
    ]
]



Object subclass: DhbDecimalFloatingNumber [
    | mantissa exponent |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    Digits := nil.

    DhbDecimalFloatingNumber class >> new: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'creation'>
	^self new normalize: aNumber
    ]

    DhbDecimalFloatingNumber class >> defaultDigits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	^15
    ]

    DhbDecimalFloatingNumber class >> digits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	Digits isNil ifTrue: [Digits := self defaultDigits].
	^Digits
    ]

    DhbDecimalFloatingNumber class >> defaultDigits: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	Digits := anInteger
    ]

    DhbDecimalFloatingNumber class >> resetDigits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	Digits := nil
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'display'>
	mantissa printOn: aStream.
	aStream nextPutAll: 'xE'.
	exponent negated printOn: aStream
    ]

    value [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	^mantissa / (10 raisedToInteger: exponent)
    ]

    * aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value * aNumber value
    ]

    + aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value + aNumber value
    ]

    - aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value - aNumber value
    ]

    / aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value / aNumber value
    ]

    sqrt [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value sqrt
    ]

    normalize: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	exponent := (self class digits - (aNumber log: 10)) floor.
	mantissa := (aNumber * (10 raisedToInteger: exponent)) rounded.
	^self
    ]
]



DhbPolynomial subclass: DhbEstimatedPolynomial [
    | errorMatrix |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    error: aNumber [
	"Compute the error on the value of the receiver for argument aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| errorVector term nextTerm |
	nextTerm := 1.
	errorVector := (coefficients collect: 
			[:each | 
			term := nextTerm.
			nextTerm := aNumber * nextTerm.
			term]) 
		    asVector.
	^(errorVector * errorMatrix * errorVector) sqrt
    ]

    errorMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^errorMatrix
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/5/99"

	<category: 'information'>
	^Array with: (self value: aNumber) with: (self error: aNumber)
    ]

    errorMatrix: aMatrix [
	"Defines the error matrix of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	errorMatrix := aMatrix
    ]
]



Object subclass: DhbFloatingPointMachine [
    | defaultNumericalPrecision radix machinePrecision negativeMachinePrecision smallestNumber largestNumber smallNumber largestExponentArgument |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbFloatingPointMachine class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'creation'>
	UniqueInstance = nil ifTrue: [UniqueInstance := super new].
	^UniqueInstance
    ]

    DhbFloatingPointMachine class >> reset [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'creation'>
	UniqueInstance := nil
    ]

    showParameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/6/99"

	<category: 'display'>
	Transcript
	    cr;
	    cr;
	    nextPutAll: 'Floating-point machine parameters';
	    cr;
	    nextPutAll: '---------------------------------';
	    cr;
	    nextPutAll: 'Radix: '.
	self radix printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Machine precision: '.
	self machinePrecision printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Negative machine precision: '.
	self negativeMachinePrecision printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Smallest number: '.
	self smallestNumber printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Largest number: '.
	self largestNumber printOn: Transcript
    ]

    computeLargestNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/6/99"

	<category: 'information'>
	| one floatingRadix fullMantissaNumber |
	one := 1.0.
	floatingRadix := self radix asFloatD.
	fullMantissaNumber := one 
		    - (floatingRadix * self negativeMachinePrecision).
	largestNumber := fullMantissaNumber.
	
	[
	[fullMantissaNumber := fullMantissaNumber * floatingRadix.
	fullMantissaNumber isFinite ifFalse: [Error signal].
	largestNumber := fullMantissaNumber.
	true] 
		whileTrue: []] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    computeMachinePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero inverseRadix tmp |
	one := 1.0.
	zero := 0.0.
	inverseRadix := one / self radix asFloatD.
	machinePrecision := one.
	
	[tmp := one + machinePrecision.
	tmp - one = zero] 
		whileFalse: [machinePrecision := machinePrecision * inverseRadix]
    ]

    computeNegativeMachinePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero floatingRadix inverseRadix tmp |
	one := 1.0.
	zero := 0.0.
	floatingRadix := self radix asFloatD.
	inverseRadix := one / floatingRadix.
	negativeMachinePrecision := one.
	
	[tmp := one - negativeMachinePrecision.
	tmp - one = zero] whileFalse: 
		    [negativeMachinePrecision := negativeMachinePrecision * inverseRadix]
    ]

    computeRadix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero a b tmp1 tmp2 |
	one := 1.0.
	zero := 0.0.
	a := one.
	
	[a := a + a.
	tmp1 := a + one.
	tmp2 := tmp1 - a.
	tmp2 - one = zero] 
		whileTrue: [].
	b := one.
	
	[b := b + b.
	tmp1 := a + b.
	radix := (tmp1 - a) truncated.
	radix = 0] 
		whileTrue: []
    ]

    computeSmallestNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/6/99"

	<category: 'information'>
	| one floatingRadix inverseRadix fullMantissaNumber |
	one := 1 asFloatD.
	floatingRadix := self radix asFloatD.
	inverseRadix := one / floatingRadix.
	fullMantissaNumber := one 
		    - (floatingRadix * self negativeMachinePrecision).
	smallestNumber := fullMantissaNumber.
	
	[
	[fullMantissaNumber := fullMantissaNumber * inverseRadix.
	fullMantissaNumber = 0.0 ifTrue: [Error signal].
	fullMantissaNumber isFinite ifFalse: [Error signal].
	smallestNumber := fullMantissaNumber.
	true] 
		whileTrue: []] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    defaultNumericalPrecision [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	defaultNumericalPrecision isNil 
	    ifTrue: [defaultNumericalPrecision := self machinePrecision sqrt].
	^defaultNumericalPrecision
    ]

    largestExponentArgument [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'information'>
	largestExponentArgument isNil 
	    ifTrue: [largestExponentArgument := self largestNumber ln].
	^largestExponentArgument
    ]

    largestNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	largestNumber isNil ifTrue: [self computeLargestNumber].
	^largestNumber
    ]

    machinePrecision [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	machinePrecision isNil ifTrue: [self computeMachinePrecision].
	^machinePrecision
    ]

    negativeMachinePrecision [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	negativeMachinePrecision isNil 
	    ifTrue: [self computeNegativeMachinePrecision].
	^negativeMachinePrecision
    ]

    radix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	radix isNil ifTrue: [self computeRadix].
	^radix
    ]

    smallestNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	smallestNumber isNil ifTrue: [self computeSmallestNumber].
	^smallestNumber
    ]

    smallNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	smallNumber isNil ifTrue: [smallNumber := self smallestNumber sqrt].
	^smallNumber
    ]
]



Array subclass: DhbVector [
    
    <shape: #pointer>
    <category: 'DHB Numerical'>
    <comment: nil>

    normalized [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30-Dec-99"

	<category: 'creation'>
	^1 / self norm * self
    ]

    asVector [
	"Answer self since the receiver is a vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self
    ]

    dimension [
	"Answer the dimension of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self size
    ]

    norm [
	"Answer the norm of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^(self * self) sqrt
    ]

    scalarProduct: aVector [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/5/99"

	<category: 'information'>
	| product n |
	n := 0.
	product := self collect: 
			[:each | 
			n := n + 1.
			(aVector at: n) * each].
	n := product size.
	[n > 1] whileTrue: 
		[| i j |
		i := 1.
		j := n.
		[i < j] whileTrue: 
			[product at: i put: (product at: i) + (product at: j).
			j := j - 1.
			i := i + 1].
		n := i min: j].
	^product at: 1
    ]

    generality [
	<category: 'numerics'>
	^nil
    ]

    * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument.
	 The argument can be a number, matrix or vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aNumberOrMatrixOrVector productWithVector: self
    ]

    + aVector [
	"Answers the sum of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector
	    do: 
		[:a :b | 
		n := n + 1.
		answer at: n put: a + b].
	^answer
    ]

    - aVector [
	"Answers the difference of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector
	    do: 
		[:a :b | 
		n := n + 1.
		answer at: n put: a - b].
	^answer
    ]

    productFromNumber: aFloatD [
	<category: 'operation'>
	^self * aFloatD
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix rowsCollect: [:each | each * self]
    ]

    productWithVector: aVector [
	"Answers the scalar product of aVector with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| n |
	n := 0.
	^self inject: 0
	    into: 
		[:sum :each | 
		n := n + 1.
		(aVector at: n) * each + sum]
    ]

    tensorProduct: aVector [
	"Answers the tensor product of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	self dimension = aVector dimension 
	    ifFalse: [^self error: 'Vector dimensions mismatch to build tensor product'].
	^DhbSymmetricMatrix 
	    rows: (self collect: [:a | aVector collect: [:b | a * b]])
    ]

    accumulate: aVectorOrAnArray [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size
	    do: [:n | self at: n put: (self at: n) + (aVectorOrAnArray at: n)]
    ]

    accumulateNegated: aVectorOrAnArray [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size
	    do: [:n | self at: n put: (self at: n) - (aVectorOrAnArray at: n)]
    ]

    negate [
	"Inverse the sign of all components of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	1 to: self size do: [:n | self at: n put: (self at: n) negated]
    ]

    scaleBy: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size do: [:n | self at: n put: (self at: n) * aNumber]
    ]
]

