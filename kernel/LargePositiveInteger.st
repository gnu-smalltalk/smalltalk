"======================================================================
|
|   LargeInteger hierarchy Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



LargeInteger subclass: LargePositiveInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
Just like my brother LargeNegativeInteger, I provide a few methods that
allow LargeInteger to determine the sign of a large integer in a fast way
during its calculations.  For example, I know that I am larger than any
LargeNegativeInteger.  In addition I implement the guts of arbitrary
precision arithmetic.'>

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	| newBytes carry a b result |
	<primitive: VMpr_LargeInteger_plus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber sign = -1 ifTrue: [^self - aNumber negated].
	aNumber generality = self generality 
	    ifFalse: [^self retrySumCoercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size) + 1.
	carry := 0.
	1 to: newBytes size - 1
	    do: 
		[:index | 
		result := (self at: index) + (aNumber at: index) + carry.
		result > 255 
		    ifTrue: 
			[carry := 1.
			result := result - 256]
		    ifFalse: [carry := 0].
		newBytes at: index put: result].
	newBytes at: newBytes size put: carry.
	^LargeInteger resultFrom: newBytes
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	| newBytes carry a b result |
	<primitive: VMpr_LargeInteger_minus>
	aNumber sign = 0 ifTrue: [^self].
	aNumber sign = -1 ifTrue: [^self + aNumber negated].
	aNumber generality = self generality 
	    ifFalse: [^self retryDifferenceCoercing: aNumber].
	newBytes := ByteArray new: (self size max: aNumber size) + 1.
	carry := 0.
	1 to: newBytes size - 1
	    do: 
		[:index | 
		result := (self at: index) - (aNumber at: index) + carry.
		result < 0 
		    ifTrue: 
			[carry := -1.
			result := result + 256]
		    ifFalse: [carry := 0].
		newBytes at: index put: result].
	newBytes at: newBytes size put: (carry bitAnd: 255).
	^LargeInteger resultFrom: newBytes
    ]

    gcd: anInteger [
	"Calculate the GCD between the receiver and anInteger"

	"Binary GCD - See Knuth `Seminumerical algorithms', Vol 2, 4.5.2
	 It was adapted to remove the variable `r' and to only work with
	 unsigned numbers"

	<category: 'arithmetic'>
	| adjust t tmp u v |
	<primitive: VMpr_LargeInteger_gcd>
	(self sign bitAnd: anInteger sign) = 0 ifTrue: [^self + anInteger].
	u := self bytes.
	v := anInteger abs.
	v generality = self generality ifFalse: [v := self coerce: v].
	v := v bytes.

	"Divide u and v by 2 as long as they are both even"
	adjust := t := self bytesTrailingZeros: u.
	self bytesRightShift: u big: t.
	adjust := adjust min: (t := self bytesTrailingZeros: v).
	self bytesRightShift: v big: t.
	u size = v size 
	    ifFalse: 
		[u size < v size 
		    ifTrue: [u := u copyGrowTo: v size]
		    ifFalse: [v := v copyGrowTo: u size]].

	"Well, this is it -- the stuff up to this point was just set up"
	
	[t := self 
		    bytes: u
		    from: 1
		    compare: v.
	t = 0] 
		whileFalse: 
		    [t < 0 
			ifTrue: 
			    [t := v.
			    v := u.
			    u := t].
		    self 
			bytes: u
			from: 1
			subtract: v.
		    ((u at: 1) bitAnd: 1) = 0 
			ifTrue: 
			    [t := self bytesTrailingZeros: u.
			    self bytesRightShift: u big: t]].
	self bytesLeftShift: u big: adjust.
	^self species resultFrom: u
    ]

    highBit [
	"Answer the receiver's highest bit's index"

	<category: 'arithmetic'>
	^(self at: self size) = 0 
	    ifTrue: [^8 * self size - 8 - (LeadingZeros at: (self at: self size - 1))]
	    ifFalse: [^8 * self size - (LeadingZeros at: (self at: self size))]
    ]

    positive [
	"Answer whether the receiver is >= 0"

	<category: 'numeric testing'>
	^true
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'numeric testing'>
	^true
    ]

    negative [
	"Answer whether the receiver is < 0"

	<category: 'numeric testing'>
	^false
    ]

    abs [
	"Answer the receiver's absolute value"

	<category: 'numeric testing'>
	^self
    ]

    sign [
	"Answer the receiver's sign"

	<category: 'numeric testing'>
	^1
    ]

    asFloat: characterization [
	"Answer the receiver converted to a Float"

	<category: 'private'>
	"Check for number bigger than maximum mantissa"

	| nTruncatedBits mantissa exponent mask trailingBits inexact carry |
	nTruncatedBits := self highBit - characterization precision.
	nTruncatedBits <= 0 ifTrue: [^self fastAsFloat: characterization].
	mantissa := self bitShift: nTruncatedBits negated.
	exponent := nTruncatedBits.

	"Apply IEEE 754 round to nearest even default rounding mode"
	carry := self bitAt: nTruncatedBits.
	(carry = 1 and: [mantissa odd or: [self lowBit < nTruncatedBits]]) 
	    ifTrue: [mantissa := mantissa + 1].
	^(characterization coerce: mantissa) timesTwoPower: exponent
    ]

    fastAsFloat: characterization [
	"Conversion can be exact, construct Float by successive mul add operations"

	<category: 'private'>
	| result byte |
	byte := characterization coerce: 256.
	result := characterization coerce: 0.
	self size to: 1
	    by: -1
	    do: [:index | result := result * byte + (self at: index)].
	^result
    ]

    mostSignificantByte [
	"Private - Answer the value of the most significant byte"

	<category: 'private'>
	^0
    ]

    asFloatD [
	"Answer the receiver converted to a FloatD"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatD>
	^self asFloat: FloatD
    ]

    asFloatE [
	"Answer the receiver converted to a FloatE"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatE>
	^self asFloat: FloatE
    ]

    asFloatQ [
	"Answer the receiver converted to a FloatQ"

	<category: 'converting'>
	<primitive: VMpr_LargeInteger_asFloatQ>
	^self asFloat: FloatQ
    ]

    replace: str withStringBase: radix [
	"Return in a String str the base radix representation of the
	 receiver."

	<category: 'converting'>
	| digits source quo t rem where |
	source := self.
	quo := ByteArray new: self size.
	where := str size.
	self size to: 1
	    by: -1
	    do: 
		[:i | 
		
		[rem := 0.
		i to: 1
		    by: -1
		    do: 
			[:j | 
			t := (rem bitShift: 8) + (source at: j).
			quo at: j put: t // radix.
			rem := t \\ radix].
		str at: where put: (Character digitValue: rem).
		where := where - 1.
		source := quo.
		(source at: i) = 0] 
			whileFalse].
	^str
    ]

    isSmall [
	"Private - Answer whether the receiver is small enough to employ simple
	 scalar algorithms for division and multiplication"

	<category: 'primitive operations'>
	^self size <= 2 and: [(self at: 2) = 0]
    ]

    divide: aNumber using: aBlock [
	"Private - Divide the receiver by aNumber (unsigned division). Evaluate
	 aBlock passing the result ByteArray, the remainder ByteArray, and
	 whether the division had a remainder"

	<category: 'primitive operations'>
	| result a b |
	aNumber isSmall 
	    ifTrue: 
		[result := ByteArray new: self size.
		b := 0.
		self size to: 1
		    by: -1
		    do: 
			[:j | 
			a := (b bitShift: 8) + (self at: j).
			result at: j put: a // (aNumber at: 1).
			b := a \\ (aNumber at: 1)].
		^aBlock 
		    value: result
		    value: (ByteArray with: b with: 0)
		    value: b ~= 0].

	"special case: numerator < denominator"
	self size < aNumber size 
	    ifTrue: 
		[^aBlock 
		    value: ZeroBytes
		    value: self
		    value: true].
	self size > aNumber size 
	    ifTrue: 
		[result := self primDivide: aNumber.
		^aBlock 
		    value: result key
		    value: result value
		    value: (result value anySatisfy: [:each | each ~= 0])].
	self size to: 1
	    by: -1
	    do: 
		[:index | 
		a := self at: index.
		b := aNumber at: index.
		b > a 
		    ifTrue: 
			[^aBlock 
			    value: ZeroBytes
			    value: self
			    value: true].
		a > b 
		    ifTrue: 
			[result := self primDivide: aNumber.
			^aBlock 
			    value: result key
			    value: result value
			    value: (result value anySatisfy: [:each | each ~= 0])]].
	"Special case: numerator = denominator"
	^aBlock 
	    value: OneBytes
	    value: ZeroBytes
	    value: false
    ]

    multiply: aNumber [
	"Private - Multiply the receiver by aNumber (unsigned multiply)"

	<category: 'primitive operations'>
	"Special case - other factor < 255"

	| newBytes byte carry index digit start |
	aNumber isSmall 
	    ifTrue: 
		[^self species from: (self bytes: self bytes multiply: (aNumber at: 1))].
	start := 1.
	[(aNumber at: start) = 0] whileTrue: [start := start + 1].
	newBytes := ByteArray new: self size + aNumber size + 2.
	1 to: self size
	    do: 
		[:indexA | 
		digit := self at: indexA.
		digit = 0 
		    ifFalse: 
			[carry := 0.
			index := indexA + start - 1.
			start to: aNumber size
			    do: 
				[:indexB | 
				byte := digit * (aNumber at: indexB) + carry + (newBytes at: index).
				carry := byte bitShift: -8.
				newBytes at: index put: (byte bitAnd: 255).
				index := index + 1].
			newBytes at: indexA + aNumber size put: carry]].
	"If I multiply two large integers, the result is large, so use #from:..."
	^self species from: newBytes
    ]

    bytes: bytes multiply: anInteger [
	"Private - Multiply the bytes in bytes by anInteger, which must be < 255.
	 Put the result back in bytes."

	<category: 'helper byte-level methods'>
	| byte carry |
	carry := 0.
	1 to: bytes size
	    do: 
		[:index | 
		byte := (bytes at: index) * anInteger + carry.
		carry := byte bitShift: -8.
		bytes at: index put: (byte bitAnd: 255)].
	carry > 0 ifTrue: [bytes at: bytes size - 1 put: carry].
	^bytes
    ]

    bytes: byteArray1 from: j compare: byteArray2 [
	"Private - Answer the sign of byteArray2 - byteArray1; the
	 j-th byte of byteArray1 is compared with the first of byteArray2,
	 the j+1-th with the second, and so on."

	<category: 'helper byte-level methods'>
	| a b i |
	i := byteArray2 size.
	j + byteArray2 size - 1 to: j
	    by: -1
	    do: 
		[:index | 
		b := byteArray2 at: i.
		a := byteArray1 at: index.
		a < b ifTrue: [^-1].
		a > b ifTrue: [^1].
		i := i - 1].
	^0
    ]

    bytes: byteArray1 from: j subtract: byteArray2 [
	"Private - Sutract the bytes in byteArray2 from those in byteArray1"

	<category: 'helper byte-level methods'>
	| carry a i |
	carry := 256.
	i := 1.
	j to: j + byteArray2 size - 1
	    do: 
		[:index | 
		a := (byteArray1 at: index) - (byteArray2 at: i) + carry.
		a < 256 
		    ifTrue: [carry := 255]
		    ifFalse: 
			[carry := 256.
			a := a - 256].
		byteArray1 at: index put: a.
		i := i + 1]
    ]

    bytesLeftShift: aByteArray [
	"Private - Left shift by 1 place the bytes in aByteArray"

	<category: 'helper byte-level methods'>
	| carry a |
	carry := 0.
	1 to: aByteArray size
	    do: 
		[:index | 
		a := aByteArray at: index.
		a := a + a + carry.
		carry := a bitShift: -8.
		a := a bitAnd: 255.
		aByteArray at: index put: a]
    ]

    bytesLeftShift: aByteArray n: shift [
	"Private - Left shift by shift places the bytes in aByteArray
	 (shift <= 7)"

	<category: 'helper byte-level methods'>
	| carry a |
	carry := 0.
	1 to: aByteArray size
	    do: 
		[:index | 
		a := aByteArray at: index.
		a := (a bitShift: shift) + carry.
		carry := a bitShift: -8.
		aByteArray at: index put: (a bitAnd: 255)]
    ]

    bytesLeftShift: aByteArray big: totalShift [
	"Private - Left shift the bytes in aByteArray by totalShift places"

	<category: 'helper byte-level methods'>
	| newBytes byteShift shift a last |
	totalShift = 0 ifTrue: [^self].
	byteShift := totalShift // 8.
	shift := totalShift bitAnd: 7.
	last := 0.
	aByteArray size - 1 to: byteShift + 1
	    by: -1
	    do: 
		[:index | 
		a := aByteArray at: index - byteShift.
		a := a bitShift: shift.
		aByteArray at: index + 1 put: last + (a bitShift: -8).
		last := a bitAnd: 255].
	aByteArray at: byteShift + 1 put: last.
	1 to: byteShift do: [:i | aByteArray at: i put: 0]
    ]

    bytesRightShift: aByteArray big: totalShift [
	"Private - Right shift the bytes in aByteArray by totalShift places"

	<category: 'helper byte-level methods'>
	| shift byteShift carryShift x a |
	totalShift = 0 ifTrue: [^self].
	byteShift := totalShift // 8.
	shift := (totalShift bitAnd: 7) negated.
	carryShift := 8 + shift.
	x := (aByteArray at: byteShift + 1) bitShift: shift.
	byteShift + 2 to: aByteArray size
	    do: 
		[:j | 
		a := aByteArray at: j.
		aByteArray at: j - byteShift - 1
		    put: ((a bitShift: carryShift) bitAnd: 255) + x.
		x := a bitShift: shift].
	aByteArray at: aByteArray size - byteShift put: x.
	aByteArray size - byteShift + 1 to: aByteArray size
	    do: [:i | aByteArray at: i put: 0]
    ]

    bytesRightShift: bytes n: aNumber [
	"Private - Right shift the bytes in `bytes' by 'aNumber' places
	 (shift <= 7)"

	<category: 'helper byte-level methods'>
	| shift carryShift x a |
	aNumber = 0 ifTrue: [^self].
	shift := aNumber negated.
	carryShift := 8 + shift.
	x := (bytes at: 1) bitShift: shift.
	2 to: bytes size
	    do: 
		[:j | 
		a := bytes at: j.
		bytes at: j - 1 put: ((a bitShift: carryShift) bitAnd: 255) + x.
		x := a bitShift: shift].
	bytes at: bytes size put: x
    ]

    bytesTrailingZeros: bytes [
	"Private - Answer the number of trailing zero bits in the receiver"

	<category: 'helper byte-level methods'>
	| each |
	1 to: bytes size
	    do: 
		[:index | 
		(each := bytes at: index) = 0 
		    ifFalse: [^index * 8 - 8 + (TrailingZeros at: each)]].
	^bytes size * 8
    ]

    primDivide: rhs [
	"Private - Implements Knuth's divide and correct algorithm from
	 `Seminumerical Algorithms' 3rd Edition, section 4.3.1 (which
	 is basically an enhanced version of the divide `algorithm' for
	 two-digit divisors which is taught in primary school!!!)"

	<category: 'helper byte-level methods'>
	"Leading zeros in `v'"

	"Cached v at: n, v at: n - 1, j + n, j + n - 1"

	"Cached `u size - v size' and `v size'"

	"High 2 bytes of `u'"

	"guess times the divisor (v)"

	"Quotient"

	"guess at the quotient byte and remainder"

	"The operands"

	"0. Initialize everything"

	| d vn vn1 jn jn1 m n high sub q guess rem u v |
	u := self bytes.
	v := rhs bytes.
	n := v size.
	sub := ByteArray new: n.
	m := u size - n.
	q := ByteArray new: m + 2.

	"1. Normalize the divisor
	 Knuth's algorithm is based on an initial guess for the quotient. The
	 guess is guaranteed to be no more than 2 in error, if v[n] >= 128.
	 If we multiply both vectors by the same value, the result of division
	 remains the same, so we can always guarantee that v[n] is
	 sufficiently large.
	 While the algorithm calls for d to be 255 / v[n], we will set d to a
	 simple left shift count because this is fast and nicely approximates that"
	[(v at: n) = 0] whileTrue: [n := n - 1].
	(v at: n) < 128 
	    ifFalse: [d := 0]
	    ifTrue: 
		["Multiply each value by the normalizing value"

		d := LeadingZeros at: (v at: n).
		self bytesLeftShift: u n: d.
		self bytesLeftShift: v n: d].
	vn := v at: n.	"Cache common values"
	vn1 := v at: n - 1.
	m + 1 to: 1
	    by: -1
	    do: 
		[:j | 
		jn := j + n.
		jn1 := jn - 1.

		"2. Calculate the quotient `guess'.
		 Remember that our guess will be generated such that
		 guess - 2 <= quotient <= guess.  Thus, we generate our first
		 guess at quotient, and keep decrementing by one until we have found
		 the real quotient."
		high := (u at: jn) * 256 + (u at: jn1).
		guess := high // vn.
		rem := high \\ vn.
		"(Array with: u with: high with: guess with: rem) printNl."

		"4. We know now that the quotient guess is most likely ok, but possibly
		 the real quotient is guess - 1 or guess - 2.  Multiply the divisor by the
		 guess and compare the result with the dividend."
		sub 
		    replaceFrom: 1
		    to: sub size
		    with: v
		    startingAt: 1.
		self bytes: sub multiply: guess.
		[(self 
		    bytes: u
		    from: j
		    compare: sub) >= 0] 
		    whileFalse: 
			["Our guess was one off, so we need to readjust it by one and subtract
			 back the divisor (since we multiplied by one in excess)."

			guess := guess - 1.
			self 
			    bytes: sub
			    from: 1
			    subtract: v].
		"(Array with: u with: sub with: guess with: rem) printNl."

		"Got another byte of the quotient"
		self 
		    bytes: u
		    from: j
		    subtract: sub.
		q at: j put: guess].
	"Readjust the remainder"
	self bytesRightShift: u n: d.
	^q -> u
    ]
]

