"======================================================================
|
|   Number Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2007,2008,2009
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



Magnitude subclass: Number [
    
    <category: 'Language-Data types'>
    <comment: 'I am an abstract class that provides operations on numbers, both floating
point and integer.  I provide some generic predicates, and supply the 
implicit type coercing code for binary operations.'>

    Number class >> coerce: aNumber [
	"Answer aNumber - whatever class it belongs to, it is good"

	<category: 'converting'>
	aNumber class == Fraction ifTrue: [ ^aNumber asFloatD ].
	^aNumber
    ]

    Number class >> readFrom: aStream radix: anInteger [
	"Answer the number read from the rest of aStream, converted to an
	 instance of the receiver. If the receiver is number, the class of the
	 result is undefined -- but the result is good.

         The exponent (for example 1.2e-1) is only parsed if anInteger is 10."

	<category: 'converting'>
        | c sgn int intexp frac exp isfloat |
        isfloat := false.
        sgn     := 1.
        int     := 0.
        intexp  := 1.
     
        c := aStream peek.
        c isNil ifTrue: [ ^0 ].
        c = $- ifTrue: [ sgn := -1. aStream next. ].
     
        c := aStream peek.
        c isNil ifTrue: [ ^0 ].
        c := c asUppercase.
        ((c isDigit: anInteger) or: [ c = $. ]) ifFalse: [ ^0 ].
     
        [ c notNil and: [
               c := c asUppercase.
               c isDigit: anInteger ] ] whileTrue: [
           aStream next.
           int := sgn * c digitValue + (int * anInteger).
           c := aStream peek
        ].
        c isNil ifTrue: [ ^int ].
     
        c = $. ifTrue: [
           aStream next.
           isfloat := true.
           [ c := aStream peek. c notNil and: [
                  c := c asUppercase.
                  c isDigit: anInteger ] ] whileTrue: [
              sgn := sgn / anInteger.
              int := sgn * c digitValue + int.
              aStream next
           ]
        ].
     
        exp := 0.
        (anInteger = 10 and: [c = $E]) ifFalse: [
             ^isfloat ifTrue: [ int asFloat ] ifFalse: [ int ] ].
     
        aStream next.
        c := aStream peek.
        c isNil ifTrue: [ ^int ].
        sgn := 1.
        c = $+ ifTrue: [ sgn :=  1. aStream next ].
        c = $- ifTrue: [ sgn := -1. aStream next ].
     
        [ c := aStream peek. c notNil and: [ c isDigit ] ] whileTrue: [
           exp := c digitValue + (exp * 10).
           aStream next
        ].
     
        int := int * (10 raisedToInteger: exp * sgn).
        ^int asFloat
    ]

    Number class >> readFrom: aStream [
	"Answer the number read from the rest of aStream, converted to an
	 instance of the receiver. If the receiver is number, the class of the
	 result is undefined -- but the result is good."

	<category: 'converting'>
	^self readFrom: aStream radix: 10
    ]

    Number class >> isImmediate [
	"Answer whether, if x is an instance of the receiver, x copy == x"

	<category: 'testing'>
	^true
    ]

    shallowCopy [
	"Return the receiver - it's an immediate (immutable) object"

	<category: 'copying'>
	^self
    ]

    deepCopy [
	"Return the receiver - it's an immediate (immutable) object"

	<category: 'copying'>
	^self
    ]

    asNumber [
	"Answer the receiver, since it is already a number"

	<category: 'converting'>
	^self
    ]

    asString [
	"Answer the receiver's #displayString, which should be a good enough
	 conversion to String for a number."

	<category: 'converting'>
	^self displayString
    ]

    degreesToRadians [
	"Convert the receiver to radians"

	<category: 'converting'>
	^self asFloatD / 57.29577951308232
    ]

    radiansToDegrees [
	"Convert the receiver from radians to degrees"

	<category: 'converting'>
	^self asFloatD * 57.29577951308232
    ]

    coerce: aNumber [
	"Answer aNumber, converted to an integer or floating-point number."

	<category: 'converting'>
	aNumber class == Fraction ifTrue: [ ^aNumber asFloatD ].
	^aNumber
    ]

    zero [
	"Coerce 0 to the receiver's class. The default implementation works,
	 but is inefficient"

	<category: 'converting'>
	^self coerce: 0
    ]

    unity [
	"Coerce 1 to the receiver's class. The default implementation works,
	 but is inefficient"

	<category: 'converting'>
	^self coerce: 1
    ]

    generality [
	"Answer the receiver's generality"

	<category: 'converting'>
	self subclassResponsibility
    ]

    asScaledDecimal: n [
	"Answer the receiver, converted to a ScaledDecimal object."

	<category: 'converting'>
	^ScaledDecimal newFromNumber: self asFraction scale: n
    ]

    asScaledDecimal: denDigits radix: base scale: n [
	"Answer the receiver, divided by base^denDigits and converted to
	 a ScaledDecimal object."

	<category: 'converting'>
	^ScaledDecimal 
	    newFromNumber: self asFraction * (base raisedToInteger: denDigits)
	    scale: n
    ]

    asCNumber [
	"Convert the receiver to a kind of number that is understood by
	 the C call-out mechanism."
	<category: 'coercion'>
	self subclassResponsibility
    ]

    asFloat [
	"Convert the receiver to an arbitrary subclass of Float"

	<category: 'converting'>
	^self asFloatD
    ]

    asFloatD [
	<category: 'converting'>
	self subclassResponsibility
    ]

    asFloatE [
	<category: 'converting'>
	self subclassResponsibility
    ]

    asFloatQ [
	<category: 'converting'>
	self subclassResponsibility
    ]

    asFraction [
	<category: 'converting'>
	self subclassResponsibility
    ]

    asExactFraction [
	"Return the receiver, converted to a Fraction retaining the exact
	 value of the receiver."

	<category: 'converting'>
	^self asFraction
    ]

    retryError [
	"Raise an error---a retrying method was called with two arguments
	 having the same generality."

	<category: 'retrying'>
	^self 
	    error: 'retry:coercing: called with arguments of the same generality'
    ]

    retry: aSymbol coercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling aSymbol.  aSymbol is
	 supposed not to be #= or #~= (since those don't fail if aNumber is not
	 a Number)."

	<category: 'retrying'>
	| selfGen aNumGen |
	selfGen := self generality.
	aNumGen := aNumber generality.
	selfGen > aNumGen 
	    ifTrue: [^self perform: aSymbol with: (self coerce: aNumber)].
	selfGen < aNumGen 
	    ifTrue: [^(aNumber coerce: self) perform: aSymbol with: aNumber].
	self retryError
    ]

    retryRelationalOp: aSymbol coercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling aSymbol (<, <=, >, >=)."

	<category: 'retrying'>
	| delta |
	delta := self retryDifferenceCoercing: aNumber.

	"Avoids a #perform: which is usually more expensive -- all the comparisons
	 below are inlined by both the compiler and the interpreter"
	aSymbol == #< ifTrue: [^delta < delta zero].
	aSymbol == #<= ifTrue: [^delta <= delta zero].
	aSymbol == #>= ifTrue: [^delta >= delta zero].
	aSymbol == #> ifTrue: [^delta > delta zero].
	self error: 'bad relational operator'
    ]

    retryEqualityCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #=."

	<category: 'retrying'>
	| selfGen aNumGen |
	(aNumber isKindOf: Number) ifFalse: [^false].
	selfGen := self generality.
	aNumGen := aNumber generality.
	aNumGen isNil ifTrue: [^false].
	selfGen > aNumGen ifTrue: [^self = (self coerce: aNumber)].
	selfGen < aNumGen ifTrue: [^(aNumber coerce: self) = aNumber].
	self retryError
    ]

    retryInequalityCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #~=."

	<category: 'retrying'>
	| selfGen aNumGen |
	(aNumber isKindOf: Number) ifFalse: [^true].
	selfGen := self generality.
	aNumGen := aNumber generality.
	aNumGen isNil ifTrue: [^true].
	selfGen > aNumGen ifTrue: [^false == (self = (self coerce: aNumber))].
	selfGen < aNumGen ifTrue: [^false == ((aNumber coerce: self) = aNumber)].
	self retryError
    ]

    retrySumCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #+."

	<category: 'retrying'>
	| selfGen aNumGen |
	selfGen := self generality.
	aNumGen := aNumber generality.
	aNumGen isNil ifTrue: [^aNumber sumFromNumber: self].
	selfGen > aNumGen ifTrue: [^self + (self coerce: aNumber)].
	selfGen < aNumGen ifTrue: [^(aNumber coerce: self) + aNumber].
	self retryError
    ]

    retryDifferenceCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #-."

	<category: 'retrying'>
	| selfGen aNumGen |
	selfGen := self generality.
	aNumGen := aNumber generality.
	aNumGen isNil ifTrue: [^aNumber differenceFromNumber: self].
	selfGen > aNumGen ifTrue: [^self - (self coerce: aNumber)].
	selfGen < aNumGen ifTrue: [^(aNumber coerce: self) - aNumber].
	self retryError
    ]

    retryMultiplicationCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #*."

	<category: 'retrying'>
	| selfGen aNumGen |
	selfGen := self generality.
	aNumGen := aNumber generality.
	aNumGen isNil ifTrue: [^aNumber productFromNumber: self].
	selfGen > aNumGen ifTrue: [^self * (self coerce: aNumber)].
	selfGen < aNumGen ifTrue: [^(aNumber coerce: self) * aNumber].
	self retryError
    ]

    retryDivisionCoercing: aNumber [
	"Coerce to the other number's class the one number between the receiver and
	 aNumber which has the lowest, and retry calling #/."

	<category: 'retrying'>
	| selfGen aNumGen |
	selfGen := self generality.
	aNumGen := aNumber generality.
	selfGen > aNumGen ifTrue: [^self / (self coerce: aNumber)].
	selfGen < aNumGen ifTrue: [^(aNumber coerce: self) / aNumber].
	self retryError
    ]

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    * aNumber [
	"Subtract the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    / aNumber [
	"Divide the receiver by aNumber, answer the result (no loss of
	 precision).  Raise a ZeroDivide exception or return a valid
	 (possibly infinite) continuation value if aNumber is zero."

	<category: 'arithmetic'>
	self subclassResponsibility
    ]

    // aNumber [
	"Return the integer quotient of dividing the receiver by aNumber with
	 truncation towards negative infinity.  Raise a ZeroDivide
	 exception if aNumber is zero"

	<category: 'arithmetic'>
	aNumber = 0 ifTrue: [self zeroDivide].
	^(self / aNumber) floor
    ]

    \\ aNumber [
	"Return the remainder of dividing the receiver by aNumber with
	 truncation towards negative infinity.  Raise a ZeroDivide
	 exception if aNumber is zero"

	<category: 'arithmetic'>
	aNumber = 0 ifTrue: [self zeroDivide].
	^self - (self // aNumber * aNumber)
    ]

    quo: aNumber [
	"Return the integer quotient of dividing the receiver by aNumber with
	 truncation towards zero.  Raise a ZeroDivide exception if aNumber is
	 zero"

	<category: 'arithmetic'>
	aNumber = 0 ifTrue: [self zeroDivide].
	^(self / aNumber) truncated
    ]

    rem: aNumber [
	"Return the remainder of dividing the receiver by aNumber with
	 truncation towards zero.  Raise a ZeroDivide exception if aNumber is
	 zero"

	<category: 'arithmetic'>
	^self - ((self quo: aNumber) * aNumber)
    ]

    integerPart [
	"Answer the receiver, truncated towards zero"

	<category: 'truncation and round off'>
	^self truncated
    ]

    fractionPart [
	"Answer a number which, summed to the #integerPart of the
	 receiver, gives the receiver itself."

	<category: 'truncation and round off'>
	^self - self integerPart
    ]

    asInteger [
	"Answer the receiver, rounded to the nearest integer"

	<category: 'truncation and round off'>
	^self rounded
    ]

    truncated [
	"Answer the receiver, truncated towards zero"

	<category: 'truncation and round off'>
	^self subclassResponsibility
    ]

    truncateTo: aNumber [
	"Answer the receiver, truncated towards zero to a multiple
	 of aNumber"

	<category: 'truncation and round off'>
	^(self coerce: (self quo: aNumber)) * aNumber
    ]

    rounded [
	"Returns the integer nearest the receiver"

	<category: 'truncation and round off'>
	^self negative 
	    ifTrue: [(self - (self unity / 2)) ceiling]
	    ifFalse: [(self + (self unity / 2)) floor]
    ]

    roundTo: aNumber [
	"Answer the receiver, truncated to the nearest multiple
	 of aNumber"

	<category: 'truncation and round off'>
	^(self coerce: (self / aNumber) rounded) * aNumber
    ]

    closeTo: num [
	"Answer whether the receiver can be considered sufficiently
	 close to num (this is done by checking equality if num is
	 not a number, and by checking with 0.01% tolerance if num
	 is a number)."

	<category: 'testing'>
	"Shortcut common cases.  But the first one is also needed
	 so that FloatD infinity closeTo: FloatD infinity!"
	self = num ifTrue: [^true].
	num isNumber ifFalse: [^false].
	self = self zero ifTrue: [^num abs < 0.0001].
	num = num zero ifTrue: [^self abs < 0.0001].

	^(self - num) abs / (self abs max: num abs) <= 0.0001
    ]

    isExact [
	"Answer whether the receiver performs exact arithmetic.  Most
	 numeric classes do (in fact the only exceptions is Float and
	 its descendants), so the default is to answer true rather than
	 calling #subclassResponsibility."

	<category: 'testing'>
	^true
    ]

    isNaN [
	"Answer whether the receiver is a Not-A-Number.  Most numeric
	 classes don't handle nans, so the default is to answer false
	 rather than calling #subclassResponsibility."

	<category: 'testing'>
	^false
    ]

    isFinite [
	"Answer whether the receiver represents a finite quantity.  Most
	 numeric classes are for finite quantities, so the default is to
	 answer true rather than calling #subclassResponsibility."

	<category: 'testing'>
	^true
    ]

    isInfinite [
	"Answer whether the receiver represents an infinite quantity.  Most
	 numeric classes are for finite quantities, so the default is to
	 answer false rather than calling #subclassResponsibility."

	<category: 'testing'>
	^false
    ]

    isRational [
	"Answer whether the receiver is rational - false by default"

	<category: 'testing'>
	^false
    ]

    isNumber [
	<category: 'testing'>
	^true
    ]

    negative [
	"Answer whether the receiver is < 0"

	<category: 'testing'>
	^self < self zero
    ]

    positive [
	"Answer whether the receiver is >= 0"

	<category: 'testing'>
	^self >= self zero
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'testing'>
	^self > self zero
    ]

    sign [
	"Returns the sign of the receiver."

	<category: 'testing'>
	self < self zero ifTrue: [^-1].
	self > self zero ifTrue: [^1].
	^0
    ]

    even [
	"Returns true if self is divisible by 2"

	<category: 'testing'>
	^self truncated even
    ]

    odd [
	"Returns true if self is not divisible by 2"

	<category: 'testing'>
	^self truncated odd
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
	^aNumber > self ifTrue: [self] ifFalse: [aNumber]
    ]

    max: aNumber [
	"Answer the maximum between the receiver and aNumber.  Redefine
	 in subclasses if necessary to ensure that if either self or
	 aNumber is a NaN, it is always answered."

	"If both self and aNumber are zero, return self in case aNumber
	 has a negative sign, because we assume our zero is positive.
	 If the test is false, always answer aNumber in case it is a
	 NaN, because we assume that self is not a NaN."

	<category: 'comparing'>
	^aNumber <= self ifTrue: [self] ifFalse: [aNumber]
    ]

    positiveDifference: aNumber [
	"Answer the positive difference of the receiver and
	 aNumber, that is self - aNumber if it is positive,
	 0 otherwise."

	<category: 'misc math'>
	| diff |
	diff := self - aNumber.
	diff isNaN ifTrue: [^diff].
	^diff negative ifTrue: [diff zero] ifFalse: [diff]
    ]

    squared [
	"Answer the square of the receiver"

	<category: 'misc math'>
	^self * self
    ]

    abs [
	"Answer the absolute value of the receiver"

	<category: 'misc math'>
	^self > self zero ifTrue: [self] ifFalse: [self negated]
    ]

    negated [
	"Answer the negated of the receiver"

	<category: 'misc math'>
	^self zero - self
    ]

    sin [
	"Answer the sine of the receiver"

	<category: 'misc math'>
	^self asFloatD sin
    ]

    cos [
	"Answer the cosine of the receiver"

	<category: 'misc math'>
	^self asFloatD cos
    ]

    tan [
	"Answer the tangent of the receiver"

	<category: 'misc math'>
	^self asFloatD tan
    ]

    arcSin [
	"Answer the arc sine of the receiver"

	<category: 'misc math'>
	^self asFloatD arcSin
    ]

    arcCos [
	"Answer the arc cosine of the receiver"

	<category: 'misc math'>
	^self asFloatD arcCos
    ]

    arcTan [
	"Answer the arc tangent of the receiver"

	<category: 'misc math'>
	^self asFloatD arcTan
    ]

    arcTan: x [
	"Answer the angle (measured counterclockwise) between (x, self) and
	 a ray starting in (0, 0) and moving towards (1, 0) - i.e. 3 o'clock"

	<category: 'misc math'>
	| result |
	x = 0 
	    ifTrue: 
		["Always adopt the most general number representation of pi.
		 If none of the number is a floating point number, go with
		 a FloatD."

		^self generality < x generality 
		    ifTrue: 
			[x generality < 0.0e generality 
			    ifTrue: [FloatD pi * self sign / 2]
			    ifFalse: [x class pi * self sign / 2]]
		    ifFalse: 
			[self generality < 0.0e generality 
			    ifTrue: [FloatD pi * self sign / 2]
			    ifFalse: [self class pi * self sign / 2]]].
	result := (self / x) arcTan.
	^x < 0 
	    ifFalse: [result]
	    ifTrue: 
		[result > result zero 
		    ifFalse: [result + result class pi]
		    ifTrue: [result - result class pi]]
    ]

    cosh [
	"Answer the hyperbolic cosine of the receiver."

	<category: 'misc math'>
	^(self exp + self negated exp) / 2
    ]

    sinh [
	"Answer the hyperbolic sine of the receiver."

	<category: 'misc math'>
	^(self exp - self negated exp) / 2
    ]

    tanh [
	"Answer the hyperbolic tangent of the receiver."

	<category: 'misc math'>
	| ep en |
	ep := self exp.
	en := self negated exp.
	^(ep - en) / (ep + en)
    ]

    arcCosh [
	"Answer the hyperbolic arc-cosine of the receiver."

	<category: 'misc math'>
	^(self + (self squared - 1) sqrt) ln
    ]

    arcSinh [
	"Answer the hyperbolic arc-sine of the receiver."

	<category: 'misc math'>
	^(self + (self squared + 1) sqrt) ln
    ]

    arcTanh [
	"Answer the hyperbolic arc-tangent of the receiver."

	<category: 'misc math'>
	^((1 + self) / (1 - self)) ln / 2
    ]

    sqrt [
	"Answer the square root of the receiver"

	<category: 'misc math'>
	^self asFloatD sqrt
    ]

    exp [
	"Answer e raised to the receiver"

	<category: 'misc math'>
	^self asFloatD exp
    ]

    ln [
	"Answer log base e of the receiver"

	<category: 'misc math'>
	^self asFloatD ln
    ]

    estimatedLog [
	"Answer an estimate of (self abs floorLog: 10). This method
	 should be overridden by subclasses, but Number's implementation
	 does not raise errors - simply, it gives a correct result, so
	 it is slow."

	<category: 'misc math'>
	^self abs floorLog: 10
    ]

    log [
	"Answer log base 10 of the receiver"

	<category: 'misc math'>
	^self asFloatD ln / FloatD ln10
    ]

    log: aNumber [
	"Answer log base aNumber of the receiver"

	<category: 'misc math'>
	^self asFloatD ln / aNumber asFloatD ln
    ]

    floorLog: radix [
	"Answer (self log: radix) floor. Optimized to answer an integer."

	<category: 'misc math'>
	| me that answer |
	self < self zero 
	    ifTrue: 
		[^self arithmeticError: 'cannot extract logarithm of a negative number'].
	radix <= radix unity 
	    ifTrue: 
		[radix <= radix zero ifTrue: [^self arithmeticError: 'bad radix'].
		radix = radix unity ifTrue: [^self arithmeticError: 'bad radix'].
		^(self ceilingLog: radix reciprocal) negated].
	answer := -1.
	self < self unity 
	    ifTrue: 
		[me := self.
		
		[me := me * radix.
		me < me unity] whileTrue: [answer := answer - 1]]
	    ifFalse: 
		[that := 1.
		[that <= self] whileTrue: 
			[that := that * radix.
			answer := answer + 1]].
	^answer
    ]

    ceilingLog: radix [
	"Answer (self log: radix) ceiling. Optimized to answer an integer."

	<category: 'misc math'>
	| me that answer |
	self < self zero 
	    ifTrue: 
		[^self arithmeticError: 'cannot extract logarithm of a negative number'].
	radix <= radix unity 
	    ifTrue: 
		[radix <= radix zero ifTrue: [^self arithmeticError: 'bad radix'].
		radix = radix unity ifTrue: [^self arithmeticError: 'bad radix'].
		^(self floorLog: radix reciprocal) negated].
	answer := 0.
	self < self unity 
	    ifTrue: 
		[me := self.
		
		[me := me * radix.
		me <= me unity] whileTrue: [answer := answer - 1]]
	    ifFalse: 
		[that := 1.
		[that < self] whileTrue: 
			[that := that * radix.
			answer := answer + 1]].
	^answer
    ]

    raisedTo: aNumber [
	"Return self raised to aNumber power"

	<category: 'misc math'>
	aNumber isInteger 
	    ifTrue: [^self raisedToInteger: aNumber].
	^aNumber generality > 1.0d generality
	    ifTrue: [(aNumber coerce: self) raisedTo: aNumber]
	    ifFalse: [self asFloatD raisedTo: aNumber asFloatD]
    ]

    raisedToInteger: anInteger [
	"Return self raised to the anInteger-th power"

	"Some special cases first"

	<category: 'misc math'>
	anInteger isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer].
	anInteger < 0 ifTrue: [^self reciprocal raisedToInteger: 0 - anInteger].
	anInteger = 0 ifTrue: [
	    self = self zero ifTrue: [self arithmeticError: 'invalid operands'].
	    ^self unity].
	anInteger = 1 ifTrue: [^self].

	"Fire the big loop."
	^self raisedToInteger: anInteger
	    withCache: ((Array new: (255 min: anInteger))
		    at: 1 put: self;
		    yourself)
    ]

    withSignOf: aNumber [
	"Answer the receiver, with its sign possibly changed to match
	 that of aNumber."

	<category: 'misc math'>
	^aNumber positive == self positive ifTrue: [self] ifFalse: [self negated]
    ]

    floor [
	"Return the integer nearest the receiver toward negative infinity."

	<category: 'truncation and round off'>
	| selfTruncated |
	selfTruncated := self truncated.
	"If positive, truncation to zero is what we want."
	self >= self zero ifTrue: [^selfTruncated].

	"Must be negative."
	self = (self coerce: selfTruncated) 
	    ifTrue: [^selfTruncated]
	    ifFalse: [^selfTruncated - 1]
    ]

    reciprocal [
	"Return the reciprocal of the receiver"

	<category: 'arithmetic'>
	self = self zero ifTrue: [self zeroDivide] ifFalse: [^self unity / self]
    ]

    to: stop [
	"Return an interval going from the receiver to stop by 1"

	<category: 'shortcuts and iterators'>
	^Interval from: self to: stop
    ]

    to: stop by: step [
	"Return an interval going from the receiver to stop with the given step"

	<category: 'shortcuts and iterators'>
	^Interval 
	    from: self
	    to: stop
	    by: step
    ]

    to: stop by: step do: aBlock [
	"Evaluate aBlock for each value in the interval going from the receiver
	 to stop with the given step. Compiled in-line for integer literal steps,
	 and for one-argument aBlocks without temporaries, and therefore
	 not overridable."

	<category: 'shortcuts and iterators'>
	| i |
	i := self.
	step > step zero 
	    ifTrue: [[i <= stop] whileTrue: 
			[aBlock value: i.
			i := i + step]]
	    ifFalse: [[i >= stop] whileTrue: 
			[aBlock value: i.
			i := i + step]].
	^stop
    ]

    to: stop do: aBlock [
	"Evaluate aBlock for each value in the interval going from the receiver
	 to stop by 1. Compiled in-line for one-argument aBlocks without
	 temporaries, and therefore not overridable."

	<category: 'shortcuts and iterators'>
	| i |
	i := self.
	[i <= stop] whileTrue: 
		[aBlock value: i.
		i := i + self unity]
    ]

    to: stop collect: aBlock [
	"Evaluate aBlock for each value in the interval going from the receiver
         to stop by 1.  The results are collected in an Array and returned."

	<category: 'shortcuts and iterators'>
	| size result i j |
        size := (stop - self) truncated + 1 max: 0.
	result := Array new: size.
	i := self.
	j := 1.
	[j <= size] whileTrue: 
		[result at: j put: (aBlock value: i).
		i := i + self unity. j := j + 1].
	^result
    ]

    to: stop by: step collect: aBlock [
	"Evaluate aBlock for each value in the interval going from the receiver
         to stop with the given step.  The results are collected in an Array
	 and returned."

	<category: 'shortcuts and iterators'>
	| size result i j |
        size := step > 0
            ifTrue: [stop >= self ifTrue: [(stop - self) // step + 1] ifFalse: [0]]
            ifFalse: [self >= stop ifTrue: [(stop - self) // step + 1] ifFalse: [0]].

	result := Array new: size.
	i := self.
	j := 1.
	[j <= size] whileTrue: 
		[result at: j put: (aBlock value: i).
		i := i + step. j := j + 1].
	^result
    ]

    arithmeticError: message [
	<category: 'errors'>
	self error: message
    ]

    zeroDivide [
	<category: 'errors'>
	self error: 'cannot divide by zero'
    ]

    raisedToInteger: n withCache: cache [
	"Internal implementation of #raisedToInteger:."

	<category: 'private'>
	"For very big numbers, remove the rightmost bit."

	| result index |
	n > 255 
	    ifTrue: 
		[result := self raisedToInteger: n // 2 withCache: cache.
		^(n bitAnd: 1) = 0 
		    ifTrue: [result squared]
		    ifFalse: [result * (result * self)]].

	"Else, use a table with the optimal choice of k so that
	 self^k * self^(n - k) does as few multiplications as possible."
	result := cache at: n.
	result isNil 
	    ifTrue: 
		[index := self powerTable at: n.
		result := (self raisedToInteger: n - index withCache: cache) 
			    * (self raisedToInteger: index withCache: cache).
		cache at: n put: result].
	^result
    ]

    powerTable [
	"Internal table for #raisedToInteger:withCache:.  Example:
	 (powerTable at: 9) == 6 means that n^9 is best computed
	 as n^3 * n^6.  From Knuth's Seminumerical Algorithms."

	<category: 'private'>
	^#[0 1 2 2 3 3 4 4 6 5 6 6 10 7 9 8 16 9 16 10 12 11 13 12 17 13 18 14 24 15 26 16 17 17 19 18 33 19 26 20 25 21 40 22 27 23 44 24 32 25 34 26 29 27 44 28 31 29 34 30 60 31 36 32 64 33 34 34 46 35 37 36 65 37 50 38 48 39 69 40 49 41 43 42 51 43 58 44 64 45 47 46 59 47 76 48 65 49 66 50 67 51 66 52 70 53 74 54 104 55 74 56 64 57 69 58 78 59 68 60 61 61 80 62 75 63 68 64 65 65 128 66 129 67 90 68 73 69 131 70 94 71 88 72 128 73 98 74 132 75 121 76 102 77 124 78 132 79 106 80 97 81 160 82 99 83 134 84 86 85 95 86 160 87 100 88 113 89 98 90 107 91 122 92 111 93 102 94 126 95 150 96 128 97 130 98 133 99 195 100 128 101 123 102 164 103 138 104 145 105 146 106 109 107 149 108 200 109 146 110 170 111 157 112 128 113 130 114 182 115 132 116 200 117 132 118 158 119 206 120 240 121 162 122 147 123 152 124 166 125 214 126 138 127 153]	"1 -   7"	"8 -  15"	"16 -  23"	"24 -  31"	"32 -  39"	"40 -  47"	"48 -  55"	"56 -  63"	"64 -  71"	"72 -  79"	"80 -  87"	"88 -  95"	"96 - 103"	"104 - 111"	"112 - 119"	"120 - 127"	"128 - 135"	"136 - 143"	"144 - 151"	"152 - 159"	"160 - 167"	"168 - 175"	"176 - 183"	"184 - 191"	"192 - 199"	"200 - 207"	"208 - 215"	"216 - 223"	"224 - 231"	"232 - 239"	"240 - 247"	"248 - 255"
    ]
]

