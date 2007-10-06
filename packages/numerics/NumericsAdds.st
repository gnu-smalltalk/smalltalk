Integer extend [

    gamma [
	"Compute the Gamma function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	self > 0 
	    ifFalse: 
		[^self 
		    error: 'Attempt to compute the Gamma function of a non-positive integer'].
	^(self - 1) factorial
    ]

    random [
	"Answer a random integer between 0 and the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'numerics'>
	^Dhb.DhbMitchellMooreGenerator new integerValue: self
    ]

]



Number class extend [

    random [
	"Answers a random number between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'numerics'>
	^Dhb.DhbMitchellMooreGenerator new floatValue
    ]

]



Number extend [

    addPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'numerics'>
	^aPolynomial addNumber: self
    ]

    asLimitedPrecisionReal [
	"Convert the receiver to an instance of
	 some subclass of LimitedPrecisionReal.
	 This method defines what the default is."

	<category: 'numerics'>
	^self asFloat
    ]

    beta: aNumber [
	"Computes the beta function of the receiver and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^(self logBeta: aNumber) exp
    ]

    dividingPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'numerics'>
	^aPolynomial timesNumber: 1 / self
    ]

    equalsTo: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'numerics'>
	^self relativelyEqualsTo: aNumber
	    upTo: Dhb.DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    errorFunction [
	"Answer the error function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^Dhb.DhbErfApproximation new value: self
    ]

    gamma [
	"Compute the Gamma function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^self > 1 
	    ifTrue: [^Dhb.DhbLanczosFormula new gamma: self]
	    ifFalse: 
		[self < 0 
		    ifTrue: [Float pi / ((Float pi * self) sin * (1 - self) gamma)]
		    ifFalse: [(Dhb.DhbLanczosFormula new gamma: self + 1) / self]]
    ]

    logBeta: aNumber [
	"Computes the logarithm of the beta function of the receiver and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^self logGamma + aNumber logGamma - (self + aNumber) logGamma
    ]

    logGamma [
	"Computes the log of the Gamma function (for positive numbers only)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^self > 1 
	    ifTrue: [Dhb.DhbLanczosFormula new logGamma: self]
	    ifFalse: 
		[self > 0 
		    ifTrue: [(Dhb.DhbLanczosFormula new logGamma: self + 1) - self ln]
		    ifFalse: [^self error: 'Argument for the log gamma function must be positive']]
    ]

    productWithMatrix: aMatrix [
	"Answer a new matrix, product of aMatrix with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^aMatrix class rows: (aMatrix rowsCollect: [:each | each * self])
    ]

    productWithVector: aVector [
	"Answers a new vector product of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^aVector collect: [:each | each * self]
    ]

    random [
	"Answers a random number distributed between 0 and the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'numerics'>
	^self class random * self
    ]

    relativelyEqualsTo: aNumber upTo: aSmallNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'numerics'>
	| norm |
	norm := self abs max: aNumber abs.
	^norm <= Dhb.DhbFloatingPointMachine new defaultNumericalPrecision 
	    or: [(self - aNumber) abs < (aSmallNumber * norm)]
    ]

    subtractToPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'numerics'>
	^aPolynomial addNumber: self negated
    ]

    timesPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'numerics'>
	^aPolynomial timesNumber: self
    ]

]



Point extend [

    extentFromBottomLeft: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self 
		    - (0 @ (aPoint isInteger ifTrue: [aPoint] ifFalse: [aPoint y]))
	    extent: aPoint
    ]

    extentFromBottomRight: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self - aPoint extent: aPoint
    ]

    extentFromCenter: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self - (aPoint // 2) extent: aPoint
    ]

    extentFromTopLeft: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self extent: aPoint
    ]

    extentFromTopRight: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self 
		    - ((aPoint isInteger ifTrue: [aPoint] ifFalse: [aPoint x]) @ 0)
	    extent: aPoint
    ]

]



Rectangle extend [

    positiveRectangle [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^(origin min: corner) corner: (origin max: corner)
    ]

]



Collection extend [

    asVector [
	<category: 'numerics'>
	^(Dhb.DhbVector new: self size) 
	    replaceFrom: 1
	    to: self size
	    with: self
	    startingAt: 1
    ]

]



DhbPolynomial extend [

    generality [
	<category: 'numerics'>
	^nil
    ]

]



DhbVector extend [

    generality [
	<category: 'numerics'>
	^nil
    ]

]

