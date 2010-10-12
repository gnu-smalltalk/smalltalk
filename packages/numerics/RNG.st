"======================================================================
|
|   Numerical methods - Random Number Generators
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



Object subclass: DhbMitchellMooreGenerator [
    | randoms lowIndex highIndex |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbMitchellMooreGenerator class >> constants: anArray lowIndex: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	^super new initialize: anArray lowIndex: anInteger
    ]

    DhbMitchellMooreGenerator class >> default [
	"Private-
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	| congruentialGenerator |
	congruentialGenerator := DhbCongruentialRandomNumberGenerator new.
	^self generateSeeds: congruentialGenerator
    ]

    DhbMitchellMooreGenerator class >> generateSeeds: congruentialGenerator [
	"Private-"

	<category: 'creation'>
	^self 
	    constants: ((1 to: 55) collect: [:n | congruentialGenerator floatValue])
	    lowIndex: 24
    ]

    DhbMitchellMooreGenerator class >> new [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	UniqueInstance isNil ifTrue: [UniqueInstance := self default].
	^UniqueInstance
    ]

    DhbMitchellMooreGenerator class >> reset: anInteger [
	"Reset the unique instance used for the default series"

	<category: 'creation'>
	UniqueInstance := self seed: anInteger
    ]

    DhbMitchellMooreGenerator class >> seed: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'creation'>
	| congruentialGenerator |
	congruentialGenerator := DhbCongruentialRandomNumberGenerator 
		    seed: anInteger.
	^self generateSeeds: congruentialGenerator
    ]

    floatValue [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'information'>
	| x |
	x := (randoms at: lowIndex) + (randoms at: highIndex).
	x < 1.0 ifFalse: [x := x - 1.0].
	randoms at: highIndex put: x.
	highIndex := highIndex + 1.
	highIndex > randoms size ifTrue: [highIndex := 1].
	lowIndex := lowIndex + 1.
	lowIndex > randoms size ifTrue: [lowIndex := 1].
	^x
    ]

    integerValue: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'information'>
	^(self floatValue * anInteger) truncated
    ]

    initialize: anArray lowIndex: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'initialization'>
	randoms := anArray.
	lowIndex := anInteger.
	highIndex := randoms size.
	^self
    ]
]



Object subclass: DhbCongruentialRandomNumberGenerator [
    | constant modulus multiplicator seed |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbCongruentialRandomNumberGenerator class >> constant: aNumber1 multiplicator: aNumber2 modulus: aNumber3 [
	"Create a new instance of the receiver with given constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new 
	    initialize: aNumber1
	    multiplicator: aNumber2
	    modulus: aNumber3
    ]

    DhbCongruentialRandomNumberGenerator class >> new [
	"Create a new instance of the receiver with D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new initialize.
		UniqueInstance setSeed: 1].
	^UniqueInstance
    ]

    DhbCongruentialRandomNumberGenerator class >> seed: aNumber [
	"Create a new instance of the receiver with given seed
	 using D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^(super new)
	    initialize;
	    setSeed: aNumber;
	    yourself
    ]

    floatValue [
	"Answer the next pseudo-random value between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self value asFloatD / modulus
    ]

    integerValue: anInteger [
	"Answer a random integer between 0 and the anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self value \\ (anInteger * 1000) // 1000
    ]

    value [
	"Answer the next pseudo-random value.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	seed := (seed * multiplicator + constant) \\ modulus.
	^seed
    ]

    initialize [
	"Private - Initializes the constants of the receiver with D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	self 
	    initialize: 2718281829.0
	    multiplicator: 3141592653.0
	    modulus: 4294967296.0
    ]

    initialize: aNumber1 multiplicator: aNumber2 modulus: aNumber3 [
	"Private - Initializes the constants needed by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	constant := aNumber1.
	modulus := aNumber2.
	multiplicator := aNumber3.
	self setSeed: 1
    ]

    setSeed: aNumber [
	"Set the seed of the receiver to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	seed := aNumber
    ]
]

