"======================================================================
|
|   Numerical methods - Optimization / Operations Research
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



Object subclass: DhbProjectedOneVariableFunction [
    | index function argument |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProjectedOneVariableFunction class >> function: aVectorFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^super new initialize: aVectorFunction
    ]

    argumentWith: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^argument
	    at: index put: aNumber;
	    yourself
    ]

    index [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	index isNil ifTrue: [index := 1].
	^index
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^function value: (self argumentWith: aNumber)
    ]

    initialize: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	function := aFunction.
	^self
    ]

    setArgument: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	argument := anArrayOrVector copy
    ]

    setIndex: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	index := anInteger
    ]

    bumpIndex [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	index isNil 
	    ifTrue: [index := 1]
	    ifFalse: 
		[index := index + 1.
		index > argument size ifTrue: [index := 1]]
    ]
]



DhbFunctionalIterator subclass: DhbFunctionOptimizer [
    | optimizingPointClass bestPoints |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbFunctionOptimizer class >> forOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^self new initializeForOptimizer: aFunctionOptimizer
    ]

    DhbFunctionOptimizer class >> maximizingFunction: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    initializeAsMaximizer;
	    setFunction: aFunction
    ]

    DhbFunctionOptimizer class >> minimizingFunction: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    initializeAsMinimizer;
	    setFunction: aFunction
    ]

    DhbFunctionOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^super defaultPrecision * 100
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	super printOn: aStream.
	bestPoints do: 
		[:each | 
		aStream cr.
		each printOn: aStream]
    ]

    bestPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^bestPoints
    ]

    functionBlock [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^functionBlock
    ]

    pointClass [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^optimizingPointClass
    ]

    initialize [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints := SortedCollection sortBlock: [:a :b | a betterThan: b].
	^super initialize
    ]

    initializeAsMaximizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := DhbMaximizingPoint.
	^self initialize
    ]

    initializeAsMinimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := DhbMinimizingPoint.
	^self
    ]

    initializeForOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := aFunctionOptimizer pointClass.
	functionBlock := aFunctionOptimizer functionBlock.
	^self initialize
    ]

    initialValue: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	result := aVector copy
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	result := bestPoints first position
    ]

    addPointAt: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	bestPoints 
	    add: (optimizingPointClass vector: aNumber function: functionBlock)
    ]
]



Object subclass: DhbMinimizingPoint [
    | value position |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMinimizingPoint class >> new: aVector value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'creation'>
	^(self new)
	    vector: aVector;
	    value: aNumber;
	    yourself
    ]

    DhbMinimizingPoint class >> vector: aVector function: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'creation'>
	^self new: aVector value: (aFunction value: aVector)
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 05-Jan-00"

	<category: 'display'>
	position printOn: aStream.
	aStream
	    nextPut: $:;
	    space.
	value printOn: aStream
    ]

    betterThan: anOptimizingPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value < anOptimizingPoint value
    ]

    position [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^position
    ]

    value [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	value := aNumber
    ]

    vector: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	position := aVector
    ]
]



DhbFunctionOptimizer subclass: DhbOneVariableFunctionOptimizer [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    GoldenSection := nil.

    DhbOneVariableFunctionOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision * 10
    ]

    DhbOneVariableFunctionOptimizer class >> goldenSection [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	GoldenSection isNil ifTrue: [GoldenSection := (3 - 5 sqrt) / 2].
	^GoldenSection
    ]

    computePrecision [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^self 
	    precisionOf: ((bestPoints at: 2) position - (bestPoints at: 3) position) 
		    abs
	    relativeTo: (bestPoints at: 1) position abs
    ]

    hasBracketingPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| x1 |
	x1 := (bestPoints at: 1) position.
	^((bestPoints at: 2) position - x1) * ((bestPoints at: 3) position - x1) 
	    < 0
    ]

    indexOfOuterPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| inferior superior x |
	inferior := false.
	superior := false.
	x := bestPoints first position.
	2 to: 4
	    do: 
		[:n | 
		(bestPoints at: n) position < x 
		    ifTrue: 
			[inferior ifTrue: [^n].
			inferior := true]
		    ifFalse: 
			[superior ifTrue: [^n].
			superior := true]]
    ]

    nextXValue [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| d3 d2 x1 |
	x1 := (bestPoints at: 1) position.
	d2 := (bestPoints at: 2) position - x1.
	d3 := (bestPoints at: 3) position - x1.
	^(d3 abs > d2 abs ifTrue: [d3] ifFalse: [d2]) * self class goldenSection 
	    + x1
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	[bestPoints size > 3] whileTrue: [bestPoints removeLast].
	bestPoints size = 3 
	    ifTrue: [self hasBracketingPoints ifFalse: [bestPoints removeLast]].
	bestPoints size < 3 
	    ifTrue: [(DhbOptimizingBracketFinder forOptimizer: self) evaluate]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	self addPointAt: self nextXValue.
	bestPoints removeAtIndex: self indexOfOuterPoint.
	^self computePrecision
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	[bestPoints isEmpty] whileFalse: [bestPoints removeLast]
    ]
]



DhbFunctionOptimizer subclass: DhbMultiVariableGeneralOptimizer [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    origin [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	^result
    ]

    origin: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	result := anArrayOrVector
    ]

    range [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	^self bestPoints
    ]

    range: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	bestPoints := anArrayOrVector
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	self range notNil ifTrue: [self performGeneticOptimization].
	self performSimplexOptimization
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| optimizer |
	optimizer := DhbHillClimbingOptimizer forOptimizer: self.
	optimizer
	    desiredPrecision: desiredPrecision;
	    maximumIterations: maximumIterations;
	    initialValue: result.
	result := optimizer evaluate.
	^optimizer precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	
    ]

    performGeneticOptimization [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	| optimizer manager |
	optimizer := DhbGeneticOptimizer forOptimizer: self.
	manager := DhbVectorChromosomeManager 
		    new: 100
		    mutation: 0.1
		    crossover: 0.1.
	manager
	    origin: self origin asVector;
	    range: self range asVector.
	optimizer chromosomeManager: manager.
	result := optimizer evaluate
    ]

    performSimplexOptimization [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	| optimizer |
	optimizer := DhbSimplexOptimizer forOptimizer: self.
	optimizer
	    desiredPrecision: desiredPrecision sqrt;
	    maximumIterations: maximumIterations;
	    initialValue: result asVector.
	result := optimizer evaluate
    ]
]



Object subclass: DhbChromosomeManager [
    | population populationSize rateOfMutation rateOfCrossover |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbChromosomeManager class >> new: anInteger mutation: aNumber1 crossover: aNumber2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'creation'>
	^(self new)
	    populationSize: anInteger;
	    rateOfMutation: aNumber1;
	    rateOfCrossover: aNumber2;
	    yourself
    ]

    randomChromosome [
	<category: 'creation'>
	self subclassResponsibility
    ]

    isFullyPopulated [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^population size >= populationSize
    ]

    population [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^population
    ]

    populationSize: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	populationSize := anInteger
    ]

    rateOfCrossover: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	(aNumber between: 0 and: 1) 
	    ifFalse: [self error: 'Illegal rate of cross-over'].
	rateOfCrossover := aNumber
    ]

    rateOfMutation: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	(aNumber between: 0 and: 1) 
	    ifFalse: [self error: 'Illegal rate of mutation'].
	rateOfMutation := aNumber
    ]

    clone: aChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^aChromosome copy
    ]

    crossover: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    mutate: aChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    process: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| roll |
	roll := Number random.
	roll < rateOfCrossover 
	    ifTrue: [population addAll: (self crossover: aChromosome1 and: aChromosome2)]
	    ifFalse: 
		[roll < (rateOfCrossover + rateOfMutation) 
		    ifTrue: 
			[population
			    add: (self mutate: aChromosome1);
			    add: (self mutate: aChromosome2)]
		    ifFalse: 
			[population
			    add: (self clone: aChromosome1);
			    add: (self clone: aChromosome2)]]
    ]

    randomizePopulation [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	self reset.
	[self isFullyPopulated] 
	    whileFalse: [population add: self randomChromosome]
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'transformation'>
	population := OrderedCollection new: populationSize
    ]
]



DhbFunctionOptimizer subclass: DhbHillClimbingOptimizer [
    | unidimensionalFinder |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 05-Jan-00"

	<category: 'initialization'>
	unidimensionalFinder := DhbOneVariableFunctionOptimizer forOptimizer: self.
	unidimensionalFinder desiredPrecision: desiredPrecision.
	bestPoints := (1 to: result size) collect: 
			[:n | 
			(DhbVectorProjectedFunction function: functionBlock)
			    direction: ((DhbVector new: result size)
					atAllPut: 0;
					at: n put: 1;
					yourself);
			    yourself]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| oldResult |
	precision := 1.0.
	bestPoints inject: result
	    into: [:prev :each | self minimizeDirection: each from: prev].
	self shiftDirections.
	self minimizeDirection: bestPoints last.
	oldResult := result.
	result := bestPoints last origin.
	precision := 0.0.
	result with: oldResult
	    do: 
		[:x0 :x1 | 
		precision := (self precisionOf: (x0 - x1) abs relativeTo: x0 abs) 
			    max: precision].
	^precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	
    ]

    minimizeDirection: aVectorFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	^unidimensionalFinder
	    reset;
	    setFunction: aVectorFunction;
	    addPointAt: 0;
	    addPointAt: precision;
	    addPointAt: precision negated;
	    evaluate
    ]

    minimizeDirection: aVectorFunction from: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	^aVectorFunction
	    origin: aVector;
	    argumentWith: (self minimizeDirection: aVectorFunction)
    ]

    shiftDirections [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| position delta firstDirection |
	firstDirection := bestPoints first direction.
	bestPoints inject: nil
	    into: 
		[:prev :each | 
		position isNil 
		    ifTrue: [position := each origin]
		    ifFalse: [prev direction: each direction].
		each].
	position := bestPoints last origin - position.
	delta := position norm.
	delta > desiredPrecision 
	    ifTrue: [bestPoints last direction: (position scaleBy: 1 / delta)]
	    ifFalse: [bestPoints last direction: firstDirection]
    ]
]



DhbFunctionOptimizer subclass: DhbGeneticOptimizer [
    | chromosomeManager |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbGeneticOptimizer class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^500
    ]

    DhbGeneticOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^0
    ]

    computePrecision [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^1
    ]

    randomIndex: aNumberArray [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	| x n |
	x := Number random.
	n := 1.
	aNumberArray do: 
		[:each | 
		x < each ifTrue: [^n].
		n := n + 1].
	^aNumberArray size	"Never reached unless an error occurs"
    ]

    randomScale [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	| norm fBest fWorst answer |
	fBest := bestPoints first value.
	fWorst := bestPoints last value.
	norm := 1 / (fBest - fWorst).
	answer := bestPoints collect: [:each | (each value - fWorst) * norm].
	norm := 1 / (answer inject: 0 into: [:sum :each | each + sum]).
	fBest := 0.
	^answer collect: 
		[:each | 
		fBest := each * norm + fBest.
		fBest]
    ]

    chromosomeManager: aChromosomeManager [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	chromosomeManager := aChromosomeManager.
	^self
    ]

    collectPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| bestPoint |
	bestPoints isEmpty not ifTrue: [bestPoint := bestPoints removeFirst].
	bestPoints removeAll: bestPoints asArray.
	chromosomeManager population do: [:each | self addPointAt: each].
	bestPoint notNil ifTrue: [bestPoints add: bestPoint].
	result := bestPoints first position
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| randomScale |
	randomScale := self randomScale.
	chromosomeManager reset.
	[chromosomeManager isFullyPopulated] 
	    whileFalse: [self processRandomParents: randomScale].
	self collectPoints.
	^self computePrecision
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	chromosomeManager randomizePopulation.
	self collectPoints
    ]

    processRandomParents: aNumberArray [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	chromosomeManager 
	    process: (bestPoints at: (self randomIndex: aNumberArray)) position
	    and: (bestPoints at: (self randomIndex: aNumberArray)) position
    ]
]



DhbMinimizingPoint subclass: DhbMaximizingPoint [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    betterThan: anOptimizingPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value > anOptimizingPoint value
    ]
]



DhbFunctionOptimizer subclass: DhbSimplexOptimizer [
    | worstVector |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbSimplexOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision * 1000
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	super printOn: aStream.
	aStream cr.
	worstVector printOn: aStream
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints 
	    add: (optimizingPointClass vector: result function: functionBlock).
	self buildInitialSimplex.
	worstVector := bestPoints removeLast position
    ]

    buildInitialSimplex [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| projectedFunction finder partialResult |
	projectedFunction := DhbProjectedOneVariableFunction 
		    function: functionBlock.
	finder := DhbOneVariableFunctionOptimizer forOptimizer: self.
	finder setFunction: projectedFunction.
	[bestPoints size < (result size + 1)] whileTrue: 
		[projectedFunction
		    setArgument: result;
		    bumpIndex.
		partialResult := finder
			    reset;
			    evaluate.
		bestPoints add: (optimizingPointClass 
			    vector: (projectedFunction argumentWith: partialResult)
			    function: functionBlock)]
    ]

    computePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	| functionValues bestFunctionValue |
	functionValues := bestPoints collect: [:each | each value].
	bestFunctionValue := functionValues removeFirst.
	^functionValues inject: 0
	    into: 
		[:max :each | 
		(self precisionOf: (each - bestFunctionValue) abs
		    relativeTo: bestFunctionValue abs) max: max]
    ]

    contract [
	"Private - Contract the Simplex around the best Vector.
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	| bestVector oldVectors |
	bestVector := bestPoints first position.
	oldVectors := OrderedCollection with: worstVector.
	[bestPoints size > 1] 
	    whileTrue: [oldVectors add: bestPoints removeLast position].
	oldVectors do: [:each | self contract: each around: bestVector].
	worstVector := bestPoints removeLast position.
	^self computePrecision
    ]

    contract: aVector around: bestVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	bestPoints 
	    add: (optimizingPointClass vector: bestVector * 0.5 + (aVector * 0.5)
		    function: functionBlock)
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| centerOfGravity newPoint nextPoint |
	centerOfGravity := (bestPoints inject: ((worstVector copy)
			    atAllPut: 0;
			    yourself)
		    into: [:sum :each | each position + sum]) * (1 / bestPoints size).
	newPoint := optimizingPointClass vector: 2 * centerOfGravity - worstVector
		    function: functionBlock.
	(newPoint betterThan: bestPoints first) 
	    ifTrue: 
		[nextPoint := optimizingPointClass 
			    vector: newPoint position * 2 - centerOfGravity
			    function: functionBlock.
		(nextPoint betterThan: newPoint) ifTrue: [newPoint := nextPoint]]
	    ifFalse: 
		[newPoint := optimizingPointClass 
			    vector: centerOfGravity * 666667 + (worstVector * 333333)
			    function: functionBlock.
		(newPoint betterThan: bestPoints first) ifFalse: [^self contract]].
	worstVector := bestPoints removeLast position.
	bestPoints add: newPoint.
	result := bestPoints first position.
	^self computePrecision
    ]
]



DhbProjectedOneVariableFunction subclass: DhbVectorProjectedFunction [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	self origin printOn: aStream.
	aStream nextPutAll: ' ('.
	self direction printOn: aStream.
	aStream nextPut: $)
    ]

    argumentWith: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^aNumber * self direction + self origin
    ]

    direction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^index
    ]

    origin [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^argument
    ]

    direction: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	index := aVector
    ]

    origin: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	argument := aVector
    ]
]



DhbOneVariableFunctionOptimizer subclass: DhbOptimizingBracketFinder [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbOptimizingBracketFinder class >> initialPoints: aSortedCollection function: aFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    setInitialPoints: aSortedCollection;
	    setFunction: aFunction
    ]

    initializeForOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	super initializeForOptimizer: aFunctionOptimizer.
	bestPoints := aFunctionOptimizer bestPoints.
	^self
    ]

    setInitialPoints: aSortedCollection [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints := aSortedCollection
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	[bestPoints size < 2] whileTrue: [self addPointAt: Number random]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| x1 x2 |
	x1 := (bestPoints at: 1) position.
	x2 := (bestPoints at: 2) position.
	self addPointAt: x1 * 3 - (x2 * 2).
	precision := (x2 - x1) * ((bestPoints at: 3) position - x1).
	self hasConverged ifFalse: [bestPoints removeLast].
	^precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	result := bestPoints
    ]
]



DhbChromosomeManager subclass: DhbVectorChromosomeManager [
    | origin range |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    randomChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'creation'>
	^((1 to: origin size) collect: [:n | self randomComponent: n]) asVector
    ]

    randomComponent: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^(range at: anInteger) asFloatD random + (origin at: anInteger)
    ]

    origin: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	origin := aVector
    ]

    range: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	range := aVector
    ]

    crossover: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| index new1 new2 |
	index := (aChromosome1 size - 1) random + 2.
	new1 := self clone: aChromosome1.
	new1 
	    replaceFrom: index
	    to: new1 size
	    with: aChromosome2
	    startingAt: index.
	new2 := self clone: aChromosome2.
	new2 
	    replaceFrom: index
	    to: new2 size
	    with: aChromosome1
	    startingAt: index.
	^Array with: new1 with: new2
    ]

    mutate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| index |
	index := aVector size random + 1.
	^(aVector copy)
	    at: index put: (self randomComponent: index);
	    yourself
    ]
]

