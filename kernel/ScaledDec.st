"======================================================================
|
|   ScaledDecimal Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
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


Number subclass:  #ScaledDecimal
	instanceVariableNames: 'fraction scale '
	classVariableNames: 'Zero One'
	poolDictionaries: ''
	category: 'Language-Data types'!

ScaledDecimal comment: 
'ScaledDecimal provides a numeric representation of fixed point decimal
numbers able to accurately represent decimal fractions.  It supports
unbounded precision, with no limit to the number of digits before and
after the decimal point.'!

!ScaledDecimal class methodsFor: 'instance creation'!

newFromNumber: aNumber scale: scale
    "Answer a new instance of ScaledDecimal, representing a decimal
     fraction with a decimal representation considered valid up to the
     scale-th digit."
    ^(self basicNew)
	setFraction: aNumber asFraction scale: scale;
	yourself! !

!ScaledDecimal class methodsFor: 'constants'!

initialize
    "Initialize the receiver's class variables"

    "We cannot create ScaledDecimal with 1.0s0 during the very
     first phases of bootstrapping, because the lexer calls in to
     #asScaledDecimal: -- but it is not a problem."
    One := self newFromNumber: 1 scale: 0.
    Zero := self newFromNumber: 0 scale: 0! !

!ScaledDecimal methodsFor: 'constants'!

one
    "Answer the receiver's representation of one."
    ^One!

zero
    "Answer the receiver's representation of zero."
    ^Zero! !

!ScaledDecimal methodsFor: 'coercion'!

fractionPart
    "Answer the fractional part of the receiver."
    ^ScaledDecimal newFromNumber: fraction fractionPart scale: scale!

integerPart
    "Answer the fractional part of the receiver."
    ^ScaledDecimal newFromNumber: fraction integerPart scale: scale!

truncated
    "Answer the receiver, converted to an Integer and truncated towards
     -infinity."
    ^fraction truncated!

ceiling
    "Answer the receiver, converted to an Integer and truncated towards
     +infinity."
    ^fraction ceiling!

asFloatD
    "Answer the receiver, converted to a FloatD"
    ^fraction asFloatD!

asFloatE
    "Answer the receiver, converted to a FloatE"
    ^fraction asFloatE!

asFloatQ
    "Answer the receiver, converted to a FloatQ"
    ^fraction asFloatQ!

asFraction
    "Answer the receiver, converted to a Fraction"
    | num denom gcd |
    denom := 10 raisedToInteger: scale.
    num := fraction numerator * denom quo: fraction denominator.
    gcd := num gcd: denom.
    ^Fraction
	numerator: (num divExact: gcd)
	denominator: (denom divExact: gcd)!

coerce: aNumber
    "Answer aNumber, converted to a ScaledDecimal with the same scale
     as the receiver."
    ^ScaledDecimal
	newFromNumber: aNumber asFraction
	scale: scale
!

generality
    "Return the receiver's generality"
    ^250
! !

!ScaledDecimal methodsFor: 'arithmetic'!

+ aNumber 
    "Sum two numbers and answer the result."

    (aNumber generality = self generality)
	ifTrue: [^ScaledDecimal
	    newFromNumber: fraction + aNumber fraction
	    scale: (scale max: aNumber scale) ]
	ifFalse: [^self retrySumCoercing: aNumber]!

- aNumber 
     "Subtract aNumber from the receiver and answer the result."

    (aNumber generality = self generality)
	ifTrue: [^ScaledDecimal
	    newFromNumber: fraction - aNumber fraction
	    scale: (scale max: aNumber scale) ]
	ifFalse: [^self retryDifferenceCoercing: aNumber]!

* aNumber 
     "Multiply two numbers and answer the result."

    (aNumber generality = self generality)
	ifTrue: [^ScaledDecimal
	    newFromNumber: fraction * aNumber fraction
	    scale: (scale max: aNumber scale) ]
	ifFalse: [^self retryMultiplicationCoercing: aNumber]!


/ aNumber 
     "Divide two numbers and answer the result."

    (aNumber generality = self generality)
	ifTrue: [^ScaledDecimal
	    newFromNumber: fraction / aNumber fraction
	    scale: (scale max: aNumber scale) ]
	ifFalse: [^self retryDivisionCoercing: aNumber]!

\\ aNumber 
    "Answer the remainder after integer division the receiver by aNumber 
    with truncation towards negative infinity."

    (aNumber generality = self generality)
	ifTrue: [^ScaledDecimal
	    newFromNumber: fraction \\ aNumber fraction
	    scale: (scale max: aNumber scale) ]
	ifFalse: [^self retry: #\\ coercing: aNumber]!

// aNumber 
    "Answer the integer quotient after dividing the receiver by aNumber 
    with truncation towards negative infinity."
    ^fraction // aNumber! !

!ScaledDecimal methodsFor: 'comparing'!

< aNumber 
     "Answer whether the receiver is less than arg."

    (aNumber generality = self generality)
	ifTrue: [^(self compare: aNumber) < 0 ]
	ifFalse: [^self retryRelationalOp: #< coercing: aNumber]!

<= aNumber 
     "Answer whether the receiver is less than or equal to arg."

    (aNumber generality = self generality)
	ifTrue: [^(self compare: aNumber) <= 0 ]
	ifFalse: [^self retryRelationalOp: #<= coercing: aNumber]!

> aNumber 
     "Answer whether the receiver is greater than arg."

    (aNumber generality = self generality)
	ifTrue: [^(self compare: aNumber) > 0 ]
	ifFalse: [^self retryRelationalOp: #> coercing: aNumber]!

>= aNumber 
     "Answer whether the receiver is greater than or equal to arg."

    (aNumber generality = self generality)
	ifTrue: [^(self compare: aNumber) >= 0 ]
	ifFalse: [^self retryRelationalOp: #>= coercing: aNumber]!

= arg 
     "Answer whether the receiver is equal to arg."

    (arg isKindOf: Number) ifFalse: [^false].

    (arg generality = self generality)
	ifTrue: [^(self compare: arg) = 0 ]
	ifFalse: [^self retryEqualityCoercing: arg]!

~= arg 
     "Answer whether the receiver is not equal arg."

    (arg isKindOf: Number) ifFalse: [^true].

    (arg generality = self generality)
	ifTrue: [^(self compare: arg) ~= 0 ]
	ifFalse: [^self retryInequalityCoercing: arg]!

hash
    "Answer an hash value for the receiver."

    ^fraction hash! !

!ScaledDecimal methodsFor: 'printing'!

displayOn: aStream
    "Print a representation of the receiver on aStream, intended to
     be directed to a user.  In this particular case, the `scale'
     part of the #printString is not emitted."
    | aFraction fracDigits |
    self < 0 ifTrue: [aStream nextPut: $-].
    aFraction := fraction abs.
    aStream nextPutAll: aFraction truncated printString.
    scale = 0 ifTrue: [^self].
    aStream nextPut: $. .
    fracDigits := aFraction fractionPart.
    scale timesRepeat: [
	fracDigits := fracDigits * 10.
	aStream nextPut: (Character digitValue: fracDigits truncated).
	fracDigits := fracDigits fractionPart
    ]!

printOn: aStream 
    "Print a representation of the receiver on aStream."
    self displayOn: aStream.
    aStream nextPut: $s.
    scale printOn: aStream! !

!ScaledDecimal methodsFor: 'storing'!

storeOn: aStream 
    "Print Smalltalk code that compiles to the receiver on aStream."
    self printOn: aStream! !

!ScaledDecimal methodsFor: 'private'!

fraction
    "Private - Answer to full precision the fraction that the receiver
     represents."
    ^fraction
!

compare: arg
    "Private - Answer a Number that is the receiver - arg,
     truncated to a number of digits equal to the minimum of our
     scale and aScaledDecimal's."
    ^((fraction - arg fraction) *
          (10 raisedToInteger: (self scale min: arg scale))) rounded!

scale
    "Private - Answer a integer which represents the total number of digits 
    used to represent the fraction part of the receiver, including trailing 
    zeroes."
    ^scale!

setFraction: theFraction scale: theScale
    "Private - Set the fraction to theFraction and the total number of digits 
    used to represent the fraction part of the receiver, including trailing 
    zeroes, to the Integer theScale."
    fraction := theFraction.
    scale := theScale! !

ScaledDecimal initialize!
