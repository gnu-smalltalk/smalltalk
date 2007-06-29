"======================================================================
|
|   Numerical methods - Statistics
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

Object subclass:  #DhbStatisticalMoments
	instanceVariableNames: 'moments '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbStatisticalMoments comment: 
nil!

Object subclass:  #DhbMahalanobisCenter
	instanceVariableNames: 'center inverseCovariance accumulator '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbMahalanobisCenter comment: 
nil!

Object subclass:  #DhbVectorAccumulator
	instanceVariableNames: 'count average '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbVectorAccumulator comment: 
nil!

DhbIterativeProcess subclass:  #DhbClusterFinder
	instanceVariableNames: 'dataServer dataSetSize minimumRelativeClusterSize '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbClusterFinder comment: 
nil!

DhbStatisticalMoments subclass:  #DhbFastStatisticalMoments
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbFastStatisticalMoments comment: 
nil!

DhbIterativeProcess subclass:  #DhbLeastSquareFit
	instanceVariableNames: 'dataHolder errorMatrix chiSquare equations constants degreeOfFreedom '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbLeastSquareFit comment: 
nil!

Object subclass:  #DhbHistogram
	instanceVariableNames: 'minimum binWidth overflow underflow moments contents freeExtent cacheSize desiredNumberOfBins '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbHistogram comment: 
nil!

Object subclass:  #DhbCluster
	instanceVariableNames: 'accumulator previousSampleSize '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbCluster comment: 
nil!

Object subclass:  #DhbAbstractDataServer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbAbstractDataServer comment: 
nil!

Object subclass:  #DhbPolynomialLeastSquareFit
	instanceVariableNames: 'pointCollection degreePlusOne '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbPolynomialLeastSquareFit comment: 
nil!

Object subclass:  #DhbLinearRegression
	instanceVariableNames: 'sum1 sumX sumY sumXX sumYY sumXY slope intercept correlationCoefficient '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbLinearRegression comment: 
nil!

DhbVectorAccumulator subclass:  #DhbCovarianceAccumulator
	instanceVariableNames: 'covariance '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbCovarianceAccumulator comment: 
nil!

DhbCluster subclass:  #DhbCovarianceCluster
	instanceVariableNames: 'center '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbCovarianceCluster comment: 
nil!

DhbStatisticalMoments subclass:  #DhbFixedStatisticalMoments
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbFixedStatisticalMoments comment: 
nil!

DhbCluster subclass:  #DhbEuclideanCluster
	instanceVariableNames: 'center '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbEuclideanCluster comment: 
nil!

DhbLeastSquareFit subclass:  #DhbMaximumLikekihoodHistogramFit
	instanceVariableNames: 'count countVariance '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbMaximumLikekihoodHistogramFit comment: 
nil!

Object subclass:  #DhbScaledProbabilityDensityFunction
	instanceVariableNames: 'probabilityDensityFunction count binWidth '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbScaledProbabilityDensityFunction comment: 
nil!

Object subclass:  #DhbWeightedPoint
	instanceVariableNames: 'xValue yValue weight error '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbWeightedPoint comment: 
nil!

DhbAbstractDataServer subclass:  #DhbMemoryBasedDataServer
	instanceVariableNames: 'data position '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbMemoryBasedDataServer comment: 
nil!

!DhbStatisticalMoments class methodsFor: 'creation'!

new
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    ^self new: 4!

new: anInteger 
    "anInteger is the degree of the highest central moments
		 accumulated within the created instance.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    ^super new initialize: anInteger + 1! !

!DhbStatisticalMoments methodsFor: 'creation'!

asWeightedPoint: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^DhbWeightedPoint point: aNumber @ self average error: self errorOnAverage! !

!DhbStatisticalMoments methodsFor: 'information'!

average
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    self count = 0 ifTrue: [^nil].
    ^moments at: 2!

centralMoment: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/6/99 "

    ^moments at: anInteger + 1!

count
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/6/99 "

    ^moments at: 1!

errorOnAverage
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 02-Jan-00 "

    ^(self variance / self count) sqrt!

kurtosis
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    | n n1 n23 |
    n := self count.
    n < 4 ifTrue: [^nil].
    n23 := (n - 2) * (n - 3).
    n1 := n - 1.
    ^((moments at: 5) * n squared * (n + 1) / (self variance squared * n1) 
	- (n1 squared * 3)) / n23!

skewness
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    | n v |
    n := self count.
    n < 3 ifTrue: [^nil].
    v := self variance.
    ^(moments at: 4) * n squared / ((n - 1) * (n - 2) * (v sqrt * v))!

standardDeviation
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    ^self variance sqrt!

unnormalizedVariance
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    ^(self centralMoment: 2) * self count!

variance
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    | n |
    n := self count.
    n < 2 ifTrue: [^nil].
    ^self unnormalizedVariance / (n - 1)! !

!DhbStatisticalMoments methodsFor: 'initialization'!

initialize: anInteger 
    "Private - ( anInteger - 1) is the degree of the highest accumulated central moment.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    moments := Array new: anInteger.
    self reset.
    ^self! !

!DhbStatisticalMoments methodsFor: 'testing'!

fConfidenceLevel: aStatisticalMomentsOrHistogram 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

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
		    confidenceLevel: fValue]!

tConfidenceLevel: aStatisticalMomentsOrHistogram 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    | sbar dof |
    dof := self count + aStatisticalMomentsOrHistogram count - 2.
    sbar := ((self unnormalizedVariance 
		+ aStatisticalMomentsOrHistogram unnormalizedVariance) / dof) 
		sqrt.
    ^(DhbStudentDistribution degreeOfFreedom: dof) 
	confidenceLevel: (self average - aStatisticalMomentsOrHistogram average) 
		/ ((1 / self count + (1 / aStatisticalMomentsOrHistogram count)) sqrt 
			* sbar)! !

!DhbStatisticalMoments methodsFor: 'transformation'!

accumulate: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

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
	    moments at: k put: term * n1]!

reset
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/5/99 "

    moments atAllPut: 0! !




!DhbMahalanobisCenter class methodsFor: 'creation'!

new: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^self new initialize: anInteger!

onVector: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^self new center: aVector! !

!DhbMahalanobisCenter methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator count printOn: aStream.
    aStream nextPutAll: ': '.
    center printOn: aStream! !

!DhbMahalanobisCenter methodsFor: 'information'!

count
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^accumulator count!

distanceTo: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    | delta |
    delta := aVector - center.
    ^delta * inverseCovariance * delta! !

!DhbMahalanobisCenter methodsFor: 'initialization'!

center: aVector 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator := DhbCovarianceAccumulator new: aVector size.
    center := aVector.
    inverseCovariance := DhbSymmetricMatrix identity: aVector size.
    ^self!

initialize: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator := DhbCovarianceAccumulator new: anInteger.
    ^self! !

!DhbMahalanobisCenter methodsFor: 'transformation'!

accumulate: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator accumulate: aVector!

computeParameters
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    center := accumulator average copy.
    inverseCovariance := accumulator covarianceMatrix inverse!

reset
    "Leave center and inverse covariant matrix untouched
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator reset! !




!DhbVectorAccumulator class methodsFor: 'creation'!

new: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^self new initialize: anInteger! !

!DhbVectorAccumulator methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    super printOn: aStream.
    aStream space.
    count printOn: aStream.
    aStream space.
    average printOn: aStream! !

!DhbVectorAccumulator methodsFor: 'information'!

average
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^average!

count
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^count! !

!DhbVectorAccumulator methodsFor: 'initialization'!

initialize: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    average := DhbVector new: anInteger.
    self reset.
    ^self! !

!DhbVectorAccumulator methodsFor: 'transformation'!

accumulate: aVectorOrArray 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    | delta |
    count := count + 1.
    delta := average - aVectorOrArray asVector scaleBy: 1 / count.
    average accumulateNegated: delta.
    ^delta!

reset
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    count := 0.
    average atAllPut: 0! !




!DhbClusterFinder class methodsFor: 'creation'!

new: anInteger server: aClusterDataServer type: aClusterClass 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    ^super new 
	initialize: anInteger
	server: aClusterDataServer
	type: aClusterClass! !

!DhbClusterFinder methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    aStream nextPutAll: 'Iterations: '.
    iterations printOn: aStream.
    result do: 
	    [:each | 
	    aStream cr.
	    each printOn: aStream]! !

!DhbClusterFinder methodsFor: 'information'!

clusters: aCollectionOfClusters 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/18/00 "

    result := aCollectionOfClusters!

indexOfNearestCluster: aVector 
    "Private - Answers the index of the cluster nearest to aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

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
    ^index!

initialize: anInteger server: aClusterDataServer type: aClusterClass 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self dataServer: aClusterDataServer.
    self clusters: ((1 to: anInteger) collect: [:n | aClusterClass new]).
    minimumRelativeClusterSize := 0.
    ^self!

minimumClusterSize
    ^(minimumRelativeClusterSize * dataSetSize) rounded! !

!DhbClusterFinder methodsFor: 'initialization'!

dataServer: aClusterDataServer 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/18/00 "

    dataServer := aClusterDataServer!

minimumRelativeClusterSize: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    minimumRelativeClusterSize := aNumber max: 0! !

!DhbClusterFinder methodsFor: 'operation'!

evaluateIteration
    "Perform an accumulation of the data from the server.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    dataServer reset.
    dataSetSize := 0.
    [dataServer atEnd] whileFalse: 
	    [self accumulate: dataServer next.
	    dataSetSize := dataSetSize + 1].
    ^self collectChangesAndResetClusters!

finalizeIterations
    "Close the data server.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    dataServer close!

initializeIterations
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    dataServer open.
    result 
	do: [:each | each isUndefined ifTrue: [each centerOn: dataServer next]]! !

!DhbClusterFinder methodsFor: 'transformation'!

accumulate: aVector 
    "Private - Accumulate aVector into the nearest cluster.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    (result at: (self indexOfNearestCluster: aVector)) accumulate: aVector!

collectChangesAndResetClusters
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

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
    ^changes / 2! !




!DhbFastStatisticalMoments methodsFor: 'information'!

average
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    self count = 0 ifTrue: [^nil].
    ^(moments at: 2) / self count!

kurtosis
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

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
    ^kFact * (m4 * n / var squared) - kConst!

skewness
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    | x1 x2 x3 n stdev |
    n := self count.
    n < 3 ifTrue: [^nil].
    stdev := self standardDeviation.
    stdev = 0 ifTrue: [^nil].
    x1 := (moments at: 2) / n.
    x2 := (moments at: 3) / n.
    x3 := (moments at: 4) / n.
    ^(x3 - (3 * x1 * x2) + (2 * x1 * x1 * x1)) * n * n 
	/ (stdev squared * stdev * (n - 1) * (n - 2))!

unnormalizedVariance
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    ^(moments at: 3) - ((moments at: 2) squared * self count)!

variance
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    | n |
    n := self count.
    n < 2 ifTrue: [^nil].
    ^((moments at: 3) - ((moments at: 2) squared / n)) / (n - 1)! !

!DhbFastStatisticalMoments methodsFor: 'transformation'!

accumulate: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    | var |
    var := 1.
    1 to: moments size
	do: 
	    [:n | 
	    moments at: n put: (moments at: n) + var.
	    var := var * aNumber]! !




!DhbLeastSquareFit class methodsFor: 'creation'!

histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    ^self points: aHistogram
	function: (DhbScaledProbabilityDensityFunction histogram: aHistogram
		distributionClass: aProbabilityDensityFunctionClass)!

points: aDataHolder function: aParametricFunction 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 11/3/99"

    ^aParametricFunction isNil 
	ifTrue: [nil]
	ifFalse: [super new initialize: aDataHolder data: aParametricFunction]! !

!DhbLeastSquareFit methodsFor: 'information'!

chiSquare
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    chiSquare isNil ifTrue: [self computeChiSquare].
    ^chiSquare!

computeChiSquare
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    chiSquare := 0.
    degreeOfFreedom := self numberOfFreeParameters negated.
    dataHolder pointsAndErrorsDo: 
	    [:each | 
	    chiSquare := (each chi2Contribution: result) + chiSquare.
	    degreeOfFreedom := degreeOfFreedom + 1]!

confidenceLevel
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/6/00 "

    ^(DhbChiSquareDistribution degreeOfFreedom: self degreeOfFreedom) 
	confidenceLevel: self chiSquare!

degreeOfFreedom
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    degreeOfFreedom isNil ifTrue: [self computeChiSquare].
    ^degreeOfFreedom!

errorMatrix
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 14/4/99 "

    ^DhbSymmetricMatrix rows: errorMatrix inverseMatrixComponents!

fitType
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    ^'Least square fit'!

numberOfFreeParameters
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    ^self numberOfParameters!

numberOfParameters
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

    ^result parameters size!

value: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/8/00 "

    ^result value: aNumber!

valueAndError: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/8/00 "

    | valueGradient |
    valueGradient := result valueAndGradient: aNumber.
    ^Array with: valueGradient first
	with: (valueGradient last * (self errorMatrix * valueGradient last)) sqrt! !

!DhbLeastSquareFit methodsFor: 'initialization'!

initialize: aDataHolder data: aParametricFunction 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    dataHolder := aDataHolder.
    result := aParametricFunction.
    ^self! !

!DhbLeastSquareFit methodsFor: 'operation'!

accumulate: aWeightedPoint 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    | f g |
    f := result valueAndGradient: aWeightedPoint xValue.
    g := f last.
    f := f first.
    constants 
	accumulate: g * ((aWeightedPoint yValue - f) * aWeightedPoint weight).
    1 to: g size
	do: [:k | (equations at: k) accumulate: g * ((g at: k) * aWeightedPoint weight)]!

accumulateEquationSystem
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    dataHolder pointsAndErrorsDo: [:each | self accumulate: each]!

computeChanges
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

    errorMatrix := DhbLUPDecomposition direct: equations.
    ^errorMatrix solve: constants!

computeEquationSystem
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    constants atAllPut: 0.
    equations do: [:each | each atAllPut: 0].
    self accumulateEquationSystem!

evaluateIteration
    "Dummy method (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    | changes maxChange |
    self computeEquationSystem.
    changes := self computeChanges.
    result changeParametersBy: changes.
    maxChange := 0.
    result parameters with: changes
	do: [:r :d | maxChange := (d / r) abs max: maxChange].
    ^maxChange!

finalizeIterations
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    equations := nil.
    constants := nil.
    degreeOfFreedom := nil.
    chiSquare := nil!

initializeIterations
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    | n |
    n := self numberOfParameters.
    constants := (DhbVector new: n)
		atAllPut: 0;
		yourself.
    equations := (1 to: n) collect: 
		    [:k | 
		    (DhbVector new: n)
			atAllPut: 0;
			yourself]! !




!DhbHistogram class methodsFor: 'creation'!

new
    "Create a standard new instance of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^super new initialize! !

!DhbHistogram class methodsFor: 'information'!

defaultCacheSize
    "Private - Answer the default cache size.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^100!

defaultNumberOfBins
    "Private - Defines the default number of bins for instances of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^50!

integerScales
    "Private - Scales for strict integers"

    ^#(2 4 5 8 10)!

scales
    "Private - Scales for any number"

    ^#(1.25 2 2.5 4 5 7.5 8 10)!

semiIntegerScales
    "Private - Scales for large integers"

    ^#(2 2.5 4 5 7.5 8 10)! !

!DhbHistogram methodsFor: 'information'!

average
    "Answer the average of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments average!

binIndex: aNumber 
    "Answers the index of the bin corresponding to aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

    ^((aNumber - minimum) / binWidth) floor + 1!

binWidth
    "Answer the bin width for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    self isCached ifTrue: [self flushCache].
    ^binWidth!

chi2Against: aScaledDistribution 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/30/00 "

    | chi2 |
    chi2 := 0.
    self pointsAndErrorsDo: 
	    [:each | 
	    chi2 := (each chi2Contribution: aScaledDistribution) + chi2].
    ^chi2!

chi2ConfidenceLevelAgainst: aScaledDistribution 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/30/00 "

    ^(DhbChiSquareDistribution 
	degreeOfFreedom: contents size - aScaledDistribution parameters size) 
	    confidenceLevel: (self chi2Against: aScaledDistribution)!

collectIntegralPoints: aBlock 
    "Collects the points needed to display the receiver as an integral.
		 Needed to use polymorphic behavior when plotting the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

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
    ^answer asArray!

collectPoints: aBlock 
    "Collects the points needed to display the receiver.
		 Needed to use polymorphic behavior when plotting the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

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
    ^answer asArray!

count
    "Answer the count of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments count!

countAt: aNumber 
    "Answer the count in the bin corresponding to aNumber or 0 if outside the limits.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

    | n |
    n := self binIndex: aNumber.
    ^(n between: 1 and: contents size) ifTrue: [contents at: n] ifFalse: [0]!

countsBetween: aNumber1 and: aNumber2 
    "Computes the events located between aNumber1 and aNumber2.
		 NOTE: This method assumes the two numbers are within the limits
			   of the receiver and that the receiver is not cached.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

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
    ^answer!

countsUpTo: aNumber 
    "Computes the events located up to aNumber.
		 NOTE: This method assumes aNumber is within the limits
					 of the receiver and that the receiver is not cached.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

    | n answer |
    n := self binIndex: aNumber.
    n > contents size ifTrue: [^self count].
    answer := (contents at: n) 
		* (aNumber - (binWidth * (n - 1) + self minimum)) / binWidth.
    1 to: n - 1 do: [:m | answer := answer + (contents at: m)].
    ^answer + underflow!

errorOnAverage
    "Answer the error on the average of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments errorOnAverage!

inverseDistributionValue: aNumber 
    "Private - Compute the value which corresponds to a integrated count of aNumber.
		 NOTE: aNumber is assumed to be between 0 and 1.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

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
    ^self maximum!

isCached
    "Private - Answer true if the content of the receiver is cached.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^binWidth isNil!

isEmpty
    "Always false. 
		 Needed to use polymorphic behavior when plotting the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

    ^false!

kurtosis
    "Answer the kurtosis of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments kurtosis!

lowBinLimitAt: anInteger 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/3/99 "

    ^(anInteger - 1) * binWidth + minimum!

maximum
    "Answer the minimum for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    self isCached ifTrue: [self flushCache].
    ^contents size * binWidth + minimum!

maximumCount
    "Answer the maximum count of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "

    self isCached ifTrue: [self flushCache].
    ^contents inject: (contents isEmpty ifTrue: [1] ifFalse: [contents at: 1])
	into: [:max :each | max max: each]!

minimum
    "Answer the minimum for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    self isCached ifTrue: [self flushCache].
    ^minimum!

overflow
    "Answer the overflow of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^overflow!

roundToScale: aNumber 
    "Private - Adjust aNumber of the lowest upper scale"

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
    ^(scales detect: [:each | rValue <= each]) * norm!

skewness
    "Answer the skewness of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments skewness!

standardDeviation
    "Answer the standardDeviation of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments standardDeviation!

totalCount
    "Answer the count of the recevier, inclusing underflow and overflow
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments count + underflow + overflow!

underflow
    "Answer the underflow of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^underflow!

unnormalizedVariance
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    ^moments unnormalizedVariance!

variance
    "Answer the variance of the recevier
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    ^moments variance! !

!DhbHistogram methodsFor: 'initialization'!

freeExtent: aBoolean 
    "Defines the range of the receiver to be freely adjustable.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    (underflow = 0 and: [overflow = 0]) 
	ifFalse: [self error: 'Histogram extent cannot be redefined'].
    freeExtent := aBoolean!

initialize
    "Private - initializes the receiver with standard settings.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    freeExtent := false.
    cacheSize := self class defaultCacheSize.
    desiredNumberOfBins := self class defaultNumberOfBins.
    contents := OrderedCollection new: cacheSize.
    moments := DhbFixedStatisticalMoments new.
    overflow := 0.
    underflow := 0.
    ^self!

setDesiredNumberOfBins: anInteger 
    "Defines the desired number of bins. It may be adjusted to a few units later on.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    anInteger > 0 
	ifFalse: [self error: 'Desired number of bins must be positive'].
    desiredNumberOfBins := anInteger!

setRangeFrom: aNumber1 to: aNumber2 bins: anInteger 
    "Defines the range of the receiver by specifying the minimum, maximum and number of bins.
		 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    self isCached 
	ifFalse: [self error: 'Histogram limits cannot be redefined'].
    minimum := aNumber1.
    self
	setDesiredNumberOfBins: anInteger;
	adjustDimensionUpTo: aNumber2!

setWidth: aNumber1 from: aNumber2 bins: anInteger 
    "Defines the range of the receiver by specifying the minimum, bin width and number of bins.
		 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    self isCached 
	ifFalse: [self error: 'Histogram limits cannot be redefined'].
    minimum := aNumber2.
    self
	setDesiredNumberOfBins: anInteger;
	adjustDimensionUpTo: aNumber1 * anInteger + aNumber2! !

!DhbHistogram methodsFor: 'iterators'!

pointsAndErrorsDo: aBlock 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    | x |
    x := self minimum - (self binWidth / 2).
    contents do: 
	    [:each | 
	    x := x + self binWidth.
	    aBlock value: (DhbWeightedPoint point: x count: each)]! !

!DhbHistogram methodsFor: 'testing'!

fConfidenceLevel: aStatisticalMomentsOrHistogram 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    ^moments fConfidenceLevel: aStatisticalMomentsOrHistogram!

tConfidenceLevel: aStatisticalMomentsOrHistogram 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/22/00 "

    ^moments tConfidenceLevel: aStatisticalMomentsOrHistogram! !

!DhbHistogram methodsFor: 'transformation'!

accumulate: aNumber 
    "Accumulate aNumber into the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    | bin |
    self isCached ifTrue: [^self accumulateInCache: aNumber].
    bin := self binIndex: aNumber.
    (bin between: 1 and: contents size) 
	ifTrue: 
	    [contents at: bin put: (contents at: bin) + 1.
	    moments accumulate: aNumber]
	ifFalse: [self processOverflows: bin for: aNumber]!

accumulateInCache: aNumber 
    "Private - Accumulate aNumber inside a cache
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    contents add: aNumber.
    contents size > cacheSize ifTrue: [self flushCache]!

adjustDimensionUpTo: aNumber 
    "Private - Compute an adequate bin width and adjust the minimum and number of bins accordingly.
		 aNumber is the maximum value to accumulate. The minimum value has already been assigned.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 16/2/99 "

    | maximum |
    binWidth := self roundToScale: (aNumber - minimum) / desiredNumberOfBins.
    minimum := (minimum / binWidth) floor * binWidth.
    maximum := (aNumber / binWidth) ceiling * binWidth.
    contents := Array new: ((maximum - minimum) / binWidth) ceiling.
    contents atAllPut: 0!

countOverflows: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    anInteger > 0 
	ifTrue: [overflow := overflow + 1]
	ifFalse: [underflow := underflow + 1]!

flushCache
    "Private - 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 15/2/99"

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
    values do: [:each | self accumulate: each]!

growContents: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    anInteger > 0 
	ifTrue: [self growPositiveContents: anInteger]
	ifFalse: [self growNegativeContents: anInteger]!

growNegativeContents: anInteger 
    "Private - 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 15/2/99"

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
    minimum := (anInteger - 1) * binWidth + minimum!

growPositiveContents: anInteger 
    "Private - 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 15/2/99"

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
    contents := newContents!

processOverflows: anInteger for: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    freeExtent 
	ifTrue: 
	    [self growContents: anInteger.
	    moments accumulate: aNumber]
	ifFalse: [self countOverflows: anInteger]! !




!DhbCluster class methodsFor: 'creation'!

new
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^super new initialize! !

!DhbCluster methodsFor: 'information'!

changes
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^(self sampleSize - previousSampleSize) abs!

distanceTo: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^self subclassResponsibility!

isInsignificantIn: aClusterFinder 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/17/00 "

    ^self sampleSize <= aClusterFinder minimumClusterSize!

isUndefined
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^self subclassResponsibility!

sampleSize
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^accumulator count! !

!DhbCluster methodsFor: 'initialization'!

centerOn: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    self subclassResponsibility!

initialize
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    previousSampleSize := 0.
    ^self! !

!DhbCluster methodsFor: 'transformation'!

accumulate: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator accumulate: aVector!

collectAccumulatorResults
    self subclassResponsibility!

reset
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    previousSampleSize := self sampleSize.
    self collectAccumulatorResults.
    accumulator reset! !




!DhbAbstractDataServer methodsFor: 'information'!

atEnd
    "Answers true if there is no more data element.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self subclassResponsibility! !

!DhbAbstractDataServer methodsFor: 'operation'!

close
    "Close the data stream (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    !

next
    "Answers the next element on the stream.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self subclassResponsibility!

open
    "Open the data stream (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self subclassResponsibility!

reset
    "Reset the position of the data stream to the beginning.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self subclassResponsibility! !




!DhbPolynomialLeastSquareFit class methodsFor: 'creation'!

new: anInteger 
    "Create a new instance of the receiver with given degree.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^super new initialize: anInteger!

new: anInteger on: aCollectionOfPoints 
    "Create a new instance of the receiver with given degree and points.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^super new initialize: anInteger on: aCollectionOfPoints! !

!DhbPolynomialLeastSquareFit methodsFor: 'information'!

evaluate
    "Perform the least square fit and answers the fitted polynomial.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    | system errorMatrix |
    system := self computeEquations.
    errorMatrix := (system at: 1) inverse.
    ^(DhbEstimatedPolynomial coefficients: errorMatrix * (system at: 2))
	errorMatrix: errorMatrix;
	yourself! !

!DhbPolynomialLeastSquareFit methodsFor: 'initialization'!

initialize: anInteger 
    "Private - Create an empty point collection for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^self initialize: anInteger on: OrderedCollection new!

initialize: anInteger on: aCollectionOfPoints 
    "Private - Defines the collection of points for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    pointCollection := aCollectionOfPoints.
    degreePlusOne := anInteger + 1.
    ^self! !

!DhbPolynomialLeastSquareFit methodsFor: 'transformation'!

accumulate: aWeightedPoint into: aVectorOfVectors and: aVector 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    | t p powers |
    p := 1.00000000000000.
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
		accumulate: powers * ((powers at: k) * aWeightedPoint weight)]!

add: aWeightedPoint 
    "Add a point to the collection of points.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^pointCollection add: aWeightedPoint!

computeEquations
    "Private - Answer a pair Matrix/Vector defining the system of equations
		 to solve the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

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
    ^Array with: (DhbSymmetricMatrix rows: rows) with: vector! !




!DhbLinearRegression class methodsFor: 'creation'!

new
    "Create a new instance of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    ^(super new)
	reset;
	yourself! !

!DhbLinearRegression methodsFor: 'information'!

asEstimatedPolynomial
    "Answer the resulting linear dependence found by the receiver in the form of a polynomial
		 with embedded error matrix.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^(DhbEstimatedPolynomial coefficients: self coefficients)
	errorMatrix: self errorMatrix;
	yourself!

asPolynomial
    "Answer the resulting linear dependence found by the receiver in the form of a polynomial.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    ^DhbPolynomial coefficients: self coefficients!

coefficients
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    ^Array with: self intercept with: self slope!

correlationCoefficient
    "Answers the correlation coefficient of the receiver
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    correlationCoefficient isNil ifTrue: [self computeResults].
    ^correlationCoefficient!

errorMatrix
    "Answer the resulting linear dependence found by the receiver in the form of a polynomial
		 with embedded error matrix.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    | c1 cx cxx |
    c1 := 1.00000000000000 / (sumXX * sum1 - sumX squared).
    cx := sumX negated * c1.
    cxx := sumXX * c1.
    c1 := sum1 * c1.
    ^DhbSymmetricMatrix rows: (Array with: (Array with: cxx with: cx)
		with: (Array with: cx with: c1))!

errorOnIntercept
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/5/99 "

    ^(sumXX / (sumXX * sum1 - sumX squared)) sqrt!

errorOnSlope
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/5/99 "

    ^(sum1 / (sumXX * sum1 - sumX squared)) sqrt!

intercept
    "Answers the intercept of the receiver
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    intercept isNil ifTrue: [self computeResults].
    ^intercept!

slope
    "Answers the slope of the receiver
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    slope isNil ifTrue: [self computeResults].
    ^slope!

value: aNumber 
    "Answer the value interpolated at aNumber by the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    ^aNumber * self slope + self intercept! !

!DhbLinearRegression methodsFor: 'transformation'!

add: aPoint 
    "Accumulate aPoint into of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    self add: aPoint weight: 1!

add: aPoint weight: aNumber 
    "Accumulate aPoint into of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    sum1 := sum1 + aNumber.
    sumX := sumX + (aPoint x * aNumber).
    sumY := sumY + (aPoint y * aNumber).
    sumXX := sumXX + (aPoint x squared * aNumber).
    sumYY := sumYY + (aPoint y squared * aNumber).
    sumXY := sumXY + (aPoint x * aPoint y * aNumber).
    self resetResults!

computeResults
    "Private - Compute the results of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    | xNorm xyNorm |
    xNorm := sumXX * sum1 - (sumX * sumX).
    xyNorm := sumXY * sum1 - (sumX * sumY).
    slope := xyNorm / xNorm.
    intercept := (sumXX * sumY - (sumXY * sumX)) / xNorm.
    correlationCoefficient := xyNorm 
		/ (xNorm * (sumYY * sum1 - (sumY * sumY))) sqrt!

remove: aPoint 
    "Remove aPoint which was accumulated into of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    sum1 := sum1 - 1.
    sumX := sumX - aPoint x.
    sumY := sumY - aPoint y.
    sumXX := sumXX - aPoint x squared.
    sumYY := sumYY - aPoint y squared.
    sumXY := sumXY - (aPoint x * aPoint y).
    self resetResults!

reset
    "Set all accumulators of the receiver to zero and reset its results.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    sum1 := 0.
    sumX := 0.
    sumY := 0.
    sumXX := 0.
    sumYY := 0.
    sumXY := 0.
    self resetResults!

resetResults
    "Private - Reset the results of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/2/99 "

    slope := nil.
    intercept := nil.
    correlationCoefficient := nil! !




!DhbCovarianceAccumulator methodsFor: 'information'!

covarianceMatrix
    "Answer a matrix containing the covariance of the accumulated data.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    | rows n |
    n := 0.
    rows := covariance collect: 
		    [:row | 
		    n := n + 1.
		    row 
			, ((n + 1 to: covariance size) collect: [:m | (covariance at: m) at: n])].
    ^DhbSymmetricMatrix rows: rows! !

!DhbCovarianceAccumulator methodsFor: 'initialization'!

initialize: anInteger 
    "Private - Initialize the receiver to accumulate vectors of dimension anInteger.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    covariance := ((1 to: anInteger) collect: [:n | DhbVector new: n]) 
		asVector.
    ^super initialize: anInteger! !

!DhbCovarianceAccumulator methodsFor: 'transformation'!

accumulate: anArray 
    "Accumulate anArray into the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

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
				+ (r * ((covariance at: n) at: m))]]!

reset
    "Set all accumulators to zero.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    super reset.
    covariance do: [:each | each atAllPut: 0]! !




!DhbCovarianceCluster methodsFor: 'display'!

distanceTo: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^accumulator distanceTo: aVector!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator printOn: aStream! !

!DhbCovarianceCluster methodsFor: 'information'!

isUndefined
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^accumulator isNil! !

!DhbCovarianceCluster methodsFor: 'initialization'!

centerOn: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved. 
	Initial code: 2/16/00"

    accumulator := aVector isNil 
		ifTrue: [nil]
		ifFalse: [DhbMahalanobisCenter onVector: aVector]! !

!DhbCovarianceCluster methodsFor: 'transformation'!

collectAccumulatorResults
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator computeParameters! !




!DhbFixedStatisticalMoments class methodsFor: 'creation'!

new
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    ^super new: 4!

new: anInteger 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

    ^self error: 'Illegal creation message for this class'! !

!DhbFixedStatisticalMoments methodsFor: 'transformation'!

accumulate: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/6/99 "

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
	at: 1 put: n1! !




!DhbEuclideanCluster methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    accumulator count printOn: aStream.
    aStream nextPutAll: ': '.
    center printOn: aStream! !

!DhbEuclideanCluster methodsFor: 'information'!

distanceTo: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^(aVector - center) norm! !

!DhbEuclideanCluster methodsFor: 'initialization'!

centerOn: aVector 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    center := aVector.
    accumulator := DhbVectorAccumulator new: aVector size!

isUndefined
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    ^center isNil! !

!DhbEuclideanCluster methodsFor: 'transformation'!

collectAccumulatorResults
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    center := accumulator average copy! !




!DhbMaximumLikekihoodHistogramFit methodsFor: 'information'!

fitType
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    ^'Maximum likelihood fit'!

normalization
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/12/00 "

    ^count!

normalizationError
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/12/00 "

    ^countVariance sqrt!

numberOfFreeParameters
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    ^super numberOfParameters!

numberOfParameters
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

    ^super numberOfParameters - 1!

valueAndError: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/8/00 "

    | valueGradient gradient gVar |
    valueGradient := result valueAndGradient: aNumber.
    gradient := valueGradient last copyFrom: 1 to: valueGradient last size - 1.
    gVar := gradient * (self errorMatrix * gradient) / count.
    ^Array with: valueGradient first
	with: ((valueGradient first / count) squared * countVariance + gVar) sqrt! !

!DhbMaximumLikekihoodHistogramFit methodsFor: 'operation'!

accumulate: aWeightedPoint 
    "Private - 
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

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
	do: [:k | (equations at: k) accumulate: g * ((g at: k) * temp)]!

computeChanges
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

    ^super computeChanges copyWith: 0!

computeNormalization
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

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
    countVariance := numerator / (4 * count)!

finalizeIterations
    "Compute the normalization factor.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self computeNormalization.
    result setCount: count.
    super finalizeIterations!

initializeIterations
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    result setCount: 1.
    count := dataHolder totalCount.
    super initializeIterations! !




!DhbScaledProbabilityDensityFunction class methodsFor: 'creation'!

histogram: aHistogram against: aProbabilityDensityFunction 
    "Create a new instance of the receiver with given probability density function and histogram.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 3/3/99 "

    ^self new 
	initialize: aProbabilityDensityFunction
	binWidth: aHistogram binWidth
	count: aHistogram totalCount!

histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass 
    "Create a new instance of the receiver with given probability density function and histogram. 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 3/3/99"

    | dp |
    ^(dp := aProbabilityDensityFunctionClass fromHistogram: aHistogram) isNil 
	ifTrue: [nil]
	ifFalse: [self histogram: aHistogram against: dp]! !

!DhbScaledProbabilityDensityFunction methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    super printOn: aStream.
    aStream
	nextPut: $[;
	nextPutAll: probabilityDensityFunction class distributionName;
	nextPut: $]! !

!DhbScaledProbabilityDensityFunction methodsFor: 'information'!

distributionFunction
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/4/99 "

    ^probabilityDensityFunction distributionFunction!

parameters
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    ^probabilityDensityFunction parameters copyWith: count!

value: aNumber 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 3/3/99 "

    ^(probabilityDensityFunction value: aNumber) * binWidth * count!

valueAndGradient: aNumber 
    "Answers an Array containing the value of the receiver at aNumber
		 and the gradient of the receiver's respective to the receiver's
		 parameters evaluated at aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    | g temp |
    g := probabilityDensityFunction valueAndGradient: aNumber.
    temp := binWidth * count.
    ^Array with: g first * temp
	with: ((g last collect: [:each | each * temp]) copyWith: g first * binWidth)! !

!DhbScaledProbabilityDensityFunction methodsFor: 'initialization'!

initialize: aProbabilityDensityFunction binWidth: aNumber count: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 3/3/99 "

    probabilityDensityFunction := aProbabilityDensityFunction.
    binWidth := aNumber.
    count := anInteger.
    ^self! !

!DhbScaledProbabilityDensityFunction methodsFor: 'transformation'!

changeParametersBy: aVector 
    "Modify the parameters of the receiver by aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/3/99 "

    count := count + aVector last.
    probabilityDensityFunction changeParametersBy: aVector!

setCount: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 12/3/99 "

    count := aNumber! !




!DhbWeightedPoint class methodsFor: 'creation'!

point: aPoint 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^self new initialize: aPoint weight: 1!

point: aNumber count: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^self point: aNumber @ anInteger
	weight: (anInteger > 0 ifTrue: [1 / anInteger] ifFalse: [1])!

point: aPoint error: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^self new initialize: aPoint error: aNumber!

point: aPoint weight: aNumber 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^self new initialize: aPoint weight: aNumber! !

!DhbWeightedPoint methodsFor: 'accessing'!

error
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    error isNil ifTrue: [error := 1 / weight sqrt].
    ^error!

point
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^xValue @ yValue!

weight
    ^weight!

xValue
    ^xValue!

yValue
    ^yValue! !

!DhbWeightedPoint methodsFor: 'information'!

chi2ComparisonContribution: aWeightedPoint 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^(aWeightedPoint yValue - yValue) squared 
	/ (1 / aWeightedPoint weight + (1 / weight))!

chi2Contribution: aFunction 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    ^(yValue - (aFunction value: xValue)) squared * weight! !

!DhbWeightedPoint methodsFor: 'initialization'!

initialize: aPoint error: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    error := aNumber.
    ^self initialize: aPoint weight: 1 / aNumber squared!

initialize: aPoint weight: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/5/00 "

    xValue := aPoint x.
    yValue := aPoint y.
    weight := aNumber.
    ^self! !




!DhbMemoryBasedDataServer methodsFor: 'information'!

atEnd
    "Answers true if there is no more data element.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    ^data size < position!

dimension
    "Answers the dimension of the vectors catered by the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    ^data first size! !

!DhbMemoryBasedDataServer methodsFor: 'initialization'!

data: anOrderedCollection 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 2/16/00 "

    data := anOrderedCollection.
    self reset! !

!DhbMemoryBasedDataServer methodsFor: 'operation'!

next
    "Answers the next element on the stream.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    | answer |
    answer := data at: position.
    position := position + 1.
    ^answer!

open
    "Open the data stream (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    self reset!

reset
    "Reset the position of the data stream to the beginning.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    position := 1! !




