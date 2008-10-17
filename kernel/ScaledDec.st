"======================================================================
|
|   ScaledDecimal Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2003, 2008 Free Software Foundation, Inc.
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



Number subclass: ScaledDecimal [
    | fraction scale |
    
    <category: 'Language-Data types'>
    <comment: 'ScaledDecimal provides a numeric representation of fixed point decimal
numbers able to accurately represent decimal fractions.  It supports
unbounded precision, with no limit to the number of digits before and
after the decimal point.'>

    ScaledDecimal class >> newFromNumber: aNumber scale: scale [
	"Answer a new instance of ScaledDecimal, representing a decimal
	 fraction with a decimal representation considered valid up to the
	 scale-th digit."

	<category: 'instance creation'>
	^(self basicNew)
	    setFraction: aNumber asFraction scale: scale;
	    yourself
    ]

    one [
	"Answer the receiver's representation of one."

	<category: 'constants'>
	^self class newFromNumber: 1 scale: scale
    ]

    zero [
	"Answer the receiver's representation of zero."

	<category: 'constants'>
	^self class newFromNumber: 0 scale: scale
    ]

    fractionPart [
	"Answer the fractional part of the receiver."

	<category: 'coercion'>
	^ScaledDecimal newFromNumber: fraction fractionPart scale: scale
    ]

    integerPart [
	"Answer the fractional part of the receiver."

	<category: 'coercion'>
	^ScaledDecimal newFromNumber: fraction integerPart scale: scale
    ]

    truncated [
	"Answer the receiver, converted to an Integer and truncated towards
	 -infinity."

	<category: 'coercion'>
	^fraction truncated
    ]

    ceiling [
	"Answer the receiver, converted to an Integer and truncated towards
	 +infinity."

	<category: 'coercion'>
	^fraction ceiling
    ]

    asCNumber [
	"Convert the receiver to a kind of number that is understood by
	 the C call-out mechanism."
	<category: 'coercion'>
	^self asFloatD
    ]

    asFloatD [
	"Answer the receiver, converted to a FloatD"

	<category: 'coercion'>
	^fraction asFloatD
    ]

    asFloatE [
	"Answer the receiver, converted to a FloatE"

	<category: 'coercion'>
	^fraction asFloatE
    ]

    asFloatQ [
	"Answer the receiver, converted to a FloatQ"

	<category: 'coercion'>
	^fraction asFloatQ
    ]

    asFraction [
	"Answer the receiver, converted to a Fraction"

	<category: 'coercion'>
	| num denom gcd |
	denom := 10 raisedToInteger: scale.
	num := fraction numerator * denom quo: fraction denominator.
	gcd := num gcd: denom.
	^Fraction numerator: (num divExact: gcd) denominator: (denom divExact: gcd)
    ]

    coerce: aNumber [
	"Answer aNumber, converted to a ScaledDecimal with the same scale
	 as the receiver."

	<category: 'coercion'>
	^ScaledDecimal newFromNumber: aNumber asFraction scale: scale
    ]

    generality [
	"Return the receiver's generality"

	<category: 'coercion'>
	^250
    ]

    + aNumber [
	"Sum two numbers and answer the result."

	<category: 'arithmetic'>
	aNumber generality = self generality 
	    ifTrue: 
		[^ScaledDecimal newFromNumber: fraction + aNumber fraction
		    scale: (scale max: aNumber scale)]
	    ifFalse: [^self retrySumCoercing: aNumber]
    ]

    - aNumber [
	"Subtract aNumber from the receiver and answer the result."

	<category: 'arithmetic'>
	aNumber generality = self generality 
	    ifTrue: 
		[^ScaledDecimal newFromNumber: fraction - aNumber fraction
		    scale: (scale max: aNumber scale)]
	    ifFalse: [^self retryDifferenceCoercing: aNumber]
    ]

    * aNumber [
	"Multiply two numbers and answer the result."

	<category: 'arithmetic'>
	aNumber generality = self generality 
	    ifTrue: 
		[^ScaledDecimal newFromNumber: fraction * aNumber fraction
		    scale: (scale max: aNumber scale)]
	    ifFalse: [^self retryMultiplicationCoercing: aNumber]
    ]

    / aNumber [
	"Divide two numbers and answer the result."

	<category: 'arithmetic'>
	aNumber generality = self generality 
	    ifTrue: 
		[^ScaledDecimal newFromNumber: fraction / aNumber fraction
		    scale: (scale max: aNumber scale)]
	    ifFalse: [^self retryDivisionCoercing: aNumber]
    ]

    \\ aNumber [
	"Answer the remainder after integer division the receiver by aNumber
	 with truncation towards negative infinity."

	<category: 'arithmetic'>
	aNumber generality = self generality 
	    ifTrue: 
		[^ScaledDecimal newFromNumber: fraction \\ aNumber fraction
		    scale: (scale max: aNumber scale)]
	    ifFalse: [^self retry: #\\ coercing: aNumber]
    ]

    // aNumber [
	"Answer the integer quotient after dividing the receiver by aNumber
	 with truncation towards negative infinity."

	<category: 'arithmetic'>
	^fraction // aNumber
    ]

    < aNumber [
	"Answer whether the receiver is less than arg."

	<category: 'comparing'>
	aNumber generality = self generality 
	    ifTrue: [^(self compare: aNumber) < 0]
	    ifFalse: [^self retryRelationalOp: #< coercing: aNumber]
    ]

    <= aNumber [
	"Answer whether the receiver is less than or equal to arg."

	<category: 'comparing'>
	aNumber generality = self generality 
	    ifTrue: [^(self compare: aNumber) <= 0]
	    ifFalse: [^self retryRelationalOp: #<= coercing: aNumber]
    ]

    > aNumber [
	"Answer whether the receiver is greater than arg."

	<category: 'comparing'>
	aNumber generality = self generality 
	    ifTrue: [^(self compare: aNumber) > 0]
	    ifFalse: [^self retryRelationalOp: #> coercing: aNumber]
    ]

    >= aNumber [
	"Answer whether the receiver is greater than or equal to arg."

	<category: 'comparing'>
	aNumber generality = self generality 
	    ifTrue: [^(self compare: aNumber) >= 0]
	    ifFalse: [^self retryRelationalOp: #>= coercing: aNumber]
    ]

    = arg [
	"Answer whether the receiver is equal to arg."

	<category: 'comparing'>
	(arg isKindOf: Number) ifFalse: [^false].
	arg generality = self generality 
	    ifTrue: [^(self compare: arg) = 0]
	    ifFalse: [^self retryEqualityCoercing: arg]
    ]

    ~= arg [
	"Answer whether the receiver is not equal arg."

	<category: 'comparing'>
	(arg isKindOf: Number) ifFalse: [^true].
	arg generality = self generality 
	    ifTrue: [^(self compare: arg) ~= 0]
	    ifFalse: [^self retryInequalityCoercing: arg]
    ]

    hash [
	"Answer an hash value for the receiver."

	<category: 'comparing'>
	^fraction hash
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream, intended to
	 be directed to a user.  In this particular case, the `scale'
	 part of the #printString is not emitted."

	<category: 'printing'>
	| aFraction fracDigits |
	self < 0 ifTrue: [aStream nextPut: $-].
	aFraction := fraction abs.
	aStream nextPutAll: aFraction truncated printString.
	scale = 0 ifTrue: [^self].
	aStream nextPut: $..
	fracDigits := aFraction fractionPart.
	scale timesRepeat: 
		[fracDigits := fracDigits * 10.
		aStream nextPut: (Character digitValue: fracDigits truncated).
		fracDigits := fracDigits fractionPart]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	self displayOn: aStream.
	aStream nextPut: $s.
	scale printOn: aStream
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
	"Print Smalltalk code that compiles to the receiver on aStream."

	<category: 'storing'>
	self printOn: aStream
    ]

    fraction [
	"Private - Answer to full precision the fraction that the receiver
	 represents."

	<category: 'private'>
	^fraction
    ]

    compare: arg [
	"Private - Answer a Number that is the receiver - arg,
	 truncated to a number of digits equal to the minimum of our
	 scale and aScaledDecimal's."

	<category: 'private'>
	^((fraction - arg fraction) 
	    * (10 raisedToInteger: (self scale min: arg scale))) rounded
    ]

    scale [
	"Private - Answer a integer which represents the total number of digits
	 used to represent the fraction part of the receiver, including trailing
	 zeroes."

	<category: 'private'>
	^scale
    ]

    setFraction: theFraction scale: theScale [
	"Private - Set the fraction to theFraction and the total number of digits
	 used to represent the fraction part of the receiver, including trailing
	 zeroes, to the Integer theScale."

	<category: 'private'>
	fraction := theFraction.
	scale := theScale
    ]
]
