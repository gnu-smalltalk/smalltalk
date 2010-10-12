"======================================================================
|
|   Numerical methods - Interpolation and root finding
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



DhbFunctionalIterator subclass: DhbNewtonZeroFinder [
    | derivativeBlock |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbNewtonZeroFinder class >> function: aBlock1 derivative: aBlock2 [
	"Convenience method to create a instance with given function block.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^(self new)
	    setFunction: aBlock1;
	    setDerivative: aBlock2;
	    yourself
    ]

    defaultDerivativeBlock [
	"Private - Answers a block computing the function's derivative by approximation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'information'>
	^
	[:x | 
	5000 
	    * ((functionBlock value: x + 0.0001) - (functionBlock value: x - 0.0001))]
    ]

    initialValue: aNumber [
	"Define the initial value for the iterations.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	result := aNumber
    ]

    setDerivative: aBlock [
	"Defines the derivative of the function for which zeroes will be found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	| x |
	(aBlock respondsTo: #value:) 
	    ifFalse: [self error: 'Derivative block must implement the method value:'].
	x := result isNil ifTrue: [Number random] ifFalse: [result + Number random].
	((aBlock value: x) 
	    relativelyEqualsTo: (self defaultDerivativeBlock value: x)
	    upTo: 0.0001) ifFalse: [self error: 'Supplied derivative is not correct'].
	derivativeBlock := aBlock
    ]

    setFunction: aBlock [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	super setFunction: aBlock.
	derivativeBlock := nil
    ]

    computeInitialValues [
	"Private - If no derivative has been defined, take an ad-hoc definition.
	 If no initial value has been defined, take 0 as the starting point (for lack of anything better).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| n |
	result isNil ifTrue: [result := 0].
	derivativeBlock isNil 
	    ifTrue: [derivativeBlock := self defaultDerivativeBlock].
	n := 0.
	[(derivativeBlock value: result) equalsTo: 0] whileTrue: 
		[n := n + 1.
		n > maximumIterations 
		    ifTrue: [self error: 'Function''s derivative seems to be zero everywhere'].
		result := Number random + result]
    ]

    evaluateIteration [
	"Compute one step of Newton's zero finding method. Answers the estimated precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| delta |
	delta := (functionBlock value: result) / (derivativeBlock value: result).
	result := result - delta.
	^self relativePrecision: delta abs
    ]
]



Object subclass: DhbLagrangeInterpolator [
    | pointCollection |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLagrangeInterpolator class >> new [
	"Create a new instance of the receiver without points. Points must be added with add:
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbLagrangeInterpolator class >> points: aCollectionOfPoints [
	"Create a new instance of the receiver with given points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: aCollectionOfPoints
    ]

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^OrderedCollection new
    ]

    size [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 3/12/00"

	<category: 'information'>
	^pointCollection size
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| norm dx products answer size |
	norm := 1.
	size := pointCollection size.
	products := Array new: size.
	products atAllPut: 1.
	1 to: size
	    do: 
		[:n | 
		dx := aNumber - (self xPointAt: n).
		dx = 0 ifTrue: [^self yPointAt: n].
		norm := norm * dx.
		1 to: size
		    do: 
			[:m | 
			m = n 
			    ifFalse: 
				[products at: m
				    put: ((self xPointAt: m) - (self xPointAt: n)) * (products at: m)]]].
	answer := 0.
	1 to: size
	    do: 
		[:n | 
		answer := (self yPointAt: n) 
			    / ((products at: n) * (aNumber - (self xPointAt: n))) + answer].
	^norm * answer
    ]

    xPointAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'information'>
	^(pointCollection at: anInteger) x
    ]

    yPointAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'information'>
	^(pointCollection at: anInteger) y
    ]

    initialize [
	"Private - Create an empty point collection for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	^self initialize: self defaultSamplePoints
    ]

    initialize: aCollectionOfPoints [
	"Private - Defines the collection of points for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	pointCollection := aCollectionOfPoints.
	^self
    ]

    add: aPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	^pointCollection add: aPoint
    ]
]



DhbFunctionalIterator subclass: DhbBisectionZeroFinder [
    | positiveX negativeX |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    setNegativeX: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'initialization'>
	(functionBlock value: aNumber) < 0 
	    ifFalse: 
		[self error: 'Function is not negative at x = ' , aNumber printString].
	negativeX := aNumber
    ]

    setPositiveX: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'initialization'>
	(functionBlock value: aNumber) > 0 
	    ifFalse: 
		[self error: 'Function is not positive at x = ' , aNumber printString].
	positiveX := aNumber
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	positiveX isNil ifTrue: [self error: 'No positive value supplied'].
	negativeX isNil ifTrue: [self error: 'No negative value supplied']
    ]

    evaluateIteration [
	"Perform one step of bisection.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	result := (positiveX + negativeX) * 0.5.
	(functionBlock value: result) > 0 
	    ifTrue: [positiveX := result]
	    ifFalse: [negativeX := result].
	^self relativePrecision: (positiveX - negativeX) abs
    ]

    findNegativeXFrom: aNumber1 range: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	| n |
	n := 0.
	
	[negativeX := Number random * aNumber2 + aNumber1.
	(functionBlock value: negativeX) < 0] 
		whileFalse: 
		    [n := n + 0.1.
		    n > maximumIterations 
			ifTrue: [self error: 'Unable to find a negative function value']]
    ]

    findPositiveXFrom: aNumber1 range: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	| n |
	n := 0.
	
	[positiveX := Number random * aNumber2 + aNumber1.
	(functionBlock value: positiveX) > 0] 
		whileFalse: 
		    [n := n + 1.
		    n > maximumIterations 
			ifTrue: [self error: 'Unable to find a positive function value']]
    ]
]



DhbLagrangeInterpolator subclass: DhbNewtonInterpolator [
    | coefficients |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeCoefficients [
	"Private - Computes the coefficients for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| size k1 kn |
	size := pointCollection size.
	coefficients := (1 to: size) collect: [:n | self yPointAt: n].
	1 to: size - 1
	    do: 
		[:n | 
		size to: n + 1
		    by: -1
		    do: 
			[:k | 
			k1 := k - 1.
			kn := k - n.
			coefficients at: k
			    put: ((coefficients at: k) - (coefficients at: k1)) 
				    / ((self xPointAt: k) - (self xPointAt: kn))]]
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| answer size |
	coefficients isNil ifTrue: [self computeCoefficients].
	size := coefficients size.
	answer := coefficients at: size.
	size - 1 to: 1
	    by: -1
	    do: [:n | answer := answer * (aNumber - (self xPointAt: n)) + (coefficients at: n)].
	^answer
    ]

    add: aPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	self resetCoefficients.
	^super add: aPoint
    ]

    resetCoefficients [
	"Private - Reset the coefficients of the receiver to force a new computation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	coefficients := nil
    ]
]



DhbNewtonInterpolator subclass: DhbSplineInterpolator [
    | startPointDerivative endPointDerivative |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^SortedCollection sortBlock: [:a :b | a x < b x]
    ]

    resetEndPointDerivatives [
	"Set the end point derivatives to undefined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	self setEndPointDerivatives: (Array new: 2)
    ]

    setEndPointDerivatives: anArray [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	startPointDerivative := anArray at: 1.
	endPointDerivative := anArray at: 2.
	self resetCoefficients
    ]

    startPointDerivative: aNumber [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	startPointDerivative := aNumber.
	self resetCoefficients
    ]

    value: aNumber [
	"Computes the value of a cubic spline interpolation over the points of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	| n1 n2 n step a b |
	coefficients isNil ifTrue: [self computeSecondDerivatives].
	n2 := pointCollection size.
	n1 := 1.
	[n2 - n1 > 1] whileTrue: 
		[n := (n1 + n2) // 2.
		(self xPointAt: n) > aNumber ifTrue: [n2 := n] ifFalse: [n1 := n]].
	step := (self xPointAt: n2) - (self xPointAt: n1).
	a := ((self xPointAt: n2) - aNumber) / step.
	b := (aNumber - (self xPointAt: n1)) / step.
	^a * (self yPointAt: n1) + (b * (self yPointAt: n2)) 
	    + ((a * (a squared - 1) * (coefficients at: n1) 
		    + (b * (b squared - 1) * (coefficients at: n2))) * step squared 
		    / 6)
    ]

    endPointDerivative: aNumber [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'initialization'>
	endPointDerivative := aNumber.
	self resetCoefficients
    ]

    computeSecondDerivatives [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'transformation'>
	| size u w s dx inv2dx |
	size := pointCollection size.
	coefficients := Array new: size.
	u := Array new: size - 1.
	startPointDerivative isNil 
	    ifTrue: 
		[coefficients at: 1 put: 0.
		u at: 1 put: 0]
	    ifFalse: 
		[coefficients at: 1 put: -1 / 2.
		s := 1 / ((self xPointAt: 2) x - (self xPointAt: 1) x).
		u at: 1
		    put: 3 * s * (s * ((self yPointAt: size) - (self yPointAt: size - 1)) 
				    - startPointDerivative)].
	2 to: size - 1
	    do: 
		[:n | 
		dx := (self xPointAt: n) - (self xPointAt: n - 1).
		inv2dx := 1 / ((self xPointAt: n + 1) - (self xPointAt: n - 1)).
		s := dx * inv2dx.
		w := 1 / (s * (coefficients at: n - 1) + 2).
		coefficients at: n put: (s - 1) * w.
		u at: n
		    put: ((((self yPointAt: n + 1) - (self yPointAt: n)) 
			    / ((self xPointAt: n + 1) - (self xPointAt: n)) 
				- (((self yPointAt: n) - (self yPointAt: n - 1)) / dx)) * 6 
			    * inv2dx - ((u at: n - 1) * s)) 
			    * w].
	endPointDerivative isNil 
	    ifTrue: [coefficients at: size put: 0]
	    ifFalse: 
		[w := 1 / 2.
		s := 1 / ((self xPointAt: size) - (self xPointAt: size - 1)).
		u at: 1
		    put: 3 * s * (endPointDerivative 
				    - (s * (self yPointAt: size) - (self yPointAt: size - 1))).
		coefficients at: size
		    put: s - (w * (u at: size - 1) / ((coefficients at: size - 1) * w + 1))].
	size - 1 to: 1
	    by: -1
	    do: 
		[:n | 
		coefficients at: n
		    put: (coefficients at: n) * (coefficients at: n + 1) + (u at: n)]
    ]
]



DhbLagrangeInterpolator subclass: DhbNevilleInterpolator [
    | leftErrors rightErrors |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeDifference: aNumber at: anInteger1 order: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| leftDist rightDist ratio |
	leftDist := (self xPointAt: anInteger1) - aNumber.
	rightDist := (self xPointAt: anInteger1 + anInteger2) - aNumber.
	ratio := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		    / (leftDist - rightDist).
	leftErrors at: anInteger1 put: ratio * leftDist.
	rightErrors at: anInteger1 put: ratio * rightDist
    ]

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^SortedCollection sortBlock: [:a :b | a x < b x]
    ]

    initializeDifferences: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| size nearestIndex dist minDist |
	size := pointCollection size.
	leftErrors size = size 
	    ifFalse: 
		[leftErrors := Array new: size.
		rightErrors := Array new: size].
	minDist := ((self xPointAt: 1) - aNumber) abs.
	nearestIndex := 1.
	leftErrors at: 1 put: (self yPointAt: 1).
	rightErrors at: 1 put: leftErrors first.
	2 to: size
	    do: 
		[:n | 
		dist := ((self xPointAt: n) - aNumber) abs.
		dist < minDist 
		    ifTrue: 
			[dist = 0 ifTrue: [^n negated].
			nearestIndex := n.
			minDist := dist].
		leftErrors at: n put: (self yPointAt: n).
		rightErrors at: n put: (leftErrors at: n)].
	^nearestIndex
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	^(self valueAndError: aNumber) first
    ]

    valueAndError: aNumber [
	"Compute and return the interpolated value of the interpolation Lagranage polynomial
	 and its estimated error.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	| size nearestIndex answer error |
	nearestIndex := self initializeDifferences: aNumber.
	nearestIndex < 0 
	    ifTrue: [^Array with: (self yPointAt: nearestIndex negated) with: 0].
	answer := leftErrors at: nearestIndex.
	nearestIndex := nearestIndex - 1.
	size := pointCollection size.
	1 to: size - 1
	    do: 
		[:m | 
		1 to: size - m
		    do: 
			[:n | 
			self 
			    computeDifference: aNumber
			    at: n
			    order: m].
		size - m > (2 * nearestIndex) 
		    ifTrue: [error := leftErrors at: nearestIndex + 1]
		    ifFalse: 
			[error := rightErrors at: nearestIndex.
			nearestIndex := nearestIndex - 1].
		answer := answer + error].
	^Array with: answer with: error abs
    ]
]



DhbNevilleInterpolator subclass: DhbBulirschStoerInterpolator [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeDifference: aNumber at: anInteger1 order: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| diff ratio |
	ratio := ((self xPointAt: anInteger1) - aNumber) 
		    * (rightErrors at: anInteger1) 
			/ ((self xPointAt: anInteger1 + anInteger2) - aNumber).
	diff := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		    / (ratio - (leftErrors at: anInteger1 + 1)).
	rightErrors at: anInteger1 put: (leftErrors at: anInteger1 + 1) * diff.
	leftErrors at: anInteger1 put: ratio * diff
    ]
]

