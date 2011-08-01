"======================================================================
|
|   Float Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2007,2008,2009
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



Number subclass: Float [
    
    <shape: #byte>
    <import: CSymbols>
    <category: 'Language-Data types'>
    <comment: 'My instances represent floating point numbers that have arbitrary
precision.  Besides the standard numerical operations, they provide
transcendental operations too.  They implement IEEE-754 correctly
if the hardware supports it.'>

    Float class >> signByte [
	"Answer the byte of the receiver that contains the sign bit"

	<category: 'byte-order dependancies'>
	self subclassResponsibility
    ]

    Float class >> e [
	"Returns the value of e. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.B7E151628AED2A6ABF71588d
    ]

    Float class >> log10Base2 [
	"Returns the value of log2 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.5269E12F346E2BF924AFDBFDd
    ]

    Float class >> ln10 [
	"Returns the value of ln 10. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r2.4D763776AAA2B05BA95B58AEd
    ]

    Float class >> pi [
	"Returns the value of pi. Hope is that it is precise enough"

	<category: 'characterization'>
	^16r3.243F6A8885A308D313198A2Ed
    ]

    Float class >> radix [
	"Answer the base in which computations between instances of the receiver
	 are made.  This should be 2 on about every known computer, so GNU
	 Smalltalk always answers 2."

	<category: 'characterization'>
	^2
    ]

    Float class >> denormalized [
	"Answer whether instances of the receiver can be in denormalized
	 form."

	<category: 'characterization'>
	^self fminDenormalized > 0
    ]

    Float class >> fminDenormalized [
	"Return the smallest Float that is > 0 if denormalized values
	 are supported, else return 0."

	<category: 'characterization'>
	^self fminNormalized timesTwoPower: 1 - self precision
    ]

    Float class >> fmin [
	"Return the smallest Float that is > 0."

	<category: 'characterization'>
	| fminDen fmin |
	fmin := self fminNormalized.
	fminDen := fmin timesTwoPower: 1 - self precision.
	^fminDen = 0 ifTrue: [fmin] ifFalse: [fminDen]
    ]

    Float class >> epsilon [
	"Return the smallest Float x for which is 1 + x ~= 1"

	<category: 'characterization'>
	^(self coerce: 2) timesTwoPower: self precision negated
    ]

    hash [
	"Answer an hash value for the receiver.  Not-a-number values do not
	 have a hash code and cannot be put in a hashed collection."

	"Hack so that 2 hash = 2.0 hash"

	<category: 'basic'>
	self = self ifFalse: [
	    SystemExceptions.InvalidValue
		signalOn: self
		reason: 'cannot put NaN in a hashed collection' ].

	^self fractionPart = 0.0 
	    ifTrue: [self asInteger hash]
	    ifFalse: [self primHash]
    ]

    negated [
	"Return the negation of the receiver.  Unlike 0-self, this converts
	 correctly signed zeros."

	<category: 'arithmetic'>
	^self * -1
    ]

    integerPart [
	"Return the receiver's integer part"

	<category: 'arithmetic'>
	^self - self fractionPart
    ]

    raisedToInteger: anInteger [
	"Return self raised to the anInteger-th power"

	<category: 'arithmetic'>
	"Some special cases first"

	| exp adjustExp val mant |
	anInteger isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer].
	anInteger = 0 ifTrue: [^self unity].
	anInteger = 1 ifTrue: [^self].

	"Avoid overflow when the result is denormal and we would have an
	 unrepresentable intermediate result for its reciprocal."
	adjustExp := self exponent.
	exp := anInteger abs.
	(anInteger > 0 or: [(adjustExp + 1) * exp < self class emax]) 
	    ifTrue: 
		[mant := self.
		adjustExp := 0]
	    ifFalse: 
		[mant := self timesTwoPower: 0 - adjustExp.
		adjustExp := adjustExp * anInteger].

	"Fire the big loop."
	val := mant raisedToInteger: exp
		    withCache: ((Array new: (255 min: exp))
			    at: 1 put: mant;
			    yourself).
	anInteger < 0 ifTrue: [val := val reciprocal].
	adjustExp = 0 ifFalse: [val := val timesTwoPower: adjustExp].
	^val
    ]

    isNaN [
	"Answer whether the receiver represents a NaN"

	<category: 'testing'>
	^self ~= self
    ]

    isFinite [
	"Answer whether the receiver does not represent infinity, nor a NaN"

	<category: 'testing'>
	^self - self = self zero
    ]

    isInfinite [
	"Answer whether the receiver represents positive or negative infinity"

	<category: 'testing'>
	^self = self class infinity or: [self = self class negativeInfinity]
    ]

    negative [
	"Answer whether the receiver is negative"

	<category: 'testing'>
	^self <= self zero and: [self unity / self <= self zero]
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'testing'>
	^self > self zero
    ]

    positive [
	"Answer whether the receiver is positive.  Negative zero is
	 not positive, so the definition is not simply >= 0."

	<category: 'testing'>
	^self >= self zero and: [self unity / self >= self zero]
    ]

    sign [
	"Answer 1 if the receiver is greater than 0, -1 if less than 0,
	 else 0.  Negative zero is the same as positive zero."

	<category: 'testing'>
	self = self zero ifTrue: [^0].
	^self < 0 ifTrue: [-1] ifFalse: [1]
    ]

    truncated [
	"Convert the receiver to an Integer.  Only used for LargeIntegers,
	 there are primitives for the other cases."

	<category: 'coercing'>
	| exponent bytes positive float |
	self isFinite ifFalse: [^self].
	(positive := self > 0) 
	    ifTrue: [float := self]
	    ifFalse: [float := self negated].
	exponent := float exponent.
	bytes := LargePositiveInteger new: (self class precision + 7) // 8 + 1.
	float := float timesTwoPower: float class precision - exponent - 8.
	1 to: bytes size
	    do: 
		[:i | 
		bytes digitAt: i put: (float fractionPart timesTwoPower: 8) truncated.
		float := float integerPart timesTwoPower: -8].
	bytes := bytes bitShift: exponent - float class precision.
	positive ifFalse: [bytes := bytes negated].
	^bytes
    ]

    asCNumber [
	"Convert the receiver to a kind of number that is understood by
	 the C call-out mechanism."
	<category: 'coercion'>
	^self
    ]

    asExactFraction [
	"Convert the receiver into a fraction with optimal approximation,
	 but with usually huge terms."

	<category: 'coercing'>
	| shift mantissa |
	self checkCoercion.
	shift := self exponent negated + self class precision.
	mantissa := (self timesTwoPower: shift) truncated.
	^shift negative 
	    ifTrue: [(mantissa * (1 bitShift: shift negated)) asFraction]
	    ifFalse: [(mantissa / (1 bitShift: shift)) asFraction]
    ]

    asFraction [
	"Convert the receiver into a fraction with a good (but undefined)
	 approximation"

	<category: 'coercing'>
	| a x n2 d2 n1 d1 n0 d0 eps abs gcd |
	self checkCoercion.

	"This uses an algorithm based on continued fractions.
	 n2/d2 = numerator and denominator of the fraction two steps ago
	 n1/d1 = numerator and denominator of the fraction a steps ago
	 n0/d0 = numerator and denominator of the fraction at the current step"
	n1 := d0 := 0.
	n0 := d1 := 1.
	abs := self abs timesTwoPower: self exponent negated.
	eps := self class epsilon.
	x := abs.
	
	[a := x truncated.
	n2 := n1.
	d2 := d1.
	n1 := n0.
	d1 := d0.
	n0 := n1 * a + n2.
	d0 := d1 * a + d2.
	(x := self unity / x fractionPart) isInfinite 
	    or: [((self coerce: n0) / (self coerce: d0) - abs) abs < eps]] 
		whileFalse.
	self exponent < 0 
	    ifTrue: [d0 := d0 * (2 raisedToInteger: self exponent negated)]
	    ifFalse: [n0 := n0 * (2 raisedToInteger: self exponent)].
	gcd := n0 gcd: d0.
	n0 := n0 divExact: gcd.
	d0 := d0 divExact: gcd.
	^Fraction numerator: (self < 0 ifTrue: [n0 negated] ifFalse: [n0])
	    denominator: d0
    ]

    log [
	"Answer log base 10 of the receiver."
	<category: 'transcendental operations'>
	^self ln / self class ln10
    ]

    log: aNumber [
	"Answer log base aNumber of the receiver"

	<category: 'misc math'>
	^self ln / (self coerce: aNumber) ln
    ]

    ceilingLog: radix [
	"Answer (self log: radix) ceiling.  Use exact arithmetic if radix
	 is not a floating point value."

	<category: 'transcendental operations'>
	radix isFloat ifFalse: [ ^self asExactFraction ceilingLog: radix ].

	self < self zero 
	    ifTrue: 
		[^self arithmeticError: 'cannot extract logarithm of a negative number'].
	radix <= radix unity 
	    ifTrue: 
		[radix <= radix zero ifTrue: [^self arithmeticError: 'bad radix'].
		radix = radix unity ifTrue: [^self arithmeticError: 'bad radix']].

	^(self log: radix) ceiling
    ]

    floorLog: radix [
	"Answer (self log: radix) floor.  Use exact arithmetic if radix
	 is not a floating point value."

	<category: 'transcendental operations'>
	radix isFloat ifFalse: [ ^self asExactFraction floorLog: radix ].

	self < self zero 
	    ifTrue: 
		[^self arithmeticError: 'cannot extract logarithm of a negative number'].
	radix <= radix unity 
	    ifTrue: 
		[radix <= radix zero ifTrue: [^self arithmeticError: 'bad radix'].
		radix = radix unity ifTrue: [^self arithmeticError: 'bad radix']].

	^(self log: radix) floor
    ]

    estimatedLog [
	"Answer an estimate of (self abs floorLog: 10)"

	<category: 'transcendental operations'>
	^(self exponent + 1) asFloatD / FloatD log10Base2
    ]

    asFloat [
	"Just defined for completeness.  Return the receiver."

	<category: 'transcendental operations'>
	^self
    ]

    min: aNumber [
	"Answer the minimum between the receiver and aNumber.  Redefine
	 in subclasses if necessary to ensure that if either self or
	 aNumber is a NaN, it is always answered."

	"If both self and aNumber are zero, return aNumber in case it
	 has a negative sign, because we assume our zero is positive.
	 If the test is false, always answer aNumber in case it is a
	 NaN, because we assume that self is not a NaN."

	<category: 'comparing'>
	^aNumber < self 
	    ifTrue: [aNumber]
	    ifFalse: 
		[self = aNumber 
		    ifFalse: [aNumber = aNumber ifFalse: [aNumber] ifTrue: [self]]
		    ifTrue: 
			["Remember than -0.0 - +0.0 = -0.0, but the other pairs are +0.0."

			self = self zero ifTrue: [(self * -1 - aNumber) * -1] ifFalse: [self]]]
    ]

    max: aNumber [
	"Answer the maximum between the receiver and aNumber.  Redefine
	 in subclasses if necessary to ensure that if either self or
	 aNumber is a NaN, it is always answered."

	<category: 'comparing'>
	^aNumber > self 
	    ifTrue: [aNumber]
	    ifFalse: 
		[self = aNumber 
		    ifFalse: [aNumber = aNumber ifFalse: [aNumber] ifTrue: [self]]
		    ifTrue: 
			["Remember than -0.0 + -0.0 = -0.0, but the other pairs are +0.0."

			self = self zero ifTrue: [self + aNumber] ifFalse: [self]]]
    ]

    withSignOf: aNumber [
	"Answer the receiver, with its sign possibly changed to match
	 that of aNumber."

	<category: 'comparing'>
	^aNumber positive == self positive ifTrue: [self] ifFalse: [self negated]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	self printOn: aStream special: #('Inf' '-Inf' 'NaN')
    ]

    isExact [
	"Answer whether the receiver performs exact arithmetic.  Floats
	 do not."

	<category: 'testing'>
	^false
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'storing'>
	^true
    ]

    storeLiteralOn: aStream [
	"Store on aStream some Smalltalk code which compiles to the receiver"

	<category: 'storing'>
	self storeOn: aStream
    ]

    storeOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'storing'>
	| printString |
	(self isInfinite or: [self isNaN]) 
	    ifTrue: 
		[^self printOn: aStream
		    special: #('%1 infinity' '%1 negativeInfinity' '%1 nan')].
	printString := self printString.
	aStream nextPutAll: printString.

	"For FloatE/FloatQ, force printing the exponent at the end."
	self exponentLetter == $d ifTrue: [^self].
	(printString includes: self exponentLetter) 
	    ifFalse: [aStream nextPut: self exponentLetter]
    ]

    checkCoercion [
	"Private - Fail if the receiver is only representable as a Float"

	<category: 'private'>
	self isInfinite 
	    ifTrue: [self arithmeticError: 'Infinity can only be a Float'].
	self isNaN 
	    ifTrue: [self arithmeticError: 'Not-a-Number can only be a Float']
    ]

    printOn: aStream special: whatToPrintArray [
	"Private - Print a decimal representation of the receiver on aStream,
	 printing one of the three elements of whatToPrintArray if it is
	 infinity, negative infinity, or a NaN"

	<category: 'private'>
	"First, take care of the easy cases."

	| me exponential small num sameUp sameDown weight prevWeight digit
          eps precision digits digitStream exponent dotPrinted allNines adjust |
	self isNaN 
	    ifTrue: [^aStream nextPutAll: (whatToPrintArray at: 3) % {self class}].
	self = self class infinity 
	    ifTrue: [^aStream nextPutAll: (whatToPrintArray at: 1) % {self class}].
	self = self class negativeInfinity 
	    ifTrue: [^aStream nextPutAll: (whatToPrintArray at: 2) % {self class}].

	"We deal only with positive values."
	me := self abs.
	self negative ifTrue: [aStream nextPut: $-].
	self = self zero 
	    ifTrue: 
		[aStream nextPutAll: '0.0'.
		^self].

	"Figure out some quantities and the way we'll print the number."
	exponential := me exponent abs > me class precision.
	small := me < me unity.

	"Compute the digits one by one."
	num := me asExactFraction.
	exponent := (num floorLog: 10) + 1.
	digits := 0.
	weight := 10 raisedToInteger: exponent - 1.

	"Smallest number such that me + eps ~= eps"
	eps := 2 raisedToInteger: me exponent - me class precision + 1.

	allNines := true.
        sameDown := true.
        sameUp := true.

        [digit := num // weight.
        num := num \\ weight.
	allNines := allNines and: [digit = 9].
        sameDown := sameDown and: [num >= eps].
        sameUp := sameUp and: [num < (weight - eps)].
	digits := digits * 10 + digit.
	prevWeight := weight.
	weight := weight / 10.
	sameDown or: [sameUp]] whileTrue.

        "For large numbers, don't let round-to-even bite us."
        eps isInteger ifTrue: [eps := eps / 2].

	adjust := 0.

        "Round the last digit if it allows to save trailing digits while
         not changing the meaning."
	(digit <= 5 and: [num + (digit * prevWeight) < (eps / 2)])
            ifTrue: [adjust := digit negated].
	(digit > 5 and: [num + ((digit - 10) * prevWeight) > (eps / -2)])
            ifTrue: [adjust := 10 - digit].

         "... otherwise, try rounding it up if it is a better approximation."
	(adjust = 0 and: [digit > 0]) ifTrue: [
            (num - prevWeight) abs < num ifTrue: [adjust := 1]].

	digits := digits + adjust.
	(adjust > 0 and: [allNines])
            ifTrue: [allNines := false. exponent := exponent + 1].

	digits := digits printString.

	"Print the non-significant zeros."
	dotPrinted := false.
	(small and: [exponential not]) 
	    ifTrue: 
		[1 - exponent timesRepeat: 
			[aStream nextPut: $0.
			dotPrinted 
			    ifFalse: 
				[dotPrinted := true.
				aStream nextPut: $.].
			exponent := exponent + 1]].

	"Make a stream with the significant digits."
	precision := digits findLast: [:ch | ch ~= $0].
	digitStream := ReadStream 
		    on: digits
		    from: 1
		    to: precision.

	"Print the integer part (only one digit if using exponential notation)."
	
	[digitStream atEnd 
	    ifTrue: [aStream nextPut: $0]
	    ifFalse: [aStream nextPut: digitStream next].
	exponent := exponent - 1.
	exponent > 0 and: [exponential not]] 
		whileTrue.

	"Print the fractional part."
	digitStream atEnd 
	    ifTrue: [dotPrinted ifFalse: [aStream nextPutAll: '.0']]
	    ifFalse: 
		[dotPrinted ifFalse: [aStream nextPut: $.].
		digitStream do: [:each | aStream nextPut: each]].

	"Finally, print the exponent if necessary."
	exponential 
	    ifTrue: 
		[aStream
		    nextPut: me exponentLetter;
		    print: exponent]
    ]

    isFloat [
	<category: 'testing functionality'>
	^true
    ]

    exp [
	"Answer 'e' (2.718281828459...) raised to the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_exp>
	self primitiveFailed
    ]

    ln [
	"Answer the logarithm of the receiver in base 'e' (2.718281828459...)"

	<category: 'built ins'>
	<primitive: VMpr_Float_ln>
	self primitiveFailed
    ]

    raisedTo: aNumber [
	"Answer the receiver raised to its aNumber power"

	<category: 'built ins'>
	<primitive: VMpr_Float_pow>
	aNumber isFloat ifTrue: [self arithmeticError: 'invalid operands'].
	^self raisedTo: (self coerce: aNumber)
    ]

    sqrt [
	"Answer the square root of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_sqrt>
	self primitiveFailed
    ]

    ceiling [
	"Answer the integer part of the receiver, truncated towards +infinity"

	<category: 'built ins'>
	<primitive: VMpr_Float_ceil>
	self checkCoercion.
	^self > 0 
	    ifTrue: [self truncated + self fractionPart sign]
	    ifFalse: [self truncated]
    ]

    rounded [
        "Answer the receiver, rounded to the nearest integer"

        <category: 'truncation and round off'>
	self fractionPart abs < self half
	    ifTrue: [^self truncated]
	    ifFalse: [^self truncated + self sign rounded]
    ]

    half [
        "Answer 0.5 in the representation of the receiver"

        <category: 'converting'>
	^self unity / 2
    ]

    primHash [
	"Private - Answer an hash value for the receiver"

	<category: 'built ins'>
	<primitive: VMpr_String_hash>
	^0
    ]

    floor [
	"Answer the integer part of the receiver, truncated towards -infinity"

	<category: 'built ins'>
	<primitive: VMpr_Float_floor>
	self checkCoercion.
	^self < 0 
	    ifTrue: [self truncated + self fractionPart sign]
	    ifFalse: [self truncated]
    ]

    sin [
	"Answer the sine of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_sin>
	self primitiveFailed
    ]

    cos [
	"Answer the cosine of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_cos>
	self primitiveFailed
    ]

    tan [
	"Answer the tangent of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_tan>
	
    ]

    arcSin [
	"Answer the arc-sine of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_arcSin>
	^self arithmeticError: 'argument out of range'
    ]

    arcCos [
	"Answer the arc-cosine of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_arcCos>
	^self arithmeticError: 'argument out of range'
    ]

    arcTan [
	"Answer the arc-tangent of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Float_arcTan>
	
    ]

    successor [
	<category: 'floating point'>
	| exponent |
	self isFinite ifFalse: [
	    (self isNaN or: [self positive]) ifTrue: [^self].
	    ^self class fmax negated].
	self = 0.0 ifTrue: [^self class fmin].
	exponent := self exponent.
	^exponent < self class emin
	    ifTrue: [self + self class fminDenormalized]
	    ifFalse: [self + (self class epsilon timesTwoPower: exponent)]
    ]

    predecessor [
	<category: 'floating point'>
	| exponent |
	self isFinite ifFalse: [
		(self isNaN or: [self negative]) ifTrue: [^self].
		^self class fmax].
	self = 0.0 ifTrue: [^self class fmin negated].
	exponent := self exponent.
	^exponent < self class emin
	    ifTrue: [self - self class fminDenormalized]
	    ifFalse: [self - (self class epsilon timesTwoPower: exponent)]
    ]
]

