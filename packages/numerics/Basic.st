"======================================================================
|
|   Numerical methods - Basic objects and concepts
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


Object subclass:  #DhbIterativeProcess
	instanceVariableNames: 'precision desiredPrecision maximumIterations result iterations '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbIterativeProcess comment: 
nil!

DhbIterativeProcess subclass:  #DhbFunctionalIterator
	instanceVariableNames: 'functionBlock relativePrecision '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbFunctionalIterator comment: 
nil!

Object subclass:  #DhbPolynomial
	instanceVariableNames: 'coefficients '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbPolynomial comment: 
nil!

Object subclass:  #DhbDecimalFloatingNumber
	instanceVariableNames: 'mantissa exponent '
	classVariableNames: 'Digits '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbDecimalFloatingNumber comment: 
nil!

DhbPolynomial subclass:  #DhbEstimatedPolynomial
	instanceVariableNames: 'errorMatrix '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbEstimatedPolynomial comment: 
nil!

Object subclass:  #DhbFloatingPointMachine
	instanceVariableNames: 'defaultNumericalPrecision radix machinePrecision negativeMachinePrecision smallestNumber largestNumber smallNumber largestExponentArgument '
	classVariableNames: 'UniqueInstance '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbFloatingPointMachine comment: 
nil!

Array variableSubclass:  #DhbVector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbVector comment: 
nil!

!DhbIterativeProcess class methodsFor: 'creation'!

new
    "Create an instance of the class.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^super new initialize! !

!DhbIterativeProcess class methodsFor: 'information'!

defaultMaximumIterations
    "Private - Answers the default maximum number of iterations for newly created instances.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^50!

defaultPrecision
    "Private - Answers the default precision for newly created instances.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^DhbFloatingPointMachine new defaultNumericalPrecision! !

!DhbIterativeProcess methodsFor: 'information'!

hasConverged
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 20/4/99 "

    ^precision <= desiredPrecision!

iterations
    "Answers the number of iterations performed.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^iterations!

limitedSmallValue: aNumber 
    "Private - prevent aNumber from being smaller in absolute value than a small number.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/3/99 "

    ^aNumber abs < DhbFloatingPointMachine new smallNumber 
	ifTrue: [DhbFloatingPointMachine new smallNumber]
	ifFalse: [aNumber]!

precision
    "Answer the attained precision for the result.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^precision!

precisionOf: aNumber1 relativeTo: aNumber2 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 3/5/99 "

    ^aNumber2 > DhbFloatingPointMachine new defaultNumericalPrecision 
	ifTrue: [aNumber1 / aNumber2]
	ifFalse: [aNumber1]!

result
    "Answer the result of the iterations (if any)
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^result! !

!DhbIterativeProcess methodsFor: 'initialization'!

desiredPrecision: aNumber 
    "Defines the desired precision for the result.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    aNumber > 0 
	ifFalse: [^self error: 'Illegal precision: ' , aNumber printString].
    desiredPrecision := aNumber!

initialize
    "Private - initialize the parameters of the receiver with default values.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    desiredPrecision := self class defaultPrecision.
    maximumIterations := self class defaultMaximumIterations.
    ^self!

maximumIterations: anInteger 
    "Defines the maximum number of iterations.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    (anInteger isInteger and: [anInteger > 1]) 
	ifFalse: 
	    [^self 
		error: 'Invalid maximum number of iteration: ' , anInteger printString].
    maximumIterations := anInteger! !

!DhbIterativeProcess methodsFor: 'operation'!

evaluate
    "Perform the iteration until either the desired precision is attained or the number of iterations exceeds the maximum.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    iterations := 0.
    self initializeIterations.
    
    [iterations := iterations + 1.
    precision := self evaluateIteration.
    self hasConverged or: [iterations >= maximumIterations]] 
	    whileFalse: [].
    self finalizeIterations.
    ^self result!

evaluateIteration
    "Dummy method (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ^self subclassResponsibility!

finalizeIterations
    "Perform cleanup operation if needed (must be implemented by subclass).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/3/99 "

    !

initializeIterations
    "Initialize the iterations (must be implemented by subclass when needed).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    ! !




!DhbFunctionalIterator class methodsFor: 'creation'!

function: aBlock 
    "Convenience method to create a instance with given function block.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    ^(self new)
	setFunction: aBlock;
	yourself! !

!DhbFunctionalIterator methodsFor: 'information'!

relativePrecision: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 27/4/99 "

    ^self precisionOf: aNumber relativeTo: result abs! !

!DhbFunctionalIterator methodsFor: 'initialization'!

setFunction: aBlock 
    "Defines the function for which zeroes will be found.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 7/1/99 "

    (aBlock respondsTo: #value:) 
	ifFalse: [self error: 'Function block must implement the method value:'].
    functionBlock := aBlock! !

!DhbFunctionalIterator methodsFor: 'operation'!

computeInitialValues
    self subclassResponsibility!

initializeIterations
    "If no initial value has been defined, take 0 as the starting point (for lack of anything better).
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/1/99 "

    functionBlock isNil ifTrue: [self error: 'No function supplied'].
    self computeInitialValues! !




!DhbPolynomial class methodsFor: 'creation'!

coefficients: anArray 
    " Creates a new instance with given coefficients
                 (c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 4/1/99 "

    ^self new initialize: anArray reverse! !

!DhbPolynomial methodsFor: 'comparing'!

= aNumberOrPolynomial 
    aNumberOrPolynomial isNil ifTrue: [^false].
    aNumberOrPolynomial isNumber 
	ifTrue: 
	    [^coefficients size = 1 and: [coefficients first = aNumberOrPolynomial]].
    aNumberOrPolynomial class = self class ifFalse: [^false].
    ^self coefficients = aNumberOrPolynomial coefficients!

hash
    ^coefficients hash! !

!DhbPolynomial methodsFor: 'creation'!

deflatedAt: aNumber 
    "Answers a new polynomial quotient of the receiver with polynomial (X-aNumber)
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 20/4/99 "

    | remainder next newCoefficients |
    remainder := 0.
    newCoefficients := coefficients collect: 
		    [:each | 
		    next := remainder.
		    remainder := remainder * aNumber + each.
		    next].
    ^self class 
	coefficients: (newCoefficients copyFrom: 2 to: newCoefficients size) 
		reverse!

derivative
    "Answer a new polynomial, derivative of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    | n |
    n := coefficients size.
    ^self class 
	coefficients: ((coefficients collect: 
		    [:each | 
		    n := n - 1.
		    each * n]) 
		reverse copyFrom: 2 to: coefficients size)!

integral
    "Answer a new polynomial, integral of the receiver with value 0 at x=0.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    ^self integral: 0!

integral: aValue 
    "Answer a new polynomial, integral of the receiver with given value at x=0.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    | n |
    n := coefficients size + 1.
    ^self class 
	coefficients: ((coefficients collect: 
		    [:each | 
		    n := n - 1.
		    each / n]) 
		copyWith: aValue) reverse! !

!DhbPolynomial methodsFor: 'display'!

printOn: aStream 
    "Append to aStream a written representation of the receiver. 
	(c) Copyrights Didier BESSET, 1999, all rights reserved. 
	Initial code: 4/1/99"

    | n firstNonZeroCoefficientPrinted |
    n := 0.
    firstNonZeroCoefficientPrinted := false.
    coefficients reverseDo: 
	    [:each | 
	    each = 0 
		ifFalse: 
		    [firstNonZeroCoefficientPrinted 
			ifTrue: 
			    [aStream space.
			    each < 0 ifFalse: [aStream nextPut: $+].
			    aStream space]
			ifFalse: [firstNonZeroCoefficientPrinted := true].
		    (each = 1 and: [n > 0]) ifFalse: [each printOn: aStream].
		    n > 0 
			ifTrue: 
			    [aStream nextPutAll: ' X'.
			    n > 1 
				ifTrue: 
				    [aStream nextPut: $^.
				    n printOn: aStream]]].
	    n := n + 1]! !

!DhbPolynomial methodsFor: 'double dispatching'!

addNumber: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 19/4/99 "

    | newCoefficients |
    newCoefficients := coefficients reverse.
    newCoefficients at: 1 put: newCoefficients first + aNumber.
    ^self class coefficients: newCoefficients!

addPolynomial: aPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		collect: [:n | (aPolynomial at: n) + (self at: n)])!

differenceFromNumber: aFloatD 
    ^self subtractFrom: aFloatD!

dividingPolynomial: aPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    ^(self dividingPolynomialWithRemainder: aPolynomial) first!

dividingPolynomialWithRemainder: aPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 17/4/99 "

    | remainderCoefficients quotientCoefficients n m norm quotientDegree |
    n := self degree.
    m := aPolynomial degree.
    quotientDegree := m - n.
    quotientDegree < 0 
	ifTrue: [^Array with: (self class new: #(0)) with: aPolynomial].
    quotientCoefficients := Array new: quotientDegree + 1.
    remainderCoefficients := (0 to: m) collect: [:k | aPolynomial at: k].
    norm := 1 / coefficients first.
    quotientDegree to: 0
	by: -1
	do: 
	    [:k | 
	    | x |
	    x := (remainderCoefficients at: n + k + 1) * norm.
	    quotientCoefficients at: quotientDegree + 1 - k put: x.
	    n + k - 1 to: k
		by: -1
		do: 
		    [:j | 
		    remainderCoefficients at: j + 1
			put: (remainderCoefficients at: j + 1) - (x * (self at: j - k))]].
    ^Array with: (self class coefficients: quotientCoefficients reverse)
	with: (self class coefficients: (remainderCoefficients copyFrom: 1 to: n))!

productFromNumber: aFloatD 
    ^self * aFloatD!

subtractFrom: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    | newCoefficients |
    newCoefficients := (coefficients collect: [:c | c negated]) reverse.
    newCoefficients at: 1 put: newCoefficients first + aNumber.
    ^self class coefficients: newCoefficients!

subtractToPolynomial: aPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		collect: [:n | (aPolynomial at: n) - (self at: n)])!

sumFromNumber: aFloatD 
    ^self + aFloatD!

timesNumber: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 17/4/99 "

    ^self class 
	coefficients: (coefficients collect: [:each | each * aNumber]) reverse!

timesPolynomial: aPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    | productCoefficients degree |
    degree := aPolynomial degree + self degree.
    productCoefficients := (degree to: 0 by: -1) collect: 
		    [:n | 
		    | sum |
		    sum := 0.
		    0 to: degree - n
			do: [:k | sum := (self at: k) * (aPolynomial at: degree - n - k) + sum].
		    sum].
    ^self class coefficients: productCoefficients! !

!DhbPolynomial methodsFor: 'information'!

at: anInteger 
    "Answers the coefficient of order anInteger.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    ^anInteger < coefficients size 
	ifTrue: [coefficients at: coefficients size - anInteger]
	ifFalse: [0]!

coefficients
    "(c) Copyrights Didier BESSET, 1999, all rights reserved. 
        Initial code: 21/5/99"

    ^coefficients reverse!

degree
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    ^coefficients size - 1!

roots
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 20/4/99 "

    ^self roots: DhbFloatingPointMachine new defaultNumericalPrecision!

roots: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 20/4/99 "

    | pol roots x rootFinder |
    rootFinder := DhbNewtonZeroFinder new.
    rootFinder desiredPrecision: aNumber.
    pol := self class 
		coefficients: (coefficients reverse collect: [:each | each asFloatD]).
    roots := OrderedCollection new: self degree.
    
    [rootFinder
	setFunction: pol;
	setDerivative: pol derivative.
    x := rootFinder evaluate.
    rootFinder hasConverged] 
	    whileTrue: 
		[roots add: x.
		pol := pol deflatedAt: x.
		pol degree > 0 ifFalse: [^roots]].
    ^roots!

value: aNumber 
    "Answer the value of the polynomial for the specified variable value.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    ^coefficients inject: 0 into: [:sum :each | sum * aNumber + each]! !

!DhbPolynomial methodsFor: 'initialization'!

initialize: anArray 
    "Private - Initialize the coefficients of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 4/1/99 "

    coefficients := anArray.
    ^self! !

!DhbPolynomial methodsFor: 'numerics'!

generality
    ^nil! !

!DhbPolynomial methodsFor: 'operation'!

* aNumberOrPolynomial 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    ^aNumberOrPolynomial timesPolynomial: self!

+ aNumberOrPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^aNumberOrPolynomial addPolynomial: self!

- aNumberOrPolynomial 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "

    ^aNumberOrPolynomial subtractToPolynomial: self!

/ aNumberOrPolynomial 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "

    ^aNumberOrPolynomial dividingPolynomial: self! !




!DhbDecimalFloatingNumber class methodsFor: 'creation'!

new: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self new normalize: aNumber! !

!DhbDecimalFloatingNumber class methodsFor: 'information'!

defaultDigits
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^15!

digits
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    Digits isNil ifTrue: [Digits := self defaultDigits].
    ^Digits! !

!DhbDecimalFloatingNumber class methodsFor: 'transformation'!

defaultDigits: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    Digits := anInteger!

resetDigits
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    Digits := nil! !

!DhbDecimalFloatingNumber methodsFor: 'display'!

printOn: aStream 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    mantissa printOn: aStream.
    aStream nextPutAll: 'xE'.
    exponent negated printOn: aStream! !

!DhbDecimalFloatingNumber methodsFor: 'information'!

value
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^mantissa / (10 raisedToInteger: exponent)! !

!DhbDecimalFloatingNumber methodsFor: 'operation'!

* aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self class new: self value * aNumber value!

+ aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self class new: self value + aNumber value!

- aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self class new: self value - aNumber value!

/ aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self class new: self value / aNumber value!

sqrt
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    ^self class new: self value sqrt! !

!DhbDecimalFloatingNumber methodsFor: 'transformation'!

normalize: aNumber 
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 9/6/99 "

    exponent := (self class digits - (aNumber log: 10)) floor.
    mantissa := (aNumber * (10 raisedToInteger: exponent)) rounded.
    ^self! !




!DhbEstimatedPolynomial methodsFor: 'information'!

error: aNumber 
    "Compute the error on the value of the receiver for argument aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    | errorVector term nextTerm |
    nextTerm := 1.
    errorVector := (coefficients collect: 
		    [:each | 
		    term := nextTerm.
		    nextTerm := aNumber * nextTerm.
		    term]) 
		asVector.
    ^(errorVector * errorMatrix * errorVector) sqrt!

errorMatrix
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/5/99 "

    ^errorMatrix!

valueAndError: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 20/5/99 "

    ^Array with: (self value: aNumber) with: (self error: aNumber)! !

!DhbEstimatedPolynomial methodsFor: 'initialization'!

errorMatrix: aMatrix 
    "Defines the error matrix of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 18/3/99 "

    errorMatrix := aMatrix! !




!DhbFloatingPointMachine class methodsFor: 'creation'!

new
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    UniqueInstance = nil ifTrue: [UniqueInstance := super new].
    ^UniqueInstance!

reset
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    UniqueInstance := nil! !

!DhbFloatingPointMachine methodsFor: 'display'!

showParameters
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 10/6/99 "

    Transcript
	cr;
	cr;
	nextPutAll: 'Floating-point machine parameters';
	cr;
	nextPutAll: '---------------------------------';
	cr;
	nextPutAll: 'Radix: '.
    self radix printOn: Transcript.
    Transcript
	cr;
	nextPutAll: 'Machine precision: '.
    self machinePrecision printOn: Transcript.
    Transcript
	cr;
	nextPutAll: 'Negative machine precision: '.
    self negativeMachinePrecision printOn: Transcript.
    Transcript
	cr;
	nextPutAll: 'Smallest number: '.
    self smallestNumber printOn: Transcript.
    Transcript
	cr;
	nextPutAll: 'Largest number: '.
    self largestNumber printOn: Transcript! !

!DhbFloatingPointMachine methodsFor: 'information'!

computeLargestNumber
    "Private -
                 (c) Copyrights Didier BESSET, 1999, all rights reserved.
                 Initial code: 11/6/99 "

    | one floatingRadix fullMantissaNumber |
    one := 1.00000000000000.
    floatingRadix := self radix asFloatD.
    fullMantissaNumber := one 
		- (floatingRadix * self negativeMachinePrecision).
    largestNumber := fullMantissaNumber.
    
    [
    [fullMantissaNumber := fullMantissaNumber * floatingRadix.
    fullMantissaNumber isFinite ifFalse: [Error signal].
    largestNumber := fullMantissaNumber.
    true] 
	    whileTrue: []] 
	    on: Error
	    do: [:signal | signal return: nil]!

computeMachinePrecision
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    | one zero inverseRadix tmp |
    one := 1.00000000000000.
    zero := 0.0.
    inverseRadix := one / self radix asFloatD.
    machinePrecision := one.
    
    [tmp := one + machinePrecision.
    tmp - one = zero] 
	    whileFalse: [machinePrecision := machinePrecision * inverseRadix]!

computeNegativeMachinePrecision
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    | one zero floatingRadix inverseRadix tmp |
    one := 1.00000000000000.
    zero := 0.0.
    floatingRadix := self radix asFloatD.
    inverseRadix := one / floatingRadix.
    negativeMachinePrecision := one.
    
    [tmp := one - negativeMachinePrecision.
    tmp - one = zero] whileFalse: 
		[negativeMachinePrecision := negativeMachinePrecision * inverseRadix]!

computeRadix
    "Private -
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    | one zero a b tmp1 tmp2 |
    one := 1.00000000000000.
    zero := 0.0.
    a := one.
    
    [a := a + a.
    tmp1 := a + one.
    tmp2 := tmp1 - a.
    tmp2 - one = zero] 
	    whileTrue: [].
    b := one.
    
    [b := b + b.
    tmp1 := a + b.
    radix := (tmp1 - a) truncated.
    radix = 0] 
	    whileTrue: []!

computeSmallestNumber
    "Private - 
        (c) Copyrights Didier BESSET, 1999, all rights reserved. 
        Initial code: 11/6/99"

    | one floatingRadix inverseRadix fullMantissaNumber |
    one := 1 asFloatD.
    floatingRadix := self radix asFloatD.
    inverseRadix := one / floatingRadix.
    fullMantissaNumber := one 
		- (floatingRadix * self negativeMachinePrecision).
    smallestNumber := fullMantissaNumber.
    
    [
    [fullMantissaNumber := fullMantissaNumber * inverseRadix.
    fullMantissaNumber = 0.0 ifTrue: [Error signal].
    fullMantissaNumber isFinite ifFalse: [Error signal].
    smallestNumber := fullMantissaNumber.
    true] 
	    whileTrue: []] 
	    on: Error
	    do: [:signal | signal return: nil]!

defaultNumericalPrecision
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    defaultNumericalPrecision isNil 
	ifTrue: [defaultNumericalPrecision := self machinePrecision sqrt].
    ^defaultNumericalPrecision!

largestExponentArgument
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/18/00 "

    largestExponentArgument isNil 
	ifTrue: [largestExponentArgument := self largestNumber ln].
    ^largestExponentArgument!

largestNumber
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/5/99 "

    largestNumber isNil ifTrue: [self computeLargestNumber].
    ^largestNumber!

machinePrecision
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    machinePrecision isNil ifTrue: [self computeMachinePrecision].
    ^machinePrecision!

negativeMachinePrecision
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 22/4/99 "

    negativeMachinePrecision isNil 
	ifTrue: [self computeNegativeMachinePrecision].
    ^negativeMachinePrecision!

radix
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "

    radix isNil ifTrue: [self computeRadix].
    ^radix!

smallestNumber
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/5/99 "

    smallestNumber isNil ifTrue: [self computeSmallestNumber].
    ^smallestNumber!

smallNumber
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 5/5/99 "

    smallNumber isNil ifTrue: [smallNumber := self smallestNumber sqrt].
    ^smallNumber! !




!DhbVector methodsFor: 'creation'!

normalized
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 30-Dec-99 "

    ^1 / self norm * self! !

!DhbVector methodsFor: 'information'!

asVector
    "Answer self since the receiver is a vector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^self!

dimension
    "Answer the dimension of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^self size!

norm
    "Answer the norm of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^(self * self) sqrt!

scalarProduct: aVector 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/5/99 "

    | product n |
    n := 0.
    product := self collect: 
		    [:each | 
		    n := n + 1.
		    (aVector at: n) * each].
    n := product size.
    [n > 1] whileTrue: 
	    [| i j |
	    i := 1.
	    j := n.
	    [i < j] whileTrue: 
		    [product at: i put: (product at: i) + (product at: j).
		    j := j - 1.
		    i := i + 1].
	    n := i min: j].
    ^product at: 1! !

!DhbVector methodsFor: 'numerics'!

generality
    ^nil! !

!DhbVector methodsFor: 'operation'!

* aNumberOrMatrixOrVector 
    "Answers the product of the receiver with the argument.
		 The argument can be a number, matrix or vector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^aNumberOrMatrixOrVector productWithVector: self!

+ aVector 
    "Answers the sum of the receiver with aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    | answer n |
    answer := self class new: self size.
    n := 0.
    self with: aVector
	do: 
	    [:a :b | 
	    n := n + 1.
	    answer at: n put: a + b].
    ^answer!

- aVector 
    "Answers the difference of the receiver with aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    | answer n |
    answer := self class new: self size.
    n := 0.
    self with: aVector
	do: 
	    [:a :b | 
	    n := n + 1.
	    answer at: n put: a - b].
    ^answer!

productFromNumber: aFloatD 
    ^self * aFloatD!

productWithMatrix: aMatrix 
    "Answers the product of aMatrix with the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    ^aMatrix rowsCollect: [:each | each * self]!

productWithVector: aVector 
    "Answers the scalar product of aVector with the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    | n |
    n := 0.
    ^self inject: 0
	into: 
	    [:sum :each | 
	    n := n + 1.
	    (aVector at: n) * each + sum]!

tensorProduct: aVector 
    "Answers the tensor product of the receiver with aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    self dimension = aVector dimension 
	ifFalse: [^self error: 'Vector dimensions mismatch to build tensor product'].
    ^DhbSymmetricMatrix 
	rows: (self collect: [:a | aVector collect: [:b | a * b]])! !

!DhbVector methodsFor: 'transformation'!

accumulate: aVectorOrAnArray 
    "
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    1 to: self size
	do: [:n | self at: n put: (self at: n) + (aVectorOrAnArray at: n)]!

accumulateNegated: aVectorOrAnArray 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    1 to: self size
	do: [:n | self at: n put: (self at: n) - (aVectorOrAnArray at: n)]!

negate
    "Inverse the sign of all components of the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "

    1 to: self size do: [:n | self at: n put: (self at: n) negated]!

scaleBy: aNumber 
    "(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/3/99 "

    1 to: self size do: [:n | self at: n put: (self at: n) * aNumber]! !




