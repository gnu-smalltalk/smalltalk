"======================================================================
|
|   Numerical methods - Random Number Generator
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

Object subclass:  #DhbMitchellMooreGenerator
	instanceVariableNames: 'randoms lowIndex highIndex '
	classVariableNames: 'UniqueInstance '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbMitchellMooreGenerator comment: 
nil!

Object subclass:  #DhbCongruentialRandomNumberGenerator
	instanceVariableNames: 'constant modulus multiplicator seed '
	classVariableNames: 'UniqueInstance '
	poolDictionaries: ''
	category: 'DHB Numerical'!

DhbCongruentialRandomNumberGenerator comment: 
nil!

!DhbMitchellMooreGenerator class methodsFor: 'creation'!

constants: anArray lowIndex: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    ^super new initialize: anArray lowIndex: anInteger!

default
    "Private- 
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    | congruentialGenerator |
    congruentialGenerator := DhbCongruentialRandomNumberGenerator new.
    ^self generateSeeds: congruentialGenerator!

generateSeeds: congruentialGenerator 
    "Private- "

    ^self 
	constants: ((1 to: 55) collect: [:n | congruentialGenerator floatValue])
	lowIndex: 24!

new
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    UniqueInstance isNil ifTrue: [UniqueInstance := self default].
    ^UniqueInstance!

reset: anInteger 
    "Reset the unique instance used for the default series"

    UniqueInstance := self seed: anInteger!

seed: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/18/00 "

    | congruentialGenerator |
    congruentialGenerator := DhbCongruentialRandomNumberGenerator 
		seed: anInteger.
    ^self generateSeeds: congruentialGenerator! !

!DhbMitchellMooreGenerator methodsFor: 'information'!

floatValue
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    | x |
    x := (randoms at: lowIndex) + (randoms at: highIndex).
    x < 1.00000000000000 ifFalse: [x := x - 1.00000000000000].
    randoms at: highIndex put: x.
    highIndex := highIndex + 1.
    highIndex > randoms size ifTrue: [highIndex := 1].
    lowIndex := lowIndex + 1.
    lowIndex > randoms size ifTrue: [lowIndex := 1].
    ^x!

integerValue: anInteger 
    "(c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    ^(self floatValue * anInteger) truncated! !

!DhbMitchellMooreGenerator methodsFor: 'initialization'!

initialize: anArray lowIndex: anInteger 
    "Private -
		 (c) Copyrights Didier BESSET, 2000, all rights reserved.
		 Initial code: 1/11/00 "

    randoms := anArray.
    lowIndex := anInteger.
    highIndex := randoms size.
    ^self! !




!DhbCongruentialRandomNumberGenerator class methodsFor: 'creation'!

constant: aNumber1 multiplicator: aNumber2 modulus: aNumber3 
    "Create a new instance of the receiver with given constants.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^super new 
	initialize: aNumber1
	multiplicator: aNumber2
	modulus: aNumber3!

new
    "Create a new instance of the receiver with D. Knuth's constants.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    UniqueInstance isNil 
	ifTrue: 
	    [UniqueInstance := super new initialize.
	    UniqueInstance setSeed: 1].
    ^UniqueInstance!

seed: aNumber 
    "Create a new instance of the receiver with given seed
		  using D. Knuth's constants.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^(super new)
	initialize;
	setSeed: aNumber;
	yourself! !

!DhbCongruentialRandomNumberGenerator methodsFor: 'information'!

floatValue
    "Answer the next pseudo-random value between 0 and 1.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^self value asFloatD / modulus!

integerValue: anInteger 
    "Answer a random integer between 0 and the anInteger.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    ^self value \\ (anInteger * 1000) // 1000!

value
    "Answer the next pseudo-random value.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    seed := (seed * multiplicator + constant) \\ modulus.
    ^seed! !

!DhbCongruentialRandomNumberGenerator methodsFor: 'initialization'!

initialize
    "Private - Initializes the constants of the receiver with D. Knuth's constants.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    self 
	initialize: 2718281829.00000
	multiplicator: 3141592653.00000
	modulus: 4294967296.00000!

initialize: aNumber1 multiplicator: aNumber2 modulus: aNumber3 
    "Private - Initializes the constants needed by the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    constant := aNumber1.
    modulus := aNumber2.
    multiplicator := aNumber3.
    self setSeed: 1! !

!DhbCongruentialRandomNumberGenerator methodsFor: 'transformation'!

setSeed: aNumber 
    "Set the seed of the receiver to aNumber.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 15/2/99 "

    seed := aNumber! !




