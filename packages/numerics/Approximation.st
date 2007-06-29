"======================================================================
|
|   Numerical methods - Interpolation and root finding
|
|
 ======================================================================"


"======================================================================
|
| Written by Didier Besset.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



DhbFunctionalIterator subclass:  #DhbNewtonZeroFinder
	instanceVariableNames: 'derivativeBlock '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbNewtonZeroFinder comment: 
nil!

Object subclass:  #DhbLagrangeInterpolator
	instanceVariableNames: 'pointCollection '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbLagrangeInterpolator comment: 
nil!

DhbFunctionalIterator subclass:  #DhbBisectionZeroFinder
	instanceVariableNames: 'positiveX negativeX '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbBisectionZeroFinder comment: 
nil!

DhbLagrangeInterpolator subclass:  #DhbNewtonInterpolator
	instanceVariableNames: 'coefficients '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbNewtonInterpolator comment: 
nil!

DhbNewtonInterpolator subclass:  #DhbSplineInterpolator
	instanceVariableNames: 'startPointDerivative endPointDerivative '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbSplineInterpolator comment: 
nil!

DhbLagrangeInterpolator subclass:  #DhbNevilleInterpolator
	instanceVariableNames: 'leftErrors rightErrors '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbNevilleInterpolator comment: 
nil!

DhbNevilleInterpolator subclass:  #DhbBulirschStoerInterpolator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbBulirschStoerInterpolator comment: 
nil!

!DhbNewtonZeroFinder class methodsFor: 'creation'!

function: aBlock1 derivative: aBlock2 
    "Convenience method to create a instance with given function block.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^(self new)
	setFunction: aBlock1;
	setDerivative: aBlock2;
	yourself! !

!DhbNewtonZeroFinder methodsFor: 'information'!

defaultDerivativeBlock
    "Private - Answers a block computing the function's derivative by approximation.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^
    [:x | 
    5000 
	* ((functionBlock value: x + 0.0001) - (functionBlock value: x - 0.0001))]! !

!DhbNewtonZeroFinder methodsFor: 'initialization'!

initialValue: aNumber 
    "Define the initial value for the iterations.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    result := aNumber!

setDerivative: aBlock 
    "Defines the derivative of the function for which zeroes will be found. 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 7/1/99"

    | x |
    (aBlock respondsTo: #value:) 
	ifFalse: [self error: 'Derivative block must implement the method value:'].
    x := result isNil ifTrue: [Number random] ifFalse: [result + Number random].
    ((aBlock value: x) 
	relativelyEqualsTo: (self defaultDerivativeBlock value: x)
	upTo: 0.0001) ifFalse: [self error: 'Supplied derivative is not correct'].
    derivativeBlock := aBlock!

setFunction: aBlock 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    super setFunction: aBlock.
    derivativeBlock := nil! !

!DhbNewtonZeroFinder methodsFor: 'operation'!

computeInitialValues
    "Private - If no derivative has been defined, take an ad-hoc definition.
		 If no initial value has been defined, take 0 as the starting point (for lack of anything better).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    | n |
    result isNil ifTrue: [result := 0].
    derivativeBlock isNil 
	ifTrue: [derivativeBlock := self defaultDerivativeBlock].
    n := 0.
    [(derivativeBlock value: result) equalsTo: 0] whileTrue: 
	    [n := n + 1.
	    n > maximumIterations 
		ifTrue: [self error: 'Function''s derivative seems to be zero everywhere'].
	    result := Number random + result]!

evaluateIteration
    "Compute one step of Newton's zero finding method. Answers the estimated precision.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    | delta |
    delta := (functionBlock value: result) / (derivativeBlock value: result).
    result := result - delta.
    ^self relativePrecision: delta abs! !





!DhbLagrangeInterpolator class methodsFor: 'creation'!

new
    "Create a new instance of the receiver without points. Points must be added with add:
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^super new initialize!

points: aCollectionOfPoints 
    "Create a new instance of the receiver with given points.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^self new initialize: aCollectionOfPoints! !

!DhbLagrangeInterpolator methodsFor: 'information'!

defaultSamplePoints
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/5/99 "

    ^OrderedCollection new!

size
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 3/12/00 "

    ^pointCollection size!

value: aNumber 
    "Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

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
    ^norm * answer!

xPointAt: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^(pointCollection at: anInteger) x!

yPointAt: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^(pointCollection at: anInteger) y! !

!DhbLagrangeInterpolator methodsFor: 'initialization'!

initialize
    "Private - Create an empty point collection for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^self initialize: self defaultSamplePoints!

initialize: aCollectionOfPoints 
    "Private - Defines the collection of points for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    pointCollection := aCollectionOfPoints.
    ^self! !

!DhbLagrangeInterpolator methodsFor: 'transformation'!

add: aPoint 
    "Add a point to the collection of points.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^pointCollection add: aPoint! !




!DhbBisectionZeroFinder methodsFor: 'initialization'!

setNegativeX: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    (functionBlock value: aNumber) < 0 
	ifFalse: 
	    [self error: 'Function is not negative at x = ' , aNumber printString].
    negativeX := aNumber!

setPositiveX: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    (functionBlock value: aNumber) > 0 
	ifFalse: 
	    [self error: 'Function is not positive at x = ' , aNumber printString].
    positiveX := aNumber! !

!DhbBisectionZeroFinder methodsFor: 'operation'!

computeInitialValues
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    positiveX isNil ifTrue: [self error: 'No positive value supplied'].
    negativeX isNil ifTrue: [self error: 'No negative value supplied']!

evaluateIteration
    "Perform one step of bisection.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    result := (positiveX + negativeX) * 0.5.
    (functionBlock value: result) > 0 
	ifTrue: [positiveX := result]
	ifFalse: [negativeX := result].
    ^self relativePrecision: (positiveX - negativeX) abs!

findNegativeXFrom: aNumber1 range: aNumber2 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    | n |
    n := 0.
    
    [negativeX := Number random * aNumber2 + aNumber1.
    (functionBlock value: negativeX) < 0] 
	    whileFalse: 
		[n := n + 0.1.
		n > maximumIterations 
		    ifTrue: [self error: 'Unable to find a negative function value']]!

findPositiveXFrom: aNumber1 range: aNumber2 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    | n |
    n := 0.
    
    [positiveX := Number random * aNumber2 + aNumber1.
    (functionBlock value: positiveX) > 0] 
	    whileFalse: 
		[n := n + 1.
		n > maximumIterations 
		    ifTrue: [self error: 'Unable to find a positive function value']]! !




!DhbNewtonInterpolator methodsFor: 'information'!

computeCoefficients
    "Private - Computes the coefficients for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

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
				/ ((self xPointAt: k) - (self xPointAt: kn))]]!

value: aNumber 
    "Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    | answer size |
    coefficients isNil ifTrue: [self computeCoefficients].
    size := coefficients size.
    answer := coefficients at: size.
    size - 1 to: 1
	by: -1
	do: [:n | answer := answer * (aNumber - (self xPointAt: n)) + (coefficients at: n)].
    ^answer! !

!DhbNewtonInterpolator methodsFor: 'transformation'!

add: aPoint 
    "Add a point to the collection of points.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    self resetCoefficients.
    ^super add: aPoint!

resetCoefficients
    "Private - Reset the coefficients of the receiver to force a new computation.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    coefficients := nil! !




!DhbSplineInterpolator methodsFor: 'information'!

defaultSamplePoints
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/5/99 "

    ^SortedCollection sortBlock: [:a :b | a x < b x]!

resetEndPointDerivatives
    "Set the end point derivatives to undefined.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

    self setEndPointDerivatives: (Array new: 2)!

setEndPointDerivatives: anArray 
    "Defines the end point derivatives.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

    startPointDerivative := anArray at: 1.
    endPointDerivative := anArray at: 2.
    self resetCoefficients!

startPointDerivative: aNumber 
    "Defines the end point derivatives.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

    startPointDerivative := aNumber.
    self resetCoefficients!

value: aNumber 
    "Computes the value of a cubic spline interpolation over the points of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

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
		/ 6)! !

!DhbSplineInterpolator methodsFor: 'initialization'!

endPointDerivative: aNumber 
    "Defines the end point derivatives.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

    endPointDerivative := aNumber.
    self resetCoefficients! !

!DhbSplineInterpolator methodsFor: 'transformation'!

computeSecondDerivatives
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

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
		put: (coefficients at: n) * (coefficients at: n + 1) + (u at: n)]! !




!DhbNevilleInterpolator methodsFor: 'information'!

computeDifference: aNumber at: anInteger1 order: anInteger2 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 28/5/99 "

    | leftDist rightDist ratio |
    leftDist := (self xPointAt: anInteger1) - aNumber.
    rightDist := (self xPointAt: anInteger1 + anInteger2) - aNumber.
    ratio := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		/ (leftDist - rightDist).
    leftErrors at: anInteger1 put: ratio * leftDist.
    rightErrors at: anInteger1 put: ratio * rightDist!

defaultSamplePoints
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/5/99 "

    ^SortedCollection sortBlock: [:a :b | a x < b x]!

initializeDifferences: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 28/5/99 "

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
    ^nearestIndex!

value: aNumber 
    "Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

    ^(self valueAndError: aNumber) first!

valueAndError: aNumber 
    "Compute and return the interpolated value of the interpolation Lagranage polynomial
		 and its estimated error.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/4/99 "

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
    ^Array with: answer with: error abs! !




!DhbBulirschStoerInterpolator methodsFor: 'information'!

computeDifference: aNumber at: anInteger1 order: anInteger2 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 28/5/99 "

    | diff ratio |
    ratio := ((self xPointAt: anInteger1) - aNumber) 
		* (rightErrors at: anInteger1) 
		    / ((self xPointAt: anInteger1 + anInteger2) - aNumber).
    diff := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		/ (ratio - (leftErrors at: anInteger1 + 1)).
    rightErrors at: anInteger1 put: (leftErrors at: anInteger1 + 1) * diff.
    leftErrors at: anInteger1 put: ratio * diff! !




