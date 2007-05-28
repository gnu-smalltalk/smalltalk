"======================================================================
|
|   Numerical methods - Test Suite
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

TestCase subclass:#DhbTestCase
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!

!DhbTestCase methodsFor: 'logging'!

defaultLogPolicyClass
    ^TestVerboseLog
! !

DhbTestCase subclass:#DhbTestGamma
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbTestGamma class methodsFor:'utility'!

epsilon
    ^0.00005
! !

!DhbTestGamma methodsFor:'helpers'!

gammaDiff: aNumber expected: result
    | a  |
    a := DhbLanczosFormula new gamma: aNumber.
    ^(a - result) abs.
! !

!DhbTestGamma methodsFor:'tests'!

testGamma
    
    | diff |
    diff := self gammaDiff: 4 expected: 6.
    self assert: diff < self class epsilon.
    diff := self gammaDiff: 1/3 expected: 2.6789.
    self assert: diff < self class epsilon.
    diff := self gammaDiff: 4/5 expected: 1.1642 .
    self assert: diff < self class epsilon.
! !

DhbTestCase subclass:#DhbTestIterators
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbTestIterators methodsFor:'integration'!

integratorTest: anIntegratorClass
    | a |
    a:= anIntegratorClass function:[:x | x sin ] from:0 to:0.
    self assert: (a evaluate equalsTo: 0).
    a:= anIntegratorClass function:[:x | x sin ] from:0 to: FloatD pi.
    self assert: ((a evaluate - 2) < 0.00001).
    a:= anIntegratorClass function:[:x | x sin ] from: FloatD pi negated to: 0.
    self assert: ((a evaluate + 2) abs < 0.00001).
    a:= anIntegratorClass function:[:x | x sin ] from: FloatD pi negated to: FloatD pi.
    self assert: (a evaluate equalsTo: 0).
!

integratorTestInversedBounds: anIntegratorClass
    | a |
    "Integrator cannot deal with nversed bounds"
    a:= anIntegratorClass function:[:x | x sin ] from: FloatD pi to: 0.
    self deny: (a evaluate equalsTo: -2).
!

testRomberg
    self integratorTest: DhbRombergIntegrator
!

testRombergInversedBounds

    "Integrator cannot deal with nversed bounds"
    self integratorTestInversedBounds: DhbRombergIntegrator
!

testSimpson
    self integratorTest: DhbSimpsonIntegrator
!

testSimpsonInversedBounds

    "Integrator cannot deal with nversed bounds"
    self integratorTestInversedBounds: DhbSimpsonIntegrator
!

testTrapeze
    self integratorTest: DhbTrapezeIntegrator
!

testTrapezeInversedBounds

    "Integrator cannot deal with nversed bounds"
    self integratorTestInversedBounds: DhbTrapezeIntegrator
! !

!DhbTestIterators methodsFor:'polynomial'!

testRootFind
    | a roots |
    a := DhbPolynomial coefficients: #(0 1 1).
    roots := a roots asSortedCollection.
    self 
	assert: roots size = 2;
	assert: (roots  first equalsTo: -1);
	assert: (roots  last equalsTo: 0)
!

testRootFindComplex
    "Does not support complex roots"
    | a roots |
    a := DhbPolynomial coefficients: #(1 0 1).
    roots := a roots.
    self 
	assert: roots size = 0.
! !

!DhbTestIterators methodsFor:'zero finders'!

testBisectionZeroFinder
    | finder |
    finder := DhbBisectionZeroFinder function: [:x | x + 1].
    finder 
	setNegativeX: -70;
	setPositiveX: 10.
    finder evaluate.
    self 
	assert: finder hasConverged;
	assert:( finder result equalsTo: -1)
!

testBisectionZeroFinderNoZero
    | finder |
    finder := DhbBisectionZeroFinder function: [:x | x*x + 1].
    self 
	should: 
	    [finder 
		findNegativeXFrom: -30
		range:  20]
	raise: Error
!

testBisectionZeroFinderSquared
    | finder |
    finder := DhbBisectionZeroFinder function: [:x | x*x - 1].
    finder 
	setNegativeX: -0.9;
	setPositiveX: 10.
    finder evaluate.
    self 
	assert: finder hasConverged;
	assert:( finder result equalsTo: 1)
!

testNewtonZeroFinder
    | finder |
    finder := DhbNewtonZeroFinder 
	function: [:x | x + 1]
	derivative: [:x | 1].
    finder evaluate.
    self 
	assert: finder hasConverged;
	assert:( finder result equalsTo: -1)
!

testNewtonZeroFinderSquared
    | finder |
    finder := DhbNewtonZeroFinder 
	function: [:x | x*x - 1]
	derivative: [:x | 2*x].
    finder evaluate.
    self 
	assert: finder hasConverged;
	assert:( finder result abs equalsTo: 1)
! !

DhbTestCase subclass:#DhbNumericalMethodsTestCase
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbNumericalMethodsTestCase methodsFor:'data mining'!

testClusterCovariance

    | dataServer clusters finder |

    dataServer := DhbMemoryBasedDataServer new.
    dataServer data: ( self generatedPoints: 1000).
    finder := DhbClusterFinder new: 5 server: dataServer type: DhbCovarianceCluster.
    finder minimumRelativeClusterSize: 0.1d.
    clusters := finder evaluate.
    self should: [ clusters size = 3].
!

testClusterEuclidean

    | dataServer clusters finder |
    dataServer := DhbMemoryBasedDataServer new.
    dataServer data: ( self generatedPoints: 1000).
    finder := DhbClusterFinder new: 5 server: dataServer type: DhbEuclideanCluster.
    finder minimumRelativeClusterSize: 0.15d.
    clusters := finder evaluate.
    self should: [ clusters size = 3].
!

testCovarianceAccumulation
    "Code example 12.2"
    | accumulator average covarianceMatrix |
    accumulator := DhbCovarianceAccumulator new: 3.
    #( 
	    (1 2 3)
	    ( 2 3 4)
	    ( 1 3 2)
	    ( 4 3 1)
	    ( 1 3 1)
	    ( 1 4 2)
	    ( 3 1 2)
	    ( 3 4 2)
	)
    do: [ :x | accumulator accumulate: x asVector].
    average := accumulator average.
    self should: [ ( average at: 1) equalsTo: 2.0d].
    self should: [ ( average at: 2) equalsTo: 2.875d].
    self should: [ ( average at: 3) equalsTo: 2.125d].
    covarianceMatrix := accumulator covarianceMatrix.
    self should: [ ((covarianceMatrix rowAt: 1) at: 1) equalsTo: 1.25d].
    self should: [ ((covarianceMatrix rowAt: 1) at: 2) equalsTo: -0.125d].
    self should: [ ((covarianceMatrix rowAt: 2) at: 1) equalsTo: -0.125d].
    self should: [ ((covarianceMatrix rowAt: 1) at: 3) equalsTo: -0.25d].
    self should: [ ((covarianceMatrix rowAt: 3) at: 1) equalsTo: -0.25d].
    self should: [ ((covarianceMatrix rowAt: 2) at: 2) equalsTo: 0.859375d].
    self should: [ ((covarianceMatrix rowAt: 2) at: 3) equalsTo: -0.109375d].
    self should: [ ((covarianceMatrix rowAt: 3) at: 2) equalsTo: -0.109375d].
    self should: [ ((covarianceMatrix rowAt: 3) at: 3) equalsTo: 0.859375d].
!

testMahalanobisCenter
    "Code example 12.5"
    | center distance|
    center := DhbMahalanobisCenter new: 3.
    #( 
	    (1 2 3)
	    ( 2 3 4)
	    ( 1 3 2)
	    ( 4 3 1)
	    ( 1 3 1)
	    ( 1 4 2)
	    ( 3 1 2)
	    ( 3 4 2)
	)
    do: [ :x | center accumulate: x asVector].
    center computeParameters.
    distance := center distanceTo: #(1 2 3) asVector.
    self should: [ distance equalsTo: 2.26602282704126d].
! !

!DhbNumericalMethodsTestCase methodsFor:'estimation'!

testFTest

    | accC accMM confidenceLevel|
    accC := DhbStatisticalMoments new.
    #( 5.56d 5.89d 4.66d 5.69d 5.34d 4.79d 4.80d 7.86d 3.64d 5.70d )
	do: [ :x | accC accumulate: x].
    accMM := DhbStatisticalMoments new.
    #( 7.48d 6.75d 3.77d 5.71d 7.25d 4.73d 6.23d 5.60d 5.94d 4.58d )
	do: [ :x | accMM accumulate: x].
    confidenceLevel := accC fConfidenceLevel: accMM.
    self should: [ (accC average - 5.393d) abs < 0.000000001d].
    self should: [ (accC standardDeviation - 1.0990809292d) abs < 0.000000001d].
    self should: [ (accMM average - 5.804d) abs < 0.000000001d].
    self should: [ (accMM standardDeviation - 1.19415428d) abs < 0.000000001d].
    self should: [ (confidenceLevel - 79.8147614536d) abs < 0.000000001d].
!

testInterpolationNewton

    | interpolator |
    interpolator := DhbNewtonInterpolator new.
    1 to: 45 by: 2 do:
	[ :x | interpolator add: x @ (x degreesToRadians sin)].
    self should: [ ((interpolator value: 8) - (8 degreesToRadians sin)) abs < 1.0d-14].
!

testLeastSquare
    "Code example 10.9"
    "Note: the seemingly large error on the fit results is due to the binning of the histogram."
    | count shape scale genDistr hist fit fittedDistr parameters |
    count := 10000.
    shape := 0.
    scale := 1.
    hist := DhbHistogram new.
    hist freeExtent: true.
    genDistr := DhbFisherTippettDistribution shape: shape scale: scale.
    count timesRepeat: [ hist accumulate: genDistr random].
    fit := DhbLeastSquareFit histogram: hist distributionClass: DhbFisherTippettDistribution.
    fittedDistr := fit evaluate.
    parameters := fittedDistr parameters.
    self should: [ ((parameters at: 1) - shape) abs < 0.1d].
    self should: [ ((parameters at: 2) - scale) abs < 0.1d].
    self should: [ ((parameters at: 3) - count) abs < 100].
!

testLeastSquarePolynomial
    "Code example 10.5"
    | fit estimation |
    fit := DhbPolynomialLeastSquareFit new: 3.
    fit
	add: (DhbWeightedPoint point: 1 @ 2.0d);
	add: (DhbWeightedPoint point: 2 @ 21.0d);
	add: (DhbWeightedPoint point: 3 @ 72.0d);
	add: (DhbWeightedPoint point: 4 @ 173.0d);
	add: (DhbWeightedPoint point: 5 @ 342.0d);
	add: (DhbWeightedPoint point: 6 @ 597.0d);
	add: (DhbWeightedPoint point: 7 @ 956.0d);
	add: (DhbWeightedPoint point: 8 @ 1437.0d);
	add: (DhbWeightedPoint point: 9 @ 2058.0d);
	add: (DhbWeightedPoint point: 10 @ 2837.0d).
    estimation := fit evaluate.
    self should: [ ((estimation value: 4.5d)- 247.875d) abs < 0.000000001d].
    self should: [ ((estimation error: 4.5d) -  5.215298d-1) abs < 0.00001d].
    self should: [ ((estimation value: 7.15d)- 1019.932625d) abs < (estimation error: 7.15d)].
!

testLinearRegression
    "Code example 10.5"
    | linReg estimation |
    linReg := DhbLinearRegression new.
    linReg
	add: 1 @ 0.72d;
	add: 2 @ 3.25d;
	add: 3 @ 5.75d;
	add: 4 @ 8.21d;
	add: 5 @ 10.71d;
	add: 6 @ 13.38d;
	add: 7 @ 15.82d;
	add: 8 @ 18.39d;
	add: 9 @ 20.72d;
	add: 10 @ 23.38d.
    self should: [ (linReg slope - 2.514727272727d) abs < 0.000000000001d].
    self should: [ (linReg intercept + 1.798d) abs < 0.000000000001d].
    self should: [ (linReg correlationCoefficient - 0.999966922113d) abs < 0.000000000001d].
    estimation := linReg asEstimatedPolynomial.
    self should: [ ((estimation value: 4.5d)- 9.5182727272727d) abs < 0.000000000001d].
    self should: [ ((estimation value: 7.15d)-  16.1823d) abs < 0.000000000001d].
!

testMaximumLikelihood
    "Code example 10.11"
    "Note: the seemingly large error on the fit results is due to the binning of the histogram."
    | count shape scale genDistr hist fit fittedDistr parameters |
    count := 10000.
    shape := 0.
    scale := 1.
    hist := DhbHistogram new.
    hist freeExtent: true.
    genDistr := DhbFisherTippettDistribution shape: shape scale: scale.
    count timesRepeat: [ hist accumulate: genDistr random].
    fit := DhbMaximumLikekihoodHistogramFit histogram: hist distributionClass: DhbFisherTippettDistribution.
    fittedDistr := fit evaluate.
    parameters := fittedDistr parameters.
    self should: [ ((parameters at: 1) - shape) abs < 0.1d].
    self should: [ ((parameters at: 2) - scale) abs < 0.1d].
    self should: [ ((parameters at: 3) - count) abs < 100].
!

testTTest

    | accC accMM confidenceLevel|
    accC := DhbStatisticalMoments new.
    #( 5.56d 5.89d 4.66d 5.69d 5.34d 4.79d 4.80d 7.86d 3.64d 5.70d )
	do: [ :x | accC accumulate: x].
    accMM := DhbStatisticalMoments new.
    #( 7.48d 6.75d 3.77d 5.71d 7.25d 4.73d 6.23d 5.60d 5.94d 4.58d )
	do: [ :x | accMM accumulate: x].
    confidenceLevel := accC tConfidenceLevel: accMM.
    self should: [ (accC average - 5.393d) abs < 0.000000001d].
    self should: [ (accC standardDeviation - 1.0990809292d) abs < 0.000000001d].
    self should: [ (accMM average - 5.804d) abs < 0.000000001d].
    self should: [ (accMM standardDeviation - 1.19415428d) abs < 0.000000001d].
    self should: [ (confidenceLevel - 56.6320739989d) abs < 0.000000001d].
! !

!DhbNumericalMethodsTestCase methodsFor:'function evaluation'!

testBeta
    "Code example 2.14"
    | value |

    value := 2.5d gamma * 5.5d gamma / 8 gamma.
    self should: [ ((2.5d beta: 5.5d)  - value) abs < 1.0d-14].
!

testBetaLog
    "Code example 2.15"
    | value |
    value := ( 2.5d gamma * 5.5d gamma / 8 gamma) ln.
    self should: [ ((2.5d logBeta: 5.5d)  - value) abs < 1.0d-13].
!

testErrorFunctionCentile
    "Code example 2.5"
    | weight average stDev centile |
    weight := 2.85d.
    average := 3.39d.
    stDev := 0.44d.
    centile := (( weight - average) / stDev) errorFunction * 100.
    self should: [ ( centile - 10.986012d) abs < 0.000001d].
!

testGamma
    "Code example 2.10"
    | value |
    value := FloatD pi sqrt * 3 / 4.
    self should: [ (2.5d gamma  - value) abs < 1.0d-14].
!

testGammaLog
    "Code example 2.11"
    | value |
    value := 2.5d gamma ln.
    self should: [ (2.5d logGamma  - value) abs < 1.0d-13].
!

testGammaLow

    | value |
    value := FloatD pi sqrt / 2.
    self should: [ ((3/2) gamma  - value) abs < 1.0d-14].
!

testGammaNegative

    | value |
    value := FloatD pi / ( 1.5 gamma * (FloatD pi / -2) sin).
    self should: [ ((-1/2) gamma  - value) abs < 1.0d-14].
!

testInterpolationBulirschStoer

    | interpolator |
    interpolator := DhbBulirschStoerInterpolator new.
    1 to: 45 by: 2 do:
	[ :x | interpolator add: x @ (x degreesToRadians sin)].
    self should: [ ((interpolator value: 8) - (8 degreesToRadians sin)) abs < 1.0d-14].
!

testInterpolationLagrange
    "Code example 3.2"
    | interpolator |
    interpolator := DhbLagrangeInterpolator new.
    1 to: 45 by: 2 do:
	[ :x | interpolator add: x @ (x degreesToRadians sin)].
    self should: [ ((interpolator value: 8) - (8 degreesToRadians sin)) abs < 1.0d-14].
!

testInterpolationLagrangeLinear
    "Code example 3.1"
    | interpolator |
    interpolator := DhbLagrangeInterpolator points: (Array with: 1 @ 2 with: 3 @ 1 ).
    self should: [ ((interpolator value: 2.2d) - 1.4d) abs < 1.0d-14].
!

testInterpolationNeville

    | interpolator |

    interpolator := DhbNevilleInterpolator new.
    1 to: 45 by: 2 do:
	[ :x | interpolator add: x @ (x degreesToRadians sin)].
    self should: [ ((interpolator value: 8) - (8 degreesToRadians sin)) abs < 1.0d-14].
!

testInterpolationNevilleLinear
    "Code example 3.1"
    | interpolator |
    interpolator := DhbNevilleInterpolator points: (Array with: 1 @ 2 with: 3 @ 1 ).
    self should: [ ((interpolator value: 2.2d) - 1.4d) abs < 1.0d-14].
!

testInterpolationNewtonLinear
    "Code example 3.1"
    | interpolator |
    interpolator := DhbNewtonInterpolator points: (Array with: 1 @ 2 with: 3 @ 1 ).
    self should: [ ((interpolator value: 2.2d) - 1.4d) abs < 1.0d-14].
!

testInterpolationSpline

    | interpolator |
    interpolator := DhbSplineInterpolator new.
    1 to: 45 by: 2 do:
	[ :x | interpolator add: x @ (x degreesToRadians sin)].
    self should: [ ((interpolator value: 8) - (8 degreesToRadians sin)) abs < 1.0d-7].
!

testInterpolationSplineLinear
    "Code example 3.1"
    | interpolator |
    interpolator := DhbSplineInterpolator points: (Array with: 1 @ 2 with: 3 @ 1 ).
    self should: [ ((interpolator value: 2.2d) - 1.4d) abs < 1.0d-14].
!

testPolynomialAddition

    | polynomial |
    polynomial :=
	(DhbPolynomial coefficients: #(2 -3 1)) +
	(DhbPolynomial coefficients: #(-3 7 2 1)).
    self should: [ (polynomial at: 0) = -1].
    self should: [ (polynomial at: 1) = 4].
    self should: [ (polynomial at: 2) = 3].
    self should: [ (polynomial at: 3) = 1].
    self should: [ (polynomial at: 4) = 0].
!

testPolynomialDerivative
    "Code example 2.3"
    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(-3 7 2 1)) derivative.
    self should: [ (polynomial at: 0) = 7].
    self should: [ (polynomial at: 1) = 4].
    self should: [ (polynomial at: 2) = 3].
    self should: [ (polynomial at: 3) = 0].
    self should: [ (polynomial at: 4) = 0].
!

testPolynomialDivision

    | pol1 pol2 polynomial |
    pol1 := DhbPolynomial coefficients: #(2 -3 1).
    pol2 := DhbPolynomial coefficients: #(-6 23 -20 3 -1 1).
    polynomial := pol2 / pol1.
    self should: [ (polynomial at: 0) = -3].
    self should: [ (polynomial at: 1) = 7].
    self should: [ (polynomial at: 2) = 2].
    self should: [ (polynomial at: 3) = 1].
    self should: [ (polynomial at: 4) = 0].
    self should: [ (polynomial at: 5) = 0].
    self should: [ (polynomial at: 6) = 0].
!

testPolynomialEvaluation
    "Code example 2.2"
    | polynomial |
    polynomial := DhbPolynomial coefficients: #(2 -3 1).
    self should: [0 = (polynomial value: 1)].
!

testPolynomialIntegral
    "Code example 2.3"
    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(-3 7 2 1)) integral.
    self should: [ (polynomial at: 0) = 0].
    self should: [ (polynomial at: 1) = -3].
    self should: [ (polynomial at: 2) = (7/2)].
    self should: [ (polynomial at: 3) = (2/3)].
    self should: [ (polynomial at: 4) = (1/4)].
    self should: [ (polynomial at: 5) = 0].
!

testPolynomialIntegralWithConstant
    "Code example 2.3"
    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(-3 7 2 1)) integral: 5.
    self should: [ (polynomial at: 0) = 5].
    self should: [ (polynomial at: 1) = -3].
    self should: [ (polynomial at: 2) = (7/2)].
    self should: [ (polynomial at: 3) = (2/3)].
    self should: [ (polynomial at: 4) = (1/4)].
    self should: [ (polynomial at: 5) = 0].
!

testPolynomialMultiplication
    "Code example 2.3"
    | pol1 pol2 polynomial |
    pol1 := DhbPolynomial coefficients: #(2 -3 1).
    pol2 := DhbPolynomial coefficients: #(-3 7 2 1).
    polynomial := pol1 * pol2.
    self should: [ (polynomial at: 0) = -6].
    self should: [ (polynomial at: 1) = 23].
    self should: [ (polynomial at: 2) = -20].
    self should: [ (polynomial at: 3) = 3].
    self should: [ (polynomial at: 4) = -1].
    self should: [ (polynomial at: 5) = 1].
    self should: [ (polynomial at: 6) = 0].
!

testPolynomialNumberAddition

    | polynomial |
    polynomial := 2 + ( DhbPolynomial coefficients: #(2 -3 1)).
    self should: [ (polynomial at: 0) = 4].
    self should: [ (polynomial at: 1) = -3].
    self should: [ (polynomial at: 2) = 1].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberAdditionInverse

    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(2 -3 1)) + 2.
    self should: [ (polynomial at: 0) = 4].
    self should: [ (polynomial at: 1) = -3].
    self should: [ (polynomial at: 2) = 1].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberDivision

    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(2 -3 1)) / 2.
    self should: [ (polynomial at: 0) = 1].
    self should: [ (polynomial at: 1) = (-3 / 2)].
    self should: [ (polynomial at: 2) = (1/2)].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberMultiplication

    | polynomial |
    polynomial := 2 * ( DhbPolynomial coefficients: #(2 -3 1)).
    self should: [ (polynomial at: 0) = 4].
    self should: [ (polynomial at: 1) = -6].
    self should: [ (polynomial at: 2) = 2].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberMultiplicationInverse

    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(2 -3 1)) * 2.
    self should: [ (polynomial at: 0) = 4].
    self should: [ (polynomial at: 1) = -6].
    self should: [ (polynomial at: 2) = 2].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberSubtraction

    | polynomial |
    polynomial := 2 - ( DhbPolynomial coefficients: #(2 -3 1)).
    self should: [ (polynomial at: 0) = 0].
    self should: [ (polynomial at: 1) = 3].
    self should: [ (polynomial at: 2) = -1].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialNumberSubtractionInverse

    | polynomial |
    polynomial := ( DhbPolynomial coefficients: #(2 -3 1)) - 2.
    self should: [ (polynomial at: 0) = 0].
    self should: [ (polynomial at: 1) = -3].
    self should: [ (polynomial at: 2) = 1].
    self should: [ (polynomial at: 3) = 0].
!

testPolynomialSubtraction

    | polynomial |
    polynomial :=
	(DhbPolynomial coefficients: #(2 -3 1)) -
	(DhbPolynomial coefficients: #(-3 7 2 1)).
    self should: [ (polynomial at: 0) = 5].
    self should: [ (polynomial at: 1) = -10].
    self should: [ (polynomial at: 2) = -1].
    self should: [ (polynomial at: 3) = -1].
    self should: [ (polynomial at: 4) = 0].
! !

!DhbNumericalMethodsTestCase methodsFor:'iterative algorithms'!

testBissection
    "Code Example 5.1"
    | zeroFinder result |
    zeroFinder := DhbBisectionZeroFinder function: [ :x | x errorFunction - 0.9d].
    zeroFinder setPositiveX: 10d; setNegativeX: 0d.
    result := zeroFinder evaluate.
    self should: [ zeroFinder hasConverged].
    self should: [ (result - 1.28155193291605d) abs < 1.0d-14]
!

testIncompleteBetaFunction

    | function |
    function := DhbIncompleteBetaFunction shape: 2 shape: 5.
    self should: [ ( (function value: 0.8d) - 0.9984d) abs < 0.00001d].
!

testIncompleteGammaFunction

    | function |
    function := DhbIncompleteGammaFunction shape: 2.
    self should: [ ( (function value: 2) - 0.59399414981d) abs < 0.00000000001d].
!

testIntegrationRomberg

    | integrator ln2 ln3|
    integrator := DhbRombergIntegrator function: [ :x | 1.0d / x] from: 1 to: 2.
    ln2 := integrator evaluate.
    integrator from: 1 to: 3.
    ln3 := integrator evaluate.
    self should: [ ( 2d ln - ln2) abs < ( 2 * integrator precision)].
    self should: [ ( 3d ln - ln3) abs < ( 2 * integrator precision)].
!

testIntegrationSimpson

    | integrator ln2 ln3|
    integrator := DhbSimpsonIntegrator function: [ :x | 1.0 / x] from: 1 to: 2.
    ln2 := integrator evaluate.
    integrator from: 1 to: 3.
    ln3 := integrator evaluate.
    self should: [ ( 2d ln - ln2) abs < integrator precision].
    self should: [ ( 3d ln - ln3) abs < integrator precision].
!

testIntegrationTrapeze
    "Code Example 6.1"
    | integrator ln2 ln3|
    integrator := DhbTrapezeIntegrator function: [ :x | 1.0d / x] from: 1 to: 2.
    ln2 := integrator evaluate.
    integrator from: 1 to: 3.
    ln3 := integrator evaluate.
    self should: [ ( 2d ln - ln2) abs < integrator precision].
    self should: [ ( 3d ln - ln3) abs < integrator precision].
!

testNewtonZeroFinder
    "Code Example 5.3"
    | zeroFinder result |
    zeroFinder := DhbNewtonZeroFinder function: [ :x | x errorFunction - 0.9d].
    zeroFinder initialValue: 1d.
    result := zeroFinder evaluate.
    self should: [ zeroFinder hasConverged].
    self should: [ (result - 1.28155193867885d) abs < zeroFinder precision]
!

testPolynomialRoots
    "Code Example 5.5"
    | polynomial roots |
    polynomial := DhbPolynomial coefficients: #( -10 -13 -2 1).
    roots := polynomial roots asSortedCollection asArray.
    self should: [ roots size = 3].
    self should: [ ( (roots at: 1) + 2) abs < DhbFloatingPointMachine new defaultNumericalPrecision].
    self should: [ ( (roots at: 2) + 1) abs < DhbFloatingPointMachine new defaultNumericalPrecision].
    self should: [ ( (roots at: 3) - 5) abs < DhbFloatingPointMachine new defaultNumericalPrecision].
! !

!DhbNumericalMethodsTestCase methodsFor:'linear algebra'!

testDeterminant

    | m |
    m := DhbMatrix rows: #( (3 2 4) (2 -5 -1) ( 1 -2 2)).
    self should: [ m determinant = -42].
!

testEigenvalues
    "Code Example 8.15"
    | m charPol roots eigenvalues finder |
    m := DhbMatrix rows: #( ( 3 -2 0) (-2 7 1) (0 1 5)).
    charPol := DhbPolynomial coefficients: #(82 -66 15 -1).
    roots := charPol roots asSortedCollection asArray reverse.
    finder := DhbJacobiTransformation matrix: m.
    finder desiredPrecision: 1.0d-09.
    eigenvalues := finder evaluate.
    self should: [ eigenvalues size = 3].
    self should: [ ((roots at: 1) - (eigenvalues at: 1)) abs < 1.0d-09].
    self should: [ ((roots at: 2) - (eigenvalues at: 2)) abs < 1.0d-09].
    self should: [ ((roots at: 3) - (eigenvalues at: 3)) abs < 1.0d-09].
!

testEigenvaluesLargest
    "Code Example 8.13"
    | m charPol roots eigenvalue finder |
    m := DhbMatrix rows: #( ( 3 -2 0) (-2 7 1) (0 1 5)).
    charPol := DhbPolynomial coefficients: #(82 -66 15 -1).
    roots := charPol roots asSortedCollection asArray reverse.
    finder := DhbLargestEigenValueFinder matrix: m.
    finder desiredPrecision: 1.0d-08.
    eigenvalue := finder evaluate.
    self should: [ ((roots at: 1) - eigenvalue) abs < 1.0d-08].
    finder := finder nextLargestEigenValueFinder.
    eigenvalue := finder evaluate.
    self should: [ ((roots at: 2) - eigenvalue) abs < 1.0d-08].
!

testLUPDecomposition
    "Code Example 8.10"
    | s sol1 sol2 |
    s := DhbLUPDecomposition
		equations: #( (3 2 4) (2 -5 -1) ( 1 -2 2)).
    sol1 := s solve: #(16 6 10).
    sol2 := s solve: #(7 10 9).
    self should: [ sol1 size = 3].
    self should: [ (sol1 at: 1) = 2].
    self should: [ (sol1 at: 2) = -1].
    self should: [ (sol1 at: 3) = 3].
    self should: [ sol2 size = 3].
    self should: [ (sol2 at: 1) = 1].
    self should: [ (sol2 at: 2) = -2].
    self should: [ (sol2 at: 3) = 2].
!

testLinearEquations
    "Code Example 8.6"
    | s sol1 sol2 |
    s := DhbLinearEquationSystem
		equations: #( (3 2 4) (2 -5 -1) ( 1 -2 2))
		constants: #( (16 6 10) (7 10 9)).
    sol1 := s solutionAt: 1.
    sol2 := s solutionAt: 2.
    self should: [ sol1 size = 3].
    self should: [ (sol1 at: 1) = 2].
    self should: [ (sol1 at: 2) = -1].
    self should: [ (sol1 at: 3) = 3].
    self should: [ sol2 size = 3].
    self should: [ (sol2 at: 1) = 1].
    self should: [ (sol2 at: 2) = -2].
    self should: [ (sol2 at: 3) = 2].
!

testLinearEquationsSingle

    | s sol |
    s := DhbLinearEquationSystem
		equations: #( (1 2 0) (3 5 4) (5 6 3))
		constant: #(0.1d 12.5d 10.3d).
    sol := s solution.
    self should: [ sol size = 3].
    self should: [ (sol at: 1) equalsTo: 0.5d].
    self should: [ (sol at: 2) equalsTo: -0.2d].
    self should: [ (sol at: 3) equalsTo:  3.0d].
!

testLinearEquationsSingular

    | s sol |
    s := DhbLinearEquationSystem
		equations: #( (1 2 0) (10 12 6) (5 6 3))
		constant: #(0.1d 12.5d 10.3d).
    sol := s solution.
    self should: [ sol isNil].
!

testMatrixInversionSmall

    | m c |
    m := DhbMatrix rows: #( (3 2 4) (2 -5 -1) ( 1 -2 2)).
    c := m inverse * m.
    self should: [ c numberOfRows = 3].
    self should: [ c numberOfColumns = 3].
    self should: [ ((c rowAt: 1) at: 1) = 1].
    self should: [ ((c rowAt: 1) at: 2) = 0].
    self should: [ ((c rowAt: 1) at: 3) = 0].
    self should: [ ((c rowAt: 2) at: 1) = 0].
    self should: [ ((c rowAt: 2) at: 2) = 1].
    self should: [ ((c rowAt: 2) at: 3) = 0].
    self should: [ ((c rowAt: 3) at: 1) = 0].
    self should: [ ((c rowAt: 3) at: 2) = 0].
    self should: [ ((c rowAt: 3) at: 3) = 1].
!

testMatrixOperation
    "Code Example 8.1"
    | a b c |
    a := DhbMatrix rows: #( ( 1 0 1) (-1 -2 3)).
    b := DhbMatrix rows: #( ( 1 2 3) (-2 1 7) (5 6 7)).
    c := a * b.
    self should: [ c numberOfRows = 2].
    self should: [ c numberOfColumns = 3].
    self should: [ ((c rowAt: 1) at: 1) = 6].
    self should: [ ((c rowAt: 1) at: 2) = 8].
    self should: [ ((c rowAt: 1) at: 3) = 10].
    self should: [ ((c rowAt: 2) at: 1) = 18].
    self should: [ ((c rowAt: 2) at: 2) = 14].
    self should: [ ((c rowAt: 2) at: 3) = 4].
!

testVectorMatrixOperation
    "Code Example 8.1"
    | a u v |
    a := DhbMatrix rows: #( ( 1 0 1) (-1 -2 3)).
    u := #(1 2 3) asVector.
    v := a * u.
    self should: [ v size = 2].
    self should: [ (v at: 1) = 4].
    self should: [ (v at: 2) = 4].
!

testVectorOperation
    "Code Example 8.1"
    | u v w |
    u := #(1 2 3) asVector.
    v := #(3 4 5) asVector.
    w := 4 * u + (3 * v).
    self should: [ w size = 3].
    self should: [ (w at: 1) = 13].
    self should: [ (w at: 2) = 20].
    self should: [ (w at: 3) = 27].
!

testVectorOperationInverse

    | u v w |
    u := #(1 2 3) asVector.
    v := #(3 4 5) asVector.
    w := v * 4 - (3 * u).
    self should: [ w size = 3].
    self should: [ (w at: 1) = 9].
    self should: [ (w at: 2) = 10].
    self should: [ (w at: 3) = 11].
!

testVectorProduct
    "Code Example 8.1"
    | u v |
    u := #(1 2 3) asVector.
    v := #(3 4 5) asVector.
    self should: [ u * v = 26].
!

testVectorTransposeMatrixOperation
    "Code Example 8.1"
    | c v w |
    c := DhbMatrix rows: #( ( 6 8 10) (18 14 4)).
    v := #(4 4) asVector.
    w := c transpose * v.
    self should: [ w size = 3].
    self should: [ (w at: 1) = 96].
    self should: [ (w at: 2) = 88].
    self should: [ (w at: 3) = 56].
! !

!DhbNumericalMethodsTestCase methodsFor:'optimization'!

testOptimize
    "General optimizer to test genetic algorithm"
    | fBlock finder result |
    fBlock := [ :x | |r| r := x * x. r = 0 ifTrue: [ 1] ifFalse: [ r sqrt sin / r] ].
    finder := DhbMultiVariableGeneralOptimizer maximizingFunction: fBlock.
    finder desiredPrecision: 1.0d-6.
    finder origin: #( 0.5d 1.0d 0.5d) asVector; range: #(2 2 2) asVector.
    result := finder evaluate.
    self should: [ finder precision < 1.0d-6].
    self should: [ (result at: 1) abs < 1.0d-6].
    self should: [ (result at: 2) abs < 1.0d-6].
    self should: [ (result at: 3) abs < 1.0d-6].
!

testOptimizeOneDimension
    "Code example 11.1"
    | distr finder maximum |
    distr := DhbGammaDistribution shape: 2 scale: 5.
    finder := DhbOneVariableFunctionOptimizer maximizingFunction: distr.
    finder desiredPrecision: 1.0d-6.
    maximum := finder evaluate.
    self should: [ ( maximum - 5) abs < 1.0d-6].
    self should: [ finder precision < 1.0d-6].
!

testOptimizePowell
    "Code example 11.3"
    | fBlock hillClimber educatedGuess result |
    fBlock := [ :x | (x * x) negated exp].
    educatedGuess := #( 0.5d 1.0d 0.5d) asVector.
    hillClimber := DhbHillClimbingOptimizer maximizingFunction: fBlock.
    hillClimber initialValue: educatedGuess.
    hillClimber desiredPrecision: 1.0d-6.
    result := hillClimber evaluate.
    self should: [ hillClimber precision < 1.0d-6].
    self should: [ (result at: 1) abs < 1.0d-6].
    self should: [ (result at: 2) abs < 1.0d-6].
    self should: [ (result at: 3) abs < 1.0d-6].
!

testOptimizeSimplex
    "Code example 11.5"
    | fBlock simplex educatedGuess result |
    fBlock := [ :x | (x * x) negated exp].
    educatedGuess := #( 0.5d 1d 0.5d) asVector.
    simplex := DhbSimplexOptimizer maximizingFunction: fBlock.
    simplex initialValue: educatedGuess.
    simplex desiredPrecision: 1.0d-6.
    result := simplex evaluate.
    self should: [ simplex precision < 1.0d-6].
    self should: [ (result at: 1) abs < 1.0d-6].
    self should: [ (result at: 2) abs < 1.0d-6].
    self should: [ (result at: 3) abs < 1.0d-6].
! !

!DhbNumericalMethodsTestCase methodsFor:'privateMethods'!

accumulateAround: aVector size: aNumber into: aCollection
    "Private - Generate a random point around the given center and insert it into the collection.
		    aNumber is the sigma for the distance to the center"
    | r phi psi localVector |

    r := ( DhbNormalDistribution new: 0 sigma: aNumber) random.
    phi := FloatD pi random.
    psi := FloatD pi random.
    localVector := DhbVector new: 3.
    localVector at: 1 put: ( phi sin * psi sin * r );
		at: 2 put: ( phi cos * psi sin * r );
		at: 3 put: ( psi cos * r ).
    aCollection add: (localVector + aVector).
!

generatedPoints: anInteger
    "Private - Generate random points into aCollection. 3 clusters are used"
    | centers results |
    centers := Array new: 3.
    centers at: 1 put: #( 200 200  200) asVector;
		 at: 2 put: #(-200 200  200) asVector;
		 at: 3 put: #( 200 200 -200) asVector.
    results := OrderedCollection new.
    anInteger timesRepeat: [ self accumulateAround: ( centers at: (3 random + 1)) size: 1 into: results].
    ^results
!

setUp
    "Reset the seed of the random numbers (to get consistent results)"
    DhbMitchellMooreGenerator reset: 0
! !

!DhbNumericalMethodsTestCase methodsFor:'statistics'!

testGammaDistribution
    | dist |
    dist := DhbGammaDistribution shape: 3.4d scale: 1.7d.
    self should: [ (dist average - (3.4d * 1.7d)) abs < 0.000000001d].
    self should: [ (dist standardDeviation - (3.4d sqrt *1.7d)) abs < 0.000000001d].
    self should: [ ((dist value: 4.5d) - 0.1446067652d) abs < 0.000000001d].
    self should: [ ((dist distributionValue: 4.5) - 0.3982869736d) abs < 0.000000001d].
!

testHistogram
    | histogram |
    histogram := DhbHistogram new.
    histogram setRangeFrom: 0.0 to: 48.0 bins: 8.
    #( 36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22  6 15 41 22  14 14  31 42 3 42 22 8  37 41 )
	do: [ :x | histogram accumulate: x].
    histogram accumulate: -1; accumulate: 55; accumulate: 56.
    self should: [ histogram count = 30].
    self should: [ histogram underflow = 1].
    self should: [ histogram overflow = 2].
    self should: [ ( histogram countAt: 1) = 3].
    self should: [ ( histogram countAt: 8.5) = 4].
    self should: [ ( histogram countAt: 16) = 8].
    self should: [ ( histogram countAt: 23.5) = 4].
    self should: [ ( histogram countAt: 31) = 6].
    self should: [ ( histogram countAt: 38.5) = 4].
    self should: [ ( histogram countAt: 46) = 1].
    self should: [ (histogram average - 24.1333333333d) abs < 0.000000001d].
    self should: [ (histogram standardDeviation - 12.461619237603d) abs < 0.000000001d].
    self should: [ (histogram skewness - 0.116659884676d) abs < 0.000000001d].
    self should: [ (histogram kurtosis + 1.004665562311d) abs < 0.000000001d].
!

testNormalDistribution
    | dist |
    dist := DhbNormalDistribution new: 3.4d sigma: 1.7d.
    self should: [ (dist average - 3.4d) abs < 0.000000001d].
    self should: [ (dist standardDeviation - 1.7d) abs < 0.000000001d].
    self should: [ ((dist value: 4.5d) - 0.1903464693d) abs < 0.000000001d].
    self should: [ ((dist distributionValue: 4.5d) - 0.7412031298d) abs < 0.000000001d].
!

testStatisticalMoments
    "comment"
    | accumulator |
    accumulator := DhbStatisticalMoments new.
    #( 36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22  6 15 41 22  14 14  31 42 3 42 22 8  37 41 )
	do: [ :x | accumulator accumulate: x].
    self should: [ (accumulator average - 24.1333333333d) abs < 0.000000001d].
    self should: [ (accumulator standardDeviation - 12.461619237603d) abs < 0.000000001d].
    self should: [(accumulator skewness - 0.116659884676d) abs < 0.000000001d].
    self should: [ (accumulator kurtosis + 1.004665562311d) abs < 0.000000001d].
!

testStatisticalMomentsFast

    | accumulator |
    accumulator := DhbFastStatisticalMoments new.
    #( 36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22  6 15 41 22  14 14  31 42 3 42 22 8  37 41 )
	do: [ :x | accumulator accumulate: x].
    self should: [ (accumulator average - 24.1333333333d) abs < 0.000000001d].
    self should: [ (accumulator standardDeviation - 12.461619237603d) abs < 0.000000001d].
    self should: [ (accumulator skewness - 0.116659884676d) abs < 0.000000001d].
    self should: [ (accumulator kurtosis + 1.004665562311d) abs < 0.000000001d].
!

testStatisticalMomentsFixed

    | accumulator |
    accumulator := DhbFixedStatisticalMoments new.
    #( 36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22  6 15 41 22  14 14  31 42 3 42 22 8  37 41 )
	do: [ :x | accumulator accumulate: x].
    self should: [ (accumulator average - 24.1333333333d) abs < 0.000000001d].
    self should: [ (accumulator standardDeviation - 12.461619237603d) abs < 0.000000001d].
    self should: [ (accumulator skewness - 0.116659884676d) abs < 0.000000001d].
    self should: [ (accumulator kurtosis + 1.004665562311d) abs < 0.000000001d].
! !

DhbTestCase subclass:#DhbTestNumericPrecision
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbTestNumericPrecision methodsFor:'decimal floating number'!

testDecimalAdd
    | a b |
    a := DhbDecimalFloatingNumber new: 1.
    b := DhbDecimalFloatingNumber new: 2.    
    self assert: (a + b) value = 3.

    a := DhbDecimalFloatingNumber new: 1.56.
    b := DhbDecimalFloatingNumber new: 2.2    .
    self assert: (a + b) value = 3.76.
!

testDecimalMultiple
    | a b result |
    a := DhbDecimalFloatingNumber new: 2.
    b := DhbDecimalFloatingNumber new: 2.    
    self assert: (a * b) value = 4.

    a := DhbDecimalFloatingNumber new: 1.5.
    b := DhbDecimalFloatingNumber new: 2.5    .
    result :=  ((a * b) value asFloat) - (1.5 * 2.5).
    self assert: result abs < 0.00001.
! !

!DhbTestNumericPrecision methodsFor:'floating point machine'!

testComputeLargestNumber
    | machine |
    machine := DhbFloatingPointMachine new .
    machine computeLargestNumber.
    self assert: machine largestNumber > 1.0e25.
!

testComputeSmallestNumber
    | machine |
    machine := DhbFloatingPointMachine new .
    machine computeSmallestNumber.
    self assert: machine smallestNumber < 1.0e-25.
!

testMachinePrecision
    | machine |
    machine := DhbFloatingPointMachine new .
    machine computeMachinePrecision.
    self assert: machine machinePrecision < 1.0e-5.
! !

DhbTestCase subclass:#DhbTestFunctions
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbTestFunctions methodsFor:'polynomial'!

testAdd
    | a b c |

    a := DhbPolynomial coefficients: #(2 1 1).
    c := a + 3.
    self assert: (c coefficients  = #(5 1 1 )).

    b := DhbPolynomial coefficients: #(1 5 ).
    c := a + b.
    self assert: (c coefficients  =  #(3 6 1 )).
!

testDerivative
    | a answer |
    a := DhbPolynomial coefficients: #(5 2 3).
    answer := DhbPolynomial coefficients: #(2 6).
    self assert: (a derivative  =  answer).
!

testDivide
    | a b c answer |
    a := DhbPolynomial coefficients: #(9 6 3).
    c := a / 3.
    self assert: (c coefficients  = #(3 2 1  )).

    answer := DhbPolynomial coefficients: #(3 3 ).
    b := DhbPolynomial coefficients: #(1 1 ).
    a := answer * b.
    c := a / b.
    self assert: (c   =  answer ).
!

testEqual
    | a b |

    a := DhbPolynomial coefficients: #(5 2 3).
    b := DhbPolynomial coefficients: #(5 2 3).
    self assert: a = b.
!

testIntegral
    | a b |
    a := DhbPolynomial coefficients: #(0 2 3).
    b := a derivative.
    self assert: (b integral  =  a).
!

testMultiply
    | a b c |
    a := DhbPolynomial coefficients: #(3 2 1).
    c := a * 3.
    self assert: (c coefficients  = #(9 6 3  )).

    b := DhbPolynomial coefficients: #(1 1 ).
    c := a * b.
    self assert: (c coefficients  =  #(3 5 3 1 )).
!

testValue
    | square |
    square := DhbPolynomial coefficients: #(2 1 1).
    self 
	assert: (square value: 1) = 4;
	assert: (square value: 3 ) = ((2) + (1*3) + (1*3*3)).

    square := DhbPolynomial coefficients: #(2 ).
    self 
	assert: (square value: 1) = 2;
	assert: (square value: 0) = 2.
! !

DhbTestCase subclass:#DhbTestBeta
    instanceVariableNames:''
    classVariableNames:''
    poolDictionaries:''
    category:'DHB Numerical SUnits'
!


!DhbTestBeta methodsFor:'tests'!

testBeta
    self assert: (2 beta:4) isNumber
! !

