"======================================================================
|
|   Test floating point operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2006, 2007, 2008, 2009 Free Software Foundation.
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

Eval [
    (1 to: 500000) collect: [ :each |
        RegressionTesting ifFalse: [
	    each \\ 1000 = 0 ifTrue: [ each basicPrint. Character nl basicPrint ]
        ].
        -1.0 negated
    ].

    ObjectMemory globalGarbageCollect
]

Eval [ 3.1 ]

Eval [ 3.45 ]

Eval [ 3.0e4 ]

Eval [ 3.45e4 ]

Eval [ 3.4 + 4.3 ]

Eval [ -5.5 - 3.12 ]

Eval [ 5.6 < 5.5 ]
Eval [ 5.5 < 5.6 ]

Eval [ 5.6 > 5.5 ]
Eval [ 5.5 > 5.6 ]

Eval [ 3.4 <= 3.4 ]
Eval [ 3.6 >= 2.5 ]

Eval [ 3.12345 = 3.12345 ]

Eval [ 4.5 ~= 5.67 ]

Eval [ 4.5 * 0.0004 ]

Eval [ 4.5 / 0.0004 ]

Eval [ 3.14159 truncated ]

Eval [ 3.1415926535 fractionPart ]

Eval [ 4523.234 exponent ]

Eval [ 45.0 timesTwoPower: 4 ]
Eval [ 45.0 timesTwoPower: -4 ]

Eval [ 1000 asFloat floorLog: 10 ]
Eval [ 1024 asFloat reciprocal ceilingLog: 10 ]

Eval [ FloatD infinity ]
Eval [ FloatD infinity printString ]

Eval [ FloatD negativeInfinity ]
Eval [ FloatD negativeInfinity printString ]

Eval [ FloatD nan ]
Eval [ FloatD nan printString ]

Eval [ FloatD infinity reciprocal printString ]
Eval [ FloatD negativeInfinity reciprocal printString ]

Eval [ 0.0 positive ]
Eval [ (0.0 * -1) positive ]

Eval [ FloatD nan min: FloatD nan ]
Eval [ FloatD nan min: 5.0 ]
Eval [ 5.0 min: FloatD nan ]
Eval [ 5.0 min: 7.0 ]
Eval [ 7.0 min: 5.0 ]
Eval [ 7.0 min: 7.0 ]
Eval [ 0.0 min: 0.0 ]
Eval [ 0.0 min: 0.0 * -1 ]
Eval [ 0.0 * -1 min: 0.0 ]
Eval [ 0.0 * -1 min: 0.0 * -1 ]

Eval [ FloatD nan max: FloatD nan ]
Eval [ FloatD nan max: 5.0 ]
Eval [ 5.0 max: FloatD nan ]
Eval [ 5.0 max: 7.0 ]
Eval [ 7.0 max: 5.0 ]
Eval [ 7.0 max: 7.0 ]
Eval [ 0.0 max: 0.0 ]
Eval [ 0.0 max: 0.0 * -1 ]
Eval [ 0.0 * -1 max: 0.0 ]
Eval [ 0.0 * -1 max: 0.0 * -1 ]

" ### need more tests"

Eval [ (( 0.6 \\  1) * 10) rounded == ( 6 \\  10) ]
Eval [ (( 0.6 \\ -1) * 10) rounded == ( 6 \\ -10) ]
Eval [ ((-0.6 \\  1) * 10) rounded == (-6 \\  10) ]
Eval [ ((-0.6 \\ -1) * 10) rounded == (-6 \\ -10) ]
Eval [ (( 0.4 \\  1) * 10) rounded == ( 4 \\  10) ]
Eval [ (( 0.4 \\ -1) * 10) rounded == ( 4 \\ -10) ]
Eval [ ((-0.4 \\  1) * 10) rounded == (-4 \\  10) ]
Eval [ ((-0.4 \\ -1) * 10) rounded == (-4 \\ -10) ]

Eval [ (1.0e raisedTo: 1   ) class ]
Eval [ (1.0d raisedTo: 1   ) class ]
Eval [ (1.0q raisedTo: 1   ) class ]
Eval [ (1.0e raisedTo: 1.0e) class ]
Eval [ (1.0d raisedTo: 1.0e) class ]
Eval [ (1.0q raisedTo: 1.0e) class ]
Eval [ (1.0e raisedTo: 1.0d) class ]
Eval [ (1.0d raisedTo: 1.0d) class ]
Eval [ (1.0q raisedTo: 1.0d) class ]
Eval [ (1.0e raisedTo: 1.0q) class ]
Eval [ (1.0d raisedTo: 1.0q) class ]
Eval [ (1.0q raisedTo: 1.0q) class ]

" Fun with signed zeros"

Eval [
 #(( -0.0d -0.0d) (-0.0d 0.0d) (0.0d -0.0d) (0.0d 0.0d)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]
]

Eval [
 #(( -0.0e -0.0e) (-0.0e 0.0e) (0.0e -0.0e) (0.0e 0.0e)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]
]


"This is less strict because it behaves differently on different long double
 formats."

Eval [
 #(( -0.0q -0.0q) (0.0q 0.0q)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]
]

Eval [
 #((-0.0q 0.0q) (0.0q -0.0q)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b.
   ((b - a) negated = (a - b)).
   ((a negated + b) = (b - a)).
   ((a + b negated) = (a - b)) } printNl ]
]



"Fun with printing"
  
Float class extend [
    test: bytes [
	| f |  "for historical results this uses little endian, reverse here."
	f := self fromBytes: bytes reverse.
        (true->f) printNl.
	^f
    ]
]

Eval [ FloatD test: #[0 128 224 55 121 195 65 67] ]
Eval [ FloatE test: #[202 27 14 90] ]
Eval [ FloatD test: #[0 72 224 37 219 237 69 67] ]
Eval [ FloatE test: #[217 110 47 90] ]
Eval [ FloatD test: #[0 0 0 0 0 0 244 63] ]
Eval [ FloatD test: #[0 0 0 0 0 0 36 64] ]
Eval [ FloatD test: #[57 0 44 60 121 196 49 64] ]
Eval [ FloatD test: #[123 242 176 80 107 154 191 63] ]
Eval [ FloatD test: #[124 242 176 80 107 154 191 63] ]
Eval [ FloatD test: #[78 250 91 111 99 53 21 62] ]
Eval [ FloatD test: #[79 250 91 111 99 53 21 62] ]
Eval [ FloatE test: #[27 171 169 48] ]
Eval [ FloatD test: #[191 220 89 240 39 160 234 63] ]
Eval [ FloatD test: #[227 220 89 240 39 160 234 63] ]
Eval [ FloatD test: #[157 232 59 160 26 192 225 63] ]
Eval [ FloatD test: #[148 232 59 160 26 192 225 63] ]
Eval [ FloatD test: #[255 255 255 255 255 255 239 63] ]
Eval [ FloatD test: #[92 244 249 110 24 220 230 84] ]
Eval [ FloatD test: #[236 81 184 30 133 235 34 64] ]
Eval [ FloatD test: #[51 51 51 51 51 51 211 63] ]
Eval [ FloatD test: #[52 51 51 51 51 51 211 63] ]


"Fun reading floats"

"The RHS has a 256-bit approximation that is way beyond the precision
 of real.c's floats."

Eval [ FloatQ pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862q ]
Eval [ FloatD pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862d ]
Eval [ FloatE pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862e ]


"Use #predecessor/#succesor to test reading."
Eval [ (0.2q0 successor asExactFraction - (1/5)) abs >= (0.2q0 asExactFraction - (1/5)) abs ]
Eval [ (0.2q0 predecessor asExactFraction - (1/5)) abs >= (0.2q0 asExactFraction - (1/5)) abs ]
Eval [ (0.2q0 successor - (1/5) asFloatQ) abs >= (0.2q0 - (1/5) asFloatQ) abs ]
Eval [ (0.2q0 predecessor - (1/5) asFloatQ) abs >= (0.2q0 - (1/5) asFloatQ) abs ]
Eval [ (0.137q0 successor asExactFraction - (137/1000)) abs >= (0.137q0 asExactFraction - (137/1000)) abs ]
Eval [ (0.137q0 predecessor asExactFraction - (137/1000)) abs >= (0.137q0 asExactFraction - (137/1000)) abs ]
Eval [ (0.137q0 successor - (137/1000) asFloatQ) abs >= (0.137q0 - (137/1000) asFloatQ) abs ]
Eval [ (0.137q0 predecessor - (137/1000) asFloatQ) abs >= (0.137q0 - (137/1000) asFloatQ) abs ]
Eval [ (1.3q0 successor asExactFraction - (13/10)) abs >= (1.3q0 asExactFraction - (13/10)) abs ]
Eval [ (1.3q0 predecessor asExactFraction - (13/10)) abs >= (1.3q0 asExactFraction - (13/10)) abs ]
Eval [ (1.3q0 successor - (13/10) asFloatQ) abs >= (1.3q0 - (13/10) asFloatQ) abs ]
Eval [ (1.3q0 predecessor - (13/10) asFloatQ) abs >= (1.3q0 - (13/10) asFloatQ) abs ]

"Fun with rounding"

Float class extend [

    assert: aBoolean [
        aBoolean ifFalse: [ self halt ] ifTrue: [ aBoolean printNl ]
    ]

    test [
        | p |
        p := 1 bitShift: self precision - 1.
        self assert: (self coerce: p+0+(1/4)) asExactFraction = (p+0).
        self assert: (self coerce: p+0+(1/2)) asExactFraction = (p+0).
        self assert: (self coerce: p+0+(3/4)) asExactFraction = (p+1).
        self assert: (self coerce: p+1+(1/4)) asExactFraction = (p+1).
        self assert: (self coerce: p+1+(1/2)) asExactFraction = (p+2).
        self assert: (self coerce: p+1+(3/4)) asExactFraction = (p+2).
    
        self assert: ((self emin - self precision - 1 to: self emax - 1) allSatisfy: [:i |
            p := (self coerce: 1) timesTwoPower: i.
	    (self coerce: p asExactFraction) = p]).
    
        self assert: ((1 to: 1 + self precision - self emin) allSatisfy: [:i |
            p := (self coerce: 1) timesTwoPower: i negated.
	    (self coerce: (1 bitShift: i) reciprocal negated) = p negated]).
    
        "check for negative zero"
        p := 1 bitShift: 1 + self precision - self emin.
        self assert: (self coerce: p reciprocal) positive.
        self assert: (self coerce: p reciprocal negated) negative.
    
        "check for infinity"
        p := 1 bitShift: self emax + 1.
        self assert: (self coerce: p) = self infinity.
        self assert: (self coerce: p negated) = self negativeInfinity.
    
        p := 1 bitShift: 1 + self precision - self emin.
        self assert: (self coerce: p / 3) = self infinity.
        self assert: (self coerce: p / -3) = self negativeInfinity.
    
        "check for non infinity/nan"
        p := 1 bitShift: self emax + 1.
        self assert: (self coerce: p / 3) isFinite.
        self assert: (self coerce: p / -3) isFinite.
    
        p := 1 bitShift: 1 + self precision - self emin.
        self assert: (self coerce: 3 / p) isFinite.
        self assert: (self coerce: -3 / p) isFinite.

	"check for rounding bugs"
	p := (1 bitShift: self precision - 1) + (self coerce: 1.0).
	self assert: p rounded = p asExactFraction.

	"Test the case with the carry == 1 in LargeInteger>>#asFloat:.
	 The number is huge so the truncated mantissa is even.  If
	 there are other trailing bits behind the carry, as with p+1,
	 the mantissa must be rounded up."
	p := (1 bitShift: self precision * 2) + (1 bitShift: self precision).
	self assert: p asFloatD truncated < (p + 1) asFloatD truncated
    ]
]

Eval [ FloatD test ]
Eval [ FloatE test ]
