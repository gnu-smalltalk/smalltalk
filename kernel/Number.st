"======================================================================
|
|   Number Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Magnitude subclass: #Number
	  instanceVariableNames: ''
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

Number comment: 
'I am an abstract class that provides operations on numbers, both floating
point and integer.  I provide some generic predicates, and supply the 
implicit type coercing code for binary operations.' !


!Number class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber - whatever class it belongs to, it is good"
    ^aNumber
!

readFrom: aStream
    "Answer the number read from the rest of aStream, converted to an
     instance of the receiver. If the receiver is number, the class of the
     result is undefined -- but the result is good."
    | value ch scale |
    value := 0.
    scale := (aStream peekFor: $-) ifTrue: [ -1 ] ifFalse: [ 1 ].

    [ aStream atEnd ifTrue: [^self coerce: value].
      (ch := aStream next) isDigit ] whileTrue: [
	 value := ch digitValue * scale + (value * 10).
    ].
    ch = $. ifFalse: [aStream skip: -1. ^value].

    [ aStream atEnd ifTrue: [^self coerce: value].
      (ch := aStream next) isDigit ] whileTrue: [
	 scale := scale / 10.
	 value := ch digitValue * scale + value.
    ].

    aStream skip: -1.
    ^self coerce: value
! !


!Number class methodsFor: 'testing'!

isImmediate
    "Answer whether, if x is an instance of the receiver, x copy == x"
    ^true
! !


!Number methodsFor: 'copying'!

shallowCopy
    "Return the receiver - it's an immediate (immutable) object"
    ^self
!

deepCopy
    "Return the receiver - it's an immediate (immutable) object"
    ^self
! !


!Number methodsFor: 'converting'!

degreesToRadians
    "Convert the receiver to radians"
    ^self asFloatD / 57.295779513082320876846364344191
!

radiansToDegrees
    "Convert the receiver from radians to degrees"
    ^self asFloatD * 57.295779513082320876846364344191
!

coerce: aNumber
    "Answer aNumber - whatever class it belongs to, it is good"
    ^aNumber
!

zero
    "Coerce 0 to the receiver's class. The default implementation works,
     but is inefficient"
    ^self coerce: 0
!

unity
    "Coerce 1 to the receiver's class. The default implementation works,
     but is inefficient"
    ^self coerce: 1
!

generality
    "Answer the receiver's generality"
    self subclassResponsibility
!

asScaledDecimal: n
    "Answer the receiver, converted to a ScaledDecimal object."
    ^ScaledDecimal
	newFromNumber: self asFraction
	scale: n
!

asScaledDecimal: denDigits scale: n
    "Answer the receiver, divided by 10^denDigits and converted to
     a ScaledDecimal object."
    ^ScaledDecimal
	newFromNumber: (self asFraction *
	  (10 raisedToInteger: denDigits))
	scale: n
!

asFloat
    "Convert the receiver to an arbitrary subclass of Float"
    ^self asFloatD
!

asFloatD
    self subclassResponsibility
!

asFloatE
    self subclassResponsibility
!

asFloatQ
    self subclassResponsibility
! !


!Number methodsFor: 'retrying'!

retryError
    "Raise an error---a retrying method was called with two arguments
     having the same generality."
    ^self error: 'retry:coercing: called with arguments of the same generality' 
!

retry: aSymbol coercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling aSymbol.  aSymbol is
     supposed not to be #= or #~= (since those don't fail if aNumber is not
     a Number)."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    selfGen > aNumGen
    	ifTrue: [ ^self perform: aSymbol with: (self coerce: aNumber) ].
    selfGen < aNumGen
    	ifTrue: [ ^(aNumber coerce: self) perform: aSymbol with: aNumber ].

    self retryError
!

retryRelationalOp: aSymbol coercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling aSymbol (<, <=, >, >=)."

    | delta |
    delta := self retryDifferenceCoercing: aNumber.

    "Avoids a #perform: which is usually more expensive -- all the comparisons
     below are inlined by both the compiler and the interpreter"

    aSymbol == #< ifTrue: [ ^delta < delta zero ].
    aSymbol == #<= ifTrue: [ ^delta <= delta zero ].
    aSymbol == #>= ifTrue: [ ^delta >= delta zero ].
    aSymbol == #> ifTrue: [ ^delta > delta zero ].
    self error: 'bad relational operator'
!

retryEqualityCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #=."

    | selfGen aNumGen |
    (aNumber isKindOf: Number) ifFalse: [ ^false ].

    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^false ].

    selfGen > aNumGen ifTrue: [ ^self = (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) = aNumber ].

    self retryError
!

retryInequalityCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #~=."

    | selfGen aNumGen |
    (aNumber isKindOf: Number) ifFalse: [ ^true ].

    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^true ].

    selfGen > aNumGen ifTrue: [ ^false == (self = (self coerce: aNumber)) ].
    selfGen < aNumGen ifTrue: [ ^false == ((aNumber coerce: self) ~= aNumber) ].

    self retryError
!

retrySumCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #+."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber sumFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self + (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) + aNumber ].

    self retryError
!

retryDifferenceCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #-."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber differenceFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self - (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) - aNumber ].

    self retryError
!

retryMultiplicationCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #*."


    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber productFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self * (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) * aNumber ].

    self retryError
!

retryDivisionCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #/."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.

    selfGen > aNumGen ifTrue: [ ^self / (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) / aNumber ].

    self retryError
! !



!Number methodsFor: 'arithmetic'!

+ aNumber
    "Sum the receiver and aNumber, answer the result"
    self subclassResponsibility
!

- aNumber
    "Subtract aNumber from the receiver, answer the result"
    self subclassResponsibility
!

* aNumber
    "Subtract the receiver and aNumber, answer the result"
    self subclassResponsibility
!

/ aNumber
    "Divide the receiver by aNumber, answer the result (no loss of
     precision).  Raise a ZeroDivide exception or return a valid
     (possibly infinite) continuation value if aNumber is zero."
    self subclassResponsibility
!

// aNumber
    "Return the integer quotient of dividing the receiver by aNumber with
    truncation towards negative infinity.  Raise a ZeroDivide
    exception if aNumber is zero"

    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^(self / aNumber) floor
!

\\ aNumber
    "Return the remainder of dividing the receiver by aNumber with
    truncation towards negative infinity.  Raise a ZeroDivide
    exception if aNumber is zero"

    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^self negative == aNumber negative
	ifTrue: [ self rem: aNumber ]
	ifFalse: [ (self rem: aNumber) + aNumber ]
!

quo: aNumber
    "Return the integer quotient of dividing the receiver by aNumber with
    truncation towards zero.  Raise a ZeroDivide exception if aNumber is
    zero"
    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^(self / aNumber) truncated
!

rem: aNumber
    "Return the remainder of dividing the receiver by aNumber with
    truncation towards zero.  Raise a ZeroDivide exception if aNumber is
    zero"

    ^self - ((self quo: aNumber) * aNumber)
! !



!Number methodsFor: 'truncation and round off'!

integerPart
    "Answer the receiver, truncated towards zero"
    ^self truncated
!

fractionPart
    "Answer a number which, summed to the #integerPart of the
     receiver, gives the receiver itself."
    ^self - self integerPart
!

asInteger
    "Answer the receiver, rounded to the nearest integer"
    ^self rounded
!

truncated
    "Answer the receiver, truncated towards zero"
    ^self subclassResponsibility
!

truncateTo: aNumber
    "Answer the receiver, truncated towards zero to a multiple
     of aNumber"
    ^(self / aNumber) integerPart * aNumber
!

rounded
    "Returns the integer nearest the receiver"
    ^self negative
	ifTrue: [ (self - 0.5) ceiling ]
	ifFalse: [ (self + 0.5) floor ]
!

roundTo: aNumber
    "Answer the receiver, truncated to the nearest multiple
     of aNumber"
    ^(self + (aNumber / 2) / aNumber) integerPart * aNumber
! !



!Number methodsFor: 'testing'!

closeTo: num
    "Answer whether the receiver can be considered sufficiently
     close to num (this is done by checking equality if num is
     not a number, and by checking with 0.01% tolerance if num
     is a number)."
    num isNumber ifFalse: [ ^self = num ].
    self = self zero ifTrue: [ ^num abs < 0.0001 ].
    num = num zero ifTrue: [ ^self abs < 0.0001 ].
    ^(self - num) abs / 0.0001 <= (self abs max: num abs)
!

isNaN
    "Answer whether the receiver is a Not-A-Number.  Most numeric
     classes don't handle nans, so the default is to answer false
     rather than calling #subclassResponsibility."
    ^false
!

isFinite
    "Answer whether the receiver represents a finite quantity.  Most
     numeric classes are for finite quantities, so the default is to
     answer true rather than calling #subclassResponsibility."
    ^true
!

isInfinite
    "Answer whether the receiver represents an infinite quantity.  Most
     numeric classes are for finite quantities, so the default is to
     answer false rather than calling #subclassResponsibility."
    ^false
!

isRational
    "Answer whether the receiver is rational - false by default"
    ^false
!

isNumber
    ^true
!

negative
    "Answer whether the receiver is < 0"
    ^self < self zero
!

positive
    "Answer whether the receiver is >= 0"
    ^self >= self zero
!

strictlyPositive
    "Answer whether the receiver is > 0"
    ^self > self zero
!

sign
    "Returns the sign of the receiver."
    self < self zero ifTrue: [ ^-1 ].
    self > self zero ifTrue: [ ^1 ].
    ^0
!

even
    "Returns true if self is divisible by 2"
    ^self truncated even
!

odd
    "Returns true if self is not divisible by 2"
    ^self truncated odd
! !



!Number methodsFor: 'comparing'!

min: aNumber
    "Redefined to ensure that a NaN is never answered.  Answer
     the minimum between the receiver and aNumber."
    self isNaN ifTrue: [ ^aNumber ].

    "< will return false if aNumber is a NaN, then self will
     be answered"
    ^aNumber < self ifTrue: [ aNumber ] ifFalse: [ self ]!

max: aNumber
    "Redefined to ensure that a NaN is never answered.  Answer
     the maximum between the receiver and aNumber."
    self isNaN ifTrue: [ ^aNumber ].

    "> will return false if aNumber is a NaN, then self will
     be answered"
    ^aNumber > self ifTrue: [ aNumber ] ifFalse: [ self ]! !



!Number methodsFor: 'misc math'!

positiveDifference: aNumber
    "Answer the positive difference of the receiver and
     aNumber, that is self - aNumber if it is positive,
     0 otherwise."
    | diff |
    diff := self - aNumber.
    diff isNaN ifTrue: [ ^diff ].
    ^diff negative ifTrue: [ diff zero ] ifFalse: [ diff ]
!

squared
    "Answer the square of the receiver"
    ^self * self
!

abs
    "Answer the absolute value of the receiver"
    ^self > self zero
	ifTrue: [ self ]
	ifFalse: [ self negated ]
!

negated
    "Answer the negated of the receiver"
    ^self zero - self
!

sin
    "return the sine of the receiver"
    ^self asFloatD sin
!

cos
    "return the cosine of the receiver"
    ^self asFloatD cos
!

tan
    "return the tangent of the receiver"
    ^self asFloatD tan
!

arcSin
    "return the arc sine of the receiver"
    ^self asFloatD arcSin
!

arcCos
    "return the arc cosine of the receiver"
    ^self asFloatD arcCos
!

arcTan
    "return the arc tangent of the receiver"
    ^self asFloatD arcTan
!

sqrt
    "return the square root of the receiver"
    ^self asFloatD sqrt
!

exp
    "return e raised to the receiver"
    ^self asFloatD exp
!

ln
    "return log base e of the receiver"
    ^self asFloatD ln
!

estimatedLog
    "Answer an estimate of (self abs floorLog: 10). This method
     should be overridden by subclasses, but Number's implementation
     does not raise errors - simply, it gives a correct result, so
     it is slow."
    ^self abs floorLog: 10
!

log
    "return log base aNumber of the receiver"
    ^self asFloatD ln / FloatD ln10
!

log: aNumber
    "return log base aNumber of the receiver"
    ^self asFloatD ln / aNumber asFloatD ln
!

floorLog: radix
    "return (self log: radix) floor. Optimized to answer an integer."

    | me answer |

    self < self zero ifTrue: [
       ^self arithmeticError: 'cannot extract logarithm of a negative number'
    ].
    radix <= radix unity ifTrue: [
	(radix <= radix zero) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	(radix = radix unity) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	^(self floorLog: radix reciprocal) negated
    ].

    me := self.
    self < self unity
	ifTrue: [
	    answer := -1.
	    [   me := me * radix. me < me unity ] whileTrue: [
		answer := answer - 1
	    ]
	]
	ifFalse: [
	    answer := 0.
	    [   me > radix ] whileTrue: [
		me := me / radix.
		answer := answer + 1
	    ]
	].

   ^answer
!

raisedTo: aNumber
    "Return self raised to aNumber power"

    ^aNumber isInteger
        ifTrue: [ self raisedToInteger: aNumber ]
        ifFalse: [ self asFloatD raisedTo: aNumber asFloatD ]
!

raisedToInteger: anInteger
    "Return self raised to the anInteger-th power"
    | result y n |

    "Some special cases first"
    anInteger isInteger ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer ].
    anInteger < 0 ifTrue: [ ^self reciprocal raisedToInteger: 0 - anInteger ].
    anInteger = 0 ifTrue: [ ^self unity ].
    anInteger = 1 ifTrue: [ ^self ].

    result := self unity.
    y := self.
    n := anInteger.
    [   (n bitAnd: 1) == 1 ifTrue: [ result := result * y ].
	n := n bitShift: -1. n > 0
    ]   whileTrue: [ y := y * y ].

    ^result
!

withSignOf: aNumber
    "Answer the receiver, with its sign possibly changed to match
     that of aNumber."
    ^aNumber positive == self positive
	ifTrue: [ self ]
	ifFalse: [ self negated ]
! !



!Number methodsFor: 'truncation and round off'!

floor
    "Return the integer nearest the receiver toward negative infinity."

    | selfTruncated |
    selfTruncated := self truncated.
    "If positive, truncation to zero is what we want."
    self >= self zero ifTrue: [^selfTruncated].

    "Must be negative."
    self = (self coerce: selfTruncated)
	ifTrue: [^selfTruncated]
	ifFalse: [^selfTruncated - 1]
! !


!Number methodsFor: 'arithmetic'!

reciprocal
    "Return the reciprocal of the receiver"
    self = self zero
	ifTrue: [self zeroDivide]
	ifFalse: [^self unity / self]
! !



!Number methodsFor: 'shortcuts and iterators'!

to: stop
    "Return an interval going from the receiver to stop by 1"
    ^Interval from: self to: stop
!

to: stop by: step
    "Return an interval going from the receiver to stop with the given step"
    ^Interval from: self to: stop by: step
!

to: stop by: step do: aBlock
    "Evaluate aBlock for each value in the interval going from the receiver
     to stop with the given step. Compiled in-line for integer literal steps,
     and for one-argument aBlocks without temporaries, and therefore
     not overridable."
    | i |
    i := self.
    step > step zero
	ifTrue: [
    	    [ i <= stop ]
	    	whileTrue: [ aBlock value: i.
		    	     i := i + step ]
    	]
	ifFalse: [
    	    [ i >= stop ]
	    	whileTrue: [ aBlock value: i.
		    	     i := i + step ]
	].
    ^stop
!

to: stop do: aBlock
    "Evaluate aBlock for each value in the interval going from the receiver
     to stop by 1. Compiled in-line for one-argument aBlocks without
     temporaries, and therefore not overridable."
    | i |
    i := self.
    [ i <= stop ]
    	whileTrue: [ aBlock value: i.
	    	     i := i + self unity ]
! !


!Number methodsFor: 'errors'!

arithmeticError: message
    self error: message
!

zeroDivide
    self error: 'cannot divide by zero'
! !

