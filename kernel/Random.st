"======================================================================
|
|   Random number Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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
    | seed |
    
    <category: 'Streams'>
    <comment: 'My instances are generator streams that produce random numbers, which are 
floating point values between 0 and 1.'>

    Random class [
	| source |
	
    ]

    Random class >> seed: aFloat [
	"Create a new random number generator whose seed is aFloat"

	<category: 'instance creation'>
	^(self basicNew)
	    seed: aFloat;
	    yourself
    ]

    Random class >> new [
	"Create a new random number generator whose seed is given by the
	 current time on the millisecond clock"

	<category: 'instance creation'>
	^self basicNew setSeed
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

	"the previous algorithm's chi-square was 93.4"

	<category: 'testing'>
	^self chiSquare: 1000 range: 100
    ]

    chiSquare: n range: r [
	"Return the chi-square deduced from calculating n random
	 numbers in the 0..r range."

	<category: 'testing'>
	| f t seed |
	seed := 0.1234567.
	f := Array new: r + 1.
	1 to: r + 1 do: [:i | f at: i put: 0].
	n timesRepeat: 
		[seed := (seed + Float pi) squared squared fractionPart.
		t := (seed * r) truncated.
		f at: t + 1 put: (f at: t + 1) + 1].
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
	i := (self next * range) truncated.
	^i + low
    ]

    next [
	"Return the next random number in the sequence."

	"Found on an obscure Japanese manual. Turns out to be good!"

	<category: 'basic'>
	^seed := (seed + Float pi) squared squared fractionPart
    ]

    nextPut: value [
	<category: 'basic'>
	self shouldNotImplement
    ]

    seed: aFloat [
	"Private - Set the random number seed to aFloat.
	 Ensure decent results even when integers are passed"

	<category: 'private'>
	seed := (aFloat / 100000.0 + aFloat) fractionPart.
	self next.
	self next
    ]

    setSeed [
	"Private - Set a random number seed."

	<category: 'private'>
	seed := Time primSecondClock - Time primMillisecondClock.
	seed := (seed / 4194303.0) fractionPart.
	self next.
	self next
    ]
]

