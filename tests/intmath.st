"======================================================================
|
|   Test integer math
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999  Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

^3!

^-3!

"Base tests"
^2r1010!
^8r377!
^16rFE!

"Arithmetic operation tests"

^3 + 4!				"should return 7"

^3 - 4!				"should return -1"

^3 < 4!				"should return true"

^17 > 18!			"should return false"
^17 > 17!			"should return false"

^23 <= 23!			"true"
^23 <= -45!			"false"
^18 >= 21!			"false"
^19 >= 18!			"true"

^23 = 23!			"true"
^23 = 24!			"false"

^45 ~= 89!			"true"
^45 ~= 45!			"false"

^3 * 4!				"should return 12"

^ 12 //  3!			"should return 4"
^ 12 //  5!			"should return 2"
^-12 // -3!			"should return 4"
^-12 // -5!			"should return 2"
^-12 //  5!			"should return -3"
^ 12 // -5!			"should return -3"

^ 12 \\  3!			"should return 0"
^ 12 \\  5!			"should return 2"
^-12 \\ -3!			"should return 0"
^-12 \\ -5!			"should return -2"
^-12 \\  5!			"should return 3"
^ 12 \\ -5!			"should return -3"


"LargeIntegers"
^(1000000000 raisedToInteger: 4) printString!

^100 factorial / 99 factorial!	"should return 100 of course"
^100 factorial printString!

^(40000 * 40000) =  (40000 * 40000)!
^(40000 * 40000) <  (40000 * 40000)!
^(40000 * 40000) <= (40000 * 40000)!
^(40000 * 40000) >  (40000 * 40000)!
^(40000 * 40000) >= (40000 * 40000)!
^(40000 * 40000) =  (32000 * 32000)!
^(40000 * 40000) <  (32000 * 32000)!
^(40000 * 40000) <= (32000 * 32000)!
^(40000 * 40000) >  (32000 * 32000)!
^(40000 * 40000) >= (32000 * 32000)!
^(34567 * 34567) =  (45678 * 45678)!
^(34567 * 34567) <  (45678 * 45678)!
^(34567 * 34567) <= (45678 * 45678)!
^(34567 * 34567) >  (45678 * 45678)!
^(34567 * 34567) >= (45678 * 45678)!

| f n f1 |
	n _ 10.
	f _ n factorial.
	f1 _ f * (n+1).
	n timesRepeat: [f1 _ f1 - f].
	(f1 - f = 0) printNl.
	n timesRepeat: [f1 _ f1 + f].
	((f1 // f) = (n+1)) printNl.
	^f1 negated negated = f1
!

    "Check normalization and conversion to/from SmallInts"
    ^(SmallInteger largest + 1 - 1) == SmallInteger largest!
    ^(SmallInteger largest + 3 - 6) == (SmallInteger largest - 3)!
    ^(SmallInteger smallest - 1 + 1) == SmallInteger smallest!
    ^(SmallInteger smallest - 3 + 6) == (SmallInteger smallest + 3)!

    | bits |

    'Shift -1 left then right and test for -1' printNl.
    bits := (1 to: 100) collect: [ :i | -1 bitShift: i ].
    bits doWithIndex: [:n :i | (n bitShift: i negated) = -1 ifFalse: [^false]].

    'Shift 1 left then right and test for 1' printNl.
    bits := (1 to: 100) collect: [ :i | 1 bitShift: i ].
    bits doWithIndex: [:n :i | (n bitShift: i negated) = 1 ifFalse: [^false]].

    'And a single bit with -1 and test for same value' printNl.
    bits doWithIndex: [:n :i | (n bitAnd: -1) = n ifFalse: [^false]].

    'Verify that (n bitAnd: n negated) = n' printNl.
    bits doWithIndex: [:n :i | (n bitAnd: n negated) = n ifFalse: [^false]].

    'Verify that (n + n complemented) = -1' printNl.
    bits doWithIndex: [:n :i | (n + n bitInvert) = -1 ifFalse: [^false]].

    'Verify that n negated = (n complemented +1)' printNl.
    bits doWithIndex: [:n :i | n bitInvert + 1 = n negated ifFalse: [^false]].

    'LargeInteger bit logic tests passed' printNl.
    ^true
!


!Fraction class methodsFor: 'instance creation'!

test: n
    | sum time |
    sum := 0.
    1 to: n do: [ :x | sum := sum + 1 / x ].
    ^sum
! !

| sum |
sum := Fraction test: 20.		"Try 100 or 200..."
sum numerator printNl.
sum denominator printNl.
^sum!
