"======================================================================
|
|   Numerical methods - Integration
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


DhbFunctionalIterator subclass:  #DhbTrapezeIntegrator
	instanceVariableNames: 'from to sum step '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbTrapezeIntegrator comment: 
nil!

DhbTrapezeIntegrator subclass:  #DhbRombergIntegrator
	instanceVariableNames: 'order points interpolator '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbRombergIntegrator comment: 
nil!

DhbTrapezeIntegrator subclass:  #DhbSimpsonIntegrator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbSimpsonIntegrator comment: 
nil!

!DhbTrapezeIntegrator class methodsFor: 'creation'!

function: aBlock from: aNumber1 to: aNumber2 
    "Create an new instance with given parameters.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^super new 
	initialize: aBlock
	from: aNumber1
	to: aNumber2!

new
    "Private - Block the constructor method for this class.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^self error: 'Method new:from:to: must be used'! !

!DhbTrapezeIntegrator class methodsFor: 'information'!

defaultMaximumIterations
    "Private - Answers the default maximum number of iterations for newly created instances.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^13! !

!DhbTrapezeIntegrator methodsFor: 'initialization'!

from: aNumber1 to: aNumber2 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    from := aNumber1.
    to := aNumber2!

initialize: aBlock from: aNumber1 to: aNumber2 
    "Private - Initialize the parameters of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    functionBlock := aBlock.
    self from: aNumber1 to: aNumber2.
    ^self! !

!DhbTrapezeIntegrator methodsFor: 'operation'!

computeInitialValues
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    step := to - from.
    sum := ((functionBlock value: from) + (functionBlock value: to)) * step 
		/ 2.
    result := sum!

evaluateIteration
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    | oldResult |
    oldResult := result.
    result := self higherOrderSum.
    ^self relativePrecision: (result - oldResult) abs! !

!DhbTrapezeIntegrator methodsFor: 'transformation'!

higherOrderSum
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    | x newSum |
    x := step / 2 + from.
    newSum := 0.
    [x < to] whileTrue: 
	    [newSum := (functionBlock value: x) + newSum.
	    x := x + step].
    sum := (step * newSum + sum) / 2.
    step := step / 2.
    ^sum! !




!DhbRombergIntegrator class methodsFor: 'information'!

defaultOrder
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    ^5! !

!DhbRombergIntegrator methodsFor: 'initialization'!

initialize
    "Private - initialize the parameters of the receiver with default values.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    order := self class defaultOrder.
    ^super initialize!

order: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    anInteger < 2 
	ifTrue: [self error: 'Order for Romberg integration must be larger than 1'].
    order := anInteger! !

!DhbRombergIntegrator methodsFor: 'operation'!

computeInitialValues
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    super computeInitialValues.
    points := OrderedCollection new: order.
    interpolator := DhbNevilleInterpolator points: points.
    points add: 1 @ sum!

evaluateIteration
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 26/4/99 "

    | interpolation |
    points addLast: (points last x * 0.25) @ self higherOrderSum.
    points size < order ifTrue: [^1].
    interpolation := interpolator valueAndError: 0.
    points removeFirst.
    result := interpolation at: 1.
    ^self relativePrecision: (interpolation at: 2) abs! !




!DhbSimpsonIntegrator methodsFor: 'operation'!

evaluateIteration
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/4/99 "

    | oldResult oldSum |
    iterations < 2 
	ifTrue: 
	    [self higherOrderSum.
	    ^1].
    oldResult := result.
    oldSum := sum.
    result := (self higherOrderSum * 4 - oldSum) / 3.
    ^self relativePrecision: (result - oldResult) abs! !




