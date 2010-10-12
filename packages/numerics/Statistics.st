"======================================================================
|
|   Numerical methods - Statistics
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



Object subclass: DhbStatisticalMoments [
    | moments |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbStatisticalMoments class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'creation'>
	^self new: 4
    ]

    DhbStatisticalMoments class >> new: anInteger [
	"anInteger is the degree of the highest central moments
	 accumulated within the created instance.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'creation'>
	^super new initialize: anInteger + 1
    ]

    asWeightedPoint: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^DhbWeightedPoint point: aNumber @ self average error: self errorOnAverage
    ]

    average [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	self count = 0 ifTrue: [^nil].
	^moments at: 2
    ]

    centralMoment: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/6/99"

	<category: 'information'>
	^moments at: anInteger + 1
    ]

    count [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/6/99"

	<category: 'information'>
	^moments at: 1
    ]

    errorOnAverage [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 02-Jan-00"

	<category: 'information'>
	^(self variance / self count) sqrt
    ]

    kurtosis [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n n1 n23 |
	n := self count.
	n < 4 ifTrue: [^nil].
	n23 := (n - 2) * (n - 3).
	n1 := n - 1.
	^((moments at: 5) * n squared * (n + 1) / (self variance squared * n1) 
	    - (n1 squared * 3)) / n23
    ]

    skewness [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n v |
	n := self count.
	n < 3 ifTrue: [^nil].
	v := self variance.
	^(moments at: 4) * n squared / ((n - 1) * (n - 2) * (v sqrt * v))
    ]

    standardDeviation [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	^self variance sqrt
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^(self centralMoment: 2) * self count
    ]

    variance [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n |
	n := self count.
	n < 2 ifTrue: [^nil].
	^self unnormalizedVariance / (n - 1)
    ]

    initialize: anInteger [
	"Private - ( anInteger - 1) is the degree of the highest accumulated central moment.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'initialization'>
	moments := Array new: anInteger.
	self reset.
	^self
    ]

    fConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	| fValue |
	fValue := self variance / aStatisticalMomentsOrHistogram variance.
	^fValue < 1 
	    ifTrue: 
		[(DhbFisherSnedecorDistribution 
		    degreeOfFreedom: aStatisticalMomentsOrHistogram count
		    degreeOfFreedom: self count) confidenceLevel: fValue reciprocal]
	    ifFalse: 
		[(DhbFisherSnedecorDistribution degreeOfFreedom: self count
		    degreeOfFreedom: aStatisticalMomentsOrHistogram count) 
			confidenceLevel: fValue]
    ]

    tConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	| sbar dof |
	dof := self count + aStatisticalMomentsOrHistogram count - 2.
	sbar := ((self unnormalizedVariance 
		    + aStatisticalMomentsOrHistogram unnormalizedVariance) / dof) 
		    sqrt.
	^(DhbStudentDistribution degreeOfFreedom: dof) 
	    confidenceLevel: (self average - aStatisticalMomentsOrHistogram average) 
		    / ((1 / self count + (1 / aStatisticalMomentsOrHistogram count)) sqrt 
			    * sbar)
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'transformation'>
	| correction n n1 oldSums pascal nTerm cTerm term |
	n := moments at: 1.
	n1 := n + 1.
	correction := ((moments at: 2) - aNumber) / n1.
	oldSums := moments copyFrom: 1 to: moments size.
	moments
	    at: 1 put: n1;
	    at: 2 put: (moments at: 2) - correction.
	pascal := Array new: moments size.
	pascal atAllPut: 0.
	pascal
	    at: 1 put: 1;
	    at: 2 put: 1.
	nTerm := -1.
	cTerm := correction.
	n1 := n / n1.
	n := n negated.
	3 to: moments size
	    do: 
		[:k | 
		cTerm := cTerm * correction.
		nTerm := n * nTerm.
		term := cTerm * (1 + nTerm).
		k to: 3
		    by: -1
		    do: 
			[:l | 
			pascal at: l put: (pascal at: l - 1) + (pascal at: l).
			term := (pascal at: l) * (oldSums at: l) + term.
			oldSums at: l put: (oldSums at: l) * correction].
		pascal at: 2 put: (pascal at: 1) + (pascal at: 2).
		moments at: k put: term * n1]
    ]

    reset [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'transformation'>
	moments atAllPut: 0
    ]
]



Object subclass: DhbMahalanobisCenter [
    | center inverseCovariance accumulator |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMahalanobisCenter class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    DhbMahalanobisCenter class >> onVector: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new center: aVector
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator count printOn: aStream.
	aStream nextPutAll: ': '.
	center printOn: aStream
    ]

    count [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator count
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	| delta |
	delta := aVector - center.
	^delta * inverseCovariance * delta
    ]

    center: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := DhbCovarianceAccumulator new: aVector size.
	center := aVector.
	inverseCovariance := DhbSymmetricMatrix identity: aVector size.
	^self
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := DhbCovarianceAccumulator new: anInteger.
	^self
    ]

    accumulate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator accumulate: aVector
    ]

    computeParameters [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	center := accumulator average copy.
	inverseCovariance := accumulator covarianceMatrix inverse
    ]

    reset [
	"Leave center and inverse covariant matrix untouched
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator reset
    ]
]



Object subclass: DhbVectorAccumulator [
    | count average |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbVectorAccumulator class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	super printOn: aStream.
	aStream space.
	count printOn: aStream.
	aStream space.
	average printOn: aStream
    ]

    average [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^average
    ]

    count [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^count
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	average := DhbVector new: anInteger.
	self reset.
	^self
    ]

    accumulate: aVectorOrArray [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	| delta |
	count := count + 1.
	delta := average - aVectorOrArray asVector scaleBy: 1 / count.
	average accumulateNegated: delta.
	^delta
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	count := 0.
	average atAllPut: 0
    ]
]



DhbIterativeProcess subclass: DhbClusterFinder [
    | dataServer dataSetSize minimumRelativeClusterSize |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbClusterFinder class >> new: anInteger server: aClusterDataServer type: aClusterClass [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'creation'>
	^super new 
	    initialize: anInteger
	    server: aClusterDataServer
	    type: aClusterClass
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	aStream nextPutAll: 'Iterations: '.
	iterations printOn: aStream.
	result do: 
		[:each | 
		aStream cr.
		each printOn: aStream]
    ]

    clusters: aCollectionOfClusters [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/18/00"

	<category: 'information'>
	result := aCollectionOfClusters
    ]

    indexOfNearestCluster: aVector [
	"Private - Answers the index of the cluster nearest to aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	| distance index |
	index := 1.
	distance := (result at: 1) distanceTo: aVector.
	2 to: result size
	    do: 
		[:n | 
		| x |
		x := (result at: n) distanceTo: aVector.
		x < distance 
		    ifTrue: 
			[distance := x.
			index := n]].
	^index
    ]

    initialize: anInteger server: aClusterDataServer type: aClusterClass [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	self dataServer: aClusterDataServer.
	self clusters: ((1 to: anInteger) collect: [:n | aClusterClass new]).
	minimumRelativeClusterSize := 0.
	^self
    ]

    minimumClusterSize [
	<category: 'information'>
	^(minimumRelativeClusterSize * dataSetSize) rounded
    ]

    dataServer: aClusterDataServer [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/18/00"

	<category: 'initialization'>
	dataServer := aClusterDataServer
    ]

    minimumRelativeClusterSize: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	minimumRelativeClusterSize := aNumber max: 0
    ]

    evaluateIteration [
	"Perform an accumulation of the data from the server.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer reset.
	dataSetSize := 0.
	[dataServer atEnd] whileFalse: 
		[self accumulate: dataServer next.
		dataSetSize := dataSetSize + 1].
	^self collectChangesAndResetClusters
    ]

    finalizeIterations [
	"Close the data server.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer close
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer open.
	result 
	    do: [:each | each isUndefined ifTrue: [each centerOn: dataServer next]]
    ]

    accumulate: aVector [
	"Private - Accumulate aVector into the nearest cluster.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'transformation'>
	(result at: (self indexOfNearestCluster: aVector)) accumulate: aVector
    ]

    collectChangesAndResetClusters [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	| hasEmptyClusters changes |
	changes := 0.
	hasEmptyClusters := false.
	result do: 
		[:each | 
		changes := each changes + changes.
		(each isInsignificantIn: self) 
		    ifTrue: 
			[each centerOn: nil.
			hasEmptyClusters := true]
		    ifFalse: [each reset]].
	hasEmptyClusters 
	    ifTrue: [result := result reject: [:each | each isUndefined]].
	^changes / 2
    ]
]



DhbStatisticalMoments subclass: DhbFastStatisticalMoments [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    average [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	self count = 0 ifTrue: [^nil].
	^(moments at: 2) / self count
    ]

    kurtosis [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| var x1 x2 x3 x4 kFact kConst n m4 xSquared |
	n := self count.
	n < 4 ifTrue: [^nil].
	var := self variance.
	var = 0 ifTrue: [^nil].
	x1 := (moments at: 2) / n.
	x2 := (moments at: 3) / n.
	x3 := (moments at: 4) / n.
	x4 := (moments at: 5) / n.
	xSquared := x1 squared.
	m4 := x4 - (4 * x1 * x3) + (6 * x2 * xSquared) - (xSquared squared * 3).
	kFact := n * (n + 1) / (n - 1) / (n - 2) / (n - 3).
	kConst := 3 * (n - 1) * (n - 1) / (n - 2) / (n - 3).
	^kFact * (m4 * n / var squared) - kConst
    ]

    skewness [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| x1 x2 x3 n stdev |
	n := self count.
	n < 3 ifTrue: [^nil].
	stdev := self standardDeviation.
	stdev = 0 ifTrue: [^nil].
	x1 := (moments at: 2) / n.
	x2 := (moments at: 3) / n.
	x3 := (moments at: 4) / n.
	^(x3 - (3 * x1 * x2) + (2 * x1 * x1 * x1)) * n * n 
	    / (stdev squared * stdev * (n - 1) * (n - 2))
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^(moments at: 3) - ((moments at: 2) squared * self count)
    ]

    variance [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| n |
	n := self count.
	n < 2 ifTrue: [^nil].
	^((moments at: 3) - ((moments at: 2) squared / n)) / (n - 1)
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'transformation'>
	| var |
	var := 1.
	1 to: moments size
	    do: 
		[:n | 
		moments at: n put: (moments at: n) + var.
		var := var * aNumber]
    ]
]



DhbIterativeProcess subclass: DhbLeastSquareFit [
    | dataHolder errorMatrix chiSquare equations constants degreeOfFreedom |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbLeastSquareFit class >> histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'creation'>
	^self points: aHistogram
	    function: (DhbScaledProbabilityDensityFunction histogram: aHistogram
		    distributionClass: aProbabilityDensityFunctionClass)
    ]

    DhbLeastSquareFit class >> points: aDataHolder function: aParametricFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'creation'>
	^aParametricFunction isNil 
	    ifTrue: [nil]
	    ifFalse: [super new initialize: aDataHolder data: aParametricFunction]
    ]

    chiSquare [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	chiSquare isNil ifTrue: [self computeChiSquare].
	^chiSquare
    ]

    computeChiSquare [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	chiSquare := 0.
	degreeOfFreedom := self numberOfFreeParameters negated.
	dataHolder pointsAndErrorsDo: 
		[:each | 
		chiSquare := (each chi2Contribution: result) + chiSquare.
		degreeOfFreedom := degreeOfFreedom + 1]
    ]

    confidenceLevel [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/6/00"

	<category: 'information'>
	^(DhbChiSquareDistribution degreeOfFreedom: self degreeOfFreedom) 
	    confidenceLevel: self chiSquare
    ]

    degreeOfFreedom [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	degreeOfFreedom isNil ifTrue: [self computeChiSquare].
	^degreeOfFreedom
    ]

    errorMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^DhbSymmetricMatrix rows: errorMatrix inverseMatrixComponents
    ]

    fitType [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^'Least square fit'
    ]

    numberOfFreeParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^self numberOfParameters
    ]

    numberOfParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^result parameters size
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	^result value: aNumber
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	| valueGradient |
	valueGradient := result valueAndGradient: aNumber.
	^Array with: valueGradient first
	    with: (valueGradient last * (self errorMatrix * valueGradient last)) sqrt
    ]

    initialize: aDataHolder data: aParametricFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'initialization'>
	dataHolder := aDataHolder.
	result := aParametricFunction.
	^self
    ]

    accumulate: aWeightedPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	| f g |
	f := result valueAndGradient: aWeightedPoint xValue.
	g := f last.
	f := f first.
	constants 
	    accumulate: g * ((aWeightedPoint yValue - f) * aWeightedPoint weight).
	1 to: g size
	    do: [:k | (equations at: k) accumulate: g * ((g at: k) * aWeightedPoint weight)]
    ]

    accumulateEquationSystem [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	dataHolder pointsAndErrorsDo: [:each | self accumulate: each]
    ]

    computeChanges [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	errorMatrix := DhbLUPDecomposition direct: equations.
	^errorMatrix solve: constants
    ]

    computeEquationSystem [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	constants atAllPut: 0.
	equations do: [:each | each atAllPut: 0].
	self accumulateEquationSystem
    ]

    evaluateIteration [
	"Dummy method (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| changes maxChange |
	self computeEquationSystem.
	changes := self computeChanges.
	result changeParametersBy: changes.
	maxChange := 0.
	result parameters with: changes
	    do: [:r :d | maxChange := (d / r) abs max: maxChange].
	^maxChange
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	equations := nil.
	constants := nil.
	degreeOfFreedom := nil.
	chiSquare := nil
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| n |
	n := self numberOfParameters.
	constants := (DhbVector new: n)
		    atAllPut: 0;
		    yourself.
	equations := (1 to: n) collect: 
			[:k | 
			(DhbVector new: n)
			    atAllPut: 0;
			    yourself]
    ]
]



Object subclass: DhbHistogram [
    | minimum binWidth overflow underflow moments contents freeExtent cacheSize desiredNumberOfBins |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbHistogram class >> new [
	"Create a standard new instance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbHistogram class >> defaultCacheSize [
	"Private - Answer the default cache size.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^100
    ]

    DhbHistogram class >> defaultNumberOfBins [
	"Private - Defines the default number of bins for instances of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^50
    ]

    DhbHistogram class >> integerScales [
	"Private - Scales for strict integers"

	<category: 'information'>
	^#(2 4 5 8 10)
    ]

    DhbHistogram class >> scales [
	"Private - Scales for any number"

	<category: 'information'>
	^#(1.25 2 2.5 4 5 7.5 8 10)
    ]

    DhbHistogram class >> semiIntegerScales [
	"Private - Scales for large integers"

	<category: 'information'>
	^#(2 2.5 4 5 7.5 8 10)
    ]

    average [
	"Answer the average of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments average
    ]

    binIndex: aNumber [
	"Answers the index of the bin corresponding to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^((aNumber - minimum) / binWidth) floor + 1
    ]

    binWidth [
	"Answer the bin width for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^binWidth
    ]

    chi2Against: aScaledDistribution [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/30/00"

	<category: 'information'>
	| chi2 |
	chi2 := 0.
	self pointsAndErrorsDo: 
		[:each | 
		chi2 := (each chi2Contribution: aScaledDistribution) + chi2].
	^chi2
    ]

    chi2ConfidenceLevelAgainst: aScaledDistribution [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/30/00"

	<category: 'information'>
	^(DhbChiSquareDistribution 
	    degreeOfFreedom: contents size - aScaledDistribution parameters size) 
		confidenceLevel: (self chi2Against: aScaledDistribution)
    ]

    collectIntegralPoints: aBlock [
	"Collects the points needed to display the receiver as an integral.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	| answer bin lastContents integral norm x |
	self isCached ifTrue: [self flushCache].
	answer := OrderedCollection new: contents size * 2 + 1.
	bin := self minimum.
	answer add: (aBlock value: bin @ 0).
	integral := self underflow.
	norm := self totalCount.
	contents do: 
		[:each | 
		integral := integral + each.
		x := integral / norm.
		answer add: (aBlock value: bin @ x).
		bin := bin + binWidth.
		answer add: (aBlock value: bin @ x)].
	answer add: (aBlock value: bin @ 0).
	^answer asArray
    ]

    collectPoints: aBlock [
	"Collects the points needed to display the receiver.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| answer bin lastContents |
	self isCached ifTrue: [self flushCache].
	answer := OrderedCollection new: contents size * 2 + 1.
	bin := self minimum.
	answer add: (aBlock value: bin @ 0).
	contents do: 
		[:each | 
		answer add: (aBlock value: bin @ each).
		bin := bin + binWidth.
		answer add: (aBlock value: bin @ each)].
	answer add: (aBlock value: bin @ 0).
	^answer asArray
    ]

    count [
	"Answer the count of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments count
    ]

    countAt: aNumber [
	"Answer the count in the bin corresponding to aNumber or 0 if outside the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n |
	n := self binIndex: aNumber.
	^(n between: 1 and: contents size) ifTrue: [contents at: n] ifFalse: [0]
    ]

    countsBetween: aNumber1 and: aNumber2 [
	"Computes the events located between aNumber1 and aNumber2.
	 NOTE: This method assumes the two numbers are within the limits
	 of the receiver and that the receiver is not cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n1 n2 answer |
	n1 := self binIndex: aNumber1.
	n2 := self binIndex: aNumber2.
	answer := (contents at: n1) * (binWidth * n1 + minimum - aNumber1) 
		    / binWidth.
	n2 > contents size 
	    ifTrue: [n2 := contents size + 1]
	    ifFalse: 
		[answer := answer 
			    + ((contents at: n2) * (aNumber2 - (binWidth * (n2 - 1) + self maximum)) 
				    / binWidth)].
	n1 + 1 to: n2 - 1 do: [:n | answer := answer + (contents at: n)].
	^answer
    ]

    countsUpTo: aNumber [
	"Computes the events located up to aNumber.
	 NOTE: This method assumes aNumber is within the limits
	 of the receiver and that the receiver is not cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n answer |
	n := self binIndex: aNumber.
	n > contents size ifTrue: [^self count].
	answer := (contents at: n) 
		    * (aNumber - (binWidth * (n - 1) + self minimum)) / binWidth.
	1 to: n - 1 do: [:m | answer := answer + (contents at: m)].
	^answer + underflow
    ]

    errorOnAverage [
	"Answer the error on the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments errorOnAverage
    ]

    inverseDistributionValue: aNumber [
	"Private - Compute the value which corresponds to a integrated count of aNumber.
	 NOTE: aNumber is assumed to be between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'information'>
	| count x integral |
	count := self count * aNumber.
	x := self minimum.
	integral := 0.
	contents do: 
		[:each | 
		| delta |
		delta := count - integral.
		each > delta ifTrue: [^self binWidth * delta / each + x].
		integral := integral + each.
		x := self binWidth + x].
	^self maximum
    ]

    isCached [
	"Private - Answer true if the content of the receiver is cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^binWidth isNil
    ]

    isEmpty [
	"Always false.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^false
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments kurtosis
    ]

    lowBinLimitAt: anInteger [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^(anInteger - 1) * binWidth + minimum
    ]

    maximum [
	"Answer the minimum for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^contents size * binWidth + minimum
    ]

    maximumCount [
	"Answer the maximum count of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^contents inject: (contents isEmpty ifTrue: [1] ifFalse: [contents at: 1])
	    into: [:max :each | max max: each]
    ]

    minimum [
	"Answer the minimum for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^minimum
    ]

    overflow [
	"Answer the overflow of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^overflow
    ]

    roundToScale: aNumber [
	"Private - Adjust aNumber of the lowest upper scale"

	<category: 'information'>
	| orderOfMagnitude norm scales rValue |
	orderOfMagnitude := (aNumber log: 10) floor.
	scales := self class scales.
	aNumber isInteger 
	    ifTrue: 
		[orderOfMagnitude < 1 ifTrue: [orderOfMagnitude := 1].
		orderOfMagnitude = 1 ifTrue: [scales := self class integerScales].
		orderOfMagnitude = 2 ifTrue: [scales := self class semiIntegerScales]].
	norm := 10 raisedToInteger: orderOfMagnitude.
	rValue := aNumber / norm.
	^(scales detect: [:each | rValue <= each]) * norm
    ]

    skewness [
	"Answer the skewness of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments skewness
    ]

    standardDeviation [
	"Answer the standardDeviation of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments standardDeviation
    ]

    totalCount [
	"Answer the count of the recevier, inclusing underflow and overflow
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments count + underflow + overflow
    ]

    underflow [
	"Answer the underflow of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^underflow
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^moments unnormalizedVariance
    ]

    variance [
	"Answer the variance of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments variance
    ]

    freeExtent: aBoolean [
	"Defines the range of the receiver to be freely adjustable.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	(underflow = 0 and: [overflow = 0]) 
	    ifFalse: [self error: 'Histogram extent cannot be redefined'].
	freeExtent := aBoolean
    ]

    initialize [
	"Private - initializes the receiver with standard settings.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	freeExtent := false.
	cacheSize := self class defaultCacheSize.
	desiredNumberOfBins := self class defaultNumberOfBins.
	contents := OrderedCollection new: cacheSize.
	moments := DhbFixedStatisticalMoments new.
	overflow := 0.
	underflow := 0.
	^self
    ]

    setDesiredNumberOfBins: anInteger [
	"Defines the desired number of bins. It may be adjusted to a few units later on.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	anInteger > 0 
	    ifFalse: [self error: 'Desired number of bins must be positive'].
	desiredNumberOfBins := anInteger
    ]

    setRangeFrom: aNumber1 to: aNumber2 bins: anInteger [
	"Defines the range of the receiver by specifying the minimum, maximum and number of bins.
	 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	self isCached 
	    ifFalse: [self error: 'Histogram limits cannot be redefined'].
	minimum := aNumber1.
	self
	    setDesiredNumberOfBins: anInteger;
	    adjustDimensionUpTo: aNumber2
    ]

    setWidth: aNumber1 from: aNumber2 bins: anInteger [
	"Defines the range of the receiver by specifying the minimum, bin width and number of bins.
	 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	self isCached 
	    ifFalse: [self error: 'Histogram limits cannot be redefined'].
	minimum := aNumber2.
	self
	    setDesiredNumberOfBins: anInteger;
	    adjustDimensionUpTo: aNumber1 * anInteger + aNumber2
    ]

    pointsAndErrorsDo: aBlock [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'iterators'>
	| x |
	x := self minimum - (self binWidth / 2).
	contents do: 
		[:each | 
		x := x + self binWidth.
		aBlock value: (DhbWeightedPoint point: x count: each)]
    ]

    fConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	^moments fConfidenceLevel: aStatisticalMomentsOrHistogram
    ]

    tConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	^moments tConfidenceLevel: aStatisticalMomentsOrHistogram
    ]

    accumulate: aNumber [
	"Accumulate aNumber into the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| bin |
	self isCached ifTrue: [^self accumulateInCache: aNumber].
	bin := self binIndex: aNumber.
	(bin between: 1 and: contents size) 
	    ifTrue: 
		[contents at: bin put: (contents at: bin) + 1.
		moments accumulate: aNumber]
	    ifFalse: [self processOverflows: bin for: aNumber]
    ]

    accumulateInCache: aNumber [
	"Private - Accumulate aNumber inside a cache
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	contents add: aNumber.
	contents size > cacheSize ifTrue: [self flushCache]
    ]

    adjustDimensionUpTo: aNumber [
	"Private - Compute an adequate bin width and adjust the minimum and number of bins accordingly.
	 aNumber is the maximum value to accumulate. The minimum value has already been assigned.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'transformation'>
	| maximum |
	binWidth := self roundToScale: (aNumber - minimum) / desiredNumberOfBins.
	minimum := (minimum / binWidth) floor * binWidth.
	maximum := (aNumber / binWidth) ceiling * binWidth.
	contents := Array new: ((maximum - minimum) / binWidth) ceiling.
	contents atAllPut: 0
    ]

    countOverflows: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	anInteger > 0 
	    ifTrue: [overflow := overflow + 1]
	    ifFalse: [underflow := underflow + 1]
    ]

    flushCache [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| maximum values |
	minimum isNil 
	    ifTrue: [minimum := contents isEmpty ifTrue: [0] ifFalse: [contents first]].
	maximum := minimum.
	contents do: 
		[:each | 
		each < minimum 
		    ifTrue: [minimum := each]
		    ifFalse: [each > maximum ifTrue: [maximum := each]]].
	maximum = minimum ifTrue: [maximum := minimum + desiredNumberOfBins].
	values := contents.
	self adjustDimensionUpTo: maximum.
	values do: [:each | self accumulate: each]
    ]

    growContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	anInteger > 0 
	    ifTrue: [self growPositiveContents: anInteger]
	    ifFalse: [self growNegativeContents: anInteger]
    ]

    growNegativeContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| n newSize newContents |
	n := 1 - anInteger.
	newSize := contents size + n.
	newContents := Array new: newSize.
	newContents at: 1 put: 1.
	2 to: n do: [:i | newContents at: i put: 0].
	newContents 
	    replaceFrom: n + 1
	    to: newSize
	    with: contents
	    startingAt: 1.
	contents := newContents.
	minimum := (anInteger - 1) * binWidth + minimum
    ]

    growPositiveContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| n newContents |
	n := contents size.
	newContents := Array new: anInteger.
	newContents 
	    replaceFrom: 1
	    to: n
	    with: contents
	    startingAt: 1.
	n + 1 to: anInteger - 1 do: [:i | newContents at: i put: 0].
	newContents at: anInteger put: 1.
	contents := newContents
    ]

    processOverflows: anInteger for: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	freeExtent 
	    ifTrue: 
		[self growContents: anInteger.
		moments accumulate: aNumber]
	    ifFalse: [self countOverflows: anInteger]
    ]
]



Object subclass: DhbCluster [
    | accumulator previousSampleSize |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbCluster class >> new [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^super new initialize
    ]

    changes [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^(self sampleSize - previousSampleSize) abs
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^self subclassResponsibility
    ]

    isInsignificantIn: aClusterFinder [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/17/00"

	<category: 'information'>
	^self sampleSize <= aClusterFinder minimumClusterSize
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^self subclassResponsibility
    ]

    sampleSize [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator count
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	self subclassResponsibility
    ]

    initialize [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	previousSampleSize := 0.
	^self
    ]

    accumulate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator accumulate: aVector
    ]

    collectAccumulatorResults [
	<category: 'transformation'>
	self subclassResponsibility
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	previousSampleSize := self sampleSize.
	self collectAccumulatorResults.
	accumulator reset
    ]
]



Object subclass: DhbAbstractDataServer [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    atEnd [
	"Answers true if there is no more data element.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    close [
	"Close the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	
    ]

    next [
	"Answers the next element on the stream.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]

    open [
	"Open the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]

    reset [
	"Reset the position of the data stream to the beginning.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]
]



Object subclass: DhbPolynomialLeastSquareFit [
    | pointCollection degreePlusOne |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbPolynomialLeastSquareFit class >> new: anInteger [
	"Create a new instance of the receiver with given degree.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'creation'>
	^super new initialize: anInteger
    ]

    DhbPolynomialLeastSquareFit class >> new: anInteger on: aCollectionOfPoints [
	"Create a new instance of the receiver with given degree and points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'creation'>
	^super new initialize: anInteger on: aCollectionOfPoints
    ]

    evaluate [
	"Perform the least square fit and answers the fitted polynomial.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| system errorMatrix |
	system := self computeEquations.
	errorMatrix := (system at: 1) inverse.
	^(DhbEstimatedPolynomial coefficients: errorMatrix * (system at: 2))
	    errorMatrix: errorMatrix;
	    yourself
    ]

    initialize: anInteger [
	"Private - Create an empty point collection for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	^self initialize: anInteger on: OrderedCollection new
    ]

    initialize: anInteger on: aCollectionOfPoints [
	"Private - Defines the collection of points for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	pointCollection := aCollectionOfPoints.
	degreePlusOne := anInteger + 1.
	^self
    ]

    accumulate: aWeightedPoint into: aVectorOfVectors and: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	| t p powers |
	p := 1.0.
	powers := aVector collect: 
			[:each | 
			t := p.
			p := p * aWeightedPoint xValue.
			t].
	aVector 
	    accumulate: powers * (aWeightedPoint yValue * aWeightedPoint weight).
	1 to: aVector size
	    do: 
		[:k | 
		(aVectorOfVectors at: k) 
		    accumulate: powers * ((powers at: k) * aWeightedPoint weight)]
    ]

    add: aWeightedPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	^pointCollection add: aWeightedPoint
    ]

    computeEquations [
	"Private - Answer a pair Matrix/Vector defining the system of equations
	 to solve the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	| rows vector |
	vector := (DhbVector new: degreePlusOne)
		    atAllPut: 0;
		    yourself.
	rows := (1 to: degreePlusOne) collect: 
			[:k | 
			(DhbVector new: degreePlusOne)
			    atAllPut: 0;
			    yourself].
	pointCollection do: 
		[:each | 
		self 
		    accumulate: each
		    into: rows
		    and: vector].
	^Array with: (DhbSymmetricMatrix rows: rows) with: vector
    ]
]



Object subclass: DhbLinearRegression [
    | sum1 sumX sumY sumXX sumYY sumXY slope intercept correlationCoefficient |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLinearRegression class >> new [
	"Create a new instance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'creation'>
	^(super new)
	    reset;
	    yourself
    ]

    asEstimatedPolynomial [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial
	 with embedded error matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	^(DhbEstimatedPolynomial coefficients: self coefficients)
	    errorMatrix: self errorMatrix;
	    yourself
    ]

    asPolynomial [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^DhbPolynomial coefficients: self coefficients
    ]

    coefficients [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	^Array with: self intercept with: self slope
    ]

    correlationCoefficient [
	"Answers the correlation coefficient of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	correlationCoefficient isNil ifTrue: [self computeResults].
	^correlationCoefficient
    ]

    errorMatrix [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial
	 with embedded error matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| c1 cx cxx |
	c1 := 1.0 / (sumXX * sum1 - sumX squared).
	cx := sumX negated * c1.
	cxx := sumXX * c1.
	c1 := sum1 * c1.
	^DhbSymmetricMatrix rows: (Array with: (Array with: cxx with: cx)
		    with: (Array with: cx with: c1))
    ]

    errorOnIntercept [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^(sumXX / (sumXX * sum1 - sumX squared)) sqrt
    ]

    errorOnSlope [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^(sum1 / (sumXX * sum1 - sumX squared)) sqrt
    ]

    intercept [
	"Answers the intercept of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	intercept isNil ifTrue: [self computeResults].
	^intercept
    ]

    slope [
	"Answers the slope of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	slope isNil ifTrue: [self computeResults].
	^slope
    ]

    value: aNumber [
	"Answer the value interpolated at aNumber by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^aNumber * self slope + self intercept
    ]

    add: aPoint [
	"Accumulate aPoint into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	self add: aPoint weight: 1
    ]

    add: aPoint weight: aNumber [
	"Accumulate aPoint into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := sum1 + aNumber.
	sumX := sumX + (aPoint x * aNumber).
	sumY := sumY + (aPoint y * aNumber).
	sumXX := sumXX + (aPoint x squared * aNumber).
	sumYY := sumYY + (aPoint y squared * aNumber).
	sumXY := sumXY + (aPoint x * aPoint y * aNumber).
	self resetResults
    ]

    computeResults [
	"Private - Compute the results of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| xNorm xyNorm |
	xNorm := sumXX * sum1 - (sumX * sumX).
	xyNorm := sumXY * sum1 - (sumX * sumY).
	slope := xyNorm / xNorm.
	intercept := (sumXX * sumY - (sumXY * sumX)) / xNorm.
	correlationCoefficient := xyNorm 
		    / (xNorm * (sumYY * sum1 - (sumY * sumY))) sqrt
    ]

    remove: aPoint [
	"Remove aPoint which was accumulated into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := sum1 - 1.
	sumX := sumX - aPoint x.
	sumY := sumY - aPoint y.
	sumXX := sumXX - aPoint x squared.
	sumYY := sumYY - aPoint y squared.
	sumXY := sumXY - (aPoint x * aPoint y).
	self resetResults
    ]

    reset [
	"Set all accumulators of the receiver to zero and reset its results.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := 0.
	sumX := 0.
	sumY := 0.
	sumXX := 0.
	sumYY := 0.
	sumXY := 0.
	self resetResults
    ]

    resetResults [
	"Private - Reset the results of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	slope := nil.
	intercept := nil.
	correlationCoefficient := nil
    ]
]



DhbVectorAccumulator subclass: DhbCovarianceAccumulator [
    | covariance |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    covarianceMatrix [
	"Answer a matrix containing the covariance of the accumulated data.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'information'>
	| rows n |
	n := 0.
	rows := covariance collect: 
			[:row | 
			n := n + 1.
			row 
			    , ((n + 1 to: covariance size) collect: [:m | (covariance at: m) at: n])].
	^DhbSymmetricMatrix rows: rows
    ]

    initialize: anInteger [
	"Private - Initialize the receiver to accumulate vectors of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'initialization'>
	covariance := ((1 to: anInteger) collect: [:n | DhbVector new: n]) 
		    asVector.
	^super initialize: anInteger
    ]

    accumulate: anArray [
	"Accumulate anArray into the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	| delta count1 r |
	count1 := count.
	delta := super accumulate: anArray.
	r := count1 / count.
	1 to: delta size
	    do: 
		[:n | 
		1 to: n
		    do: 
			[:m | 
			(covariance at: n) at: m
			    put: count1 * (delta at: n) * (delta at: m) 
				    + (r * ((covariance at: n) at: m))]]
    ]

    reset [
	"Set all accumulators to zero.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	super reset.
	covariance do: [:each | each atAllPut: 0]
    ]
]



DhbCluster subclass: DhbCovarianceCluster [
    | center |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	^accumulator distanceTo: aVector
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator printOn: aStream
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator isNil
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := aVector isNil 
		    ifTrue: [nil]
		    ifFalse: [DhbMahalanobisCenter onVector: aVector]
    ]

    collectAccumulatorResults [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator computeParameters
    ]
]



DhbStatisticalMoments subclass: DhbFixedStatisticalMoments [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFixedStatisticalMoments class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'creation'>
	^super new: 4
    ]

    DhbFixedStatisticalMoments class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'transformation'>
	| correction n n1 c2 c3 |
	n := moments at: 1.
	n1 := n + 1.
	correction := ((moments at: 2) - aNumber) / n1.
	c2 := correction squared.
	c3 := c2 * correction.
	moments
	    at: 5
		put: ((moments at: 5) + ((moments at: 4) * correction * 4) 
			+ ((moments at: 3) * c2 * 6) + (c2 squared * (n squared * n + 1))) 
			* n / n1;
	    at: 4
		put: ((moments at: 4) + ((moments at: 3) * correction * 3) 
			+ (c3 * (1 - n squared))) * n 
			/ n1;
	    at: 3 put: ((moments at: 3) + (c2 * (1 + n))) * n / n1;
	    at: 2 put: (moments at: 2) - correction;
	    at: 1 put: n1
    ]
]



DhbCluster subclass: DhbEuclideanCluster [
    | center |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator count printOn: aStream.
	aStream nextPutAll: ': '.
	center printOn: aStream
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^(aVector - center) norm
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	center := aVector.
	accumulator := DhbVectorAccumulator new: aVector size
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	^center isNil
    ]

    collectAccumulatorResults [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	center := accumulator average copy
    ]
]



DhbLeastSquareFit subclass: DhbMaximumLikekihoodHistogramFit [
    | count countVariance |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    fitType [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^'Maximum likelihood fit'
    ]

    normalization [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/12/00"

	<category: 'information'>
	^count
    ]

    normalizationError [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/12/00"

	<category: 'information'>
	^countVariance sqrt
    ]

    numberOfFreeParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^super numberOfParameters
    ]

    numberOfParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^super numberOfParameters - 1
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	| valueGradient gradient gVar |
	valueGradient := result valueAndGradient: aNumber.
	gradient := valueGradient last copyFrom: 1 to: valueGradient last size - 1.
	gVar := gradient * (self errorMatrix * gradient) / count.
	^Array with: valueGradient first
	    with: ((valueGradient first / count) squared * countVariance + gVar) sqrt
    ]

    accumulate: aWeightedPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	| f g temp inverseProbability |
	f := result valueAndGradient: aWeightedPoint xValue.
	g := f last copyFrom: 1 to: f last size - 1.
	f := f first.
	f = 0 ifTrue: [^nil].
	inverseProbability := 1 / f.
	temp := aWeightedPoint yValue * inverseProbability.
	constants accumulate: g * temp.
	temp := temp * inverseProbability.
	1 to: g size
	    do: [:k | (equations at: k) accumulate: g * ((g at: k) * temp)]
    ]

    computeChanges [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	^super computeChanges copyWith: 0
    ]

    computeNormalization [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	| numerator denominator temp |
	numerator := 0.
	denominator := 0.
	dataHolder pointsAndErrorsDo: 
		[:each | 
		temp := result value: each xValue.
		temp = 0 
		    ifFalse: 
			[numerator := numerator + (each yValue squared / temp).
			denominator := denominator + temp]].
	count := (numerator / denominator) sqrt.
	countVariance := numerator / (4 * count)
    ]

    finalizeIterations [
	"Compute the normalization factor.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self computeNormalization.
	result setCount: count.
	super finalizeIterations
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	result setCount: 1.
	count := dataHolder totalCount.
	super initializeIterations
    ]
]



Object subclass: DhbScaledProbabilityDensityFunction [
    | probabilityDensityFunction count binWidth |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbScaledProbabilityDensityFunction class >> histogram: aHistogram against: aProbabilityDensityFunction [
	"Create a new instance of the receiver with given probability density function and histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self new 
	    initialize: aProbabilityDensityFunction
	    binWidth: aHistogram binWidth
	    count: aHistogram totalCount
    ]

    DhbScaledProbabilityDensityFunction class >> histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass [
	"Create a new instance of the receiver with given probability density function and histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| dp |
	^(dp := aProbabilityDensityFunctionClass fromHistogram: aHistogram) isNil 
	    ifTrue: [nil]
	    ifFalse: [self histogram: aHistogram against: dp]
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'display'>
	super printOn: aStream.
	aStream
	    nextPut: $[;
	    nextPutAll: probabilityDensityFunction class distributionName;
	    nextPut: $]
    ]

    distributionFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^probabilityDensityFunction distributionFunction
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	^probabilityDensityFunction parameters copyWith: count
    ]

    value: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'information'>
	^(probabilityDensityFunction value: aNumber) * binWidth * count
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| g temp |
	g := probabilityDensityFunction valueAndGradient: aNumber.
	temp := binWidth * count.
	^Array with: g first * temp
	    with: ((g last collect: [:each | each * temp]) copyWith: g first * binWidth)
    ]

    initialize: aProbabilityDensityFunction binWidth: aNumber count: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'initialization'>
	probabilityDensityFunction := aProbabilityDensityFunction.
	binWidth := aNumber.
	count := anInteger.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	count := count + aVector last.
	probabilityDensityFunction changeParametersBy: aVector
    ]

    setCount: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	count := aNumber
    ]
]



Object subclass: DhbWeightedPoint [
    | xValue yValue weight error |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbWeightedPoint class >> point: aPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint weight: 1
    ]

    DhbWeightedPoint class >> point: aNumber count: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self point: aNumber @ anInteger
	    weight: (anInteger > 0 ifTrue: [1 / anInteger] ifFalse: [1])
    ]

    DhbWeightedPoint class >> point: aPoint error: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint error: aNumber
    ]

    DhbWeightedPoint class >> point: aPoint weight: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint weight: aNumber
    ]

    error [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'accessing'>
	error isNil ifTrue: [error := 1 / weight sqrt].
	^error
    ]

    point [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'accessing'>
	^xValue @ yValue
    ]

    weight [
	<category: 'accessing'>
	^weight
    ]

    xValue [
	<category: 'accessing'>
	^xValue
    ]

    yValue [
	<category: 'accessing'>
	^yValue
    ]

    chi2ComparisonContribution: aWeightedPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'information'>
	^(aWeightedPoint yValue - yValue) squared 
	    / (1 / aWeightedPoint weight + (1 / weight))
    ]

    chi2Contribution: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'information'>
	^(yValue - (aFunction value: xValue)) squared * weight
    ]

    initialize: aPoint error: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'initialization'>
	error := aNumber.
	^self initialize: aPoint weight: 1 / aNumber squared
    ]

    initialize: aPoint weight: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'initialization'>
	xValue := aPoint x.
	yValue := aPoint y.
	weight := aNumber.
	^self
    ]
]



DhbAbstractDataServer subclass: DhbMemoryBasedDataServer [
    | data position |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    atEnd [
	"Answers true if there is no more data element.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	^data size < position
    ]

    dimension [
	"Answers the dimension of the vectors catered by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	^data first size
    ]

    data: anOrderedCollection [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	data := anOrderedCollection.
	self reset
    ]

    next [
	"Answers the next element on the stream.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	| answer |
	answer := data at: position.
	position := position + 1.
	^answer
    ]

    open [
	"Open the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self reset
    ]

    reset [
	"Reset the position of the data stream to the beginning.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	position := 1
    ]
]

