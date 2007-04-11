"======================================================================
|
|   Test floating point operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2006, 2007  Free Software Foundation.
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
  
Float extend [
    test [
        (((Behavior evaluate: self printString) = self) -> self) printNl
    ]
]

Eval [ 1d16 test ]
Eval [ 1e16 test ]
Eval [ 1.2345d16 test ]
Eval [ 1.2345e16 test ]
Eval [ 1.25 test ]
Eval [ 10.0 test ]
Eval [ (20 - 2.2325251) test ]
Eval [ 0.12345 test ]
Eval [ 0.12345d-8 test ]
Eval [ 0.12345e-8 test ]
Eval [ 0.83205029433784 test ]
Eval [ 0.832050294337844 test ]
Eval [ 0.55470019622523 test ]
Eval [ 0.554700196225229 test ]


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
        self assert: (self coerce: -3 / p) isFinite
    ]
]

Eval [ FloatD test ]
Eval [ FloatE test ]
