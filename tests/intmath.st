"======================================================================
|
|   Test integer math
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Eval [ 3 ]

Eval [ -3 ]

"Base tests"
Eval [ 2r1010 ]
Eval [ 8r377 ]
Eval [ 16rFE ]

"Arithmetic operation tests"

Eval [ 3 + 4 ]				"should return 7"

Eval [ 3 - 4 ]				"should return -1"

Eval [ 3 < 4 ]				"should return true"

Eval [ 17 > 18 ]			"should return false"
Eval [ 17 > 17 ]			"should return false"

Eval [ 23 <= 23 ]			"true"
Eval [ 23 <= -45 ]			"false"
Eval [ 18 >= 21 ]			"false"
Eval [ 19 >= 18 ]			"true"

Eval [ 23 = 23 ]			"true"
Eval [ 23 = 24 ]			"false"

Eval [ 45 ~= 89 ]			"true"
Eval [ 45 ~= 45 ]			"false"

Eval [ 3 * 4 ]				"should return 12"

Eval [  12 //  3 ]			"should return 4"
Eval [  12 //  5 ]			"should return 2"
Eval [ -12 // -3 ]			"should return 4"
Eval [ -12 // -5 ]			"should return 2"
Eval [ -12 //  5 ]			"should return -3"
Eval [  12 // -5 ]			"should return -3"

Eval [  12 \\  3 ]			"should return 0"
Eval [  12 \\  5 ]			"should return 2"
Eval [ -12 \\ -3 ]			"should return 0"
Eval [ -12 \\ -5 ]			"should return -2"
Eval [ -12 \\  5 ]			"should return 3"
Eval [  12 \\ -5 ]			"should return -3"


"LargeIntegers"
Eval [ (1000000000 raisedToInteger: 4) printString ]

Eval [ 100 factorial / 99 factorial ]	"should return 100 of course"
Eval [ 100 factorial printString ]

Eval [ (SmallInteger largest + SmallInteger largest) > 0 ]
Eval [ (SmallInteger largest - SmallInteger smallest) > 0 ]
Eval [ SmallInteger smallest negated > 0 ]

Eval [ (40000 * 40000) =  (40000 * 40000) ]
Eval [ (40000 * 40000) <  (40000 * 40000) ]
Eval [ (40000 * 40000) <= (40000 * 40000) ]
Eval [ (40000 * 40000) >  (40000 * 40000) ]
Eval [ (40000 * 40000) >= (40000 * 40000) ]
Eval [ (40000 * 40000) =  (32000 * 32000) ]
Eval [ (40000 * 40000) <  (32000 * 32000) ]
Eval [ (40000 * 40000) <= (32000 * 32000) ]
Eval [ (40000 * 40000) >  (32000 * 32000) ]
Eval [ (40000 * 40000) >= (32000 * 32000) ]
Eval [ (34567 * 34567) =  (45678 * 45678) ]
Eval [ (34567 * 34567) <  (45678 * 45678) ]
Eval [ (34567 * 34567) <= (45678 * 45678) ]
Eval [ (34567 * 34567) >  (45678 * 45678) ]
Eval [ (34567 * 34567) >= (45678 * 45678) ]

Eval [ (4000000000 * 4000000000) =  (4000000000 * 4000000000) ]
Eval [ (4000000000 * 4000000000) <  (4000000000 * 4000000000) ]
Eval [ (4000000000 * 4000000000) <= (4000000000 * 4000000000) ]
Eval [ (4000000000 * 4000000000) >  (4000000000 * 4000000000) ]
Eval [ (4000000000 * 4000000000) >= (4000000000 * 4000000000) ]
Eval [ (4000000000 * 4000000000) =  (1600000000 * 1600000000) ]
Eval [ (4000000000 * 4000000000) <  (1600000000 * 1600000000) ]
Eval [ (4000000000 * 4000000000) <= (1600000000 * 1600000000) ]
Eval [ (4000000000 * 4000000000) >  (1600000000 * 1600000000) ]
Eval [ (4000000000 * 4000000000) >= (1600000000 * 1600000000) ]
Eval [ (3456734567 * 3456734567) =  (4567845678 * 4567845678) ]
Eval [ (3456734567 * 3456734567) <  (4567845678 * 4567845678) ]
Eval [ (3456734567 * 3456734567) <= (4567845678 * 4567845678) ]
Eval [ (3456734567 * 3456734567) >  (4567845678 * 4567845678) ]
Eval [ (3456734567 * 3456734567) >= (4567845678 * 4567845678) ]

"parsing in bases other than 10"
Eval [ 16rFFFFFFFF = 4294967295 ]

Eval [
	n _ 10.
	f _ n factorial.
	f1 _ f * (n+1).
	n timesRepeat: [f1 _ f1 - f].
	(f1 - f = 0) printNl.
	n timesRepeat: [f1 _ f1 + f].
	((f1 // f) = (n+1)) printNl.
	^f1 negated negated = f1
]

    "Check normalization and conversion to/from SmallInts"
Eval [     ^(SmallInteger largest + 1 - 1) == SmallInteger largest ]
Eval [     ^(SmallInteger largest + 3 - 6) == (SmallInteger largest - 3) ]
Eval [     ^(SmallInteger smallest - 1 + 1) == SmallInteger smallest ]
Eval [     ^(SmallInteger smallest - 3 + 6) == (SmallInteger smallest + 3) ]

Eval [
    | bits |

    'Shift -1 left then right and test for -1' printNl.
    bits := (1 to: 100) collect: [ :i | -1 bitShift: i ].
    bits keysAndValuesDo: [:i :n | (n bitShift: i negated) = -1 ifFalse: [^i]].

    'Shift 1 left then right and test for 1' printNl.
    bits := (1 to: 100) collect: [ :i | 1 bitShift: i ].
    bits keysAndValuesDo: [:i :n | (n bitShift: i negated) = 1 ifFalse: [^i]].

    'And a single bit with -1 and test for same value' printNl.
    bits keysAndValuesDo: [:i :n | (n bitAnd: -1) = n ifFalse: [^i]].

    'Verify that (n bitAnd: n negated) = n' printNl.
    bits keysAndValuesDo: [:i :n | (n bitAnd: n negated) = n ifFalse: [^i]].

    'Verify that (n + n complemented) = -1' printNl.
    bits keysAndValuesDo: [:i :n | (n + n bitInvert) = -1 ifFalse: [^i]].

    'Verify that n negated = (n complemented +1)' printNl.
    bits keysAndValuesDo: [:i :n | n bitInvert + 1 = n negated ifFalse: [^i]].

    'LargeInteger bit logic tests passed' printNl.
    ^true
]


Fraction class extend [

    test: n [
        | sum time |
        sum := 0.
        1 to: n do: [ :x | sum := sum + 1 / x ].
        ^sum
    ]
]

Eval [
    | sum |
    sum := Fraction test: 20.		"Try 100 or 200..."
    sum numerator printNl.
    sum denominator printNl.
    ^sum
]


"Another fraction torture test"
Stream subclass: PiSeries [
    | i s tot |
    PiSeries class >> new [
	^super new initialize
    ]

    initialize [
	i := 1.
	s := 4.
	tot := 4
    ]

    next [
        ^tot := tot + ((s := 0 - s) / (i := i + 2))
    ]
]

Stream extend [
    accelerate [
	^Generator on: [ :gen |
   	    |s0 s1 s2|
   	    s0 := self next.
   	    s1 := self next.
   	    [
		s2 := self next.
   	        gen yield: s2 - ((s2 - s1) squared / (s0 - s1 - s1 + s2)).
	        s0 := s1. s1 := s2] repeat]
    ]
]

Eval [
    g := PiSeries new.
    7 timesRepeat: [ g := g accelerate ].
    pi := g peek.
    pi numerator size printNl.
    pi denominator size printNl.
    (pi * 100000) asInteger
]
