"======================================================================
|
|   Class Fraction Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002
| Free Software Foundation, Inc.
| Written by David Duke.
| Slightly modified by Steve Byrne and Paolo Bonzini.
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


Number subclass: #Fraction
	instanceVariableNames: 'numerator denominator'
	classVariableNames: 'Zero One'
	poolDictionaries: ''
	category: 'Language-Data types'!

Fraction comment:
' I represent rational numbers in the form (p/q) where p and q are integers.
The arithmetic operations  *, +, -, /,  on fractions, all return a reduced 
fraction.'!



!Fraction class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber converted to a Fraction"
    ^aNumber asFraction
! !


!Fraction class methodsFor: 'instance creation'!

initialize
    "Initialize the receiver's class variables"
    Zero := self numerator: 0 denominator: 1.
    One := self numerator: 1 denominator: 1.
!

numerator: nInteger denominator: dInteger 
    " Answer a new instance of fraction (nInteger/dInteger)"
 
    ^self new setNumerator: nInteger setDenominator: dInteger 
! !


!Fraction methodsFor: 'accessing'!

denominator
    "Answer the receiver's denominator"
    ^denominator!

numerator
    "Answer the receiver's numerator"
    ^numerator 

! !



!Fraction methodsFor: 'arithmetic'!

* aNumber 
    "Multiply two numbers and answer the result."

    | num den gcd |
    (aNumber generality = self generality)
	ifFalse: [^self retryMultiplicationCoercing: aNumber].

    num := numerator * aNumber numerator.
    den := denominator * aNumber denominator.

    aNumber == self ifFalse: [
	gcd := (numerator gcd: aNumber denominator) * 
	       (denominator gcd: aNumber numerator).

	num := num quo: gcd.
	den := den quo: gcd
    ].

    den = 1 ifTrue: [ ^num ].
    ^Fraction numerator: num denominator: den
!

+ aNumber 
    "Sum two numbers and answer the result."
    | gcd num den |
    (aNumber generality = self generality)
	ifFalse: [^self retrySumCoercing: aNumber].

    gcd := denominator gcd: aNumber denominator.
    gcd == 1 ifTrue: [
	^Fraction
	    numerator: (numerator * aNumber denominator) +
		       (aNumber numerator * denominator) 
	    denominator: denominator * aNumber denominator ].

    num := (numerator * (aNumber denominator quo: gcd)) +
	   (aNumber numerator * (denominator quo: gcd)).
    den := denominator * aNumber denominator quo: gcd.

    "Compute a GCD on smaller operands"
    gcd := gcd gcd: num.

    num := num quo: gcd.
    den := den quo: gcd.
    den = 1 ifTrue: [ ^num ].
    ^Fraction numerator: num denominator: den
!

- aNumber
     "Subtract aNumber from the receiver and answer the result."

    | gcd num den |
    (aNumber generality = self generality)
	 ifFalse: [^self retryDifferenceCoercing: aNumber].

    gcd := denominator gcd: aNumber denominator.
    gcd == 1 ifTrue: [
	^Fraction
	    numerator: (numerator * aNumber denominator) -
		       (aNumber numerator * denominator) 
	    denominator: denominator * aNumber denominator ].

    num := (numerator * (aNumber denominator quo: gcd)) -
	   (aNumber numerator * (denominator quo: gcd)).
    den := denominator * aNumber denominator quo: gcd.

    "Compute a GCD on smaller operands"
    gcd := gcd gcd: num.

    num := num quo: gcd.
    den := den quo: gcd.
    den = 1 ifTrue: [ ^num ].
    ^Fraction numerator: num denominator: den
!

/ aNumber 
    "Divide the receiver by aNumber and answer the result."

    | num den gcd |
    (aNumber generality = self generality)
	ifFalse: [^self retryDivisionCoercing: aNumber].

    num := numerator * aNumber denominator.
    den := denominator * aNumber numerator.
    gcd := (numerator gcd: aNumber numerator) * 
	(denominator gcd: aNumber denominator).

    num := num quo: gcd.
    den := den quo: gcd.
    den = 1 ifTrue: [ ^num ].
    ^Fraction numerator: num denominator: den
!

// aNumber
     "Return the integer quotient of dividing the receiver by aNumber with
      truncation towards negative infinity."
     ^(self / aNumber) floor 
!

\\ aNumber
    "Return the remainder from dividing the receiver by aNumber, (using //)."
    ^self - (self // aNumber * aNumber)
!

estimatedLog
    "Answer an estimate of (self abs floorLog: 10)"
    ^numerator estimatedLog - denominator estimatedLog
!


!Fraction methodsFor: 'coercing'!

zero
    "Coerce 0 to the receiver's class"
    ^Zero
!

unity
    "Coerce 1 to the receiver's class"
    ^One
!

coerce: aNumber 
    "Coerce aNumber to the receiver's class"
    ^aNumber asFraction
!

generality
    "Return the receiver's generality"
    ^300
!

floor
    "Truncate the receiver towards negative infinity
     and return the truncated result"
    ^numerator // denominator
!

ceiling
    "Truncate the receiver towards positive infinity
     and return the truncated result"
    ^(numerator + denominator - 1) // denominator
!

truncated
    "Truncate the receiver and return the truncated result"
    ^numerator quo: denominator
! !



!Fraction methodsFor: 'comparing'!

< arg 
    "Test if the receiver is less than arg."

    (arg generality = self generality)
	ifFalse: [^self retryRelationalOp: #< coercing: arg].

    ^(self compare: arg) < 0
!

<= arg 
    "Test if the receiver is less than or equal to arg."

    (arg generality = self generality)
	ifFalse: [^self retryRelationalOp: #<= coercing: arg].

    ^(self compare: arg) <= 0
!

> arg 
    "Test if the receiver is more than arg."

    (arg generality = self generality)
	ifFalse: [^self retryRelationalOp: #> coercing: arg].

    ^(self compare: arg) > 0
!

>= arg 
    "Test if the receiver is greater than or equal to arg."

    (arg generality = self generality)
	ifFalse: [^self retryRelationalOp: #>= coercing: arg].

    ^(self compare: arg) >= 0
!

= arg 
    "Test if the receiver equals arg."

    (arg isKindOf: Number)
	ifFalse: [^false].

    (arg generality = self generality)
	ifFalse: [^self retryEqualityCoercing: arg].

    ^self numerator = arg numerator and: [
	self denominator = arg denominator ].
!

hash
    "Answer an hash value for the receiver"
    denominator = 1 ifTrue: [ ^numerator hash ].
    ^(numerator asFloatD / denominator asFloatD) hash
! !


!Fraction methodsFor: 'private - comparing'!

compare: arg
    "Answer an integer <, >, = 0 depending on the ordering
     between the receiver and arg."

    | n1 n2 delta |

    "Comparing numbers with different signs, we just care about that;
     canonical form further restricts the check to the numerator."
    self numerator sign = arg numerator sign
	ifFalse: [ ^numerator sign - arg numerator sign ].

    n1 := numerator abs.
    n2 := arg numerator abs.

    "The first line is (n1 * d2) highBit +/- 1, and similarly for the second."
    delta := numerator abs highBit + arg denominator highBit -
             arg numerator abs highBit - denominator highBit.

    delta < -1 ifTrue: [ ^delta * numerator sign ].
    delta >  1 ifTrue: [ ^delta * numerator sign ].

    "Cross multiply and compare.  Sending #* to the denominators is
     faster because they cannot be LargeNegativeIntegers."
    ^((arg denominator * numerator) - (denominator * arg numerator)) sign
! !


!Fraction methodsFor: 'testing'!

isRational
    "Answer whether the receiver is rational - true"
    ^true
! !



!Fraction methodsFor: 'converting'!

integerPart
    "Answer the integer part of the receiver, expressed as a Fraction"
    ^Fraction numerator: self truncated denominator: 1
!

asFloatD
    "Answer the receiver converted to a FloatD"
    ^self asFloat: FloatD
!

asFloatE
    "Answer the receiver converted to a FloatD"
    ^self asFloat: FloatE
!

asFloatQ
    "Answer the receiver converted to a FloatD"
    ^self asFloat: FloatQ
!

asFraction
    "Answer the receiver, it is already a Fraction"
    ^self 
! !



!Fraction methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"

    aStream
	print: numerator;
	nextPut: $/;
	print: denominator
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPutAll: '(Fraction numerator: ';
	store: numerator;
	nextPutAll: ' denominator: ';
	store: numerator ;
	nextPut: $)
! !



!Fraction methodsFor: 'private'!

asFloat: characterization
    "Answer the receiver converted to a Float"
    | n d shift sign |
    n := numerator.
    d := denominator.
    sign := n sign * d sign.

    "Avoid answering NaNs and infinite values.
     1e1800 asFloat / (1e1799 + 1) asFloat = NaN, but
     (1e1800 / (1e1799 + 1)) asFloat must be 10."

    shift := (characterization emax - numerator highBit).
    shift := shift min: (characterization emax - denominator highBit).
    shift < 0 ifTrue: [
	"Lose some more precision, but we MUST avoid infinites and NaNs!"
	shift := shift - 10. n := n bitShift: shift. d := d bitShift: shift ].

    d = 0 ifTrue: [
	^sign > 0
	    ifTrue: [ characterization infinity ]
	    ifFalse: [ characterization negativeInfinity ] ].
    n = 0 ifTrue: [
	^sign > 0
	    ifTrue: [ characterization coerce: 0 ]
	    ifFalse: [ characterization negativeInfinity reciprocal ] ].

    ^(characterization coerce: n)
	 / (characterization coerce: d)
!

reduce
    "Reduce the fraction."
    | gcd |
    numerator = 1 ifTrue: [ ^self ].
    denominator = 1 ifTrue: [ ^numerator ].
    numerator = 0 ifTrue: [^0].
    numerator = denominator ifTrue: [^1].

    gcd := numerator gcd: denominator.
    gcd = 1 ifTrue: [^self].
    denominator = gcd ifTrue: [^numerator quo: gcd].
    numerator := numerator quo: gcd.
    denominator := denominator quo: gcd.
    ^self
!

setNumerator: numInteger setDenominator: denInteger 
    "Set the fraction's numerator and denominator"
    denInteger = 0
	ifTrue: [ ^numInteger zeroDivide ].
    denInteger < 0
	ifTrue: [numerator := numInteger negated.
		 denominator := denInteger negated ]
	ifFalse: [numerator := numInteger.
		  denominator := denInteger]
! !


!Fraction methodsFor: 'optimized cases'!

negated
    "Return the receiver, with its sign changed."
    ^Fraction
	numerator: 0 - numerator
	denominator: denominator
!

raisedToInteger: anInteger 
    "Return self raised to the anInteger-th power."
    "No need to reduce"
    anInteger < 0 ifTrue: [ ^self reciprocal raisedToInteger: 0 - anInteger ].

    ^Fraction
	numerator: (numerator raisedToInteger: anInteger)
	denominator: (denominator raisedToInteger: anInteger)
!

reciprocal
    "Return the reciprocal of the receiver"
    denominator < 0
	ifTrue: [^Fraction numerator: denominator negated 
			   denominator: numerator negated ]
	ifFalse: [^Fraction numerator: denominator denominator: numerator]

!

squared
    "Return the square of the receiver."
    ^Fraction
	numerator: numerator squared
	denominator: denominator squared
! !
