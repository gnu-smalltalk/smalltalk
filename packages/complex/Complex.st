"======================================================================
|
|   Complex number declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



Number subclass: Complex [
    | re im |
    
    <category: 'Examples-Useful'>
    <comment: 'I provide complex numbers, with full interoperability
with other kinds of numbers.  Complex numbers can be created from imaginary
numbers, which in turn are created with `Complex i'' or the #i method
(e.g. `3 i'').  Alternatively, they can be created from polar numbers.'>

    Zero := nil.
    One := nil.
    I := nil.

    Complex class >> initialize [
	"Initialize some common complex numbers."

	<category: 'instance creation'>
	Zero := Complex basicNew setReal: 0 imaginary: 0.
	One := Complex basicNew setReal: 1 imaginary: 0.
	I := Complex real: 0 imaginary: 1
    ]

    Complex class >> i [
	"Return the imaginary unit, -1 sqrt."

	<category: 'instance creation'>
	^I
    ]

    Complex class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    Complex class >> rho: dist theta: angle [
	"Return a complex number whose absolute value is dist and whose
	 argument is angle."

	<category: 'instance creation'>
	^Complex realResult: dist * angle cos imaginary: dist * angle sin
    ]

    Complex class >> realResult: re imaginary: im [
	"Private - Return a new complex number knowing that re and im have the
	 same generality."

	<category: 'instance creation'>
	im = 0 ifTrue: [^re].
	^self basicNew setReal: re imaginary: im
    ]

    Complex class >> real: re imaginary: im [
	"Return a complex number with the given real and imaginary parts."

	<category: 'instance creation'>
	im = 0 ifTrue: [^re].
	re isComplex ifTrue: [^re + im i].
	im isComplex ifTrue: [^re + im i].
	re generality = im generality 
	    ifTrue: [^self basicNew setReal: re imaginary: im].
	^re generality < im generality 
	    ifTrue: [^self basicNew setReal: (im coerce: re) imaginary: im]
	    ifFalse: [^self basicNew setReal: re imaginary: (re coerce: im)]
    ]

    + z [
	"Sum the receiver with the (real or complex) number z."

	<category: 'math'>
	^Complex realResult: self real + z real
	    imaginary: self imaginary + z imaginary
    ]

    - z [
	"Subtract the (real or complex) number z from the receiver."

	<category: 'math'>
	^Complex realResult: self real - z real
	    imaginary: self imaginary - z imaginary
    ]

    * z [
	"Multiply the receiver by the (real or complex) number z."

	<category: 'math'>
	| ac bd abcd |
	z isComplex 
	    ifFalse: [^Complex realResult: self real * z imaginary: self imaginary * z].
	ac := self real * z real.
	bd := self imaginary * z imaginary.
	abcd := (self real + self imaginary) * (z real + z imaginary).
	^Complex realResult: ac - bd imaginary: abcd - ac - bd
    ]

    / z [
	"Divide the receiver by the (real or complex) number z."

	<category: 'math'>
	| r1 r2 i1 i2 d1 d2 w |
	z isComplex 
	    ifFalse: [^Complex realResult: self real / z imaginary: self imaginary / z].
	r1 := i2 := self real.
	r2 := i1 := self imaginary.
	d1 := z real.
	d2 := z imaginary.
	d1 abs > d2 abs
	    ifTrue: [ w := d2 / d1. r2 := r2 * w. i2 := i2 * w. d2 := d2 * w ]
	    ifFalse: [ w := d1 / d2. r1 := r1 * w. i1 := i1 * w. d1 := d1 * w ].

	w := d1 + d2.
	^Complex realResult: (r1 + r2) / w imaginary: (i1 - i2) / w
    ]

    reciprocal [
	"Return the reciprocal of the receiver."

	<category: 'math'>
	| r1 i2 d1 d2 w |
	r1 := 1. i2 := -1.
	d1 := self real.
	d2 := self imaginary.
	d1 abs > d2 abs
	    ifTrue: [ w := d2 / d1. i2 := w * -1. d2 := d2 * w ]
	    ifFalse: [ r1 := d1 / d2. d1 := d1 * r1 ].

	w := d1 + d2.
	^Complex realResult: r1 / w imaginary: i2 / w
    ]

    abs [
	"Return the absolute value of the receiver."

	<category: 'math'>
	| rAbs iAbs |
	rAbs := self real abs.
	iAbs := self imaginary abs.
	^rAbs > iAbs
	    ifTrue: [ rAbs * ((iAbs / rAbs) squared + 1) sqrt ]
	    ifFalse: [ iAbs * ((rAbs / iAbs) squared + 1) sqrt ]
    ]

    absSquared [
	"Return the squared absolute value of the receiver."

	<category: 'math'>
	^self real squared + self imaginary squared
    ]

    conjugate [
	"Return the complex conjugate of the receiver."

	<category: 'math'>
	^Complex realResult: self real imaginary: self imaginary negated
    ]

    exp [
	"Return e raised to the receiver."

	<category: 'transcendental functions'>
	| expRe |
	expRe := self real exp.
	^Complex realResult: expRe * self imaginary cos
	    imaginary: expRe * self imaginary sin
    ]

    sqrt [
	"Return the square root of the receiver.  Can be improved!"

	<category: 'transcendental functions'>
	| w x rAbs iAbs |
	rAbs := self real abs.
	iAbs := self imaginary abs.
	rAbs > iAbs
	    ifTrue: [
		w := iAbs / rAbs.
		w := rAbs sqrt * ((1 + (w squared + 1) sqrt) / 2) sqrt ]
	    ifFalse: [
		w := rAbs / iAbs.
		w := iAbs sqrt * ((w + (w squared + 1) sqrt) / 2) sqrt ].

	w = 0 ifTrue: [ ^0 ].
	x := self imaginary / (w + w).
	self real < 0 ifFalse: [ ^Complex realResult: w imaginary: x ].
	self imaginary >= 0 ifTrue: [ ^Complex realResult: x abs imaginary: w ].
	^Complex realResult: x abs imaginary: w negated
    ]

    sin [
	"Return the sine of the receiver."

	<category: 'transcendental functions'>
	| sinhIm |
	sinhIm := self imaginary sinh.
	^Complex realResult: self real sin * (sinhIm squared + 1) sqrt
	    imaginary: self real cos * sinhIm
    ]

    cos [
	"Return the cosine of the receiver."

	<category: 'transcendental functions'>
	| sinhIm |
	sinhIm := self imaginary sinh.
	^Complex realResult: self real cos * (sinhIm squared + 1) sqrt
	    imaginary: self real sin negated * sinhIm
    ]

    sinh [
	"Return the hyperbolic sine of the receiver."

	<category: 'transcendental functions'>
	| sinhRe |
	sinhRe := self real sinh.
	^Complex realResult: sinhRe * self imaginary cos
	    imaginary: (sinhRe squared + 1) sqrt * self imaginary sin
    ]

    cosh [
	"Return the hyperbolic cosine of the receiver."

	<category: 'transcendental functions'>
	| sinhRe |
	sinhRe := self real sinh.
	^Complex realResult: (sinhRe squared + 1) sqrt * self imaginary cos
	    imaginary: sinhRe * self imaginary sin
    ]

    arg [
	"Return the argument of the receiver."

	<category: 'transcendental functions'>
	^self imaginary arcTan: self real
    ]

    arcTan [
	"Return the arc-tangent of the receiver."

	<category: 'transcendental functions'>
	| z |
	z := ((Complex i + self) / (Complex i - self) asFloat) ln.
	^Complex real: 0 imaginary: z / 2
    ]

    arcTan: aNumber [
	"Return the arc-tangent of aNumber divided by the receiver."

	<category: 'transcendental functions'>
	| z |
	z := ((aNumber i + self) / (aNumber i - self) asFloat) ln.
	^Complex real: 0 imaginary: z / 2
    ]

    ln [
	"Return the natural logarithm of the receiver."

	<category: 'transcendental functions'>
	^Complex realResult: self absSquared ln / 2 imaginary: self arg
    ]

    log [
	"Return the base-10 logarithm of the receiver."

	<category: 'transcendental functions'>
	| ln |
	ln := self ln.
	^ln / ln real class ln10
    ]

    tanh [
	"Return the hyperbolic tangent of the receiver."

	<category: 'transcendental functions'>
	^self sinh / self cosh
    ]

    tan [
	"Return the tangent of the receiver."

	<category: 'transcendental functions'>
	^self sin / self cos
    ]

    < aNumber [
	<category: 'comparing'>
	^self abs < aNumber abs
    ]

    <= aNumber [
	<category: 'comparing'>
	^self abs <= aNumber abs
    ]

    >= aNumber [
	<category: 'comparing'>
	^self abs >= aNumber abs
    ]

    > aNumber [
	<category: 'comparing'>
	^self abs > aNumber abs
    ]

    = aNumber [
	<category: 'comparing'>
	aNumber isNumber ifFalse: [^false].
	^self real = aNumber real and: [self imaginary = aNumber imaginary]
    ]

    ~= aNumber [
	<category: 'comparing'>
	aNumber isNumber ifFalse: [^true].
	^self real ~= aNumber real or: [self imaginary ~= aNumber imaginary]
    ]

    hash [
	<category: 'comparing'>
	^self real hash bitXor: self imaginary hash
    ]

    asFloat [
	<category: 'converting'>
	^Complex real: self real asFloat imaginary: self imaginary asFloat
    ]

    asFloatD [
	<category: 'converting'>
	^Complex real: self real asFloatD imaginary: self imaginary asFloatD
    ]

    asFloatE [
	<category: 'converting'>
	^Complex real: self real asFloatE imaginary: self imaginary asFloatE
    ]

    asFloatQ [
	<category: 'converting'>
	^Complex real: self real asFloatQ imaginary: self imaginary asFloatQ
    ]

    asFraction [
	<category: 'converting'>
	^Complex real: self real asFraction imaginary: self imaginary asFraction
    ]

    asExactFraction [
	<category: 'converting'>
	^Complex real: self real asExactFraction
	    imaginary: self imaginary asExactFraction
    ]

    floor [
	<category: 'converting'>
	^Complex real: self real floor imaginary: self imaginary floor
    ]

    ceiling [
	<category: 'converting'>
	^Complex real: self real ceiling imaginary: self imaginary ceiling
    ]

    truncated [
	<category: 'converting'>
	^Complex real: self real truncated imaginary: self imaginary truncated
    ]

    rounded [
	<category: 'converting'>
	^Complex real: self real rounded imaginary: self imaginary rounded
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    print: self real;
	    nextPut: $+;
	    print: self imaginary;
	    nextPut: $i;
	    nextPut: $)
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self real;
	    nextPut: $+;
	    store: self imaginary;
	    nextPutAll: ' i)'
    ]

    isExact [
	"Answer whether the receiver performs exact arithmetic.  Complex
	 numbers do so as long as both parts, real and imaginary, are exact."

	<category: 'testing'>
	^self real isExact and: [self imaginary isExact]
    ]

    isComplex [
	<category: 'creation/coercion'>
	^true
    ]

    zero [
	<category: 'creation/coercion'>
	^Zero
    ]

    one [
	<category: 'creation/coercion'>
	^One
    ]

    generality [
	<category: 'creation/coercion'>
	^re generality + 1000
    ]

    real [
	<category: 'creation/coercion'>
	^re
    ]

    imaginary [
	<category: 'creation/coercion'>
	^im
    ]

    coerce: aNumber [
	<category: 'creation/coercion'>
	aNumber isComplex 
	    ifFalse: [^Complex basicNew setReal: aNumber imaginary: aNumber zero].
	^Complex basicNew setReal: (re coerce: aNumber real)
	    imaginary: (re coerce: aNumber imaginary)
    ]

    setReal: real imaginary: imag [
	<category: 'creation/coercion'>
	re := real.
	im := imag
    ]

    i [
	"Return the receiver multiplied by the imaginary unit."

	<category: 'creation/coercion'>
	^Complex real: self imaginary negated imaginary: self real
    ]
]



Number extend [

    real [
	"Return the real part of the receiver."

	<category: 'accessing'>
	^self
    ]

    imaginary [
	"Return the imaginary part of the receiver, which is zero."

	<category: 'accessing'>
	^self zero
    ]

    conjugate [
	"Return the receiver, which is the same as its conjugate."

	<category: 'accessing'>
	^self
    ]

    isComplex [
	<category: 'accessing'>
	^false
    ]

    absSquared [
	"Return the square of the receiver, which is also the squared absolute
	 value for real numbers."

	<category: 'accessing'>
	^self squared
    ]

    raisedTo: aNumber [
	"Return the receiver, raised to aNumber.  This may answer a complex number
	 if the receiver is negative."

	<category: 'accessing'>
	| log theta |
	theta := self arg.
	(aNumber isComplex or: [theta ~= 0]) ifTrue: [
	    log := self abs ln.
	    ^Complex
		rho: (aNumber real * log - (aNumber imaginary * theta)) exp
		theta: aNumber real * theta + (aNumber imaginary * log)].

        aNumber isInteger
            ifTrue: [^self raisedToInteger: aNumber].
        ^aNumber generality > 1.0d generality
            ifTrue: [(aNumber coerce: self) raisedTo: aNumber]
            ifFalse: [self asFloatD raisedTo: aNumber asFloatD]
    ]

    arg [
	"Return the argument of the receiver."

	<category: 'accessing'>
	^self >= 0 ifTrue: [0.0] ifFalse: [FloatD pi]
    ]

    i [
	"Return the receiver multiplied by the imaginary unit."

	<category: 'accessing'>
	^Complex real: self zero imaginary: self
    ]

]



Float extend [

    primLn [
	"Answer the natural logarithm of the receiver"

	<category: 'private'>
	<primitive: VMpr_Float_ln>
	self primitiveFailed
    ]

    primSqrt [
	"Answer the square root of the receiver"

	<category: 'private'>
	<primitive: VMpr_Float_sqrt>
	self primitiveFailed
    ]

    arg [
	"Return the argument of the receiver."

	<category: 'transcendental functions'>
	^self >= 0 ifTrue: [self zero] ifFalse: [self class pi]
    ]

    ln [
	"Answer the natural logarithm of the receiver"

	<category: 'transcendental functions'>
	self >= 0 ifTrue: [^self primLn].
	^Complex real: self negated primLn imaginary: self class pi
    ]

    sqrt [
	"Answer the square root of the receiver"

	<category: 'transcendental functions'>
	self >= 0 ifTrue: [^self primSqrt].
	^Complex real: 0 imaginary: self negated sqrt
    ]

    primRaisedTo: aNumber [
        "Answer the receiver raised to its aNumber power"

        <category: 'built ins'>
        <primitive: VMpr_Float_pow>
        aNumber isFloat ifTrue: [self arithmeticError: 'invalid operands'].
        ^self raisedTo: (self coerce: aNumber)
    ]

    raisedTo: aNumber [
	"Return the receiver, raised to aNumber.  This may answer a complex number
	 if the receiver is negative."

	<category: 'accessing'>
	| log theta |
	^(aNumber isComplex or: [self < 0])
	    ifTrue: [ super raisedTo: aNumber ]
	    ifFalse: [ self primRaisedTo: aNumber ].
    ]

]



FloatQ extend [

    arg [
	"Return the argument of the receiver."

	<category: 'accessing'>
	^self >= 0 ifTrue: [self zero] ifFalse: [self class pi]
    ]
]


Integer extend [
    sqrt [
	"Return the square root of the receiver.  Unlike the default
	 implementation, this returns an integer if the receiver is
	 a perfect square."

	| k l l1 |
	self < 0 ifTrue: [ ^Complex real: 0 imaginary: self negated sqrt ].
	self <= 1 ifTrue: [ ^self ].
	"Find an upper bound to self sqrt."
	k := self bitShift: ((self floorLog: 2) quo: -2).
	"Use Newton iteration to find if self is a perfect square."
	[ 
	    l1 := (self + k - 1) quo: k.
	    (k - l1) < 1 ] whileFalse: [
	        l := self / k.
	        k := (k + l) / 2 ].
	l1 squared = self ifTrue: [ ^l1 ].
	^super sqrt
    ]
]

Number extend [

    arcCos [
	"Return the arc-cosine of the receiver."

	<category: 'transcendental functions'>
	| z |
	z := (Complex real: self imaginary: (1 - self squared) sqrt) ln.
	^Complex real: 0 imaginary: z negated
    ]

    arcSin [
	"Return the arc-sine of the receiver."

	<category: 'transcendental functions'>
	| z |
	z := (Complex real: (1 - self squared) sqrt imaginary: self) ln.
	^Complex real: 0 imaginary: z negated
    ]

]



Eval [
    (Float methodDictionary)
	removeKey: #arcSin;
	removeKey: #arcCos.
    Complex initialize
]

