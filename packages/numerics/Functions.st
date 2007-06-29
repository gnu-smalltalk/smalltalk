"======================================================================
|
|   Numerical methods - Special functions
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


Object subclass:  #DhbSeriesTermServer
	instanceVariableNames: 'x lastTerm '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbSeriesTermServer comment: 
nil!

DhbIterativeProcess subclass:  #DhbInfiniteSeries
	instanceVariableNames: 'termServer '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbInfiniteSeries comment: 
nil!

Object subclass:  #DhbIncompleteGammaFunction
	instanceVariableNames: 'alpha alphaLogGamma series fraction '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteGammaFunction comment: 
nil!

DhbSeriesTermServer subclass:  #DhbIncompleteGammaFractionTermServer
	instanceVariableNames: 'alpha '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteGammaFractionTermServer comment: 
nil!

Object subclass:  #PointSeries
	instanceVariableNames: 'points '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

PointSeries comment: 
nil!

Object subclass:  #DhbLanczosFormula
	instanceVariableNames: 'coefficients sqrt2Pi '
	classVariableNames: 'UniqueInstance '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbLanczosFormula comment: 
nil!

DhbSeriesTermServer subclass:  #DhbIncompleteBetaFractionTermServer
	instanceVariableNames: 'alpha1 alpha2 '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteBetaFractionTermServer comment: 
nil!

DhbSeriesTermServer subclass:  #DhbIncompleteGammaSeriesTermServer
	instanceVariableNames: 'alpha sum '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteGammaSeriesTermServer comment: 
nil!

Object subclass:  #DhbIncompleteBetaFunction
	instanceVariableNames: 'alpha1 alpha2 fraction inverseFraction logNorm '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteBetaFunction comment: 
nil!

DhbInfiniteSeries subclass:  #DhbContinuedFraction
	instanceVariableNames: 'numerator denominator '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbContinuedFraction comment: 
nil!

DhbIterativeProcess subclass:  #DhbIncompleteBetaFunctionFraction
	instanceVariableNames: 'x q1 q2 q3 numerator denominator alpha1 alpha2 '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIncompleteBetaFunctionFraction comment: 
nil!

Object subclass:  #DhbErfApproximation
	instanceVariableNames: 'constant series norm '
	classVariableNames: 'UniqueInstance '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbErfApproximation comment: 
nil!

!DhbSeriesTermServer methodsFor: 'initialization'!

setArgument: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    x := aNumber asFloatD! !




!DhbInfiniteSeries class methodsFor: 'creation'!

server: aTermServer 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    ^self new initialize: aTermServer! !

!DhbInfiniteSeries methodsFor: 'initialization'!

initialize: aTermServer 
    "Private - Assigns the object responsible to compute each term.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    termServer := aTermServer.
    ^self! !

!DhbInfiniteSeries methodsFor: 'operation'!

evaluateIteration
    "Perform one iteration.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    | delta |
    delta := termServer termAt: iterations.
    result := result + delta.
    ^self precisionOf: delta abs relativeTo: result abs!

initializeIterations
    "Initialize the series.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    result := termServer initialTerm! !




!DhbIncompleteGammaFunction class methodsFor: 'creation'!

shape: aNumber 
    "Defines a new instance of the receiver with paramater aNumber
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    ^super new initialize: aNumber! !

!DhbIncompleteGammaFunction methodsFor: 'information'!

evaluateFraction: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    fraction isNil 
	ifTrue: 
	    [fraction := DhbIncompleteGammaFractionTermServer new.
	    fraction setParameter: alpha].
    fraction setArgument: aNumber.
    ^(DhbContinuedFraction server: fraction)
	desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	evaluate!

evaluateSeries: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    series isNil 
	ifTrue: 
	    [series := DhbIncompleteGammaSeriesTermServer new.
	    series setParameter: alpha].
    series setArgument: aNumber.
    ^(DhbInfiniteSeries server: series)
	desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	evaluate!

value: aNumber 
    "Compute the value of the receiver for argument aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    | x norm |
    aNumber = 0 ifTrue: [^0].
    x := aNumber asFloatD.
    norm := [(x ln * alpha - x - alphaLogGamma) exp] on: Error
		do: [:signal | signal return: nil].
    norm isNil ifTrue: [^1].
    ^x - 1 < alpha 
	ifTrue: [(self evaluateSeries: x) * norm]
	ifFalse: [1 - (norm / (self evaluateFraction: x))]! !

!DhbIncompleteGammaFunction methodsFor: 'initialization'!

initialize: aNumber 
    "Private - Defines the parameter alpha of the receiver
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    alpha := aNumber asFloatD.
    alphaLogGamma := alpha logGamma.
    ^self! !




!DhbIncompleteGammaFractionTermServer methodsFor: 'information'!

initialTerm
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    lastTerm := x - alpha + 1.
    ^lastTerm!

termsAt: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    lastTerm := lastTerm + 2.
    ^Array with: (alpha - anInteger) * anInteger with: lastTerm! !

!DhbIncompleteGammaFractionTermServer methodsFor: 'initialization'!

setParameter: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    alpha := aNumber asFloatD! !




!PointSeries class methodsFor: 'creation'!

new
    "Create a new instance and initialize it"

    ^super new initialize! !

!PointSeries methodsFor: 'privateMethods'!

primitiveAdd: aPoint 
    "Private - Add a point to the receiver"

    points add: aPoint!

primitiveRemove: aPoint 
    "Private - Removes a point from the receiver"

    points remove: aPoint!

sortBlock
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/5/99 "

    ^[:a :b | a x < b x]! !

!PointSeries methodsFor: 'public methods'!

add: anObject 
    "Add a point to the receiver"

    self primitiveAdd: anObject.
    self changed: self changedSymbol.
    ^anObject!

at: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^points at: anInteger!

changedSymbol
    "Answers the symbol of the event sent when the points of the receiver change"

    ^#pointsChanged!

collectPoints: aBlock 
    ^points collect: aBlock!

do: aBlock 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    self pointsDo: aBlock!

firstPoint
    "Answers the first point stored in the receiver"

    ^self at: 1!

initialize
    "Create the point collection"

    points := SortedCollection sortBlock: self sortBlock.
    ^self!

isEmpty
    "
		 (c) Copyrights Didier BESSET, 1998, all rights reserved.
		 Initial code: 28/9/98 "

    ^points isEmpty!

notEmpty
    ^points notEmpty!

pointCollection
    " Answer the collection of points.
		 (c) Copyrights Didier BESSET, 1998, all rights reserved.
		 Initial code: 28/9/98 "

    ^self collectPoints: [:each | each]!

pointsDo: aBlock 
    points do: aBlock!

remove: anObject 
    "Add a point to the receiver"

    self primitiveRemove: anObject.
    self changed: self changedSymbol.
    ^anObject!

size
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^points size!

sort
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/5/99 "

    points := (points asSortedCollection: self sortBlock) asOrderedCollection! !




!DhbLanczosFormula class methodsFor: 'creation'!

new
    "Answer a unique instance. Create it if it does not exist.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    UniqueInstance isNil 
	ifTrue: 
	    [UniqueInstance := super new.
	    UniqueInstance initialize].
    ^UniqueInstance! !

!DhbLanczosFormula methodsFor: 'information'!

gamma: aNumber 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "

    ^(self leadingFactor: aNumber) exp * (self series: aNumber) * sqrt2Pi 
	/ aNumber!

leadingFactor: aNumber 
    "Private - Answers the log of the leading factor in Lanczos' formula.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "

    | temp |
    temp := aNumber + 5.5.
    ^temp ln * (aNumber + 0.5) - temp!

logGamma: aNumber 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "

    ^(self leadingFactor: aNumber) 
	+ ((self series: aNumber) * sqrt2Pi / aNumber) ln!

series: aNumber 
    "Private - Answer the value of the series of Lanczos' formula.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "

    | term |
    term := aNumber.
    ^coefficients inject: 1.00000000019001
	into: 
	    [:sum :each | 
	    term := term + 1.
	    each / term + sum]! !

!DhbLanczosFormula methodsFor: 'initialization'!

initialize
    "Private - Initialize the coefficients of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "

    sqrt2Pi := (FloatD pi * 2) sqrt.
    coefficients := #(76.1800917294714 -86.5053203294167 24.0140982408309 -1.23173957245015 0.00120865097387 -0.00000539523938).
    ^self! !




!DhbIncompleteBetaFractionTermServer methodsFor: 'information'!

initialTerm
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    ^1!

termsAt: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    | n n2 |
    n := anInteger // 2.
    n2 := 2 * n.
    ^Array with: (n2 < anInteger 
		ifTrue: 
		    [x negated * (alpha1 + n) * (alpha1 + alpha2 + n) 
			/ ((alpha1 + n2) * (alpha1 + 1 + n2))]
		ifFalse: [x * n * (alpha2 - n) / ((alpha1 + n2) * (alpha1 - 1 + n2))])
	with: 1! !

!DhbIncompleteBetaFractionTermServer methodsFor: 'initialization'!

setParameter: aNumber1 second: aNumber2 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    alpha1 := aNumber1.
    alpha2 := aNumber2! !




!DhbIncompleteGammaSeriesTermServer methodsFor: 'information'!

initialTerm
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    lastTerm := 1 / alpha.
    sum := alpha.
    ^lastTerm!

termAt: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    sum := sum + 1.
    lastTerm := lastTerm * x / sum.
    ^lastTerm! !

!DhbIncompleteGammaSeriesTermServer methodsFor: 'initialization'!

setParameter: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    alpha := aNumber asFloatD! !




!DhbIncompleteBetaFunction class methodsFor: 'creation'!

shape: aNumber1 shape: aNumber2 
    "Create an instance of the receiver with given shape parameters.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^super new initialize: aNumber1 shape: aNumber2! !

!DhbIncompleteBetaFunction methodsFor: 'information'!

evaluateFraction: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    fraction isNil 
	ifTrue: 
	    [fraction := DhbIncompleteBetaFractionTermServer new.
	    fraction setParameter: alpha1 second: alpha2].
    fraction setArgument: aNumber.
    ^(DhbContinuedFraction server: fraction)
	desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	evaluate!

evaluateInverseFraction: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    inverseFraction isNil 
	ifTrue: 
	    [inverseFraction := DhbIncompleteBetaFractionTermServer new.
	    inverseFraction setParameter: alpha2 second: alpha1].
    inverseFraction setArgument: 1 - aNumber.
    ^(DhbContinuedFraction server: inverseFraction)
	desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	evaluate!

value: aNumber 
    "Compute the value of the receiver for argument aNumber.
		 Note: aNumber must be between 0 and 1 (otherwise an exception will occur)
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    | norm |
    aNumber = 0 ifTrue: [^0].
    aNumber = 1 ifTrue: [^1].
    norm := (aNumber ln * alpha1 + ((1 - aNumber) ln * alpha2) + logNorm) exp.
    ^(alpha1 + alpha2 + 2) * aNumber < (alpha1 + 1) 
	ifTrue: [norm / ((self evaluateFraction: aNumber) * alpha1)]
	ifFalse: [1 - (norm / ((self evaluateInverseFraction: aNumber) * alpha2))]! !

!DhbIncompleteBetaFunction methodsFor: 'initialization'!

initialize: aNumber1 shape: aNumber2 
    "Private - Initialize the parameters of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    alpha1 := aNumber1.
    alpha2 := aNumber2.
    logNorm := (alpha1 + alpha2) logGamma - alpha1 logGamma - alpha2 logGamma.
    ^self! !




!DhbContinuedFraction methodsFor: 'operation'!

evaluateIteration
    "Perform one iteration.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    | terms delta |
    terms := termServer termsAt: iterations.
    denominator := 1 
		/ (self limitedSmallValue: (terms at: 1) * denominator + (terms at: 2)).
    numerator := self 
		limitedSmallValue: (terms at: 1) / numerator + (terms at: 2).
    delta := numerator * denominator.
    result := result * delta.
    ^(delta - 1) abs!

initializeIterations
    "Initialize the series.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    numerator := self limitedSmallValue: termServer initialTerm.
    denominator := 0.
    result := numerator! !




!DhbIncompleteBetaFunctionFraction class methodsFor: 'creation'!

shape: aNumber1 shape: aNumber2 
    "Create an instance of the receiver with given shape parameters.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^super new initialize: aNumber1 shape: aNumber2! !

!DhbIncompleteBetaFunctionFraction methodsFor: 'initialization'!

initialize: aNumber1 shape: aNumber2 
    "Private - Initialize the parameters of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    alpha1 := aNumber1.
    alpha2 := aNumber2.
    q1 := alpha1 + alpha2.
    q2 := alpha1 + 1.
    q3 := alpha1 - 1.
    ^self!

setArgument: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    x := aNumber! !

!DhbIncompleteBetaFunctionFraction methodsFor: 'operation'!

evaluateIteration
    "Compute and add the next term of the fraction.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

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
    ^(temp - 1) abs!

initializeIterations
    "Initialize the iterations (subclasses must write their own method and call this one last).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/3/99 "

    numerator := 1.
    denominator := 1 / (self limitedSmallValue: 1 - (q1 * x / q2)).
    result := denominator! !




!DhbErfApproximation class methodsFor: 'creation'!

new
    "Answer a unique instance. Create it if it does not exist.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/1/99 "

    UniqueInstance isNil 
	ifTrue: 
	    [UniqueInstance := super new.
	    UniqueInstance initialize].
    ^UniqueInstance! !

!DhbErfApproximation methodsFor: 'information'!

normal: aNumber 
    "Computes the value of the Normal distribution for aNumber
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/1/99 "

    ^[(aNumber squared * -0.5) exp * norm] on: Error
	do: [:signal | signal return: 0]!

value: aNumber 
    "Answer erf( aNumber) using an approximation from Abramovitz and Stegun, Handbook of Mathematical Functions.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/1/99 "

    | t |
    aNumber = 0 ifTrue: [^0.5].
    aNumber > 0 ifTrue: [^1 - (self value: aNumber negated)].
    aNumber < -20 ifTrue: [^0].
    t := 1 / (1 - (constant * aNumber)).
    ^(series value: t) * t * (self normal: aNumber)! !

!DhbErfApproximation methodsFor: 'initialization'!

initialize
    "Private - Initialize constants needed to evaluate the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/1/99 "

    constant := 0.2316419.
    norm := 1 / (FloatD pi * 2) sqrt.
    series := DhbPolynomial 
		coefficients: #(0.31938153 -0.356563782 1.781477937 -1.821255978 1.330274429)! !




