"======================================================================
|
|   Numerical methods - Special functions
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



Object subclass: DhbSeriesTermServer [
    | x lastTerm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    setArgument: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	x := aNumber asFloatD
    ]
]



DhbIterativeProcess subclass: DhbInfiniteSeries [
    | termServer |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbInfiniteSeries class >> server: aTermServer [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'creation'>
	^self new initialize: aTermServer
    ]

    initialize: aTermServer [
	"Private - Assigns the object responsible to compute each term.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	termServer := aTermServer.
	^self
    ]

    evaluateIteration [
	"Perform one iteration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	| delta |
	delta := termServer termAt: iterations.
	result := result + delta.
	^self precisionOf: delta abs relativeTo: result abs
    ]

    initializeIterations [
	"Initialize the series.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	result := termServer initialTerm
    ]
]



Object subclass: DhbIncompleteGammaFunction [
    | alpha alphaLogGamma series fraction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIncompleteGammaFunction class >> shape: aNumber [
	"Defines a new instance of the receiver with paramater aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'creation'>
	^super new initialize: aNumber
    ]

    evaluateFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	fraction isNil 
	    ifTrue: 
		[fraction := DhbIncompleteGammaFractionTermServer new.
		fraction setParameter: alpha].
	fraction setArgument: aNumber.
	^(DhbContinuedFraction server: fraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    evaluateSeries: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	series isNil 
	    ifTrue: 
		[series := DhbIncompleteGammaSeriesTermServer new.
		series setParameter: alpha].
	series setArgument: aNumber.
	^(DhbInfiniteSeries server: series)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    value: aNumber [
	"Compute the value of the receiver for argument aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	| x norm |
	aNumber = 0 ifTrue: [^0].
	x := aNumber asFloatD.
	norm := [(x ln * alpha - x - alphaLogGamma) exp] on: Error
		    do: [:signal | signal return: nil].
	norm isNil ifTrue: [^1].
	^x - 1 < alpha 
	    ifTrue: [(self evaluateSeries: x) * norm]
	    ifFalse: [1 - (norm / (self evaluateFraction: x))]
    ]

    initialize: aNumber [
	"Private - Defines the parameter alpha of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD.
	alphaLogGamma := alpha logGamma.
	^self
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteGammaFractionTermServer [
    | alpha |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := x - alpha + 1.
	^lastTerm
    ]

    termsAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := lastTerm + 2.
	^Array with: (alpha - anInteger) * anInteger with: lastTerm
    ]

    setParameter: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD
    ]
]



Object subclass: PointSeries [
    | points |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    PointSeries class >> new [
	"Create a new instance and initialize it"

	<category: 'creation'>
	^super new initialize
    ]

    primitiveAdd: aPoint [
	"Private - Add a point to the receiver"

	<category: 'privateMethods'>
	points add: aPoint
    ]

    primitiveRemove: aPoint [
	"Private - Removes a point from the receiver"

	<category: 'privateMethods'>
	points remove: aPoint
    ]

    sortBlock [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'privateMethods'>
	^[:a :b | a x < b x]
    ]

    add: anObject [
	"Add a point to the receiver"

	<category: 'public methods'>
	self primitiveAdd: anObject.
	self changed: self changedSymbol.
	^anObject
    ]

    at: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	^points at: anInteger
    ]

    changedSymbol [
	"Answers the symbol of the event sent when the points of the receiver change"

	<category: 'public methods'>
	^#pointsChanged
    ]

    collectPoints: aBlock [
	<category: 'public methods'>
	^points collect: aBlock
    ]

    do: aBlock [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	self pointsDo: aBlock
    ]

    firstPoint [
	"Answers the first point stored in the receiver"

	<category: 'public methods'>
	^self at: 1
    ]

    initialize [
	"Create the point collection"

	<category: 'public methods'>
	points := SortedCollection sortBlock: self sortBlock.
	^self
    ]

    isEmpty [
	"
	 (c) Copyrights Didier BESSET, 1998, all rights reserved.
	 Initial code: 28/9/98"

	<category: 'public methods'>
	^points isEmpty
    ]

    notEmpty [
	<category: 'public methods'>
	^points notEmpty
    ]

    pointCollection [
	"Answer the collection of points.
	 (c) Copyrights Didier BESSET, 1998, all rights reserved.
	 Initial code: 28/9/98"

	<category: 'public methods'>
	^self collectPoints: [:each | each]
    ]

    pointsDo: aBlock [
	<category: 'public methods'>
	points do: aBlock
    ]

    remove: anObject [
	"Add a point to the receiver"

	<category: 'public methods'>
	self primitiveRemove: anObject.
	self changed: self changedSymbol.
	^anObject
    ]

    size [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	^points size
    ]

    sort [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'public methods'>
	points := (points asSortedCollection: self sortBlock) asOrderedCollection
    ]
]



Object subclass: DhbLanczosFormula [
    | coefficients sqrt2Pi |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbLanczosFormula class >> new [
	"Answer a unique instance. Create it if it does not exist.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new.
		UniqueInstance initialize].
	^UniqueInstance
    ]

    gamma: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	^(self leadingFactor: aNumber) exp * (self series: aNumber) * sqrt2Pi 
	    / aNumber
    ]

    leadingFactor: aNumber [
	"Private - Answers the log of the leading factor in Lanczos' formula.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	| temp |
	temp := aNumber + 5.5.
	^temp ln * (aNumber + 0.5) - temp
    ]

    logGamma: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	^(self leadingFactor: aNumber) 
	    + ((self series: aNumber) * sqrt2Pi / aNumber) ln
    ]

    series: aNumber [
	"Private - Answer the value of the series of Lanczos' formula.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	| term |
	term := aNumber.
	^coefficients inject: 1.00000000019001
	    into: 
		[:sum :each | 
		term := term + 1.
		each / term + sum]
    ]

    initialize [
	"Private - Initialize the coefficients of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'initialization'>
	sqrt2Pi := (FloatD pi * 2) sqrt.
	coefficients := #(76.1800917294714 -86.50532032941671 24.0140982408309 -1.23173957245015 0.00120865097387 -0.00000539523938).
	^self
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteBetaFractionTermServer [
    | alpha1 alpha2 |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	^1
    ]

    termsAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	| n n2 |
	n := anInteger // 2.
	n2 := 2 * n.
	^Array with: (n2 < anInteger 
		    ifTrue: 
			[x negated * (alpha1 + n) * (alpha1 + alpha2 + n) 
			    / ((alpha1 + n2) * (alpha1 + 1 + n2))]
		    ifFalse: [x * n * (alpha2 - n) / ((alpha1 + n2) * (alpha1 - 1 + n2))])
	    with: 1
    ]

    setParameter: aNumber1 second: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteGammaSeriesTermServer [
    | alpha sum |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := 1 / alpha.
	sum := alpha.
	^lastTerm
    ]

    termAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	sum := sum + 1.
	lastTerm := lastTerm * x / sum.
	^lastTerm
    ]

    setParameter: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD
    ]
]



Object subclass: DhbIncompleteBetaFunction [
    | alpha1 alpha2 fraction inverseFraction logNorm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIncompleteBetaFunction class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    evaluateFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	fraction isNil 
	    ifTrue: 
		[fraction := DhbIncompleteBetaFractionTermServer new.
		fraction setParameter: alpha1 second: alpha2].
	fraction setArgument: aNumber.
	^(DhbContinuedFraction server: fraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    evaluateInverseFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	inverseFraction isNil 
	    ifTrue: 
		[inverseFraction := DhbIncompleteBetaFractionTermServer new.
		inverseFraction setParameter: alpha2 second: alpha1].
	inverseFraction setArgument: 1 - aNumber.
	^(DhbContinuedFraction server: inverseFraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    value: aNumber [
	"Compute the value of the receiver for argument aNumber.
	 Note: aNumber must be between 0 and 1 (otherwise an exception will occur)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	| norm |
	aNumber = 0 ifTrue: [^0].
	aNumber = 1 ifTrue: [^1].
	norm := (aNumber ln * alpha1 + ((1 - aNumber) ln * alpha2) + logNorm) exp.
	^(alpha1 + alpha2 + 2) * aNumber < (alpha1 + 1) 
	    ifTrue: [norm / ((self evaluateFraction: aNumber) * alpha1)]
	    ifFalse: [1 - (norm / ((self evaluateInverseFraction: aNumber) * alpha2))]
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	logNorm := (alpha1 + alpha2) logGamma - alpha1 logGamma - alpha2 logGamma.
	^self
    ]
]



DhbInfiniteSeries subclass: DhbContinuedFraction [
    | numerator denominator |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    evaluateIteration [
	"Perform one iteration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	| terms delta |
	terms := termServer termsAt: iterations.
	denominator := 1 
		    / (self limitedSmallValue: (terms at: 1) * denominator + (terms at: 2)).
	numerator := self 
		    limitedSmallValue: (terms at: 1) / numerator + (terms at: 2).
	delta := numerator * denominator.
	result := result * delta.
	^(delta - 1) abs
    ]

    initializeIterations [
	"Initialize the series.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	numerator := self limitedSmallValue: termServer initialTerm.
	denominator := 0.
	result := numerator
    ]
]



DhbIterativeProcess subclass: DhbIncompleteBetaFunctionFraction [
    | x q1 q2 q3 numerator denominator alpha1 alpha2 |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbIncompleteBetaFunctionFraction class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	q1 := alpha1 + alpha2.
	q2 := alpha1 + 1.
	q3 := alpha1 - 1.
	^self
    ]

    setArgument: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	x := aNumber
    ]

    evaluateIteration [
	"Compute and add the next term of the fraction.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'operation'>
	| m m2 temp |
	m := iterations + 1.
	m2 := m * 2.
	temp := m * (alpha2 - m) * x / ((q3 + m2) * (alpha1 + m2)).
	denominator := self limitedSmallValue: denominator * temp + 1.
	numerator := self limitedSmallValue: temp / numerator + 1.
	denominator := 1 / denominator.
	result := result * numerator * denominator.
	temp := (alpha1 + m) negated * (q1 + m) * x / ((q2 + m2) * (alpha1 + m2)).
	denominator := self limitedSmallValue: denominator * temp + 1.
	numerator := self limitedSmallValue: temp / numerator + 1.
	denominator := 1 / denominator.
	temp := numerator * denominator.
	result := result * temp.
	^(temp - 1) abs
    ]

    initializeIterations [
	"Initialize the iterations (subclasses must write their own method and call this one last).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'operation'>
	numerator := 1.
	denominator := 1 / (self limitedSmallValue: 1 - (q1 * x / q2)).
	result := denominator
    ]
]



Object subclass: DhbErfApproximation [
    | constant series norm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbErfApproximation class >> new [
	"Answer a unique instance. Create it if it does not exist.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new.
		UniqueInstance initialize].
	^UniqueInstance
    ]

    normal: aNumber [
	"Computes the value of the Normal distribution for aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'information'>
	^[(aNumber squared * -0.5) exp * norm] on: Error
	    do: [:signal | signal return: 0]
    ]

    value: aNumber [
	"Answer erf( aNumber) using an approximation from Abramovitz and Stegun, Handbook of Mathematical Functions.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'information'>
	| t |
	aNumber = 0 ifTrue: [^0.5].
	aNumber > 0 ifTrue: [^1 - (self value: aNumber negated)].
	aNumber < -20 ifTrue: [^0].
	t := 1 / (1 - (constant * aNumber)).
	^(series value: t) * t * (self normal: aNumber)
    ]

    initialize [
	"Private - Initialize constants needed to evaluate the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'initialization'>
	constant := 0.2316419.
	norm := 1 / (FloatD pi * 2) sqrt.
	series := DhbPolynomial 
		    coefficients: #(0.31938153 -0.356563782 1.781477937 -1.821255978 1.330274429)
    ]
]

