"======================================================================
|
|   Numerical methods - Integration
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



DhbFunctionalIterator subclass: DhbTrapezeIntegrator [
    | from to sum step |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbTrapezeIntegrator class >> function: aBlock from: aNumber1 to: aNumber2 [
	"Create an new instance with given parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^super new 
	    initialize: aBlock
	    from: aNumber1
	    to: aNumber2
    ]

    DhbTrapezeIntegrator class >> new [
	"Private - Block the constructor method for this class.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^self error: 'Method new:from:to: must be used'
    ]

    DhbTrapezeIntegrator class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^13
    ]

    from: aNumber1 to: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	from := aNumber1.
	to := aNumber2
    ]

    initialize: aBlock from: aNumber1 to: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	functionBlock := aBlock.
	self from: aNumber1 to: aNumber2.
	^self
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	step := to - from.
	sum := ((functionBlock value: from) + (functionBlock value: to)) * step 
		    / 2.
	result := sum
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	| oldResult |
	oldResult := result.
	result := self higherOrderSum.
	^self relativePrecision: (result - oldResult) abs
    ]

    higherOrderSum [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'transformation'>
	| x newSum |
	x := step / 2 + from.
	newSum := 0.
	[x < to] whileTrue: 
		[newSum := (functionBlock value: x) + newSum.
		x := x + step].
	sum := (step * newSum + sum) / 2.
	step := step / 2.
	^sum
    ]
]



DhbTrapezeIntegrator subclass: DhbRombergIntegrator [
    | order points interpolator |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbRombergIntegrator class >> defaultOrder [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'information'>
	^5
    ]

    initialize [
	"Private - initialize the parameters of the receiver with default values.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	order := self class defaultOrder.
	^super initialize
    ]

    order: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	anInteger < 2 
	    ifTrue: [self error: 'Order for Romberg integration must be larger than 1'].
	order := anInteger
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	super computeInitialValues.
	points := OrderedCollection new: order.
	interpolator := DhbNevilleInterpolator points: points.
	points add: 1 @ sum
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	| interpolation |
	points addLast: (points last x * 0.25) @ self higherOrderSum.
	points size < order ifTrue: [^1].
	interpolation := interpolator valueAndError: 0.
	points removeFirst.
	result := interpolation at: 1.
	^self relativePrecision: (interpolation at: 2) abs
    ]
]



DhbTrapezeIntegrator subclass: DhbSimpsonIntegrator [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/4/99"

	<category: 'operation'>
	| oldResult oldSum |
	iterations < 2 
	    ifTrue: 
		[self higherOrderSum.
		^1].
	oldResult := result.
	oldSum := sum.
	result := (self higherOrderSum * 4 - oldSum) / 3.
	^self relativePrecision: (result - oldResult) abs
    ]
]

