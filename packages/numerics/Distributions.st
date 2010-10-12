"======================================================================
|
|   Numerical methods - Probability densities
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



Object subclass: DhbProbabilityDensity [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProbabilityDensity class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	^nil
    ]

    DhbProbabilityDensity class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Unknown distribution'
    ]

    distributionFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'creation'>
	^DhbProbabilityDistributionFunction density: self
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'display'>
	| params |
	aStream nextPutAll: self class distributionName.
	(params := self parameters) notNil 
	    ifTrue: 
		[| first |
		first := true.
		aStream nextPut: $(.
		params do: 
			[:each | 
			first ifTrue: [first := false] ifFalse: [aStream nextPut: $,].
			aStream space.
			each printOn: aStream].
		aStream nextPut: $)]
    ]

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(self distributionValue: aNumber2) - (self distributionValue: aNumber1)
    ]

    approximatedValueAndGradient: aNumber [
	"Private - gradients an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 The gradient is computed by approximation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| delta parameters dp gradient n |
	parameters := self parameters.
	n := parameters size.
	dp := self value: aNumber.
	delta := Array new: n.
	delta atAllPut: 0.
	gradient := DhbVector new: n.
	1 to: n
	    do: 
		[:k | 
		delta at: k put: (parameters at: k) * 0.0001.
		self changeParametersBy: delta.
		gradient at: k put: ((self value: aNumber) - dp) / (delta at: k).
		delta at: k put: (delta at: k) negated.
		k > 1 ifTrue: [delta at: k - 1 put: 0]].
	self changeParametersBy: delta.
	^Array with: dp with: gradient
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self subclassResponsibility
    ]

    inverseDistributionValue: aNumber [
	"Answer the number whose distribution value is aNumber.
	 NOTE: Subclass MUST NOT overwrite this method.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber between: 0 and: 1) 
	    ifTrue: [self privateInverseDistributionValue: aNumber]
	    ifFalse: [self error: 'Illegal argument for inverse distribution value']
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    parameters [
	"Returns an Array containing the parameters of the distribution.
	 It is used to print out the distribution and for fitting.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^self subclassResponsibility
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose distribution is aNumber.
	 NOTE: Subclass may overwrite this method for faster computation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbNewtonZeroFinder 
	    function: [:x | (self distributionValue: x) - aNumber]
	    derivative: self)
	    initialValue: self average / (1 - aNumber);
	    evaluate
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self 
	    privateInverseDistributionValue: DhbMitchellMooreGenerator new floatValue
    ]

    skewness [
	"Answer the skewness of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self variance sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^self approximatedValueAndGradient: aNumber
    ]

    variance [
	"Answer the variance of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self standardDeviation squared
    ]

    changeParametersBy: aVector [
	<category: 'transformation'>
	self subclassResponsibility
    ]
]



DhbProbabilityDensity subclass: DhbProbabilityDensityWithUnknownDistribution [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: aNumber1
	    to: aNumber2) evaluate
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 This general purpose routine uses numerical integration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: self lowestValue
	    to: aNumber) evaluate
    ]

    lowestValue [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'information'>
	^0
    ]
]



DhbProbabilityDensity subclass: DhbWeibullDistribution [
    | alpha beta norm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbWeibullDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| average xMin xMax accMin accMax |
	aHistogram minimum < 0 ifTrue: [^nil].
	average := aHistogram average.
	xMin := (aHistogram minimum + average) / 2.
	accMin := (aHistogram countsUpTo: xMin) / aHistogram totalCount.
	xMax := (aHistogram maximum + average) / 2.
	accMax := (aHistogram countsUpTo: xMax) / aHistogram totalCount.
	^
	[self 
	    solve: xMin
	    acc: accMin
	    upper: xMax
	    acc: accMax] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    DhbWeibullDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbWeibullDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbWeibullDistribution class >> solve: lowX acc: lowAcc upper: highX acc: highAcc [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| lowLnAcc highLnAcc deltaLnAcc lowLnX highLnX |
	lowLnAcc := (1 - lowAcc) ln negated ln.
	highLnAcc := (1 - highAcc) ln negated ln.
	deltaLnAcc := highLnAcc - lowLnAcc.
	lowLnX := lowX ln.
	highLnX := highX ln.
	^self shape: deltaLnAcc / (highLnX - lowLnX)
	    scale: ((highLnAcc * lowLnX - (lowLnAcc * highLnX)) / deltaLnAcc) exp
    ]

    DhbWeibullDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Weibull distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(1 / alpha) gamma * beta / alpha
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 Assumes that the value of the receiver is 0 for x < 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [1 - (aNumber / beta raisedTo: alpha) negated exp]
	    ifFalse: [0]
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber / beta raisedTo: alpha) negated exp 
	    * (aNumber raisedTo: alpha - 1) * norm
    ]

    variance [
	"Answer the variance of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta squared / alpha 
	    * ((2 / alpha) gamma * 2 - ((1 / alpha) gamma squared / alpha))
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'initialization'>
	norm := alpha / (beta raisedTo: alpha)
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	self computeNorm.
	^self
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	^((1 - aNumber) ln negated raisedTo: 1 / alpha) * beta
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2).
	self computeNorm
    ]
]



DhbProbabilityDensity subclass: DhbExponentialDistribution [
    | beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbExponentialDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| mu |
	aHistogram minimum < 0 ifTrue: [^nil].
	mu := aHistogram average.
	^mu > 0 ifTrue: [self scale: aHistogram average] ifFalse: [nil]
    ]

    DhbExponentialDistribution class >> new [
	"Create a new instance of the receiver with scale parameter 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: 1
    ]

    DhbExponentialDistribution class >> scale: aNumber [
	"Create a new instance of the receiver with given scale parameter.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber
    ]

    DhbExponentialDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Exponential distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^[1 - (aNumber / beta negated) exp] on: Error
	    do: [:signal | signal return: 0]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^6
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: beta
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(1 - aNumber) ln negated * beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^DhbMitchellMooreGenerator new floatValue ln * beta negated
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^2
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^[(aNumber / beta) negated exp / beta] on: Error
	    do: [:signal | signal return: 0]
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| dp |
	dp := self value: aNumber.
	^Array with: dp with: (DhbVector with: (aNumber / beta - 1) * dp / beta)
    ]

    initialize: aNumber [
	"Private - Set the scale parameter of the receiver to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	aNumber > 0 ifFalse: [self error: 'Illegal distribution parameters'].
	beta := aNumber.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	beta := beta + (aVector at: 1)
    ]
]



DhbProbabilityDensity subclass: DhbBetaDistribution [
    | alpha1 alpha2 gamma1 gamma2 logNorm incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbBetaDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| average variance a b |
	(aHistogram minimum < 0 or: [aHistogram maximum > 1]) ifTrue: [^nil].
	average := aHistogram average.
	variance := aHistogram variance.
	a := ((1 - average) / variance - 1) * average.
	a > 0 ifFalse: [^nil].
	b := (1 / average - 1) * a.
	b > 0 ifFalse: [^nil].
	^self shape: a shape: b
    ]

    DhbBetaDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbBetaDistribution class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    DhbBetaDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Beta distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha1 / (alpha1 + alpha2)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction shape: alpha1
			    shape: alpha2].
	^incompleteBetaFunction value: aNumber
    ]

    firstGammaDistribution [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	gamma1 isNil 
	    ifTrue: [gamma1 := DhbGammaDistribution shape: alpha1 scale: 1].
	^gamma1
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^3 * (alpha1 + alpha2 + 1) 
	    * (((alpha1 + alpha2) squared * 2 
		    + ((alpha1 + alpha2 - 6) * alpha1 * alpha2)) 
			/ ((alpha1 + alpha2 + 2) * (alpha1 + alpha2 + 3) * alpha1 * alpha2)) 
		- 3
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha1 with: alpha2
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| r |
	r := self firstGammaDistribution random.
	^r / (self secondGammaDistribution random + r)
    ]

    secondGammaDistribution [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	gamma2 isNil 
	    ifTrue: [gamma2 := DhbGammaDistribution shape: alpha2 scale: 1].
	^gamma2
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^(alpha1 + alpha2 + 1) sqrt * 2 * (alpha2 - alpha1) 
	    / ((alpha1 * alpha2) sqrt * (alpha1 + alpha2 + 2))
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber > 0 and: [aNumber < 1]) 
	    ifTrue: 
		[(aNumber ln * (alpha1 - 1) + ((1 - aNumber) ln * (alpha2 - 1)) + logNorm) 
		    exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha1 * alpha2 / ((alpha1 + alpha2) squared * (alpha1 + alpha2 + 1))
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	logNorm := (alpha1 + alpha2) logGamma - alpha1 logGamma - alpha2 logGamma
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha1 := alpha1 + (aVector at: 1).
	alpha2 := alpha2 + (aVector at: 2).
	self computeNorm.
	gamma1 := nil.
	gamma2 := nil.
	incompleteBetaFunction := nil
    ]
]



DhbProbabilityDensity subclass: DhbUniformDistribution [
    | lowLimit highLimit |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbUniformDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'public'>
	^'Uniform distribution'
    ]

    DhbUniformDistribution class >> from: aNumber1 to: aNumber2 [
	"Create a new instance of the receiver with given limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'public'>
	^super new initialize: aNumber1 to: aNumber2
    ]

    DhbUniformDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'public'>
	| b c |
	b := aHistogram standardDeviation * 1.73205080756888.	"12 sqrt / 2"
	b = 0 ifTrue: [^nil].
	c := aHistogram average.
	^self from: c - b to: c + b
    ]

    DhbUniformDistribution class >> new [
	"Create a new instance of the receiver with limits 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'public'>
	^self from: 0 to: 1
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit + lowLimit) / 2
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	aNumber < lowLimit ifTrue: [^0].
	^aNumber < highLimit 
	    ifTrue: [(aNumber - lowLimit) / (highLimit - lowLimit)]
	    ifFalse: [1]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^-12 / 10
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: lowLimit with: highLimit
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) * aNumber + lowLimit
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) / 3.46410161513774	"12 sqrt"
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: [1 / (highLimit - lowLimit)]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) squared / 12
    ]

    initialize: aNumber1 to: aNumber2 [
	"Private - Defines the limits of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	aNumber1 < aNumber2 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	lowLimit := aNumber1.
	highLimit := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	lowLimit := lowLimit + (aVector at: 1).
	highLimit := highLimit + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbFisherTippettDistribution [
    | alpha beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFisherTippettDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| beta |
	beta := aHistogram standardDeviation.
	beta = 0 ifTrue: [^nil].
	beta := beta * (6 sqrt / FloatD pi).
	^self shape: aHistogram average - (0.5772156649 * beta) scale: beta
    ]

    DhbFisherTippettDistribution class >> new [
	"Create a standard version of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbFisherTippettDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbFisherTippettDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Fisher-Tippett distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^0.5772566490000001 * beta + alpha
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	| arg |
	arg := (aNumber - alpha) / beta.
	arg := arg < DhbFloatingPointMachine new largestExponentArgument negated 
		    ifTrue: [^0]
		    ifFalse: [arg negated exp].
	^arg > DhbFloatingPointMachine new largestExponentArgument 
	    ifTrue: [1]
	    ifFalse: [arg negated exp]
    ]

    integralFrom: aNumber1 to: aNumber2 [
	"Private - Compute the integral of the receiver from aNumber1 to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: aNumber1
	    to: aNumber2) evaluate
    ]

    integralUpTo: aNumber [
	"Private - Compute the integral of the receiver from -infinity to aNumber.
	 aNumber must be below 0 (no checking!!).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: [:x | x = 0 ifTrue: [0] ifFalse: [(self value: 1 / x) / x squared]]
	    from: 1 / aNumber
	    to: 0) evaluate
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^2.4
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/4/99"

	<category: 'information'>
	| t |
	
	[t := DhbMitchellMooreGenerator new floatValue ln negated.
	t > 0] 
		whileFalse: [].
	^t ln negated * beta + alpha
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^1.3
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^FloatD pi * beta / 6 sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| arg |
	arg := (aNumber - alpha) / beta.
	arg := arg > DhbFloatingPointMachine new largestExponentArgument 
		    ifTrue: [^0]
		    ifFalse: [arg negated exp + arg].
	^arg > DhbFloatingPointMachine new largestExponentArgument 
	    ifTrue: [0]
	    ifFalse: [arg negated exp / beta]
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp dy y |
	dp := self value: aNumber.
	y := (aNumber - alpha) / beta.
	dy := y negated exp - 1.
	^Array with: dp
	    with: (DhbVector with: dy * dp / beta negated
		    with: dp * (y * dy + 1) / beta negated)
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'initialization'>
	aNumber2 > 0 ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	^self
    ]
]



DhbProbabilityDensityWithUnknownDistribution subclass: DhbLogNormalDistribution [
    | normalDistribution |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLogNormalDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| average variance sigma2 |
	aHistogram minimum < 0 ifTrue: [^nil].
	average := aHistogram average.
	average > 0 ifFalse: [^nil].
	variance := aHistogram variance.
	sigma2 := (variance / average squared + 1) ln.
	sigma2 > 0 ifFalse: [^nil].
	^self new: average ln - (sigma2 * 5) sigma: sigma2 sqrt
    ]

    DhbLogNormalDistribution class >> new [
	"Create a new instance of the receiver with mu=0 and sigma=1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self new: 0 sigma: 1
    ]

    DhbLogNormalDistribution class >> new: aNumber1 sigma: aNumber2 [
	"Create a new instance of the receiver with given mu and sigma.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 sigma: aNumber2
    ]

    DhbLogNormalDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Log normal distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(normalDistribution variance * 0.5 + normalDistribution average) exp
    ]

    fourthCentralMoment [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 24/6/99"

	<category: 'information'>
	| y x |
	y := normalDistribution average exp.
	x := normalDistribution variance exp.
	^y squared squared * x squared 
	    * (((x squared * x - 4) * x squared + 6) * x - 3)
    ]

    kurtosis [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| x |
	x := normalDistribution variance exp.
	^((x + 2) * x + 3) * x squared - 6
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^normalDistribution parameters
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^normalDistribution random exp
    ]

    skewness [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| x |
	x := normalDistribution variance exp.
	^(x - 1) sqrt * (x + 2)
    ]

    thirdCentralMoment [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 24/6/99"

	<category: 'information'>
	| y x |
	y := normalDistribution average exp.
	x := normalDistribution variance exp.
	^y squared * y * (x raisedTo: 3 / 2) * ((x squared negated + 3) * x - 2)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [(normalDistribution value: aNumber ln) / aNumber]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(normalDistribution average * 2 + normalDistribution variance) exp 
	    * (normalDistribution variance exp - 1)
    ]

    initialize: aNumber1 sigma: aNumber2 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	normalDistribution := DhbNormalDistribution new: aNumber1 sigma: aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	normalDistribution changeParametersBy: aVector
    ]
]



DhbProbabilityDensity subclass: DhbCauchyDistribution [
    | mu beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbCauchyDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self shape: aHistogram average
	    scale: 4 * aHistogram variance 
		    / (FloatD pi * (aHistogram maximum squared + aHistogram minimum squared)) 
			    sqrt
    ]

    DhbCauchyDistribution class >> new [
	"Create an instance of the receiver with center 0 and scale 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbCauchyDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given center and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbCauchyDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Cauchy distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^mu
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 Assumes that the value of the receiver is 0 for x < 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^((aNumber - mu) / beta) arcTan / FloatD pi + (1 / 2)
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: beta
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^((aNumber - (1 / 2)) * FloatD pi) tan * beta + mu
    ]

    standardDeviation [
	"The standard deviation of the receiver is not defined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^beta / (FloatD pi * (beta squared + (aNumber - mu) squared))
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp denominator |
	dp := self value: aNumber.
	denominator := 1 / ((aNumber - mu) squared + beta squared).
	^Array with: dp
	    with: (DhbVector with: 2 * dp * (aNumber - mu) * denominator
		    with: dp * (1 / beta - (2 * beta * denominator)))
    ]

    variance [
	"The variance of the receiver is not defined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	beta := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]
]



Object subclass: DhbProbabilityDistributionFunction [
    | probabilityDensity |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProbabilityDistributionFunction class >> density: aProbabilityDensity [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'creation'>
	^self new initialize: aProbabilityDensity
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^probabilityDensity distributionValue: aNumber
    ]

    initialize: aProbabilityDensity [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'initialization'>
	probabilityDensity := aProbabilityDensity.
	^self
    ]
]



DhbProbabilityDensity subclass: DhbGammaDistribution [
    | alpha beta norm randomCoefficients incompleteGammaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbGammaDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| alpha beta |
	aHistogram minimum < 0 ifTrue: [^nil].
	alpha := aHistogram average.
	beta := aHistogram variance / alpha.
	^[self shape: alpha / beta scale: beta] on: Error
	    do: [:signal | signal return: nil]
    ]

    DhbGammaDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbGammaDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbGammaDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Gamma distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha * beta
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self incompleteGammaFunction value: aNumber / beta
    ]

    incompleteGammaFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	incompleteGammaFunction isNil 
	    ifTrue: [incompleteGammaFunction := DhbIncompleteGammaFunction shape: alpha].
	^incompleteGammaFunction
    ]

    initializeRandomCoefficientsForLargeAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| a b q d |
	a := 1 / (2 * alpha - 1) sqrt.
	b := alpha - 4 ln.
	q := 1 / a + alpha.
	d := 4.5 ln + 1.
	^Array 
	    with: a
	    with: b
	    with: q
	    with: d
    ]

    initializeRandomCoefficientsForSmallAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| e |
	e := 1 exp.
	^(e + alpha) / e
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^6 / alpha
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(alpha > 1 
	    ifTrue: [self randomForLargeAlpha]
	    ifFalse: [self randomForSmallAlpha]) * beta
    ]

    randomCoefficientsForLargeAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	randomCoefficients isNil 
	    ifTrue: [randomCoefficients := self initializeRandomCoefficientsForLargeAlpha].
	^randomCoefficients
    ]

    randomCoefficientsForSmallAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	randomCoefficients isNil 
	    ifTrue: [randomCoefficients := self initializeRandomCoefficientsForSmallAlpha].
	^randomCoefficients
    ]

    randomForLargeAlpha [
	"Private - Generate a random number distributed according to the receiver
	 when alpha > 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	[true] whileTrue: 
		[| u1 u2 c v y z w |
		u1 := DhbMitchellMooreGenerator new floatValue.
		u2 := DhbMitchellMooreGenerator new floatValue.
		c := self randomCoefficientsForLargeAlpha.
		v := (u1 / (1 - u1)) ln * (c at: 1).
		y := v exp * alpha.
		z := u1 squared * u2.
		w := (c at: 3) * v + (c at: 2) - y.
		(c at: 4) + w >= (4.5 * z) ifTrue: [^y].
		z ln <= w ifTrue: [^y]]
    ]

    randomForSmallAlpha [
	"Private - Generate a random number distributed according to the receiver
	 when alpha < 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	[true] whileTrue: 
		[| p |
		p := DhbMitchellMooreGenerator new floatValue 
			    * self randomCoefficientsForSmallAlpha.
		p > 1 
		    ifTrue: 
			[| y |
			y := ((self randomCoefficientsForSmallAlpha - p) / alpha) ln negated.
			DhbMitchellMooreGenerator new floatValue <= (y raisedTo: alpha - 1) 
			    ifTrue: [^y]]
		    ifFalse: 
			[| y |
			y := p raisedTo: 1 / alpha.
			DhbMitchellMooreGenerator new floatValue <= y negated exp ifTrue: [^y]]]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^2 / alpha sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [(aNumber ln * (alpha - 1) - (aNumber / beta) - norm) exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta squared * alpha
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	norm := beta ln * alpha + alpha logGamma
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2).
	self computeNorm.
	incompleteGammaFunction := nil.
	randomCoefficients := nil
    ]
]



DhbProbabilityDensity subclass: DhbTriangularDistribution [
    | lowLimit highLimit peak |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbTriangularDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| b c |
	b := aHistogram standardDeviation * 1.73205080756888.	"12 sqrt / 2"
	b = 0 ifTrue: [^nil].
	c := aHistogram average.
	^self 
	    new: c
	    from: c - b
	    to: c + b
    ]

    DhbTriangularDistribution class >> new [
	"Create an instance of the receiver with peak at 1/2 and limits 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^self 
	    new: 1 / 2
	    from: 0
	    to: 1
    ]

    DhbTriangularDistribution class >> new: aNumber1 from: aNumber2 to: aNumber3 [
	"Create an instance of the receiver with peak at aNumber1 and limits aNumber2 and aNumber3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new 
	    initialize: aNumber1
	    from: aNumber2
	    to: aNumber3
    ]

    DhbTriangularDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Triangular distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(lowLimit + peak + highLimit) / 3
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| norm |
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: 
		[aNumber < peak 
		    ifTrue: 
			[norm := (highLimit - lowLimit) * (peak - lowLimit).
			(aNumber - lowLimit) squared / norm]
		    ifFalse: 
			[aNumber > peak 
			    ifTrue: 
				[norm := (highLimit - lowLimit) * (highLimit - peak).
				1 - ((highLimit - aNumber) squared / norm)]
			    ifFalse: [(peak - lowLimit) / (highLimit - lowLimit)]]]
	    ifFalse: [0]
    ]

    inverseAcceptanceAfterPeak: aNumber [
	"Private - Compute inverse acceptance function in the region after the peak.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^highLimit 
	    - ((1 - aNumber) * (highLimit - lowLimit) * (highLimit - peak)) sqrt
    ]

    inverseAcceptanceBeforePeak: aNumber [
	"Private - Compute inverse acceptance function in the region before the peak.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^(aNumber * (highLimit - lowLimit) * (peak - lowLimit)) sqrt + lowLimit
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^-6 / 10
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array 
	    with: lowLimit
	    with: highLimit
	    with: peak
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(peak - lowLimit) / (highLimit - lowLimit) > aNumber 
	    ifTrue: [self inverseAcceptanceBeforePeak: aNumber]
	    ifFalse: [self inverseAcceptanceAfterPeak: aNumber]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^((lowLimit squared * lowLimit + (peak squared * peak) 
	    + (highLimit squared * highLimit)) / 135 
	    - ((lowLimit squared * peak + (lowLimit squared * highLimit) 
		    + (peak squared * lowLimit) + (peak squared * highLimit) 
		    + (highLimit squared * lowLimit) + (highLimit squared * peak)) 
		    / 90) 
		+ (2 * lowLimit * peak * highLimit / 45)) 
		/ (self standardDeviation raisedToInteger: 3)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| norm |
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: 
		[aNumber < peak 
		    ifTrue: 
			[norm := (highLimit - lowLimit) * (peak - lowLimit).
			2 * (aNumber - lowLimit) / norm]
		    ifFalse: 
			[aNumber > peak 
			    ifTrue: 
				[norm := (highLimit - lowLimit) * (highLimit - peak).
				2 * (highLimit - aNumber) / norm]
			    ifFalse: [2 / (highLimit - lowLimit)]]]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(lowLimit squared + peak squared + highLimit squared - (lowLimit * peak) 
	    - (lowLimit * highLimit) - (peak * highLimit)) 
	    / 18
    ]

    initialize: aNumber1 from: aNumber2 to: aNumber3 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber2 < aNumber3 and: [aNumber1 between: aNumber2 and: aNumber3]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	peak := aNumber1.
	lowLimit := aNumber2.
	highLimit := aNumber3.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	lowLimit := lowLimit + (aVector at: 1).
	highLimit := highLimit + (aVector at: 2).
	peak := peak + (aVector at: 3)
    ]
]



DhbProbabilityDensity subclass: DhbLaplaceDistribution [
    | mu beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLaplaceDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self shape: aHistogram average scale: (aHistogram variance / 2) sqrt
    ]

    DhbLaplaceDistribution class >> new [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbLaplaceDistribution class >> shape: aNumber1 scale: aNumber2 [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbLaplaceDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Laplace distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^mu
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^3
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| r |
	r := DhbMitchellMooreGenerator new floatValue ln * beta negated.
	^DhbMitchellMooreGenerator new floatValue > 0.5 
	    ifTrue: [mu + r]
	    ifFalse: [mu - r]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta * 2 sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^((aNumber - mu) / beta) abs negated exp / (2 * beta)
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp |
	dp := self value: aNumber.
	^Array with: dp
	    with: (DhbVector with: (aNumber - mu) sign * dp / beta
		    with: ((aNumber - mu) abs / beta - 1) * dp / beta)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	^aNumber > mu 
	    ifTrue: [1 - (((aNumber - mu) / beta) negated exp / 2)]
	    ifFalse: [((aNumber - mu) / beta) exp / 2]
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	beta := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbFisherSnedecorDistribution [
    | dof1 dof2 norm chiSquareDistribution1 chiSquareDistribution2 incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFisherSnedecorDistribution class >> degreeOfFreedom: anInteger1 degreeOfFreedom: anInteger2 [
	"Create a new instance of the receiver with given degrees of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^super new initialize: anInteger1 and: anInteger2
    ]

    DhbFisherSnedecorDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	| n1 n2 a |
	aHistogram minimum < 0 ifTrue: [^nil].
	n2 := (2 / (1 - (1 / aHistogram average))) rounded.
	n2 > 0 ifFalse: [^nil].
	a := (n2 - 2) * (n2 - 4) * aHistogram variance / (n2 squared * 2).
	n1 := (7 * (n2 - 2) / (1 - a)) rounded.
	^n1 > 0 
	    ifTrue: [self degreeOfFreedom: n1 degreeOfFreedom: n2]
	    ifFalse: [nil]
    ]

    DhbFisherSnedecorDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbFisherSnedecorDistribution class >> test: aStatisticalMoment1 with: aStatisticalMoment2 [
	"Perform a consistency Fisher test (or F-test) on the variances of two statistical moments ( or histograms).
	 Answer the probability of passing the test.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^(self class degreeOfFreedom: aStatisticalMoment1 count
	    degreeOfFreedom: aStatisticalMoment2 count) 
		distributionValue: aStatisticalMoment1 variance 
			/ aStatisticalMoment2 variance
    ]

    DhbFisherSnedecorDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Fisher-Snedecor distribution'
    ]

    average [
	"Answer the average of the receiver.
	 Undefined if dof2 is smaller than 3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^dof2 > 2 ifTrue: [dof2 / (dof2 - 2)] ifFalse: [nil]
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a value
	 distributed according to the receiver outside of the
	 interval [ 1/aNumber, aNumber].
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	aNumber < 0 
	    ifTrue: [self error: 'Confidence level argument must be positive'].
	^(1 - (self acceptanceBetween: aNumber reciprocal and: aNumber)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^1 - (self incompleteBetaFunction value: dof2 / (aNumber * dof1 + dof2))
    ]

    incompleteBetaFunction [
	"Private - Answers the incomplete beta function used to compute
	 the symmetric acceptance integral of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction shape: dof2 / 2
			    shape: dof1 / 2].
	^incompleteBetaFunction
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: dof1 with: dof2
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	chiSquareDistribution1 isNil 
	    ifTrue: 
		[chiSquareDistribution1 := DhbChiSquareDistribution degreeOfFreedom: dof1.
		chiSquareDistribution2 := DhbChiSquareDistribution degreeOfFreedom: dof2].
	^chiSquareDistribution1 random * dof2 
	    / (chiSquareDistribution2 random * dof1)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: 
		[(norm + (aNumber ln * (dof1 / 2 - 1)) 
		    - ((aNumber * dof1 + dof2) ln * ((dof1 + dof2) / 2))) exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 Undefined if dof2 is smaller than 5.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^dof2 > 4 
	    ifTrue: 
		[dof2 squared * 2 * (dof1 + dof2 - 2) 
		    / ((dof2 - 2) squared * dof1 * (dof2 - 4))]
	    ifFalse: [nil]
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	norm := dof1 ln * (dof1 / 2) + (dof2 ln * (dof2 / 2)) 
		    - (dof1 / 2 logBeta: dof2 / 2)
    ]

    initialize: anInteger1 and: anInteger2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	dof1 := anInteger1.
	dof2 := anInteger2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	dof1 := dof1 + (aVector at: 1) max: 1.
	dof2 := dof2 + (aVector at: 2) max: 1.
	self computeNorm.
	chiSquareDistribution1 := nil.
	chiSquareDistribution2 := nil.
	incompleteBetaFunction := nil
    ]
]



DhbGammaDistribution subclass: DhbChiSquareDistribution [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbChiSquareDistribution class >> degreeOfFreedom: anInteger [
	"Create a new instance of the receiver with given degree of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^anInteger > 40 
	    ifTrue: [DhbAsymptoticChiSquareDistribution degreeOfFreedom: anInteger]
	    ifFalse: [super shape: anInteger / 2 scale: 2]
    ]

    DhbChiSquareDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| dof |
	aHistogram minimum < 0 ifTrue: [^nil].
	dof := aHistogram average rounded.
	^dof > 0 
	    ifTrue: [self degreeOfFreedom: aHistogram average rounded]
	    ifFalse: [nil]
    ]

    DhbChiSquareDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbChiSquareDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Chi square distribution'
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a chi square value
	 distributed according to the receiver larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	^(1 - (self distributionValue: aNumber)) * 100
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha * 2
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 13/4/99"

	<category: 'transformation'>
	super changeParametersBy: (Array with: aVector first / 2 with: 0)
    ]
]



DhbProbabilityDensity subclass: DhbAsymptoticChiSquareDistribution [
    | degreeOfFreedom reducedDOF normalDistribution |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbAsymptoticChiSquareDistribution class >> degreeOfFreedom: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	^super new initialize: anInteger
    ]

    DhbAsymptoticChiSquareDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbAsymptoticChiSquareDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^'Chi square distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^degreeOfFreedom
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a chi square value
	 distributed according to the receiver larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	^(1 - (self distributionValue: aNumber)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	| x |
	^aNumber > 0 
	    ifTrue: 
		[x := (aNumber * 2) sqrt.
		DhbErfApproximation new value: x - reducedDOF]
	    ifFalse: [0]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^12 / degreeOfFreedom
    ]

    parameters [
	"Returns an Array containing the parameters of the distribution.
	 It is used to print out the distribution and for fitting.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: degreeOfFreedom
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbNormalDistribution random + reducedDOF) squared / 2
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^(2 / degreeOfFreedom) sqrt * 2
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	| x |
	^aNumber > 0 
	    ifTrue: 
		[x := (aNumber * 2) sqrt.
		(DhbErfApproximation new normal: x - reducedDOF) / x]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^degreeOfFreedom * 2
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'initialization'>
	degreeOfFreedom := anInteger.
	reducedDOF := (degreeOfFreedom * 2 - 1) sqrt.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	normalDistribution changeParametersBy: aVector
    ]
]



DhbProbabilityDensity subclass: DhbHistogrammedDistribution [
    | histogram |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbHistogrammedDistribution class >> histogram: aHistogram [
	"Create a new instance of the receiver corresponding to a histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'creation'>
	^super new initialize: aHistogram
    ]

    DhbHistogrammedDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbHistogrammedDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Experimental distribution'
    ]

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(histogram countsBetween: (aNumber1 max: histogram minimum)
	    and: (aNumber2 min: histogram maximum)) / histogram totalCount
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram average
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber < histogram minimum 
	    ifTrue: [0]
	    ifFalse: 
		[aNumber < histogram maximum 
		    ifTrue: [(histogram countsUpTo: aNumber) / histogram totalCount]
		    ifFalse: [1]]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^histogram kurtosis
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose distribution is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram inverseDistributionValue: aNumber
    ]

    skewness [
	"Answer the skewness of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^histogram skewness
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram standardDeviation
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^(aNumber >= histogram minimum and: [aNumber < histogram maximum]) 
	    ifTrue: 
		[(histogram countAt: aNumber) / (histogram totalCount * histogram binWidth)]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram variance
    ]

    initialize: aHistogram [
	"Private - Defines the histogram of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'initialization'>
	aHistogram count = 0 
	    ifTrue: 
		[self error: 'Cannot define probability density on an empty histogram'].
	histogram := aHistogram.
	^self
    ]
]



DhbProbabilityDensity subclass: DhbNormalDistribution [
    | mu sigma nextRandom |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    NextRandom := nil.

    DhbNormalDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self new: aHistogram average sigma: aHistogram standardDeviation
    ]

    DhbNormalDistribution class >> new [
	"Create a new instance of the receiver with mu=0 and sigma=1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self new: 0 sigma: 1
    ]

    DhbNormalDistribution class >> new: aNumber1 sigma: aNumber2 [
	"Create a new instance of the receiver with given mu and sigma.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 sigma: aNumber2
    ]

    DhbNormalDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Normal distribution'
    ]

    DhbNormalDistribution class >> random [
	"Answer a random number distributed according to a (0,1) normal distribution.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| v1 v2 w y |
	NextRandom isNil 
	    ifTrue: 
		[
		[v1 := Number random * 2 - 1.
		v2 := Number random * 2 - 1.
		w := v1 squared + v2 squared.
		w > 1] 
			whileTrue: [].
		y := (w ln * 2 negated / w) sqrt.
		v1 := y * v1.
		NextRandom := y * v2]
	    ifFalse: 
		[v1 := NextRandom.
		NextRandom := nil].
	^v1
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^mu
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^DhbErfApproximation new value: (aNumber - mu) / sigma
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: sigma
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self class random * sigma + mu
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^sigma
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbErfApproximation new normal: (aNumber - mu) / sigma) / sigma
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| dp y |
	y := (aNumber - mu) / sigma.
	dp := (DhbErfApproximation new normal: y) / sigma.
	^Array with: dp
	    with: (DhbVector with: dp * y / sigma with: dp * (y squared - 1) / sigma)
    ]

    initialize: aNumber1 sigma: aNumber2 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	sigma := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	sigma := sigma + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbStudentDistribution [
    | degreeOfFreedom norm chiSquareDistribution incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbStudentDistribution class >> asymptoticLimit [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/4/99"

	<category: 'creation'>
	^30
    ]

    DhbStudentDistribution class >> degreeOfFreedom: anInteger [
	"Create a new instance of the receiver with anInteger degrees of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^anInteger > self asymptoticLimit 
	    ifTrue: [DhbNormalDistribution new]
	    ifFalse: 
		[anInteger = 1 
		    ifTrue: [DhbCauchyDistribution shape: 0 scale: 1]
		    ifFalse: [super new initialize: anInteger]]
    ]

    DhbStudentDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	| dof var |
	var := aHistogram variance.
	var = 0 ifTrue: [^nil].
	dof := (2 / (1 - (1 / aHistogram variance))) rounded max: 1.
	^dof > self asymptoticLimit 
	    ifTrue: [nil]
	    ifFalse: [self degreeOfFreedom: dof]
    ]

    DhbStudentDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbStudentDistribution class >> test: aStatisticalMoment1 with: aStatisticalMoment2 [
	"Preform a consistency Student test (or t-test) on the averages of  two statistical moments ( or histograms).
	 Answers the probability of failing the test.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	| t |
	t := (aStatisticalMoment1 average - aStatisticalMoment2 average) abs.
	^1 
	    - ((self class 
		    degreeOfFreedom: aStatisticalMoment1 count + aStatisticalMoment2 count - 2) 
			acceptanceBetween: t negated
			and: t)
    ]

    DhbStudentDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Student distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^0
    ]

    chiSquareDistribution [
	"Private - Answer the chi square distribution used to generate
	 random numbers for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	chiSquareDistribution isNil 
	    ifTrue: 
		[chiSquareDistribution := DhbChiSquareDistribution 
			    degreeOfFreedom: degreeOfFreedom - 1].
	^chiSquareDistribution
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a value
	 distributed according to the receiver with an absolute value
	 larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^(1 - (self symmetricAcceptance: aNumber abs)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	aNumber = 0 ifTrue: [^1 / 2].
	^(aNumber > 0 
	    ifTrue: [2 - (self symmetricAcceptance: aNumber abs)]
	    ifFalse: [self symmetricAcceptance: aNumber abs]) / 2
    ]

    incompleteBetaFunction [
	"Private - Answers the incomplete beta function used to compute
	 the symmetric acceptance integral of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction 
			    shape: degreeOfFreedom / 2
			    shape: 0.5].
	^incompleteBetaFunction
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined if the degree of freedom is less than 5.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^degreeOfFreedom > 4 ifTrue: [6 / (degreeOfFreedom - 4)] ifFalse: [nil]
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: degreeOfFreedom
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^DhbNormalDistribution random 
	    * ((degreeOfFreedom - 1) / self chiSquareDistribution random) sqrt
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    symmetricAcceptance: aNumber [
	"Private - Compute the acceptance of the receiver between -aNumber and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^self incompleteBetaFunction 
	    value: degreeOfFreedom / (aNumber squared + degreeOfFreedom)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(norm 
	    - ((aNumber squared / degreeOfFreedom + 1) ln * ((degreeOfFreedom + 1) / 2))) 
		exp
    ]

    variance [
	"Answer the variance of the receiver.
	 Undefined if the degree of freedom is less than 3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^degreeOfFreedom > 2 
	    ifTrue: [degreeOfFreedom / (degreeOfFreedom - 2)]
	    ifFalse: [nil]
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	norm := ((degreeOfFreedom / 2 logBeta: 1 / 2) + (degreeOfFreedom ln / 2)) 
		    negated
    ]

    initialize: anInteger [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	anInteger > 0 ifFalse: [self error: 'Degree of freedom must be positive'].
	degreeOfFreedom := anInteger.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	degreeOfFreedom := degreeOfFreedom + (aVector at: 1).
	self computeNorm
    ]
]

