"======================================================================
|
|   Random number Method Definitions
|   This is the Mersenne Twister generator implementation
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2011
| Free Software Foundation, Inc.
| Written by Steve Byrne and Mathieu Suen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Stream subclass: Random [
    <category: 'Streams'>
    <comment: 'My instances are generator streams that produce random numbers, which are 
floating point values between 0 and 1.'>
    <shape: #uint>

    Random class [
	| source |
	
    ]

    Random class >> mtSize [
	"MT19937 have a size of 624"
	^624
    ]

    Random class >> seed: anInteger [
	"Create a new random number generator whose seed is anInteger."

	<category: 'instance creation'>
	^(self basicNew: self mtSize + 1) setSeed: anInteger
    ]

    Random class >> new [
	"Create a new random number generator whose seed is given by the
	 current time on the millisecond clock"

	<category: 'instance creation'>
	^(self basicNew: self mtSize + 1) setSeed
    ]

    Random class >> source [
	"Return a standard source of random numbers."

	<category: 'shortcuts'>
	^source isNil ifTrue: [source := self new] ifFalse: [source]
    ]

    Random class >> next [
	"Return a random number between 0 and 1 (excluded)"

	<category: 'shortcuts'>
	^self source next
    ]

    Random class >> between: low and: high [
	"Return a random integer between the given extrema"

	<category: 'shortcuts'>
	^self source between: low and: high
    ]

    chiSquare [
	"Compute the chi-square of the random that this class generates."

	<category: 'testing'>
	^self chiSquare: 1000 range: 100
    ]

    chiSquare: n range: r [
	"Return the chi-square deduced from calculating n random
	 numbers in the 0..r range."

	<category: 'testing'>
	| f t |
	f := Array new: r withAll: 0.
	n timesRepeat: 
		[t := self between: 1 and: r.
		f at: t put: (f at: t) + 1].
	t := 0.
	1 to: r do: [:i | t := t + (f at: i) squared].
	^r asFloat * t / n - n
    ]

    atEnd [
	"This stream never ends. Always answer false."

	<category: 'basic'>
	^false
    ]

    between: low and: high [
	"Return a random integer between low and high."

	<category: 'basic'>
	| i range |
	range := high - low + 1.
	i := self nextLimit: range.
	^i + low
    ]

    next [
	"Return a random SmallInteger of maximum 32-bits precision."

	<category: 'basic'>
	<primitive: VMpr_Random_next>
        self primitiveFailed
    ]

    nextLimit: anInteger [
	"Return a random SmallInteger, uniformly distributed between 0 and
         anInteger."

	<category: 'basic'>
	<primitive: VMpr_Random_next>
        self primitiveFailed
    ]

    nextPut: value [
	<category: 'basic'>
	self shouldNotImplement
    ]

    setSeed: anInteger [
	"Private - Set the random number seed to anInteger."

        | previous value |
        "Avoid getting all zeros!"
	previous := anInteger bitOr: 1.
	1 to: self class mtSize do:[ :mtIndex |
	    value := 1812433253 * (previous bitXor: (previous bitShift: -30)).
	    self at: mtIndex put: (previous := value bitAnd: 16rFFFFFFFF)
	].
        self at: self size put: 0
    ]

    setSeed [
	"Private - Set a random number seed."

	<category: 'private'>
        | seed |
	seed := Time primSecondClock bitXor: Time millisecondClock.
	seed := seed + (Time primNanosecondClock \\ 1000000).
	self setSeed: seed
    ]
]

